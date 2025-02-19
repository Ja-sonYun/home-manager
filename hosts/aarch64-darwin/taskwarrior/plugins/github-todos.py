import asyncio
import base64
import json
import os
import sqlite3
import subprocess
from contextlib import contextmanager
from dataclasses import dataclass
from datetime import datetime
from hashlib import sha256
from pathlib import Path
from time import sleep
from typing import Any, Generator, List, Optional, Union
from uuid import UUID, uuid5

from github import Auth, Github
from github.Issue import Issue
from github.PullRequest import PullRequest
from openai import AsyncClient
from rich import print

task = os.getenv("TASKWARRIOR_BIN", "/etc/profiles/per-user/jasony/bin/task")
auth = Auth.Token(os.getenv("GITHUB_API_KEY", ""))

GITHUB_SYNCER_DB = Path("~/.task/github-syncer.sqlite3").expanduser()

ns = UUID("795DD124-10FB-4B0C-876C-64693A625F76")


@contextmanager
def sqlite_execute(commit: bool = False) -> Generator[sqlite3.Cursor, None, None]:
    conn = sqlite3.connect(GITHUB_SYNCER_DB)
    cur = conn.cursor()
    try:
        yield cur
        if commit:
            conn.commit()
    finally:
        conn.close()


def get_text_hash(text: str) -> str:
    # Remove all \n, \t, \r, \s,  characters
    text = (
        text.lower()
        .replace("\n", "")
        .replace("\t", "")
        .replace("\r", "")
        .replace(" ", "")
        .replace("\\n", "")
        .replace("\\t", "")
        .replace("\\r", "")
    )
    return sha256(text.encode()).hexdigest()


@dataclass
class Todo:
    key: str
    uid: str
    title: str
    summarized_notes: str
    original_notes: str
    is_completed: bool
    list: str
    url: str
    tags: List[str]
    creation_date: datetime

    is_flagged: Optional[bool] = None
    due_date: Optional[datetime] = None
    priority: Optional[str] = None
    completion_date: Optional[str] = None

    def add_to_taskwarrior(self, uuid: Optional[str] = None) -> None:
        priority_map = {"High": "H", "Medium": "M", "Low": "L"}

        import_data: dict[str, Any] = {
            "description": self.title,
            "status": self.is_completed and "completed" or "pending",
            "project": self.list,
            "uuid": uuid or self.uid.lower(),
        }
        if self.due_date:
            import_data["due"] = self.due_date.strftime("%Y%m%dT%H%M%SZ")
        import_data["tags"] = ["readonly"] + (self.tags or [])
        import_data["tags"] = [
            tag.replace("-", "_").replace("/", "_") for tag in import_data["tags"]
        ]
        if self.priority and self.priority != "None":
            import_data["priority"] = priority_map[self.priority]
        if self.summarized_notes:
            import_data["annotations"] = [
                {
                    "entry": self.creation_date.strftime("%Y%m%dT%H%M%SZ"),
                    "description": self.summarized_notes,
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


async def summarize_notes(notes: str) -> str:
    client = AsyncClient()
    response = await client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {
                "role": "system",
                "content": (
                    "User will pass github issue or pull request notes."
                    "한국어로 내용을 100단어 이내로 요약해줘"
                ),
            },
            {"role": "user", "content": notes},
        ],
        max_tokens=170,
    )

    return response.choices[0].message.content or notes


def get_github_todos(
    tracked_issues: Optional[dict[str, tuple[str, str]]] = None,
) -> List[Todo]:
    tracked_issues = tracked_issues or {}

    todos: List[Todo] = []
    github = Github(auth=auth)

    issues_query = "is:open is:issue assignee:@me created:>2024-06-01"
    state_map = {"open": False, "closed": True}

    issues: list[Union[PullRequest, Issue]] = list(github.search_issues(issues_query))
    fetched_issues = [issue.html_url for issue in issues]
    should_be_fetched = set(tracked_issues.keys()) - set(fetched_issues)

    issues_query = "is:open is:pr created:>2024-06-01 review-requested:@me"
    pull_requests: list[Union[PullRequest, Issue]] = list(
        github.search_issues(issues_query)
    )

    for url in should_be_fetched:
        # https://github.com/avilendev/terminal/issues/997
        url_segments = url.split("/")

        repo = f"{url_segments[-4]}/{url_segments[-3]}"
        number = int(url_segments[-1])

        repository = github.get_repo(repo)

        if url_segments[-2] == "issues":
            issue = repository.get_issue(number)
            issues.append(issue)
        elif url_segments[-2] == "pull":
            pull = repository.get_pull(number)
            pull_requests.append(pull)

    print(f"Fetched {len(issues)} issues and {len(pull_requests)} pull requests")

    async def _summarize_notes(issues: list[Union[PullRequest, Issue]]) -> list[str]:
        print("Summarizing notes")
        nonlocal tracked_issues
        assert tracked_issues is not None

        tasks = []
        print(tracked_issues)
        for issue in issues:
            body_hash = get_text_hash(issue.body)
            if issue.html_url in tracked_issues:
                (previous_hash, prev_summary) = tracked_issues[issue.html_url]
                print(f"Previous hash: {previous_hash}")
                print(f"Current hash: {body_hash}")
                if body_hash == previous_hash:
                    # Notes haven't changed, skip summarization
                    print(f"Skipping {issue.html_url}")

                    async def _summarize_notes(notes: str) -> str:
                        return notes

                    tasks.append(_summarize_notes(prev_summary))
                    continue

            print(f"Summarizing {issue.html_url}")
            tasks.append(summarize_notes(issue.body))

        return await asyncio.gather(*tasks)

    event_loop = asyncio.get_event_loop()

    issues_summarized_notes = event_loop.run_until_complete(_summarize_notes(issues))
    pr_summarized_notes = event_loop.run_until_complete(_summarize_notes(pull_requests))

    for issue, summarized_note in zip(issues, issues_summarized_notes):
        assert isinstance(issue, Issue)
        todo = Todo(
            key=base64.b64encode(issue.html_url.encode()).decode(),
            uid=str(uuid5(ns, issue.html_url)),
            title=f"[{issue.repository.full_name} #{issue.number}] {issue.title}",
            summarized_notes=summarized_note,
            original_notes=issue.body,
            due_date=(
                issue.milestone.due_on
                if issue.milestone and issue.milestone.due_on
                else None
            ),
            creation_date=issue.created_at,
            is_completed=state_map[issue.state],
            list="GithubIssues",
            url=issue.html_url,
            tags=["issue-assigned"] + issue.repository.full_name.split("/"),
        )
        todos.append(todo)

    for pull, summarized_note in zip(pull_requests, pr_summarized_notes):
        url_segments = pull.html_url.split("/")
        fullname = f"{url_segments[-4]}/{url_segments[-3]}"
        todo = Todo(
            key=base64.b64encode(pull.html_url.encode()).decode(),
            uid=str(uuid5(ns, pull.html_url)),
            title=f"[{fullname} #{pull.number}] {pull.title}",
            summarized_notes=summarized_note,
            original_notes=pull.body,
            due_date=(
                pull.milestone.due_on
                if pull.milestone and pull.milestone.due_on
                else None
            ),
            creation_date=pull.created_at,
            is_completed=state_map[pull.state],
            list="GithubPRs",
            url=pull.html_url,
            tags=["review-assigned"] + fullname.split("/"),
        )
        todos.append(todo)

    return todos


def main() -> None:
    with sqlite_execute(commit=True) as cur:
        cur.execute(
            """
            CREATE TABLE IF NOT EXISTS sync_keys (
                id         INTEGER PRIMARY KEY,
                key        TEXT UNIQUE,
                notes_hash TEXT,
                summarized TEXT,
                tracking   BOOLEAN
            );
        """
        )

    with sqlite_execute(commit=True) as cur:
        cur.execute(
            "SELECT key, notes_hash, summarized FROM sync_keys WHERE tracking = 1"
        )
        tracking_keys: dict[str, tuple[str, str]] = {}
        for row in cur.fetchall():
            key = row[0]
            notes_hash = row[1]
            summarized = row[2]
            print(f"Found tracking key: {key} with hash {notes_hash}")
            decoded_key = base64.b64decode(key).decode()
            tracking_keys[decoded_key] = (notes_hash, summarized)

    todos = get_github_todos(tracking_keys)

    for todo in todos:
        todo.add_to_taskwarrior()

        with sqlite_execute(commit=True) as cur:
            cur.execute(
                (
                    "INSERT INTO sync_keys (key, notes_hash, summarized, tracking) VALUES (?, ?, ?, 1) "
                    "ON CONFLICT(key) DO UPDATE SET "
                    "notes_hash = excluded.notes_hash, "
                    "summarized = excluded.summarized, "
                    "tracking = ?;"
                ),
                (
                    todo.key,
                    get_text_hash(todo.original_notes),
                    todo.summarized_notes,
                    int(not todo.is_completed),
                ),
            )


if __name__ == "__main__":
    main()
