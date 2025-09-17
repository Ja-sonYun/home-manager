# Stream Plot CLI

This CLI consumes line-oriented logs from `stdin`, learns a numeric extraction
regex with OpenAI, and renders a live sparkline using `uniplot`.

## Installation

Inside the `portable/plot` directory install the dependencies for your active
Python (3.11+) environment. Examples:

```bash
# with uv (recommended)
uv sync

# or with pip
python -m venv .venv
. .venv/bin/activate
pip install -e .
```

## Configuration

The CLI reads configuration from both environment variables and CLI flags via
`pydantic-settings`. Set at least the OpenAI credentials before running:

| Environment Variable | Description |
| --- | --- |
| `OPENAI_API_KEY` | Required when regex synthesis is enabled. |
| `OPENAI_BASE_URL` | Optional override for the OpenAI endpoint. |
| `OPENAI_MODEL` | Optional default model used for synthesis (`gpt-4o-mini` by default). |

You can supply any setting via CLI as well; CLI options are automatically
derived from the Pydantic model and use kebab-case names.

## Usage

Run the CLI by piping a log stream into the module:

```bash
tail -f metrics.log \
  | python -m plot.main \
      --sample-size 10 \
      --openai-model gpt-4o-mini \
      --prompt "target the request latency column"
```

### Core Options

| Flag | Description |
| --- | --- |
| `--sample-size` | Number of initial non-empty lines gathered before synthesis (default `5`). |
| `--window` | Sliding window size of plotted points (default `200`). |
| `--prompt` | Additional hint passed to the OpenAI prompt. |
| `--openai-model` | Model used for regex synthesis (`gpt-4o-mini` by default). |
| `--regex` | Bypass OpenAI and provide your own regex (must expose a single capturing group). |
| `--group` | Capturing group index to extract when `--regex` is supplied (default `1`). |
| `--title` | Title drawn above the plot. |
| `--learn-timeout` | Seconds to wait for initial samples before continuing (default `10`). |
| `--refresh` | Minimum seconds between plot redraws (default `0.5`). |

### Behaviour

1. The tool buffers the first `sample-size` lines, requests a regex from OpenAI
   that matches the JSON schema, and validates the response.
2. If OpenAI refuses or returns invalid output, it falls back to a permissive
   numeric regex that matches typical decimal and scientific formats.
3. An asynchronous reader keeps collecting new lines while the OpenAI request is
   running, so log ingestion never blocks on the API call.
4. Values are parsed, added to a sliding window, and redrawn at the chosen
   refresh interval using `uniplot`.

### Fallback Mode

Provide `--regex` when the target metric is already known. This skips network
calls entirely and works even without an OpenAI API key.

## Development

Run `python -m plot.main --help` to inspect every generated flag and verify the
parser. The CLI uses `asyncio`, so when embedding it in scripts make sure to run
it from the main thread or a fresh event loop via `asyncio.run`.
