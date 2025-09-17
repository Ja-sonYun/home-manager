import re


def remove_ansi(text: str) -> str:
    ansi_escape = re.compile(r"\x1B\[[0-?]*[ -/]*[@-~]")
    clean = ansi_escape.sub("", text)
    return clean
