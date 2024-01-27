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

update_system()
