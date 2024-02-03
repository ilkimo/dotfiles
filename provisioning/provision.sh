#!/bin/bash

# Set PROJECT_PATH based on whether the script is running under Vagrant
if [ "$VAGRANT_TEST" = "true" ]; then
    PROJECT_PATH="/vagrant"
    USER="vagrant"
else
    # Get the directory where the script is located
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
    # Get the parent directory of where the script is located
    PROJECT_PATH="$(dirname "$SCRIPT_DIR")"

    # Check if the .env file exists and source it
    if [ -f "$PROJECT_PATH/secrets/.env" ]; then
        echo "Loading environment variables from .env file..."
        set -o allexport
        source "$PROJECT_PATH/secrets/.env"
        set +o allexport
    else
        echo "No .env file found in secrets directory, using default values"
        # Set default values or exit if necessary
        USER="default_user"
    fi
fi
echo "User is set to $USER"
echo "Project_path is set to $PROJECT_PATH"

echo "Sourcing library script with functions"
source "${PROJECT_PATH}/provisioning/lib/packages-installer.sh"

echo "Updating the system"
update_system

install_packages git base-devel go go-yq

# Check if yay is already installed
if ! command -v yay &> /dev/null; then
    echo "yay not found, installing yay..."

    # Cloning yay repository
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay

    # Building and installing yay
    makepkg -si --noconfirm

    cd -  # Returning to the original directory
else
    echo "yay is already installed."
fi
echo "yay package is located at $(which yay)"

echo "Installing other packages"
install_packages sl cmatrix cowsay lolcat fastfetch xorg-server nvidia nvidia-utils nvidia-settings xorg-xrandr arandr xorg-xcalc vim neovim kitty ranger zathura feh tree lightdm lightdm-slick-greeter i3-wm rofi pcmanfm xclip polybar docker docker-compose maim picom pavucontrol thunderbird bitwarden spotify-launcher telegram-desktop imagemagick code kubectl helm alsa-utils pulseaudio pulseaudio-alsa qjackctl intellij-idea-community-edition fluxcd perl-image-exiftool perl-anyevent-i3 terraform obsidian vagrant virtualbox
# TODO morc_menu bmenu
# imagemagick is for image generation (directory template_images)

echo "----------------------------------------"
echo "---------- Installing modules ----------"
echo "----------------------------------------"
install_modules "${PROJECT_PATH}/modules-to-provision.yaml" "${PROJECT_PATH}/modules"
echo "----------------------------------------"
echo "---------- Modules installed ----------"
echo "----------------------------------------"

echo "Installation complete!"
