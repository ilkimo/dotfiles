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

# New variables for sorting and truncation
sort_order="desc" # default sort order
truncate_under=0  # default threshold (0 means no truncation)

# Parse command-line options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--path)
            # Check if the next argument exists and is a directory
            if [[ -n $2 && -d $2 ]]; then
                path="$2"
                shift 2
            else
                echo "Invalid wallpaper path specified."
                exit 1
            fi
            ;;
        -o|--order)
            if [[ $2 == "asc" || $2 == "desc" ]]; then
                sort_order="$2"
                shift 2
            else
                echo "Invalid order specified. Use 'asc' or 'desc'."
                exit 1
            fi
            ;;
        -t|--truncate-under)
            if [[ -n $2 && $2 =~ ^[0-9]+$ ]]; then
                truncate_under="$2"
                shift 2
            else
                echo "Invalid truncate under value specified."
                exit 1
            fi
            ;;
        -c|--cut-rankings)
            cut_rankings=true
            shift
            ;;
        *)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done

image_list=$(explore_directory "$path")

# Filter and sort the image list
IFS=$'\n' image_array=($(echo "$image_list" | tr ' ' '\n'))
sorted_list=()
for item in "${image_array[@]}"; do
    rating=${item%%_*}
    if (( rating >= truncate_under )); then
        sorted_list+=("${item}") # Add only the path
    fi
done

if [[ "$sort_order" == "desc" ]]; then
    sorted_list=($(printf "%s\n" "${sorted_list[@]}" | sort -r))
else
    sorted_list=($(printf "%s\n" "${sorted_list[@]}" | sort))
fi

for item in "${sorted_list[@]}"; do
    if [ "$cut_rankings" = true ]; then
        echo ${item#*_} # Echoes only filename
    else
        echo ${item} # Echoes rating and filename
    fi
done
