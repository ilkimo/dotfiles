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
install_packages sl cmatrix cowsay lolcat fastfetch xorg-server nvidia nvidia-utils nvidia-settings xorg-xrandr arandr xorg-xcalc vim neovim kitty ranger zathura feh tree lightdm lightdm-slick-greeter i3-wm rofi pcmanfm xclip polybar docker docker-compose maim picom pavucontrol thunderbird bitwarden spotify-launcher telegram-desktop imagemagick code kubectl kubeseal helm alsa-utils pulseaudio pulseaudio-alsa qjackctl intellij-idea-community-edition fluxcd perl-image-exiftool perl-anyevent-i3 terraform obsidian vagrant virtualbox noto-fonts-emoji ttf-icomoon-feather-git zoxide fzf cheese velero kustomize kubeconform subsurface bat istio zsh snixembed safeeyes
# TODO morc_menu bmenu
# imagemagick is for image generation (directory template_images)
# ttf-icomoon-feather-git is for the polybar symbols

echo "----------------------------------------"
echo "---------- Installing modules ----------"
echo "----------------------------------------"
install_modules "${PROJECT_PATH}/modules-to-provision.yaml" "${PROJECT_PATH}/modules" "~/repos/provisioned_modules"
echo "----------------------------------------"
echo "---------- Modules installed ----------"
echo "----------------------------------------"

echo "Add slick-greeter configuration"
sudo cp "$PROJECT_PATH/display-manager/slick-greeter.conf" /etc/lightdm/slick-greeter.conf

# Path to the lightdm.conf file
LIGHTDM_CONF="/etc/lightdm/lightdm.conf"
# Use sed to uncomment and set the greeter-session and user-session
sudo sed -i 's/^#greeter-session=.*/greeter-session=lightdm-slick-greeter/' $LIGHTDM_CONF
sudo sed -i 's/^#user-session=.*/user-session=i3/' $LIGHTDM_CONF

echo "Updated lightdm.conf:"
grep "greeter-session\|user-session" $LIGHTDM_CONF

echo "Enabling Display Manager lightdm-slick-greeter"
sudo systemctl enable lightdm

# Create user directory
# Check if $USER is set
if [ -z "$USER" ]; then
    echo "The \$USER variable is not set."
    exit 1
fi

# Define the user's home directory
USER_HOME="/home/$USER"

# Check if the directory exists
echo "Checking if $USER_HOME directory exists"
if [ ! -d "$USER_HOME" ]; then
    echo "Directory $USER_HOME does not exist. Creating it..."

    # Attempt to create the directory with sudo
    sudo mkdir "$USER_HOME"
    # Change the ownership of the directory to the user
    sudo chown "$USER:$USER" "$USER_HOME"
    # Set the appropriate permissions for the home directory
    sudo chmod 700 "$USER_HOME"

    # Check if the operations were successful
    if [ -d "$USER_HOME" ] && [ "$(stat -c '%U' "$USER_HOME")" = "$USER" ]; then
        echo "Directory $USER_HOME created and configured successfully."
    else
        echo "Failed to properly create and configure $USER_HOME."
        exit 1
    fi
else
    echo "Directory $USER_HOME already exists."
fi

# Handle wallpaper and lock-screen
mkdir -p ~/Pictures/wallpapers
mkdir -p ~/Pictures/lock-screens
sudo cp $PROJECT_PATH/template_images/7680x1440/wallpaper ~/Pictures/wallpapers/wallpaper-7680x1440
sudo cp $PROJECT_PATH/template_images/7680x1440/lock-screen ~/Pictures/lock-screens/lock-screen-7680x1440
sudo cp $PROJECT_PATH/template_images/2560x1440/wallpaper ~/Pictures/wallpapers/wallpaper-2560x1440
sudo cp $PROJECT_PATH/template_images/2560x1440/lock-screen ~/Pictures/lock-screens/lock-screen-2560x1440
sudo cp $PROJECT_PATH/template_images/1920x1080/wallpaper ~/Pictures/wallpapers/wallpaper-1920x1080
sudo cp $PROJECT_PATH/template_images/1920x1080/lock-screen ~/Pictures/lock-screens/lock-screen-1920x1080

# Setup i3 symlinks
echo "Creating symlinks for i3 personal dotfiles stored in $PROJECT_PATH/i3"
mkdir -p "$USER_HOME/.config/i3"
touch "$USER_HOME/.config/i3/dynamic_bindsym.conf"
ln -sf $PROJECT_PATH/i3/config_colemak-dhm-ansi ~/.config/i3/config
ln -sf $PROJECT_PATH/i3/dynamic_bindsym.sh ~/.config/i3/dynamic_bindsym.sh
ln -sf $PROJECT_PATH/i3/set-wallpaper.sh ~/.config/i3/set-wallpaper.sh
ln -sf $PROJECT_PATH/i3/set-lock-screen.sh ~/.config/i3/set-lock-screen.sh
sudo chown --recursive "$USER:$USER" ~/.config/i3

# Setup picom links
mkdir -p ~/.config/picom
ln -sf $PROJECT_PATH/picom/picom.conf ~/.config/picom/picom.conf
sudo chown --recursive "$USER:$USER" ~/.config/picom

if [ "$VAGRANT_TEST" = "true" ]; then
    echo "Setting picom backend to xrender for VM compatibility"

    # Use $HOME instead of ~ for reliable path expansion
    PICOM_CONF_PATH="$USER_HOME/.config/picom/picom.conf"

    # Use sed to change the backend line to xrender
    sed -i 's/^backend\s*=.*/backend = "xrender"/' "$PICOM_CONF_PATH"
    echo "done --> $(cat $PICOM_CONF_PATH | grep 'backend = ')"
fi

# Setup kitty links
mkdir -p ~/.config/kitty
ln -sf $PROJECT_PATH/kitty/kitty.conf ~/.config/kitty/kitty.conf
ln -sf $PROJECT_PATH/kitty/current-theme.conf ~/.config/kitty/current-theme.conf
ln -sf $PROJECT_PATH/kitty/kitty_teaching.conf ~/.config/kitty/kitty_teaching.conf
sudo chown --recursive "$USER:$USER" ~/.config/kitty

# Setup Neovim links
# In Vagrant this won't work, I think that this is because of the presence of .gitignored files from the host system (and probably cache files that tell neovim that everything is updated or something like that). To make it work on Vagrant, clone the repo directly instead of linking it like this.
ln -sf $PROJECT_PATH/kickstart.nvim ~/.config/nvim

# Set ~/.bash_aliases if ./secrets/.bash_aliases exists
if [ -e "$PROJECT_PATH/secrets/.bash_aliases" ]; then
    if [ -L "$USER_HOME/.bash_aliases" ] || [ -e "$USER_HOME/.bash_aliases" ]; then
        echo "Symlink or file already exists at $USER_HOME/.bash_aliases. Please remove it first."
    else
        ln -sf "$PROJECT_PATH/secrets/.bash_aliases" "$USER_HOME/.bash_aliases"
        echo "Symlink created: $USER_HOME/.bash_aliases -> $PROJECT_PATH/secrets/.bash_aliases"
    fi
else
    echo "Target file ./secrets/.bash_aliases does not exist, could not link ~/.bash_aliases"
fi

# Set ~/.bashrc and bash customization
ln -sf "$PROJECT_PATH/secrets/.bashrc" "$USER_HOME/.bashrc"
ln -sf "$PROJECT_PATH/bash/bash_customizations" "$USER_HOME/.bash_customizations"

# Set font
sudo mkdir -p /usr/share/fonts/TTF
sudo ln -s "$PROJECT_PATH/fonts/FiraCodeNerdFont-Bold.ttf" /usr/share/fonts/TTF/FiraCodeNerdFont-Bold.ttf
sudo ln -s "$PROJECT_PATH/fonts/FiraCodeNerdFont-Light.ttf" /usr/share/fonts/TTF/FiraCodeNerdFont-Light.ttf
sudo ln -s "$PROJECT_PATH/fonts/FiraCodeNerdFont-Medium.ttf" /usr/share/fonts/TTF/FiraCodeNerdFont-Medium.ttf
sudo ln -s "$PROJECT_PATH/fonts/FiraCodeNerdFontMono-Bold.ttf" /usr/share/fonts/TTF/FiraCodeNerdFontMono-Bold.ttf
sudo ln -s "$PROJECT_PATH/fonts/FiraCodeNerdFontMono-Light.ttf" /usr/share/fonts/TTF/FiraCodeNerdFontMono-Light.ttf
sudo ln -s "$PROJECT_PATH/fonts/FiraCodeNerdFontMono-Medium.ttf" /usr/share/fonts/TTF/FiraCodeNerdFontMono-Medium.ttf
sudo ln -s "$PROJECT_PATH/fonts/FiraCodeNerdFontMono-Regular.ttf" /usr/share/fonts/TTF/FiraCodeNerdFontMono-Regular.ttf
sudo ln -s "$PROJECT_PATH/fonts/FiraCodeNerdFontMono-Retina.ttf" /usr/share/fonts/TTF/FiraCodeNerdFontMono-Retina.ttf
sudo ln -s "$PROJECT_PATH/fonts/FiraCodeNerdFontMono-SemiBold.ttf" /usr/share/fonts/TTF/FiraCodeNerdFontMono-SemiBold.ttf
sudo ln -s "$PROJECT_PATH/fonts/FiraCodeNerdFontPropo-Bold.ttf" /usr/share/fonts/TTF/FiraCodeNerdFontPropo-Bold.ttf
sudo ln -s "$PROJECT_PATH/fonts/FiraCodeNerdFontPropo-Light.ttf" /usr/share/fonts/TTF/FiraCodeNerdFontPropo-Light.ttf
sudo ln -s "$PROJECT_PATH/fonts/FiraCodeNerdFontPropo-Medium.ttf" /usr/share/fonts/TTF/FiraCodeNerdFontPropo-Medium.ttf
sudo ln -s "$PROJECT_PATH/fonts/FiraCodeNerdFontPropo-Regular.ttf" /usr/share/fonts/TTF/FiraCodeNerdFontPropo-Regular.ttf
sudo ln -s "$PROJECT_PATH/fonts/FiraCodeNerdFontPropo-Retina.ttf" /usr/share/fonts/TTF/FiraCodeNerdFontPropo-Retina.ttf
sudo ln -s "$PROJECT_PATH/fonts/FiraCodeNerdFontPropo-SemiBold.ttf" /usr/share/fonts/TTF/FiraCodeNerdFontPropo-SemiBold.ttf
sudo ln -s "$PROJECT_PATH/fonts/FiraCodeNerdFont-Regular.ttf" /usr/share/fonts/TTF/FiraCodeNerdFont-Regular.ttf
sudo ln -s "$PROJECT_PATH/fonts/FiraCodeNerdFont-Retina.ttf" /usr/share/fonts/TTF/FiraCodeNerdFont-Retina.ttf
sudo ln -s "$PROJECT_PATH/fonts/FiraCodeNerdFont-SemiBold.ttf" /usr/share/fonts/TTF/FiraCodeNerdFont-SemiBold.ttf

# Install Polybar
ln -s "$PROJECT_PATH/polybar/polybar-themes/simple" "$USER_HOME/.config/polybar"

# Set default applications
sudo -u $USER xdg-mime default google-chrome.desktop x-scheme-handler/http
sudo -u $USER xdg-mime default google-chrome.desktop x-scheme-handler/http

# Add user to the Docker group
sudo usermod -aG docker $USER

echo "Starting Display Manager lightdm"
sudo systemctl start lightdm

# Enable and start pulse audio service
systemctl --user enable pulseaudio.service
systemctl --user start pulseaudio.service


echo "Installation complete!"
