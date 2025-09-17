from pydantic import BaseModel, Field, NonNegativeInt

USER_TEMPLATE = """Samples:
{samples}

Extra instruction: {extra}
"""


class ExtractSpec(BaseModel):
    name: str = Field(
        description="Legend label for this series.",
        examples=["Used MiB", "Total MiB"],
    )
    regex: str = Field(
        description=(
            "Python regex that isolates the numeric token to plot for this series. "
            "Use capturing groups to target the desired number (e.g., '(\\d+\\.?\\d*)MiB')."
        ),
        examples=[r"(\d+\.?\d*)MiB"],
    )
    group: NonNegativeInt = Field(
        default=1,
        description="Capturing group index that holds the numeric token.",
        examples=[1],
    )
    unit: str | None = Field(
        default=None,
        description="Optional unit label for this series (used for y-axis label if set).",
        examples=["MiB"],
    )
    scale: float = Field(
        default=1.0,
        description="Optional multiplicative scale applied after parsing the number.",
        examples=[1.0, 1024.0],
    )


class PlotSpec(BaseModel):
    title: str = Field(
        description=(
            "A concise, human-readable title for the plot. "
            "It should describe the metric being tracked (e.g., CPU load, memory usage)."
        ),
        examples=["CPU Usage", "Memory Consumption"],
    )
    extracts: list[ExtractSpec] = Field(
        description=(
            "One or more extraction specs. Each spec produces one plotted series. "
            "Example for '768.3MiB / 15.66GiB': "
            "use two ExtractSpec items, the first '(\\d+\\.?\\d*)MiB' for the dynamic value, "
            "the second '(\\d+\\.?\\d*)GiB' for the maximum if you want to plot both."
        ),
        min_length=1,
    )
    legend: str = Field(
        default="Value",
        description=(
            "Label for the plotted series. "
            "This text appears in the plot legend and should describe what the extracted values represent."
        ),
        examples=["Used Memory (MiB)", "Response Time (ms)", "Error Rate (%)"],
    )
    unit: str | None = Field(
        default=None,
        description=(
            "Optional unit string appended to the y-axis label. "
            "This helps clarify the scale of the plotted values (e.g., 'MiB', 'ms', '%')."
        ),
        examples=["MiB", "ms", "%"],
    )
