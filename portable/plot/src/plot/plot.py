import asyncio
import re
import shutil
import time
from collections import deque
from typing import Deque

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


def _append_sample(
    *,
    line: str,
    plot_spec: PlotSpec,
    start_time: float,
    buffers: dict[str, Deque[float]],
    time_queue: Deque[float],
    line_queue: Deque[str],
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

    elapsed = time.time() - start_time
    time_queue.append(elapsed)
    line_queue.append(line)

    return True


def _series_snapshot(
    *,
    buffers: dict[str, Deque[float]],
    time_queue: Deque[float],
    line_queue: Deque[str],
    end_index: int | None,
) -> tuple[list[str], list[list[float]], list[float], str]:
    times = list(time_queue)
    if not times:
        return [], [], [], ""

    final_index = len(times) - 1 if end_index is None else end_index
    final_index = max(0, min(final_index, len(times) - 1))

    legends = list(buffers.keys())
    materialized = {name: list(series) for name, series in buffers.items()}
    series = [materialized[name][: final_index + 1] for name in legends]
    time_slice = times[: final_index + 1]
    lines = list(line_queue)
    line = lines[final_index] if lines else ""

    return legends, series, time_slice, line


def _render_view(
    *,
    live: Live,
    settings: AppSettings,
    plot_spec: PlotSpec,
    buffers: dict[str, Deque[float]],
    time_queue: Deque[float],
    line_queue: Deque[str],
    end_index: int | None,
    paused: bool,
) -> None:
    legends, series, times, line = _series_snapshot(
        buffers=buffers,
        time_queue=time_queue,
        line_queue=line_queue,
        end_index=end_index,
    )

    if not times or not series:
        return

    flat_values = [value for stream in series for value in stream]
    y_min = min(flat_values) if flat_values else None
    y_max = max(flat_values) if flat_values else None

    y_unit = next(
        (ex.unit for ex in plot_spec.extracts if ex.unit), plot_spec.unit or ""
    )

    rendered_plot = generate_plot(
        title=plot_spec.title,
        legends=legends,
        series=series,
        time=times,
        height=settings.height,
        y_min=y_min,
        y_max=y_max,
        y_unit=y_unit,
    )

    if paused:
        suffix = f"{line} [yellow](paused)[/yellow]" if line else "[yellow](paused)[/yellow]"
        status = suffix
    else:
        status = line

    rendered = f"{rendered_plot}\n\n{status}"
    renderable = Text.from_ansi(rendered)
    live.update(renderable, refresh=True)


def _step_backward(times: list[float], index: int, seconds: float) -> int:
    if not times:
        return index

    target = times[index] - seconds
    cursor = index
    while cursor > 0 and times[cursor] > target:
        cursor -= 1
    return cursor


def _step_forward(times: list[float], index: int, seconds: float) -> int:
    if not times:
        return index

    target = times[index] + seconds
    cursor = index
    last = len(times) - 1
    while cursor < last and times[cursor] < target:
        cursor += 1
    return cursor


async def render_plot(
    settings: AppSettings,
    plot_spec: PlotSpec,
    act_queue: asyncio.Queue[str | KeyStroke],
) -> None:
    start_time = time.time()

    buffers: dict[str, Deque[float]] = {}
    for ex in plot_spec.extracts:
        buffers[ex.name] = deque(maxlen=settings.window)
    time_queue: Deque[float] = deque(maxlen=settings.window)
    line_queue: Deque[str] = deque(maxlen=settings.window)

    paused = False
    view_index: int | None = None

    with Live(console=stdout, auto_refresh=False) as live:
        while True:
            line = await act_queue.get()

            match line:
                case str() as frame:
                    was_full = (
                        time_queue.maxlen is not None
                        and len(time_queue) == time_queue.maxlen
                    )
                    if not _append_sample(
                        line=frame,
                        plot_spec=plot_spec,
                        start_time=start_time,
                        buffers=buffers,
                        time_queue=time_queue,
                        line_queue=line_queue,
                    ):
                        continue

                    if paused:
                        if not time_queue:
                            view_index = None
                            continue

                        if view_index is None:
                            view_index = len(time_queue) - 1
                        if was_full and view_index is not None and view_index > 0:
                            view_index -= 1
                        if view_index is not None and view_index >= len(time_queue):
                            view_index = len(time_queue) - 1
                        continue

                    _render_view(
                        live=live,
                        settings=settings,
                        plot_spec=plot_spec,
                        buffers=buffers,
                        time_queue=time_queue,
                        line_queue=line_queue,
                        end_index=None,
                        paused=False,
                    )

                case None:
                    continue
                case KeyStroke(event=KeyEvent.CTRL_C) | KeyStroke(
                    event=KeyEvent.ESCAPE
                ):
                    return
                case KeyStroke(event=KeyEvent.CHARACTER, value="q"):
                    return
                case KeyStroke(event=KeyEvent.CHARACTER, value=" "):
                    paused = not paused
                    if paused:
                        if time_queue:
                            view_index = len(time_queue) - 1
                            _render_view(
                                live=live,
                                settings=settings,
                                plot_spec=plot_spec,
                                buffers=buffers,
                                time_queue=time_queue,
                                line_queue=line_queue,
                                end_index=view_index,
                                paused=True,
                            )
                        else:
                            view_index = None
                    else:
                        view_index = None
                        if time_queue:
                            _render_view(
                                live=live,
                                settings=settings,
                                plot_spec=plot_spec,
                                buffers=buffers,
                                time_queue=time_queue,
                                line_queue=line_queue,
                                end_index=None,
                                paused=False,
                            )
                    continue
                case KeyStroke(event=KeyEvent.ENTER):
                    if not paused:
                        continue
                    paused = False
                    view_index = None
                    if time_queue:
                        _render_view(
                            live=live,
                            settings=settings,
                            plot_spec=plot_spec,
                            buffers=buffers,
                            time_queue=time_queue,
                            line_queue=line_queue,
                            end_index=None,
                            paused=False,
                        )
                    continue
                case KeyStroke(event=KeyEvent.CHARACTER, value="h"):
                    if not paused or not time_queue:
                        continue

                    if view_index is None:
                        view_index = len(time_queue) - 1

                    times = list(time_queue)
                    view_index = _step_backward(times, view_index, 1.0)

                    _render_view(
                        live=live,
                        settings=settings,
                        plot_spec=plot_spec,
                        buffers=buffers,
                        time_queue=time_queue,
                        line_queue=line_queue,
                        end_index=view_index,
                        paused=True,
                    )
                    continue
                case KeyStroke(event=KeyEvent.CHARACTER, value="l"):
                    if not paused or not time_queue:
                        continue

                    if view_index is None:
                        view_index = len(time_queue) - 1

                    times = list(time_queue)
                    view_index = _step_forward(times, view_index, 1.0)

                    _render_view(
                        live=live,
                        settings=settings,
                        plot_spec=plot_spec,
                        buffers=buffers,
                        time_queue=time_queue,
                        line_queue=line_queue,
                        end_index=view_index,
                        paused=True,
                    )
                    continue
                case KeyStroke() as ke:
                    stdout.print(f"[yellow]Ignored key event:[/yellow] {ke.value}")
                    continue
