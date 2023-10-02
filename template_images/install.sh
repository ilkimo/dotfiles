#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

# Get the directory of the currently executing script
scriptDir=$(dirname "$0")

# Get the absolute path of the script directory
absScriptDir=$(realpath "$scriptDir")

# Define the relative path to the directory containing the target images
relativeTargetDir="template_images/"

# Concatenate the absolute path of the script directory with the relative path to the target images
targetDir="$absScriptDir/$relativeTargetDir"

# Define the directory where the symbolic links will be created
linkDir=~/Pictures/

# Use xdpyinfo to get the screen dimensions and parse the output to get the resolution
resolution=$(xdpyinfo | awk '/dimensions:/ { print $2 }') || { echo "Error getting screen resolution" >&2; exit 1; }

# Determine the path to the target image based on the screen resolution
case "$resolution" in
    "1920x1080")
        targetPath="${targetDir}1920x1080"
        ;;
    "2560x1440")
        targetPath="${targetDir}2560x1440"
        ;;
    *)
        # If the screen resolution is not supported, print an error message to stderr and exit
        echo "Unsupported screen resolution: $resolution" >&2
        exit 1
        ;;
esac

# Create the symbolic links and check for errors
ln -sf "$targetPath/wallpaper.png" "${linkDir}wallpaper" || { echo "Error creating wallpaper symlink" >&2; exit 1; }
ln -sf "$targetPath/lock-screen.png" "${linkDir}lock-screen" || { echo "Error creating lock-screen symlink" >&2; exit 1; }

echo "Symbolic links created successfully!" >&2

