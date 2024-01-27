#!/bin/bash

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

