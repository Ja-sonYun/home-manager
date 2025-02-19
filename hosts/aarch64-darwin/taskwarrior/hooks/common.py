import base64
import json
import logging
import sqlite3
import subprocess
import sys
from contextlib import contextmanager
from logging.handlers import RotatingFileHandler
from pathlib import Path
from typing import Any, Generator

logger = logging.getLogger("taskwarrior-hooks")
logger.setLevel(logging.DEBUG)

formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")

handler = RotatingFileHandler(
    "/tmp/reminder-syncer.log",
    maxBytes=1048576,
    backupCount=5,
)
handler.setFormatter(formatter)
logger.addHandler(handler)

LOG_FILE = "/tmp/reminder-syncer.log"
REMINDER_SYNCER_DB = Path("~/.task/reminder-syncer.sqlite3").expanduser()

priority_map = {"High": "H", "Medium": "M", "Low": "L"}


@contextmanager
def sqlite_execute(commit: bool = False) -> Generator[sqlite3.Cursor, None, None]:
    conn = sqlite3.connect(REMINDER_SYNCER_DB)
    cur = conn.cursor()
    try:
        yield cur
        if commit:
            conn.commit()
    finally:
        conn.close()


def run_shortcuts(request_dict: dict[str, Any]) -> str:
    # Convert dict to JSON, then to base64 and run shortcuts command
    req_json = json.dumps(request_dict)
    logger.debug(f"Sending request to shortcuts: {req_json}")
    b64_req = base64.b64encode(req_json.encode()).decode()
    try:
        proc = subprocess.run(
            ["/usr/bin/shortcuts", "run", "Reminder", "-i", "-"],
            input=b64_req.encode(),
            stdout=subprocess.PIPE,
            check=True,
        )
    except subprocess.CalledProcessError:
        sys.exit(1)
    # Decode base64 output from shortcuts
    logger.debug(f"Received response from shortcuts: {proc.stdout}")
    resp_decoded = base64.b64decode(proc.stdout).decode()
    logger.debug(f"Decoded response: {resp_decoded}")
    return resp_decoded
