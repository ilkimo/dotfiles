#!/bin/bash

# Function to update system packages using the detected package manager
update_system() {
    echo "Updating system packages..."
    if command -v pacman >/dev/null; then
        # If yay is installed, use it for updating to include AUR packages
        if command -v yay >/dev/null; then
            echo "Updating system packages and AUR packages with yay..."
            yay -Syu --noconfirm || return 1
        else
            echo "Updating system packages with pacman..."
            sudo pacman -Syu --noconfirm || return 1
        fi
    elif command -v apt-get >/dev/null; then
        echo "Updating system packages with apt-get..."
        sudo apt-get update && sudo apt-get upgrade -y || return 1
    else
        echo "Package manager not supported for updates."
        return 1
    fi
    echo "System update complete."
}

# Function to install multiple packages using the detected package manager
install_packages() {
    echo "Detecting package manager..."
    if command -v pacman >/dev/null; then
        PACKAGE_MANAGER="pacman"
        echo "Detected pacman as package manager."
    elif command -v apt-get >/dev/null; then
        PACKAGE_MANAGER="apt"
        echo "Detected apt as package manager."
    # Add detection for other package managers here
    else
        echo "Package manager not supported."
        return 1
    fi

    local packages=("$@")  # Array of packages
    echo "Preparing to install packages: ${packages[*]}"

    case $PACKAGE_MANAGER in
        pacman)
            echo "Checking for packages in the official repositories and AUR..."
            local official_packages=()  # Packages found in official repos
            local aur_packages=()       # Packages likely from AUR

            # Determine whether each package is in the official repos or the AUR
            for package in "${packages[@]}"; do
                if pacman -Si $package &>/dev/null; then
                    official_packages+=("$package")
                else
                    aur_packages+=("$package")
                fi
            done

            # Install packages from the official repositories
            if [ ${#official_packages[@]} -gt 0 ]; then
                echo "Installing official repository packages: ${official_packages[*]}"
                sudo pacman -S --noconfirm --needed "${official_packages[@]}" || return 1
            fi

            # Install AUR packages, assuming `yay` is available
            if [ ${#aur_packages[@]} -gt 0 ]; then
                if command -v yay >/dev/null; then
                    echo "Installing AUR packages: ${aur_packages[*]}"
                    yay -S --noconfirm --needed "${aur_packages[@]}" || return 1
                else
                    echo "yay is not installed. Please install yay to proceed with AUR packages."
                    return 1
                fi
            fi
            ;;
        apt)
            echo "Installing packages with apt-get: ${packages[*]}"
            sudo apt-get update && sudo apt-get install -y "${packages[@]}" || return 1
            ;;
        # Handle other package managers here
    esac
    echo "Package installation complete."
}

# Function to clone and install from a Git repository
install_from_git() {
    local repo_url=$1
    local module_name=$2
    local modules_dir=$3
    local modules_git_clone_path=$4

    # Correctly build the path to the module directory
    local module_path="$modules_dir/$module_name"
    
    echo "Checking if $modules_git_clone_path already exists..."
    if [ -d "$modules_git_clone_path" ]; then
        echo "$modules_git_clone_path already exists. Skipping cloning."
        return 0  # Exit successfully if the directory already exists
    fi

    # If the directory does not exist, proceed with cloning
    echo "Creating directory $modules_dir"
    mkdir -p "$modules_dir"
    echo "Cloning repository $repo_url into $modules_git_clone_path"
    
    if git clone "$repo_url" "$modules_git_clone_path"; then
        echo "Repository cloned successfully."
        local install_script_path="$module_path/install.sh"
        if [[ -f "$install_script_path" ]]; then
            echo "Found install script. Executing..."
            chmod +x "$install_script_path"
            (cd "$module_path" && ./install.sh "$modules_git_clone_path")
            return $?
        else
            echo "No install.sh found in $repo_url. Installation cannot proceed."
            return 1
        fi
    else
        echo "Failed to clone $repo_url into $modules_git_clone_path."
        return 1
    fi
}

# Main function to parse the YAML file and install modules
install_modules() {
    local yaml_file=$1  # Path to the modules-to-provision.yaml file
    local modules_dir=$2  # Base directory for modules
    local modules_installation_dir=$3 # Base directory for git clone operation

    # Ensure the yaml_file path is absolute or correctly relative to the current script
    if [[ ! -f "$yaml_file" ]]; then
        echo "YAML file $yaml_file not found."
        return 1
    fi

    # Read the number of modules
    local modules_count=$(yq e '.modules | length' "$yaml_file")

    for ((i=0; i<modules_count; i++)); do
        local base_path=".modules[$i]"
        local name=$(yq e "$base_path.name" "$yaml_file")
        local sources_count=$(yq e "$base_path.alternative_sources | length" "$yaml_file")

        echo "Processing module: $name"

        for ((j=0; j<sources_count; j++)); do
            local source=$(yq e "$base_path.alternative_sources[$j]" "$yaml_file")

            echo "Trying source: $source for module: $name"

            if [[ "$source" == "package_repository" ]]; then
                if install_packages "$name"; then
                    echo "Successfully installed $name from package repository"
                    break
                else
                    echo "Failed to install $name from package repository"
                fi
            else
                echo "Starting git repository installation for source $source"
                if install_from_git "$source" "$name" "$modules_dir" "$modules_installation_dir"; then
                    echo "Successfully installed $name from $source"
                    break
                else
                    echo "Failed to install $name from $source"
                fi
            fi
        done
    done
}

