import asyncio
import re
import shutil
import time
from collections import deque

from rich.live import Live
from rich.text import Text
from uniplot import plot_to_string

from plot.capture import KeyEvent, KeyStroke
from plot.console import stderr, stdout
from plot.prompts import PlotSpec
from plot.settings import AppSettings
from plot.utils import as_number


def generate_plot(
    *,
    title: str,
    legends: list[str],
    series: list[list[float]],
    time: list[float],
    height: int = 30,
    y_min: float | None = None,
    y_max: float | None = None,
    y_unit: str = "",
) -> str:
    t = list(time)
    xs = [t[:] for _ in series]
    ys = series

    unit_length = len(y_unit) + 1 if y_unit else 0
    max_y_length = max(len(str(y)) for s in series for y in s) if series else 0

    right_padding = unit_length + max_y_length + 1

    return plot_to_string(
        xs=xs,
        ys=ys,
        title=title,
        legend_labels=legends,
        color=True,
        lines=True,
        width=shutil.get_terminal_size((80, 24)).columns - right_padding,
        height=height,
        x_unit="s",
        y_unit=y_unit,
        y_min=y_min,
        y_max=y_max,
        character_set="braille",
    )


def _render_stream_plot(
    settings: AppSettings,
    plot_spec: PlotSpec,
    min_value: float | None,
    max_value: float | None,
    start_time: float,
    buffers: dict[str, deque[float]],
    time_queue: deque[float],
    line: str,
    live: Live,
) -> bool:

    values: dict[str, float] = {}
    missing: list[str] = []

    for ex in plot_spec.extracts:
        match = re.search(ex.regex, line)
        if not match:
            missing.append(ex.name)
            return False

        raw = match.group(ex.group)
        val = as_number(raw) * ex.scale
        values[ex.name] = val

    if not values:
        stderr.print("[yellow]No match in sample[/yellow]")
        return False

    if len(values) != len(plot_spec.extracts):
        missing_labels = ", ".join(missing)
        stderr.print(
            f"[yellow]Partial match; missing:[/yellow] {missing_labels or 'unknown'}"
        )
        return False

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

    rendered_plot = generate_plot(
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

    return True


async def render_plot(
    settings: AppSettings,
    plot_spec: PlotSpec,
    act_queue: asyncio.Queue[str | KeyStroke],
) -> None:
    min_value: float | None = None
    max_value: float | None = None
    start_time = time.time()

    buffers: dict[str, deque[float]] = {}
    for ex in plot_spec.extracts:
        buffers[ex.name] = deque(maxlen=settings.window)
    time_queue: deque[float] = deque(maxlen=settings.window)

    with Live(console=stdout, auto_refresh=False) as live:
        while True:
            line = await act_queue.get()

            match line:
                case str() as frame:
                    if not _render_stream_plot(
                        settings,
                        plot_spec,
                        min_value,
                        max_value,
                        start_time,
                        buffers,
                        time_queue,
                        frame,
                        live,
                    ):
                        continue

                case KeyStroke(event=KeyEvent.CTRL_C) | KeyStroke(
                    event=KeyEvent.ESCAPE
                ):
                    return
                case KeyStroke(event=KeyEvent.CHARACTER, value="q"):
                    return
                case KeyStroke() as ke:
                    stdout.print(f"[yellow]Ignored key event:[/yellow] {ke.value}")
                    continue
