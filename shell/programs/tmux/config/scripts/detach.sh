#!/usr/bin/env bash

# If current session is default or popup, do nothing. otherwise, detach
session_name=$(tmux display-message -p '#S')
if [[ "$session_name" == "default" || "$session_name" == "popup" ]]; then
    exit 0
fi

tmux detach
