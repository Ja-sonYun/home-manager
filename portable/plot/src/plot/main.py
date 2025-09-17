import asyncio
import re
import sys
import time
from collections import deque

from openai import AsyncOpenAI
from rich.live import Live
from rich.text import Text

from plot.collect import iter_stdin_frames, iter_stdin_lines
from plot.console import stderr, stdout
from plot.plot import render_plot
from plot.prompts import USER_TEMPLATE, PlotSpec
from plot.settings import AppSettings, OpenAISettings
from plot.utils import as_number


async def _main() -> None:
    settings = AppSettings()
    openai = OpenAISettings()

    client = AsyncOpenAI(
        api_key=(openai.api_key.get_secret_value() if openai.api_key else None),
        base_url=openai.base_url,
    )

    samples: list[str] = []

    reader = iter_stdin_frames if settings.frame_stream else iter_stdin_lines

    with stdout.status(
        "[bold green]Collecting samples for regex synthesis...",
        spinner="dots",
    ):
        try:
            async with asyncio.timeout(settings.learn_timeout):
                async for line in reader():
                    if len(samples) < settings.sample_size:
                        samples.append(line)
                    else:
                        break
        except TimeoutError:
            stderr.print(
                f"[red]Timeout reached after {settings.learn_timeout} seconds.[/red]"
            )
            sys.exit(1)

    with stdout.status("[bold green]Synthesizing regex pattern...", spinner="dots"):
        response = await client.beta.chat.completions.parse(
            model=settings.model,
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

    min_value: float | None = None
    max_value: float | None = None
    start_time = time.time()

    buffers: dict[str, deque[float]] = {}
    for ex in plot_spec.extracts:
        buffers[ex.name] = deque(maxlen=settings.window)
    time_queue: deque[float] = deque(maxlen=settings.window)

    with Live(console=stdout, auto_refresh=False) as live:
        async for line in reader():
            values: dict[str, float] = {}
            missing: list[str] = []

            for ex in plot_spec.extracts:
                match = re.search(ex.regex, line)
                if not match:
                    missing.append(ex.name)
                    continue

                raw = match.group(ex.group)
                val = as_number(raw) * ex.scale
                values[ex.name] = val

            if not values:
                stderr.print("[yellow]No match in sample[/yellow]")
                continue

            if len(values) != len(plot_spec.extracts):
                missing_labels = ", ".join(missing)
                stderr.print(
                    f"[yellow]Partial match; missing:[/yellow] {missing_labels or 'unknown'}"
                )
                continue

            for name, val in values.items():
                buffers[name].append(val)
                min_value = val if min_value is None else min(min_value, val)
                max_value = val if max_value is None else max(max_value, val)

            elapsed = time.time() - start_time
            time_queue.append(elapsed)

            legends = list(buffers.keys())
            series = [list(buffers[name]) for name in legends]
            # choose y-axis unit: prefer the first non-empty per-series unit, else fallback
            y_unit = next(
                (ex.unit for ex in plot_spec.extracts if ex.unit), plot_spec.unit or ""
            )

            rendered_plot = render_plot(
                title=plot_spec.title,
                legends=legends,
                series=series,
                time=list(time_queue),
                height=settings.height,
                y_min=min_value,
                y_max=max_value,
                y_unit=y_unit,
            )
            rendered = f"{rendered_plot}\n\n{line}"
            renderable = Text.from_ansi(rendered)
            live.update(renderable, refresh=True)


def main() -> None:
    asyncio.run(_main())
