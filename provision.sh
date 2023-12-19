#!/bin/bash

# Function to update the system using the detected package manager
update_system() {
    echo "Updating the system..."

    case $PACKAGE_MANAGER in
        pacman)
            sudo pacman -Syu --noconfirm || {
                echo "Failed to update the system"
                exit 1
            }
            ;;
        apt)
            sudo apt-get update && sudo apt-get upgrade -y || {
                echo "Failed to update the system"
                exit 1
            }
            ;;
        # Add other package manager update commands here
    esac
}

# Function to install a package using the detected package manager
install_package() {
    local package=$1
    echo "Installing package: $package"

    case $PACKAGE_MANAGER in
        pacman)
            sudo pacman -S --noconfirm $package || {
                echo "Failed to install $package"
                exit 1
            }
            ;;
        apt)
            sudo apt-get install -y $package || {
                echo "Failed to install $package"
                exit 1
            }
            ;;
        # Add other package manager cases here
    esac
}

# Function to install multiple packages using the detected package manager
install_packages() {
    local packages=("$@")  # Array of packages
    echo "Installing packages: ${packages[*]}"

    case $PACKAGE_MANAGER in
        pacman)
            local official_packages=()  # Packages found in official repos
            local aur_packages=()       # Packages likely from AUR

            # Check each package if it's in the official repos or AUR
            for package in "${packages[@]}"; do
                if pacman -Si $package &> /dev/null; then
                    official_packages+=("$package")
                else
                    aur_packages+=("$package")
                fi
            done

            # Install found packages with pacman
            if [ ${#official_packages[@]} -ne 0 ]; then
		echo "Installing the sequent packages with pacman: ${official_packages[*]}"
        	sudo pacman -S --noconfirm --needed "${official_packages[@]}" || {
                    echo "Failed to install official repo packages: ${official_packages[*]}"
                    exit 1
                }
            fi

            # Install AUR packages with yay
            if [ ${#aur_packages[@]} -ne 0 ]; then
		echo "Installing the sequent packages with yay: ${aur_packages[*]}"
                yay -S --noconfirm --needed --useask "${aur_packages[@]}" || {
                    echo "Failed to install AUR packages: ${aur_packages[*]}"
                    exit 1
                }
            fi
            ;;
        apt)
            sudo apt-get install -y "${packages[@]}" || {
                echo "Failed to install packages: ${packages[*]}"
                exit 1
            }
            ;;
        # Add other package manager cases here
    esac
}

# START SCRIPT -----------------------------------------------------------------------------
# Set PROJECT_PATH based on whether the script is running under Vagrant
if [ "$VAGRANT_TEST" = "true" ]; then
    PROJECT_PATH="/vagrant"
    USER="vagrant"
else
    PROJECT_PATH="$(pwd)"
    # Check if the .env file exists and source it
    if [ -f "./secrets/.env" ]; then
        echo "Loading environment variables from .env file..."
        set -o allexport
        source "./secrets/.env"
        set +o allexport
    else
        echo "No .env file found in secrets directory, using default values"
        # Set default values or exit if necessary
        USER="default_user"
    fi
fi
echo "User is set to $USER"
echo "Project_path is set to $PROJECT_PATH"

# Detect the package manager
echo "Detecting package manager"
if command -v pacman >/dev/null 2>&1; then
    PACKAGE_MANAGER="pacman"
    echo "Detected pacman as package manager"
elif command -v apt-get >/dev/null 2>&1; then
    PACKAGE_MANAGER="apt"
    echo "Detected apt as package manager"
# Add other package managers here
else
    echo "Package manager not supported"
    exit 1
fi

echo "Updating the system"
update_system

install_packages git base-devel go

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
install_packages sl cmatrix cowsay lolcat cava fastfetch pipes.sh xorg-server nvidia nvidia-utils nvidia-settings xorg-xrandr xorg-xcalc vim neovim kitty ranger zathura feh tree lightdm lightdm-slick-greeter i3-wm rofi pcmanfm pywal xclip polybar docker docker-compose maim picom pavucontrol thunderbird bitwarden spotify-launcher telegram-desktop google-chrome imagemagick openlens-bin gitkraken code kubectl alsa-utils pulseaudio pulseaudio-alsa qjackctl intellij-idea-community-edition clion
# TODO morc_menu bmenu
# imagemagick is for image generation (directory template_images)

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
mkdir -p ~/.config/i3
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
ln -sf $PROJECT_PATH/kickstart.nvim/init-qwerty.lua ~/.config/nvim/init.lua

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
