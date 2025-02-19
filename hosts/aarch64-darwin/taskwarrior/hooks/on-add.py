import base64
import json
import sys
from datetime import datetime

from common import logger, priority_map, run_shortcuts, sqlite_execute


def main() -> None:
    input_data = sys.stdin.read()
    new_data = json.loads(input_data)
    logger.debug(f"Received new_data: {new_data}")

    request_json = {"action": "create"}

    description = new_data.get("description")
    if description:
        request_json["title"] = description

    due = new_data.get("due")
    if due:
        try:
            due_iso = datetime.strptime(due, "%Y%m%dT%H%M%SZ").isoformat()
            request_json["due_date"] = due_iso
        except Exception:
            # If conversion fails, skip due_date conversion
            pass

    # Process project information
    project = new_data.get("project")
    if project:
        request_json["list"] = project

    # Process tags: join list with comma if list, else use as is
    tags = new_data.get("tags")
    if tags:
        if isinstance(tags, list):
            tags_joined = ",".join(tags)
        else:
            tags_joined = tags
        request_json["tags"] = tags_joined

    # Process priority conversion
    priority = new_data.get("priority")
    if priority:
        request_json["priority"] = priority_map.get(priority, priority)

    # Process annotations to obtain notes and encode in base64
    annotations = new_data.get("annotations")
    if annotations and isinstance(annotations, list) and len(annotations) > 0:
        notes = annotations[0].get("description", "")
        b64_notes = base64.b64encode(notes.encode()).decode()
        request_json["notes"] = b64_notes

    # Process URL if exists
    url = new_data.get("url")
    if url:
        request_json["url"] = url

    # Get uuid and key from input JSON
    uuid_val = new_data.get("uuid")
    key = new_data.get("_key")
    logger.debug(f"Received UUID: {uuid_val}, Key: {key}")
    if not key:
        logger.debug("Key not found, requesting new key from shortcuts")
        resp = run_shortcuts(request_json)
        resp_json = json.loads(resp)
        logger.debug(f"Decoded JSON: {resp_json}")
        key = resp_json.get("key")

    # Connect to SQLite database and ensure table exists
    with sqlite_execute(commit=True) as cur:
        cur.execute(
            """
            CREATE TABLE IF NOT EXISTS sync_keys (
                id       INTEGER PRIMARY KEY,
                key_a    TEXT UNIQUE,
                key_b    TEXT UNIQUE,
                list     TEXT,
                tracking BOOLEAN
            );
        """
        )

    with sqlite_execute(commit=True) as cur:
        logger.debug(f"Inserting new sync record: {uuid_val}, {key}")
        # Insert new sync record
        cur.execute(
            "INSERT INTO sync_keys (key_a, key_b, list, tracking) VALUES (?, ?, ?, ?);",
            (uuid_val, key, project, 1),
        )

    # Output the original new_data JSON
    result = json.dumps(new_data)
    print(result)
    logger.debug(f"Outputting new_data: {result}")
    sys.exit(0)


if __name__ == "__main__":
    main()
