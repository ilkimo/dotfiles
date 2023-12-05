#!/bin/bash

# Function to process a directory recursively and create a list of "Rating_filename" pairs
explore_directory() {
  local path="$1"
  local image_list=""

  # Loop through all files and directories in the current directory
  for entry in "$path"/*; do
    if [ -d "$entry" ]; then
      # If it's a directory, explore it recursively
      explore_directory "$entry"
    elif [ -f "$entry" ]; then
      # If it's a file, check if it's a valid image (JPEG or PNG)
      if [[ "$entry" =~ \.(jpg|jpeg|png)$ ]]; then
        # Get the Rating metadata (if available) using exiftool
        rating=$(exiftool -Rating "$entry" | awk -F': ' '{print $2}')
        
        # Check if a Rating was found
        if [ -n "$rating" ]; then
          # Add the "Rating_filename" pair to the image_list
          image_list+="$(printf "%02d" "$rating")_$entry "
        fi
      fi
    fi
  done

  # Output the image list
  echo "$image_list"
}

# Parse command-line options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--path)
            # Check if the next argument exists and is a directory
            if [[ -n $2 && -d $2 ]]; then
                path="$2"
                shift 2
            else
                #log "ERROR" "Invalid wallpaper path specified."
                echo "Invalid wallpaper path specified."
                exit 1
            fi
            ;;
        *)
            # Treat any other argument as an unknown option
            #log "ERROR" "Unknown option $1"
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done

# Start exploring the current directory (you can specify a different directory)
image_list=$(explore_directory "$path")

# Sort the image list in descending order and print the output
IFS=$'\n' sorted_list=($(echo "$image_list" | tr ' ' '\n' | sort -r))
for item in "${sorted_list[@]}"; do
  #echo "${item#*_}"  # Extract the filename from "Rating_filename" pair
  echo "${item}"  # Extract the filename from "Rating_filename" pair
done
