#!/bin/bash

# Display names
LEFT_DISPLAY="DP-0"
CENTER_DISPLAY="DP-1"
RIGHT_DISPLAY="DP-2"

# Define directories for wallpapers
WALLPAPER_DIR_3_DISPLAYS="$HOME/Pictures/wallpapers/wallpaper-7680x1440"
WALLPAPER_DIR_1_DISPLAY_2560x1440="$HOME/Pictures/wallpapers/wallpaper-2560x1440"
WALLPAPER_DIR_1_DISPLAY_1920x1080="$HOME/Pictures/wallpapers/wallpaper-1920x1080"

# Using xrandr to get the number of connected displays
NUM_DISPLAYS=$(xrandr --query | grep " connected" | wc -l)

# Check the number of displays and set the wallpaper accordingly
if [ "$NUM_DISPLAYS" -eq 3 ]; then
    # Check if all three displays are 2560x1440
    if xrandr | grep -q "2560x1440.* connected"; then
        # Configure the displays
        xrandr --output $LEFT_DISPLAY --mode 2560x1440 --pos 0x0 --rotate normal \
               --output $CENTER_DISPLAY --mode 2560x1440 --pos 2560x0 --rotate normal \
               --output $RIGHT_DISPLAY --mode 2560x1440 --pos 5120x0 --rotate normal

        feh --no-xinerama --bg-scale "$WALLPAPER_DIR_3_DISPLAYS"
    fi
elif [ "$NUM_DISPLAYS" -eq 1 ] && xrandr | grep -q "2560x1440.* connected"; then
    feh --bg-scale "$WALLPAPER_DIR_1_DISPLAY_2560x1440"
else
    feh --bg-fill "$WALLPAPER_DIR_1_DISPLAY_1920x1080"
fi
