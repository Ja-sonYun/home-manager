import asyncio
import os
import sys
import termios
from dataclasses import dataclass
from enum import Enum


class KeyEvent(Enum):
    ESCAPE = "escape"
    CTRL_C = "ctrl_c"
    ARROW_UP = "arrow_up"
    ARROW_DOWN = "arrow_down"
    ARROW_LEFT = "arrow_left"
    ARROW_RIGHT = "arrow_right"
    CHARACTER = "character"
    ENTER = "enter"
    BACKSPACE = "backspace"
    TAB = "tab"
    EOF = "eof"
    UNKNOWN = "unknown"


@dataclass(slots=True)
class KeyStroke:
    event: KeyEvent
    value: str | None = None


class KeyCapture:
    def __init__(
        self,
        queue: asyncio.Queue[KeyStroke],
        *,
        read_chunk: int = 32,
    ) -> None:
        self._queue = queue
        self._read_chunk = read_chunk
        self._buffer = bytearray()
        self._running = False
        self._original_term: list[int] | None = None
        self._owns_fd = False

        self._fd: int

        if sys.stdin.isatty():
            self._fd = sys.stdin.fileno()
        else:
            try:
                self._fd = os.open("/dev/tty", os.O_RDONLY)
                self._owns_fd = True
            except OSError as exc:
                raise RuntimeError("No TTY available for key capture") from exc

        self._cancel_r, self._cancel_w = os.pipe()

    async def run(self) -> None:
        if self._running:
            return

        loop = asyncio.get_running_loop()
        self._enter_raw_mode()
        self._running = True

        try:
            while self._running:
                chunk = await loop.run_in_executor(
                    None,
                    self._cancellable_read,
                    self._fd,
                    self._read_chunk,
                    self._cancel_r,
                )
                if chunk is None:
                    break
                if not chunk:
                    await self._queue.put(KeyStroke(KeyEvent.EOF))
                    break

                self._buffer.extend(chunk)
                for stroke in self._drain_buffer():
                    await self._queue.put(stroke)
        except asyncio.CancelledError:
            try:
                os.write(self._cancel_w, b"x")
            except OSError:
                pass
            return
        finally:
            self._running = False
            self._restore_terminal()

    @staticmethod
    def _cancellable_read(fd: int, n: int, cancel_fd: int) -> bytes | None:
        import select

        while True:
            r, _, _ = select.select([fd, cancel_fd], [], [])
            if cancel_fd in r:
                # drain cancel pipe
                try:
                    os.read(cancel_fd, 4096)
                except OSError:
                    pass
                return None
            if fd in r:
                try:
                    return os.read(fd, n)
                except InterruptedError:
                    continue

    def _enter_raw_mode(self) -> None:
        if self._original_term is not None:
            return

        attrs = termios.tcgetattr(self._fd)
        self._original_term = attrs[:]

        attrs[3] &= ~(termios.ECHO | termios.ICANON | termios.ISIG)
        attrs[6][termios.VMIN] = 1
        attrs[6][termios.VTIME] = 0

        termios.tcsetattr(self._fd, termios.TCSANOW, attrs)

    def _restore_terminal(self) -> None:
        if self._original_term is not None:
            termios.tcsetattr(
                self._fd,
                termios.TCSANOW,
                self._original_term,  # type: ignore
            )
            self._original_term = None
        if self._owns_fd:
            os.close(self._fd)
            self._owns_fd = False
            self._fd = -1

    def _drain_buffer(self) -> list[KeyStroke]:
        strokes: list[KeyStroke] = []

        while self._buffer:
            first = self._buffer[0]

            if first == 0x1B:  # ESC
                event = self._consume_escape_sequence()
                if event is None:
                    break
                strokes.append(event)
                continue

            if first == 0x03:  # Ctrl+C
                del self._buffer[0]
                strokes.append(KeyStroke(KeyEvent.CTRL_C))
                continue

            if first == 0x7F:  # Backspace
                del self._buffer[0]
                strokes.append(KeyStroke(KeyEvent.BACKSPACE))
                continue

            if first in (0x0D, 0x0A):  # Enter
                del self._buffer[0]
                if first == 0x0D and self._buffer[:1] == b"\n":
                    del self._buffer[0]
                strokes.append(KeyStroke(KeyEvent.ENTER))
                continue

            if first == 0x09:  # Tab
                del self._buffer[0]
                strokes.append(KeyStroke(KeyEvent.TAB))
                continue

            if first == 0x04:  # Ctrl+D / EOF
                del self._buffer[0]
                strokes.append(KeyStroke(KeyEvent.EOF))
                continue

            decoded = self._consume_character()
            if decoded is None:
                break
            strokes.append(KeyStroke(KeyEvent.CHARACTER, decoded))

        return strokes

    def _consume_escape_sequence(self) -> KeyStroke | None:
        if len(self._buffer) == 1:
            return None

        if self._buffer[1:2] == b"[":
            if len(self._buffer) < 3:
                return None

            mapping = {
                ord("A"): KeyEvent.ARROW_UP,
                ord("B"): KeyEvent.ARROW_DOWN,
                ord("C"): KeyEvent.ARROW_RIGHT,
                ord("D"): KeyEvent.ARROW_LEFT,
            }

            terminator = self._buffer[2]
            if terminator in mapping:
                del self._buffer[:3]
                return KeyStroke(mapping[terminator])

            for index in range(2, len(self._buffer)):
                byte = self._buffer[index]
                if 0x40 <= byte <= 0x7E:
                    sequence = bytes(self._buffer[: index + 1])
                    del self._buffer[: index + 1]
                    text = sequence.decode("ascii", errors="ignore") or None
                    return KeyStroke(KeyEvent.UNKNOWN, text)
            return None

        del self._buffer[0]
        return KeyStroke(KeyEvent.ESCAPE)

    def _consume_character(self) -> str | None:
        for size in range(1, len(self._buffer) + 1):
            try:
                text = self._buffer[:size].decode("utf-8")
            except UnicodeDecodeError:
                continue
            if not text:
                continue
            char = text[0]
            del self._buffer[:size]
            return char
        return None
