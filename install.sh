#!/bin/bash

# THIS SCRIPT ASSUMES THAT THE REPOSITORY IS CLONED AT PATH ~/repos/

# i3
mkdir -p ~/.config/i3
rm -f ~/.config/i3/config
ln -s ~/repos/dotfiles/i3/config_qwerty ~/.config/i3/config

# picom
mkdir -p ~/.config/picom
rm -f ~/.config/picom/picom.conf
ln -s ~/repos/dotfiles/picom/picom.conf ~/.config/picom/picom.conf


