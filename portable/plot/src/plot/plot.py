import shutil

from uniplot import plot_to_string


def render_plot(
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
