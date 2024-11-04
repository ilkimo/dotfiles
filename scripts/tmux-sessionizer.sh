#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find ~ ~/repos ~/repos/work ~/repos/work/bando_uni ~/repos/work/bando_uni/utility ~/repos/dotfiles ~/repos/projects ~/repos/projects/scuba_dive/ ~/repos/projects/life_management/ ~/repos/projects/games/minecraft ~/repos/projects/keyboards/ ~/kimo-data/all/projects ~/repos/work/ites/ ~/kimo-data/all/study -mindepth 1 -maxdepth 1 -type d | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s $selected_name -c $selected
    exit 0
fi

if ! tmux has-session -t=$selected_name 2> /dev/null; then
    tmux new-session -ds $selected_name -c $selected 'nvim -c "terminal"'
fi

tmux switch-client -t $selected_name
