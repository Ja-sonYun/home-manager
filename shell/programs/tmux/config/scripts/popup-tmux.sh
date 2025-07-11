#!/bin/bash

session_name=$(tmux display-message -p -F \"#{session_name}\")

if [ "$session_name" = "\"popup\"" ]; then
    IS_DEFAULT_ATTACHED=$(tmux ls | grep 'default')
    if [[ "$IS_DEFAULT_ATTACHED" == *"(attached)"* ]]; then
        tmux detach-client
    else
        tmux switch-client -t default
    fi
else
    if [ "$1" = "top" ]; then
        tmux popup -w75% -h70% -E "tmux attach -t popup || tmux new -s popup" || true
    elif [ "$1" = "bottom" ]; then
        tmux popup -w75% -h70% -E "tmux attach -t popup || tmux new -s popup" || true
    fi
fi
