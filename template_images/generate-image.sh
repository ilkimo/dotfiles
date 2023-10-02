#!/bin/bash

# Get the screen dimensions using xdpyinfo and parse the output to get the resolution
resolution=$(xdpyinfo | awk '/dimensions:/ { print $2 }') || { echo "Error getting screen resolution" >&2; exit 1; }

# Define the size of each square in the checkerboard pattern
squareSize=50

# Define the colors for the squares
color1="#2E2E2E" # dark gray
color2="#000000" # black

# Define the output file name
outputFile="dark-theme-pattern.png"

# Define the pattern size
patternSize="${squareSize}x${squareSize}"

# Create a checkerboard pattern image with the specified resolution, square size, and colors
if magick -size "$patternSize" xc:"$color1" xc:"$color2" -append -write mpr:tile +delete -size "$resolution" tile:mpr:tile "$outputFile"; then
    echo "Dark theme pattern image created successfully!"
else
    echo "Error creating the image" >&2
    exit 1
fi

