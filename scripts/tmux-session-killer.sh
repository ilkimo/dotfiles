#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(echo -e "all-sessions\n$(tmux ls | cut -d':' -f1)" | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

if [[ $selected == "all-sessions" ]]; then
    # Loop through each session and kill them
    for session_name in $(tmux ls | cut -d':' -f1); do
        tmux kill-session -t "$session_name"
    done
else
    # Kill the selected session
    tmux kill-session -t "$selected"
fi

