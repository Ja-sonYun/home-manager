import asyncio
import sys
from collections.abc import AsyncIterator
from typing import Literal

from plot.text import remove_ansi

_FRAME_BOUNDARIES: tuple[str, ...] = (
    "\x1b[2J\x1b[H",
    "\x1b[H\x1b[2J",
    "\x1b[H",
)


def _find_boundary(buffer: str) -> tuple[int, str]:
    index = -1
    token = ""
    for candidate in _FRAME_BOUNDARIES:
        pos = buffer.find(candidate)
        if pos == -1:
            continue
        if index == -1 or pos < index or (pos == index and len(candidate) > len(token)):
            index = pos
            token = candidate
    return index, token


def _normalize(text: str) -> str:
    cleaned = remove_ansi(text)
    cleaned = cleaned.replace("\r", "")
    return cleaned.strip()


async def iter_stdin_lines() -> AsyncIterator[str]:
    """Yield lines from standard input without blocking the event loop."""
    try:
        prev: str | None = None
        while True:
            line = await asyncio.to_thread(sys.stdin.readline)
            line = _normalize(line)
            if line == "":
                continue

            if line == prev:
                continue
            prev = line

            yield line
    except (asyncio.CancelledError, GeneratorExit):
        return


async def iter_stdin_frames() -> AsyncIterator[str]:
    """Yield ANSI-driven screen updates as whole frames."""
    reader = getattr(sys.stdin.buffer, "read1", sys.stdin.buffer.read)
    buffer = ""
    frame = ""
    prev: str | None = None

    try:
        while True:
            chunk = await asyncio.to_thread(reader, 4096)
            if not chunk:
                break

            buffer += chunk.decode(errors="ignore")

            while True:
                idx, boundary = _find_boundary(buffer)
                if idx == -1:
                    break

                segment = buffer[:idx]
                frame += segment
                buffer = buffer[idx + len(boundary) :]

                normalized = _normalize(frame)
                if normalized and normalized != prev:
                    prev = normalized
                    yield normalized
                frame = ""

            frame += buffer
            buffer = ""
    except (asyncio.CancelledError, GeneratorExit):
        return

    normalized = _normalize(frame)
    if normalized and normalized != prev:
        yield normalized


async def queue_stdin(
    queue: asyncio.Queue[str],
    mode: Literal["lines", "frames"] = "lines",
) -> None:
    """Read from standard input and put lines or frames into the queue."""
    reader = iter_stdin_frames if mode == "frames" else iter_stdin_lines
    try:
        async for item in reader():
            await queue.put(item)
    except (asyncio.CancelledError, GeneratorExit):
        return
