#!/bin/bash

# THIS SCRIPT ASSUMES THAT THE REPOSITORY IS CLONED AT PATH ~/repos/ RESULTING IN PATH ~/repos/dotfiles

# i3
mkdir -p ~/.config/i3
rm -f ~/.config/i3/config
ln -s ~/repos/dotfiles/i3/config_qwerty ~/.config/i3/config

# picom
mkdir -p ~/.config/picom
rm -f ~/.config/picom/picom.conf
ln -s ~/repos/dotfiles/picom/picom.conf ~/.config/picom/picom.conf

# polybar
mkdir -p ~/.config/polybar
#ln -s ~/repos/dotfiles/polybar/config.ini ~/.config/polybar/config.ini
#ln -s ~/repos/dotfiles/polybar/launch.sh ~/.config/polybar/launch.sh
sudo pacman -S calc rofi
yay -S pywal

# kitty
mv ~/.config/kitty ~/.config/kitty.old
mkdir -p ~/.config/kitty
ln -s ~/repos/dotfiles/kitty/kitty.conf ~/.config/kitty/kitty.conf
ln -s ~/repos/dotfiles/kitty/current-theme.conf ~/.config/kitty/current-theme.conf
