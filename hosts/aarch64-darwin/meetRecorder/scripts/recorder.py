import base64
import logging
import os
import subprocess
import sys
import time
from collections.abc import Generator
from contextlib import contextmanager
from datetime import datetime, timedelta
from pathlib import Path
from subprocess import run
from typing import Annotated, Final, Generic, Literal, TypeVar, cast, overload

import obsws_python as obs
import whisper
from openai import OpenAI
from pydantic import (
    AfterValidator,
    BaseModel,
    Field,
    SecretStr,
    ValidationError,
    computed_field,
)
from pydantic_settings import BaseSettings, CliApp, CliImplicitFlag, SettingsError
from rich import print
from rich.logging import RichHandler
from rich.prompt import Prompt

logging.basicConfig(
    format="%(message)s",
    datefmt="[%X]",
)
logger = logging.getLogger("recorder")


def _resolve_abs_path(path: Path) -> Path:
    return path.expanduser().resolve()


AbsPath = Annotated[Path, AfterValidator(_resolve_abs_path)]

ARG = TypeVar("ARG")
RT = TypeVar("RT")


class ShortcutBase(Generic[ARG, RT]):
    executable: Final[str] = "shortcuts"
    name: str | None = None

    @overload
    def _run(self, arg: ARG, return_cls: None = None) -> None: ...
    @overload
    def _run(self, arg: ARG, return_cls: type[RT]) -> RT: ...
    def _run(self, arg: ARG, return_cls: type[RT] | None = None) -> RT | None:
        if not isinstance(arg, BaseModel):
            raise TypeError(f"arg must be a pydantic model, not {type(arg)}")
        if return_cls is not None and not issubclass(return_cls, BaseModel):
            raise TypeError(f"return_cls must be a pydantic model, not {return_cls}")

        b64_arg = base64.b64encode(arg.model_dump_json().encode()).decode()
        result = run(
            [
                self.executable,
                "run",
                self.name or self.__class__.__name__,
                "-i",
                "-",
            ],
            input=b64_arg,
            text=True,
            capture_output=True,
        )
        if return_cls is None:
            return

        try:
            decoded = base64.b64decode(result.stdout.encode()).decode()
            return return_cls.model_validate_json(decoded)
        except Exception as e:
            raise RuntimeError(f"Failed to decode result: {e}") from e


class GetNextCalendarEventRequest(BaseModel):
    action: Literal["query"] = "query"
    calendar: str
    after_datetime: str
    before_datetime: str


class GetNextCalendarEventResponse(BaseModel):
    title: str
    start_date: datetime
    end_date: datetime
    is_all_day: bool
    calendar: str
    location: str
    url: str
    notes: str
    key: str
    uid: str
    attendees: set[str]
    my_status: str
    is_canceled: bool

    @computed_field
    @property
    def duration(self) -> int:
        return (self.end_date - self.start_date).seconds * 60


class GetNextCalendarEventsResponse(BaseModel):
    events: list[GetNextCalendarEventResponse]


class GetNextCalendarEvents(
    ShortcutBase[
        GetNextCalendarEventRequest,
        GetNextCalendarEventsResponse,
    ]
):
    name = "Calendar"

    def run(self, arg: GetNextCalendarEventRequest) -> GetNextCalendarEventsResponse:
        return super()._run(arg, GetNextCalendarEventsResponse)


# ==== NOTE


class CreateNoteRequest(BaseModel):
    action: Literal["create"] = "create"
    content: str
    folder: str


class CreateNoteResponse(BaseModel):
    key: str


class CreateMarkdownNote(ShortcutBase[CreateNoteRequest, CreateNoteResponse]):
    name = "Notes"

    def run(self, arg: CreateNoteRequest) -> CreateNoteResponse:
        return super()._run(arg, CreateNoteResponse)


class AppendNoteRequest(BaseModel):
    action: Literal["append"] = "append"
    key: str
    content: str | None = None
    filepath: str | None = None


class AppendMarkdownNote(ShortcutBase[AppendNoteRequest, None]):
    name = "Notes"

    def run(self, arg: AppendNoteRequest) -> None:
        return super()._run(arg)


class GetNoteRequest(BaseModel):
    action: Literal["get"] = "get"
    key: str


class GetNoteResponse(BaseModel):
    content: str
    folder: str


class GetNote(ShortcutBase[GetNoteRequest, GetNoteResponse]):
    name = "Notes"

    def run(self, arg: GetNoteRequest) -> GetNoteResponse:
        return super()._run(arg, GetNoteResponse)


NOTE_TEMPLATES = """\
# {title}


<strong>Date</strong>
*{start_date} - {end_date}*
<br>

<strong>Attendees</strong>
{attendees}

<br>

<strong>Notes</strong>
{notes}
<br>
Memo
---
"""

SUMMARIZE_TEMPLATES = """\
다음 회의 내용을 한국어로 요약해주세요.
다음은 이 회의에 대한 정보와 메모,  그리고 Transcribe된 텍스트입니다.
요약할때 마크다운 형식을 유지해주세요. 요약할때,  마지막 문단에는 다음에 취해야할 행동을 적어주세요.
**중요**:  마크다운을 사용해주세요.  Tab를 사용하지 마세요.


---------

:: 회의에대한 정보 및 메모. 이건 요약하지 마세요. 이미 요약된 내용입니다.

{notes}

---------

:: Transcribe된 텍스트. 이거만 요약해주세요.

{transcribed_text}
"""


class Args(BaseSettings, cli_parse_args=True):
    host: str = Field(
        description="OBS WebSocket server host",
        default="localhost",
    )
    port: int = Field(
        description="OBS WebSocket server port",
        default=4455,
    )
    password: SecretStr = Field(
        description="OBS WebSocket server password",
        default_factory=lambda: SecretStr(os.environ.get("OBS_PASSWORD", "")),
    )

    obs_result_dir: AbsPath = Field(
        description="Directory to save the recording result",
        default=Path("~/Movies"),
    )

    obs_app_name: str = Field(
        description="OBS application name",
        default="OBS",
    )
    obs_scene_name: str = Field(
        description="OBS scene name to switch",
        default="MeetRecord",
    )
    audio_output_dir: AbsPath = Field(
        description="Directory to save the audio output",
        default=Path("~/Documents/Attachments"),
    )
    obs_result_wait_timeout: int = Field(
        description="Timeout to wait for the recording result",
        default=120,
    )

    calendar_name: str = Field(
        description="Calendar name to get the next event",
        default="ゆ：ユンジェソン",
    )
    record_buffer: int = Field(
        description="Buffer minutes to record after the event done",
        default=10,
    )

    shortcut_name: str = Field(
        description="Shortcut name for the recording",
        default="CreateMeetingRecordNote",
    )
    notes_folder: str = Field(
        description="Folder name for the notes",
        default="Work",
    )

    verbose: CliImplicitFlag[bool] = Field(
        description="Verbose mode",
        default=False,
        validation_alias=("v"),
    )
    language: str = Field(
        description="Language for transcription",
        default="Japanese",
    )


@contextmanager
def suppress_output() -> Generator[None, None, None]:
    original_stdout = sys.stdout
    original_stderr = sys.stderr

    with open(os.devnull, "w") as devnull:
        sys.stdout = devnull
        sys.stderr = devnull
        try:
            yield
        finally:
            sys.stdout = original_stdout
            sys.stderr = original_stderr


@contextmanager
def run_obs(args: Args) -> Generator[obs.ReqClient, None, None]:
    print("Starting OBS...")
    command = f"open -a '{args.obs_app_name}' --args --minimize-to-tray --disable-shutdown-check"
    logger.debug(f"Executing command: {command}")
    subprocess.Popen(command, shell=True)
    try:
        client: obs.ReqClient | None = None
        attempt = 0

        while client is None and attempt < 10:
            logger.debug(f"Connection attempt {attempt + 1}")
            try:
                with suppress_output():
                    client = obs.ReqClient(
                        host=args.host,
                        port=args.port,
                        password=args.password.get_secret_value(),
                    )
            except (BaseException, ConnectionRefusedError):
                attempt += 1
                time.sleep(1)

        if client is None:
            raise ConnectionError("Failed to connect to OBS WebSocket server")

        logger.debug("Connected to OBS WebSocket server")

        connected = False
        attempt = 0

        while not connected and attempt < 10:
            try:
                logger.debug(f"Connection attempt {attempt + 1}")
                client.get_stats()
                connected = True
            except BaseException:
                attempt += 1
                time.sleep(1)

        if not connected:
            raise ConnectionError("Failed to connect to OBS WebSocket server")

        print("OBS started")
        yield client
    finally:
        print("Stopping OBS...")
        command = f"pkill {args.obs_app_name}"
        logger.debug(f"Executing command: {command}")
        subprocess.Popen(command, shell=True)


def wait_and_get_recent_mov(mov_dir: Path, timeout: int = 120) -> Path:
    # Find the mov file that generate within 1 minute from now
    files = sorted(mov_dir.glob("*.mov"), key=os.path.getctime, reverse=True)
    now = time.time()

    elapsed = 0

    while elapsed < timeout:
        for file in files:
            if now - os.path.getctime(file) < 60:
                return file

        time.sleep(1)
        elapsed += 1

    raise FileNotFoundError("No recent mov file found")


def convert_mov_to_m4a(mov_file: Path, output_dir: Path, verbose: bool = False) -> None:
    command = f"ffmpeg -i '{mov_file}' -vn -acodec aac -y '{output_dir}'"
    logger.debug(f"Executing command: {command}")
    if verbose:
        subprocess.run(command, shell=True)
    else:
        subprocess.run(
            command,
            shell=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )


def transcribe_audio(m4a_file: Path, language: str, verbose: bool = False) -> str:
    logger.info("Transcribing audio")
    model = whisper.load_model("large-v3")
    result = model.transcribe(
        str(m4a_file),
        verbose=verbose,
        language=language,
    )
    logger.debug(f"Transcribed result: {result}")
    texts = [
        cast(dict, segment)["text"]
        for segment in result["segments"]
        if "text" in segment
    ]
    return "\n".join(texts)


def main() -> None:
    try:
        args = CliApp.run(Args)
    except (SettingsError, ValidationError):
        CliApp.run(Args, cli_args=["--help"])
        return

    if args.verbose:
        logger.setLevel(logging.DEBUG)
        logger.addHandler(RichHandler())

    start_date = (datetime.now() - timedelta(minutes=30)).isoformat()
    end_date = (datetime.now() + timedelta(days=4)).isoformat()
    print(f"Start date: {start_date}")
    print(f"End date: {end_date}")

    # Get the next calendar event
    next_events = (
        GetNextCalendarEvents()
        .run(
            GetNextCalendarEventRequest(
                calendar=args.calendar_name,
                after_datetime=start_date,
                before_datetime=end_date,
            )
        )
        .events
    )
    events = [next_event for next_event in next_events if not next_event.is_all_day]
    events.sort(key=lambda event: event.start_date)

    options = [event.title for event in events]
    print("Select the event to record")

    for i, event in enumerate(events):
        print(f"{i + 1}. ({event.start_date}) {event.title}")

    choice = Prompt.ask(
        "Enter the number of your choice",
        choices=[str(i) for i in range(1, len(options) + 1)],
    )

    next_event = events[int(choice) - 1]

    print(f"Next event: {next_event.title}")
    print(f"Start: {next_event.start_date}")
    print(f"End: {next_event.end_date}")
    print(f"Duration: {next_event.duration} seconds")
    print(f"Attendees: {', '.join(next_event.attendees)}")
    print(f"Notes: {next_event.notes}")

    # Create a note for the event
    new_note = CreateMarkdownNote().run(
        CreateNoteRequest(
            content=NOTE_TEMPLATES.format(
                title=next_event.title,
                start_date=next_event.start_date.strftime("%Y-%m-%d %H:%M:%S"),
                end_date=next_event.end_date.strftime("%H:%M:%S"),
                attendees="\n".join(
                    [
                        f"- {attendee}"
                        for attendee in next_event.attendees
                        if "@" in attendee
                    ]
                ),
                notes=next_event.notes,
            ),
            folder=args.notes_folder,
        )
    )

    record_duration = next_event.duration + args.record_buffer

    with run_obs(args) as client:
        client.set_current_scene_collection(args.obs_scene_name)
        client.set_current_program_scene(args.obs_scene_name)

        try:
            logger.info("Starting recording")
            client.start_record()

            logger.info(f"Recording for {record_duration} minutes")
            time.sleep(record_duration * 60)
        except KeyboardInterrupt:
            logger.info("Recording interrupted")
        finally:
            logger.info("Stopping recording")
            client.stop_record()
            client.disconnect()

    file_name = f"{next_event.title} {next_event.start_date.strftime('%Y%m%d%H%M%S')}"
    result_file = args.audio_output_dir / file_name
    result_m4a_file = result_file.with_suffix(".m4a")
    result_txt_file = result_file.with_suffix(".txt")

    mov_file = wait_and_get_recent_mov(
        args.obs_result_dir,
        args.obs_result_wait_timeout,
    )
    print(f"Found mov file: {mov_file}. Converting to m4a...")
    convert_mov_to_m4a(mov_file, result_m4a_file)
    print(f"Converted to m4a saved to {result_m4a_file}")

    print("Transcribing audio...")
    transcribed_text = transcribe_audio(result_m4a_file, args.language, args.verbose)

    with open(result_txt_file, "w") as f:
        f.write(transcribed_text)

    print(f"Transcribed text saved to {result_txt_file}")

    # After transcribing, remove the mov file
    mov_file.unlink()
    print("Removed mov file")
    print("Done")

    updated_note = GetNote().run(GetNoteRequest(key=new_note.key))

    client = OpenAI()
    summarize_text = SUMMARIZE_TEMPLATES.format(
        transcribed_text=transcribed_text,
        notes=updated_note.content,
    )

    response = client.chat.completions.create(
        model="o1",
        messages=[
            {"role": "system", "content": "Summarize the following text."},
            {"role": "user", "content": summarize_text},
        ],
    )
    summary = response.choices[0].message.content or "No summary"

    AppendMarkdownNote().run(
        AppendNoteRequest(
            key=new_note.key,
            filepath=result_m4a_file.name,
        )
    )
    AppendMarkdownNote().run(
        AppendNoteRequest(
            key=new_note.key,
            content=summary,
        )
    )


if __name__ == "__main__":
    main()
