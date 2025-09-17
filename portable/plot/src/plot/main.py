import asyncio
import sys
from contextlib import suppress

from openai import AsyncOpenAI

from plot.capture import KeyCapture, KeyStroke
from plot.collect import queue_stdin
from plot.console import stderr, stdout
from plot.plot import render_plot
from plot.prompts import USER_TEMPLATE, PlotSpec
from plot.queue import merge_queues
from plot.settings import AppSettings, OpenAISettings


async def _main() -> None:
    settings = AppSettings()
    openai = OpenAISettings()

    client = AsyncOpenAI(
        api_key=(openai.api_key.get_secret_value() if openai.api_key else None),
        base_url=openai.base_url,
    )

    samples: list[str] = []

    piped_input_queue = asyncio.Queue[str]()
    mode = "frames" if settings.frame_stream else "lines"
    piped_input_task = asyncio.create_task(queue_stdin(piped_input_queue, mode))

    with stdout.status(
        "[bold green]Collecting samples for regex synthesis...",
        spinner="dots",
    ):
        try:
            async with asyncio.timeout(settings.learn_timeout):
                while len(samples) < settings.sample_size:
                    sample = await piped_input_queue.get()
                    if sample is None:
                        break
                    samples.append(sample)
        except TimeoutError:
            stderr.print(
                f"[red]Timeout reached after {settings.learn_timeout} seconds.[/red]"
            )
            sys.exit(1)

    with stdout.status("[bold green]Synthesizing regex pattern...", spinner="dots"):
        response = await client.beta.chat.completions.parse(
            model=settings.model,
            reasoning_effort="minimal" if "gpt-5" in settings.model else None,
            messages=[
                {
                    "role": "user",
                    "content": USER_TEMPLATE.format(
                        samples="\n".join(f"- {s}" for s in samples),
                        extra=settings.prompt,
                    ),
                },
            ],
            response_format=PlotSpec,
        )

    plot_spec = response.choices[0].message.parsed
    if plot_spec is None:
        stderr.print("[red]Error:[/red] No function call in response.")
        sys.exit(1)

    key_stoke_queue = asyncio.Queue[KeyStroke]()
    key_capture = KeyCapture(key_stoke_queue)
    key_capture_task = asyncio.create_task(key_capture.run())

    act_queue, act_producer_task = await merge_queues(
        piped_input_queue,
        key_stoke_queue,
    )

    try:
        await render_plot(settings, plot_spec, act_queue)
    finally:
        key_capture_task.cancel()
        for task in (key_capture_task, piped_input_task, act_producer_task):
            task.cancel()
        for task in (key_capture_task, piped_input_task, act_producer_task):
            with suppress(asyncio.CancelledError):
                await task


def main() -> None:
    asyncio.run(_main())
