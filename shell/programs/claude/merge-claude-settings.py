import json
import sys
from pathlib import Path
from typing import Any


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text()) if path.exists() else {}


def merge_lists(a: list[Any], b: list[Any]) -> list[Any]:
    result = list(a)
    for item in b:
        if item not in result:
            result.append(item)
    return result


def merge_dicts(
    base: dict[str, Any],
    overlay: dict[str, Any],
) -> dict[str, Any]:
    result = dict(base)
    for k, v in overlay.items():
        if k in result:
            if isinstance(result[k], dict) and isinstance(v, dict):
                result[k] = merge_dicts(result[k], v)
            elif isinstance(result[k], list) and isinstance(v, list):
                result[k] = merge_lists(result[k], v)
            else:
                result[k] = v
        else:
            result[k] = v
    return result


def remove_deleted(
    settings: dict[str, Any],
    prev: dict[str, Any],
    current: dict[str, Any],
) -> dict[str, Any]:
    result = dict(settings)
    for k in list(result.keys()):
        if k in prev and k not in current:
            del result[k]
        elif k in prev and k in current:
            if isinstance(prev[k], dict) and isinstance(current[k], dict):
                if isinstance(result.get(k), dict):
                    result[k] = remove_deleted(result[k], prev[k], current[k])
            elif isinstance(prev[k], list) and isinstance(current[k], list):
                if isinstance(result.get(k), list):
                    # filter out items that were in prev but not in current
                    result[k] = [x for x in result[k] if x not in prev[k] or x in current[k]]
    return result


if __name__ == "__main__":
    settings_path = Path(sys.argv[1])  # ~/.claude/settings.json
    managed_path = Path(sys.argv[2])  # nix store file (current nix settings)
    prev_path = Path(sys.argv[3])  # ~/.claude/settings.nix.json

    settings = load_json(settings_path)
    managed = load_json(managed_path)  # read from nix store file
    prev = load_json(prev_path)  # read-only (home.file updates after writeBoundary)

    settings = remove_deleted(settings, prev, managed)
    settings = merge_dicts(settings, managed)

    settings_path.parent.mkdir(parents=True, exist_ok=True)
    settings_path.write_text(json.dumps(settings, indent=2))
