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

# Function to create symlinks
create_symlink() {
    local target_file=$1  # The actual file or directory to link to (target of the symlink)
    local symlink_name=$2  # The name of the symbolic link (link name)

    if [ -L "$symlink_name" ]; then
        echo "Removing existing symlink: $symlink_name"
        rm "$symlink_name"
    elif [ -e "$symlink_name" ]; then
        echo "Renaming existing file/directory: $symlink_name to ${symlink_name}.old"
        mv "$symlink_name" "${symlink_name}.old"
    fi

    echo "Creating symlink from $target_file to $symlink_name"
    ln -s "$(pwd)/$target_file" "$symlink_name"
}

# START SCRIPT -----------------------------------------------------------------------------

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

# TODO
#echo "Installing yay"
#install_package yay
#which yay

echo "Installing other packages"
install_packages sl cmatrix cowsay lolcat xorg-server nvidia nvidia-utils nvidia-settings xorg-xcalc kitty ranger zathura feh tree vim lightdm lightdm-slick-greeter i3-wm dmenu  polybar

sudo touch /etc/lightdm/slick-greeter.conf
echo "[Greeter]
background=/usr/share/backgrounds/sword-art-online
background-color=#2e3d44
draw-grid=false
#theme-name=Adapta-Nokto-Eta-Maia
#icon-theme-name=Papirus-Adapta-Nokto-Maia
#font-name='Noto Sans 11'
xft-antialias=true
xft-hintstyle=hintfull
enable-hidpi=auto
" > /etc/lightdm/slick-greeter.conf"

# Path to the lightdm.conf file
LIGHTDM_CONF="/etc/lightdm/lightdm.conf"

# Use sed to uncomment and set the greeter-session and user-session
sudo sed -i 's/^#greeter-session=.*/greeter-session=lightdm-slick-greeter/' $LIGHTDM_CONF
sudo sed -i 's/^#user-session=.*/user-session=i3/' $LIGHTDM_CONF

echo "Updated lightdm.conf:"
grep "greeter-session\|user-session" $LIGHTDM_CONF

echo "Enabling Display Manager lightdm-slick-greeter"
sudo systemctl enable lightdm
echo "Starting Display Manager lightdm"
sudo systemctl start lightdm

# TODO when yay works
# install_packages pywal














echo "Installation complete!"
