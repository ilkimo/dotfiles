#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    read -p "Enter session name: " selected
fi

if [[ -z $selected ]]; then
    exit 0
fi

tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s $selected
    exit 0
fi

if ! tmux has-session -t=$selected 2> /dev/null; then
    tmux new-session -ds $selected 'nvim -c "terminal"'
fi

tmux switch-client -t $selected
