# Plot

Plot any data stream in your terminal, with OpenAI generated regex parsing.

## How It Works

`plot` reads from standard input, receive a sample of non-empty lines, and uses OpenAI's API to generate a regex pattern that extracts numeric values from the input. It then continuously reads from the input, applies the regex to extract values, and plots them in real-time in the terminal.

## Example Usage

```sh
 $ plot -h
usage: plot [-h] [-s int] [-w int] [-p str] [--height int] [-m str] [--learn-timeout float] [-r float] [-f | --frame-stream | --no-frame-stream]

options:
  -h, --help            show this help message and exit
  -s, --sample-size int
                        Number of initial non-empty lines to learn from. (default: 5)
  -w, --window int      Sliding window length for plotted values. (default: 200)
  -p, --prompt str      Additional instruction to steer regex generation. (default: )
  --height int          Height of the plot in terminal rows. (default: 30)
  -m, --model str       OpenAI model used when synthesizing regex patterns. (default: gpt-5)
  --learn-timeout float
                        Seconds to wait for sample collection before continuing. (default: 10.0)
  -r, --refresh float   Minimum seconds between plot redraws. (default: 0.5)
  -f, --frame-stream, --no-frame-stream
                        Interpret ANSI screen refresh sequences as frame-sized samples. (default: False)

```

```python
docker stats | plot -f -p 'Plot all containers memory usage'
```
