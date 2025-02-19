import base64
import json
import sys
from datetime import datetime
from typing import Any

from common import logger, run_shortcuts, sqlite_execute


def main() -> None:
    # Read two inputs from stdin (old_data and new_data)
    old_data_raw = sys.stdin.readline()
    new_data_raw = sys.stdin.readline()

    logger.debug(f"Received old_data: {old_data_raw}")
    logger.debug(f"Received new_data: {new_data_raw}")

    # Remove control characters and parse JSON
    try:
        old_data: dict[str, Any] = json.loads(old_data_raw)
        new_data: dict[str, Any] = json.loads(new_data_raw)
    except json.JSONDecodeError as e:
        logger.error(f"JSON decode error: {e}")
        sys.exit("JSON decode error: " + str(e))

    # Connect to SQLite DB and retrieve key_b using uuid from old_data
    uuid_val = old_data["uuid"]

    with sqlite_execute() as cur:
        cur.execute(
            "SELECT key_b FROM sync_keys WHERE key_a COLLATE NOCASE = ?", (uuid_val,)
        )
        row = cur.fetchone()
        if row:
            key = row[0]
        else:
            key = None

        logger.debug(f"Retrieved key: {key}")

    taskstatus = new_data["status"]

    if taskstatus == "deleted":
        logger.debug("Task is deleted, removing from reminders")
        # Build delete action JSON and run shortcuts command
        request_json = {"action": "delete", "key": key}
        run_shortcuts(request_json)

        with sqlite_execute(commit=True) as cur:
            cur.execute(
                "DELETE FROM sync_keys WHERE key_a COLLATE NOCASE = ?",
                (uuid_val,),
            )
        result = json.dumps(new_data)
        print(result)
        logger.debug(f"Returning result: {result}")
        sys.exit(0)

    # Otherwise, update action
    request_json = {"action": "update", "key": key}

    old_status = old_data.get("status")
    if taskstatus and (taskstatus != old_status):
        request_json["is_completed"] = taskstatus == "completed"

    # Process description (title)
    description = new_data.get("description")
    old_description = old_data.get("description")
    if description and (description != old_description):
        request_json["title"] = description

    # Process due date
    due = new_data.get("due", "")
    old_due = old_data.get("due", "")
    if due and (due != old_due):
        try:
            # Parse date in format "%Y%m%dT%H%M%SZ" and convert to ISO format
            due_iso = datetime.strptime(due, "%Y%m%dT%H%M%SZ").isoformat()
            request_json["due_date"] = due_iso
        except Exception:
            pass
    elif due is None and old_due is not None:
        # If due date is removed, set to "None"
        request_json["due_date"] = "None"

    # Process project (list)
    project = new_data.get("project")
    old_project = old_data.get("project")
    if project and (project != old_project):
        request_json["list"] = project

    # Process annotations (notes)
    annotations_new = new_data.get("annotations")
    annotations_old = old_data.get("annotations")
    if annotations_new and (annotations_new != annotations_old):
        # Get description from first annotation and encode in base64
        notes = ""
        if isinstance(annotations_new, list) and len(annotations_new) > 0:
            notes = annotations_new[0].get("description", "")
        b64_notes = base64.b64encode(notes.encode()).decode()
        request_json["notes"] = b64_notes

    # Process URL
    url = new_data.get("url", "")
    old_url = old_data.get("url", "")
    if url and (url != old_url):
        request_json["url"] = url

    # Process tags
    tags_new = new_data.get("tags")
    old_tags = old_data.get("tags")
    if tags_new and (tags_new != old_tags):
        # Join list using comma if necessary
        if isinstance(tags_new, list):
            tags_joined = ",".join(tags_new)
        else:
            tags_joined = tags_new
        request_json["tags"] = tags_joined

    # Process priority
    priority = new_data.get("priority", "")
    old_priority = old_data.get("priority", "")
    if priority and (priority != old_priority):
        priority_dict = {"H": "High", "M": "Medium", "L": "Low"}
        request_json["priority"] = priority_dict.get(priority, priority)
    elif (not priority) and old_priority:
        request_json["priority"] = "None"

    run_shortcuts(request_json)

    result = json.dumps(new_data)
    print(result)
    logger.debug(f"Returning result: {result}")

    # If task is completed, update sync_keys.tracking to 0
    if taskstatus == "completed":
        logger.debug("Task is completed, updating tracking to 0")

        with sqlite_execute(commit=True) as cur:
            cur.execute(
                "UPDATE sync_keys SET tracking = 0 WHERE key_a COLLATE NOCASE = ?",
                (uuid_val,),
            )

    sys.exit(0)


if __name__ == "__main__":
    main()
