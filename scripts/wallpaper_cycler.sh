#!/bin/bash

# Default values
sleep_time=60
wallpaper_path="/usr/share/backgrounds"
valid_extensions=("jpg" "png" "bmp" "jpeg" "gif" "svg")

# Function to echo based on verbosity level
log() {
    local level="$1"
    local message="$2"
    
    if [[ "$level" == "ERROR" ]]; then
        echo "$message"
    else
        case "$verbosity" in
            "DEBUG")
                if [[ "$level" == "ERROR" || "$level" == "DEBUG" ]]; then
                    echo "$message"
                fi
                ;;
            "TRACE")
                if [[ "$level" == "ERROR" || "$level" == "DEBUG" || "$level" == "TRACE" ]]; then
                    echo "$message"
                fi
                ;;
        esac  
    fi
}

# Parse command-line options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -s|--sleep)
            # Check if the next argument exists and is a positive integer
            if [[ -n $2 && $2 =~ ^[0-9]+$ ]]; then
                sleep_time=$2
                shift 2
            else
                log "ERROR" "Invalid sleep time specified."
                exit 1
            fi
            ;;
        -p|--path)
            # Check if the next argument exists and is a directory
            if [[ -n $2 && -d $2 ]]; then
                wallpaper_path="$2"
                shift 2
            else
                log "ERROR" "Invalid wallpaper path specified."
                exit 1
            fi
            ;;
        -v|--verbosity)
            # Check if the next argument is a valid verbosity level
            case "$2" in
                ERROR|DEBUG|TRACE)
                    verbosity="$2"
                    shift 2
                    ;;
                *)
                    log "ERROR" "Invalid verbosity level specified: $2"
                    exit 1
                    ;;
            esac
            ;;
        *)
            # Treat any other argument as an unknown option
            log "ERROR" "Unknown option $1"
            exit 1
            ;;
    esac
done

log "DEBUG" "Script started with verbosity: $verbosity"

# Generate a list of all wallpaper file paths
all_wallpaper_files=($(find "$wallpaper_path" -type f))

# Filter the list to include only files with valid extensions
wallpaper_files=()
for file in "${all_wallpaper_files[@]}"; do
    for ext in "${valid_extensions[@]}"; do
        if [[ "${file,,}" == *".$ext" ]]; then
            wallpaper_files+=("$file")
            break
        fi
    done
done

log "DEBUG" "Valid images found: ${wallpaper_files[*]}"

# Get a list of connected displays
connected_displays=($(xrandr | grep " connected" | awk '{print $1}'))

while true; do
    # Shuffle the list of wallpaper file paths
    shuffled_wallpapers=($(shuf -e "${wallpaper_files[@]}"))

    # Build the feh command with wallpaper file paths for the first N connected displays
    feh_command="feh --bg-fill"
    i=0
    j=0
    for ((i = 0; i < ${#connected_displays[@]}; i++, j++)); do
        if [ -e "${shuffled_wallpapers[j]}" ]; then
            feh_command+=" '${shuffled_wallpapers[j]}'"
        else
            log "DEBUG" "file ${shuffled_wallpapers[j]} has been removed or relocated, trying to use a different file"
            sleep 1
            ((i--))  # Decrease i to select another image for this display
        fi
    done

    # Check if all files for connected displays exist before executing the feh command
    if [ "$i" -eq ${#connected_displays[@]} ]; then
        # Execute the feh command and check its exit status
        if eval "$feh_command"; then
            log "TRACE" "executed --> $feh_command"
        else
            log "ERROR" "Failed to set wallpaper with feh. Command: $feh_command"
        fi
    else
        log "DEBUG" "Some images have been removed at the last second, skipping this try..."
    fi

    # Sleep for the specified time
    sleep "$sleep_time"
done

