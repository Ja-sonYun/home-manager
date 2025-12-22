import json
import os
import shutil
import stat
import sys
import tarfile
from pathlib import Path


def load_manifest(path: Path) -> set[str]:
    if path.exists():
        return set(json.loads(path.read_text()))
    return set()


def save_manifest(path: Path, files: set[str]) -> None:
    if path.exists():
        path.chmod(path.stat().st_mode | stat.S_IWUSR)
    path.write_text(json.dumps(sorted(files), indent=2))


def get_tar_entries(archive_path: Path) -> set[str]:
    entries = set()
    with tarfile.open(archive_path, "r") as tar:
        for member in tar.getnames():
            normalized = member.lstrip("./")
            if normalized:
                entries.add(normalized)
    return entries


def get_top_level_dirs(entries: set[str]) -> set[str]:
    dirs = set()
    for entry in entries:
        parts = entry.split("/")
        if len(parts) >= 1 and parts[0]:
            dirs.add(parts[0])
    return dirs


def make_files_readonly(path: Path) -> None:
    if path.is_dir():
        for root, _, files in os.walk(path):
            for f in files:
                p = Path(root) / f
                p.chmod(p.stat().st_mode & ~stat.S_IWUSR & ~stat.S_IWGRP & ~stat.S_IWOTH)
    elif path.is_file():
        path.chmod(path.stat().st_mode & ~stat.S_IWUSR & ~stat.S_IWGRP & ~stat.S_IWOTH)


def make_files_writable(path: Path) -> None:
    if path.is_dir():
        for root, _, files in os.walk(path):
            for f in files:
                p = Path(root) / f
                p.chmod(p.stat().st_mode | stat.S_IWUSR)
    elif path.is_file():
        path.chmod(path.stat().st_mode | stat.S_IWUSR)


def remove_path(path: Path) -> None:
    if not path.exists():
        return
    make_files_writable(path)
    if path.is_dir():
        shutil.rmtree(path)
    else:
        path.unlink()


if __name__ == "__main__":
    archive_path = Path(sys.argv[1])
    claude_dir = Path(sys.argv[2])
    manifest_path = claude_dir / "nix-managed.json"

    if not archive_path.exists():
        sys.exit(0)

    prev_entries = load_manifest(manifest_path)
    new_entries = get_tar_entries(archive_path)

    prev_dirs = get_top_level_dirs(prev_entries)
    new_dirs = get_top_level_dirs(new_entries)

    # make existing files writable for extraction
    for d in new_dirs:
        target = claude_dir / d
        if target.exists():
            make_files_writable(target)

    # remove dirs that were in prev but not in new
    for d in prev_dirs - new_dirs:
        remove_path(claude_dir / d)

    # remove files that were in prev but not in new
    for entry in prev_entries - new_entries:
        target = claude_dir / entry
        if target.is_file():
            target.unlink()

    # extract new archive
    with tarfile.open(archive_path, "r") as tar:
        tar.extractall(claude_dir, filter="data")

    # make files readonly (dirs stay writable)
    for d in new_dirs:
        target = claude_dir / d
        if target.exists():
            make_files_readonly(target)

    save_manifest(manifest_path, new_entries)
    manifest_path.chmod(manifest_path.stat().st_mode & ~stat.S_IWUSR & ~stat.S_IWGRP & ~stat.S_IWOTH)
