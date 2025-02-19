import base64
import json
import os
import sqlite3
import subprocess
from contextlib import contextmanager
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from time import sleep
from typing import Any, Generator, List, Optional

from rich import print

filter_list = ["Avilen", "Todos"]

REMINDER = "Reminder"

REMINDER_SYNCER_DB = Path("~/.task/reminder-syncer.sqlite3").expanduser()

shortcuts = "/usr/bin/shortcuts"
task = os.getenv("TASKWARRIOR_BIN", "/etc/profiles/per-user/jasony/bin/task")


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


def get_tracking_ids() -> dict[str, str]:
    """
    Return dictionary of key to uuid
    """

    with sqlite_execute() as cur:
        try:
            cur.execute("SELECT key_a, key_b, list FROM sync_keys WHERE tracking = 1;")
            rows = cur.fetchall()

            trackings: dict[str, str] = {}
            for row in rows:
                list_name = row[2]
                if list_name not in filter_list:
                    continue
                trackings[row[1]] = row[0]

            return trackings
        except Exception as e:
            if "no such table" in str(e):
                return {}
            else:
                raise


@dataclass
class Todo:
    key: str
    uid: str
    title: str
    notes: str
    due_date: str
    priority: str
    is_completed: bool
    is_flagged: bool
    completion_date: str
    list: str
    url: str
    tags: List[str]

    def add_to_taskwarrior(self, uuid: Optional[str] = None) -> None:
        priority_map = {"High": "H", "Medium": "M", "Low": "L"}

        import_data: dict[str, Any] = {
            "description": self.title,
            "status": self.is_completed and "completed" or "pending",
            "project": self.list,
            "uuid": uuid or self.uid.lower(),
            "_key": self.key,
        }
        if self.due_date:
            due_date = datetime.fromisoformat(self.due_date)
            import_data["due"] = due_date.strftime("%Y%m%dT%H%M%SZ")
        if self.tags:
            import_data["tags"] = self.tags
        if self.priority and self.priority != "None":
            import_data["priority"] = priority_map[self.priority]
        if self.notes:
            key_segments = json.loads(base64.b64decode(self.key).decode("utf-8"))
            creation_date = datetime.fromisoformat(key_segments["creation_date"])
            import_data["annotations"] = [
                {
                    "entry": creation_date.strftime("%Y%m%dT%H%M%SZ"),
                    "description": self.notes,
                }
            ]
        if self.url:
            import_data["url"] = self.url
        print(f"Importing: {import_data}")

        # Pass dumped json as stdin
        proc = subprocess.Popen(
            [task, "import"], stdin=subprocess.PIPE, stdout=subprocess.PIPE
        )
        proc.communicate(input=json.dumps(import_data).encode("utf-8"))
        sleep(1)


def fetch_todos(_list: str) -> list[Todo]:
    input = {"action": "query", "is_completed": False, "list": _list}
    process = subprocess.run(
        [shortcuts, "run", REMINDER, "-i", "-"],
        capture_output=True,
        input=base64.b64encode(json.dumps(input).encode("utf-8")),
    )
    output = base64.b64decode(process.stdout).decode("utf-8")
    todos = json.loads(output)["reminders"]

    return [Todo(**todo) for todo in todos]


def fetch_todo(key: str) -> Optional[Todo]:
    try:
        input = {"action": "get", "key": key}
        process = subprocess.run(
            [shortcuts, "run", REMINDER, "-i", "-"],
            capture_output=True,
            input=base64.b64encode(json.dumps(input).encode("utf-8")),
        )
        output = base64.b64decode(process.stdout).decode("utf-8")
        todo = json.loads(output)
        if "title" not in todo or not todo["title"]:
            return None
        return Todo(**todo)
    except Exception as e:
        print(f"Error fetching todo: {e}")
        return None


def get_current_uuids() -> List[str]:
    raw_last_data = subprocess.check_output([task, "status:pending", "export"])
    last_data = json.loads(raw_last_data.decode("utf-8"))

    return [data["uuid"] for data in last_data]


def get_target_todos() -> List[Todo]:
    todos: list[Todo] = []
    for _list in filter_list:
        todos += fetch_todos(_list)

    tracking_ids = get_tracking_ids()
    tracking_keys = tracking_ids.keys()

    fetched_keys = [todo.key for todo in todos]

    remaining_keys = set(tracking_keys) - set(fetched_keys)

    for key in remaining_keys:
        todo = fetch_todo(key)
        if todo:
            todos.append(todo)

    return todos


def main() -> None:
    todos = get_target_todos()
    print(todos)
    print(f"Found {len(todos)} todos")

    current_traking_ids = get_tracking_ids()
    print(f"Found {len(current_traking_ids)} tracking ids")

    for task_key, uuid in current_traking_ids.items():
        todo = next((t for t in todos if t.key == task_key), None)

        if not todo:
            print(f"Deleting task: {uuid}")
            try:
                subprocess.check_call([task, "delete", uuid])
            except subprocess.CalledProcessError as e:
                print(f"Error deleting task: {e}")

    for todo in todos:
        if todo.list not in filter_list:
            continue
        uuid = current_traking_ids.get(todo.key)
        if uuid:
            todo.add_to_taskwarrior(uuid)
        else:
            todo.add_to_taskwarrior()


if __name__ == "__main__":
    main()
