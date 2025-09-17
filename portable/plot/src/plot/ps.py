import sys

import psutil


def get_connected_cmd() -> str:
    # Find current process
    current_process = psutil.Process()
    # Get the command line arguments of the current process
    cmdline = current_process.cmdline()

    print(f"Current command line: {cmdline}", file=sys.stderr)


    parent = current_process.parent()
    print(f"Parent process: {parent}", file=sys.stderr)

