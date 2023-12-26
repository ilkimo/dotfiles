#!/bin/bash

# Default values
sleep_time=60
wallpaper_path="/usr/share/backgrounds"
valid_extensions=("jpg" "png" "bmp" "jpeg" "gif" "svg")
verbosity="ERROR" # Default verbosity level
truncate_under=0  # Default truncate under threshold

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
            if [[ -n $2 && $2 =~ ^[0-9]+$ ]]; then
                sleep_time=$2
                shift 2
            else
                log "ERROR" "Invalid sleep time specified."
                exit 1
            fi
            ;;
        -p|--path)
            if [[ -n $2 && -d $2 ]]; then
                wallpaper_path="$2"
                shift 2
            else
                log "ERROR" "Invalid wallpaper path specified."
                exit 1
            fi
            ;;
        -v|--verbosity)
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
        -t|--truncate-under)
            if [[ -n $2 && $2 =~ ^[0-9]+$ ]]; then
                truncate_under=$2
                shift 2
            else
                log "ERROR" "Invalid truncate under value specified."
                exit 1
            fi
            ;;
        *)
            log "ERROR" "Unknown option $1"
            exit 1
            ;;
    esac
done


log "DEBUG" "-----------------------------------------------------------------------------------"
log "DEBUG" "Script started with verbosity: $verbosity"
log "DEBUG" "Keeping only images with Rating metadata above $truncate_under"
log "DEBUG" "-----------------------------------------------------------------------------------"

# Get the directory of the current script
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
# Call ranker.sh to get the sorted and truncated list of wallpapers
wallpaper_files=($("$script_dir/ranker.sh" -p "$wallpaper_path" -o desc -t "$truncate_under"))

log "DEBUG" "${#wallpaper_files[@]} files have been selected:"
for item in "${wallpaper_files[@]}"; do
    # Split the item into rating and file path
    rating=${item%%_*}
    file=${item#*_}

    truncated_file_path="${file#$wallpaper_path/}"
    log "DEBUG" "Rating=$rating --> File=$truncated_file_path"
done

log "DEBUG" "-----------------------------------------------------------------------------------"

while true; do
    # Shuffle the list of wallpaper file paths
    shuffled_wallpapers=($(shuf -e "${wallpaper_files[@]}"))

    # Build the feh command with wallpaper file paths for the first N connected displays
    feh_command="feh"
    for display in $(xrandr | grep " connected" | awk '{print $1}'); do
        if [ -n "${shuffled_wallpapers[0]}" ]; then
            # Strip out the NUM_ prefix and then add the path to the feh_command
            path_without_num_prefix=${shuffled_wallpapers[0]#*_}
            feh_command+=" --bg-fill '${path_without_num_prefix}'"
            shuffled_wallpapers=("${shuffled_wallpapers[@]:1}")
        fi
    done

    # Execute the feh command and check its exit status
    if eval "$feh_command"; then
        log "TRACE" "executed --> $feh_command"
    else
        log "ERROR" "Failed to set wallpaper with feh. Command: $feh_command"
    fi

    # Sleep for the specified time
    sleep "$sleep_time"
done

