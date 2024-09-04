#!/usr/bin/env bash
# The idea of this script is to open a new fuzzy finder window from a tmux session, where all the open tmux session are listed. When selecting one, tmux session get's switched to the selected one.

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(tmux ls | fzf | cut -d':' -f1)
fi

if [[ -z $selected ]]; then
    exit 0
fi


tmux switch-client -t $selected
