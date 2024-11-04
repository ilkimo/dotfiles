#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(kubectl config get-contexts -o name | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

kubectl config use-context $selected
