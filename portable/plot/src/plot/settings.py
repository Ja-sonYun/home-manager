from pydantic import AliasChoices, Field, PositiveInt, SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict


class OpenAISettings(BaseSettings):
    model_config = SettingsConfigDict(
        env_prefix="OPENAI_",
        extra="forbid",
    )

    api_key: SecretStr | None = Field(
        default=None,
        description="OpenAI API key.",
    )
    base_url: str | None = Field(
        default=None,
        description="Base URL for OpenAI-compatible API endpoint.",
    )


class AppSettings(BaseSettings):
    model_config = SettingsConfigDict(
        cli_parse_args=True,
        cli_kebab_case=True,
        cli_implicit_flags=True,
        populate_by_name=True,
        extra="forbid",
    )

    sample_size: PositiveInt = Field(
        default=5,
        description="Number of initial non-empty lines to learn from.",
        validation_alias=AliasChoices("s", "sample-size"),
    )
    window: PositiveInt = Field(
        default=200,
        description="Sliding window length for plotted values.",
        validation_alias=AliasChoices("w", "window"),
    )
    prompt: str = Field(
        default="",
        description="Additional instruction to steer regex generation.",
        validation_alias=AliasChoices("p", "prompt"),
    )
    height: PositiveInt = Field(
        default=30,
        description="Height of the plot in terminal rows.",
    )
    model: str = Field(
        default="gpt-5",
        description="OpenAI model used when synthesizing regex patterns.",
        validation_alias=AliasChoices("m", "model"),
    )
    learn_timeout: float = Field(
        default=10.0,
        gt=0,
        description="Seconds to wait for sample collection before continuing.",
    )
    refresh: float = Field(
        default=0.5,
        gt=0,
        description="Minimum seconds between plot redraws.",
        validation_alias=AliasChoices("r", "refresh"),
    )
    frame_stream: bool = Field(
        default=False,
        description="Interpret ANSI screen refresh sequences as frame-sized samples.",
        validation_alias=AliasChoices("f", "frame-stream"),
    )
