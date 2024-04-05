#!/bin/bash

# Display names
CENTER_DISPLAY="DP-0"
RIGHT_DISPLAY="DP-2"
LEFT_DISPLAY="DP-4"

# Define directories for wallpapers
WALLPAPER_SYMLINK_POSITION="$HOME/Pictures/wallpapers/wallpaper"
WALLPAPER_DIR_3_DISPLAYS="$HOME/Pictures/wallpapers/wallpaper-7680x1440"
WALLPAPER_DIR_1_DISPLAY_2560x1440="$HOME/Pictures/wallpapers/wallpaper-2560x1440"
WALLPAPER_DIR_1_DISPLAY_1920x1080="$HOME/Pictures/wallpapers/wallpaper-1920x1080"

# Using xrandr to get the number of connected displays
NUM_DISPLAYS=$(xrandr --query | grep " connected" | wc -l)

# Check the number of displays and set the wallpaper accordingly
if [ "$NUM_DISPLAYS" -ge 3 ]; then
    xrandr --output $LEFT_DISPLAY --mode 2560x1440 --pos 0x0 --rotate normal \
           --output $CENTER_DISPLAY --mode 2560x1440 --pos 2560x0 --rotate normal \
           --output $RIGHT_DISPLAY --mode 2560x1440 --pos 5120x0 --rotate normal

    ln -sf "$WALLPAPER_DIR_3_DISPLAYS" "$WALLPAPER_SYMLINK_POSITION"
    feh --no-xinerama --bg-scale ~/Pictures/wallpapers/wallpaper
elif [ "$NUM_DISPLAYS" -eq 1 ] && xrandr | grep -q "2560x1440.* connected"; then
    echo "A"

    ln -sf "$WALLPAPER_DIR_3_DISPLAYS" "$WALLPAPER_SYMLINK_POSITION"
    feh --bg-scale "$WALLPAPER_SYMLINK_POSITION"
else
    echo "B"
    ln -sf "$WALLPAPER_DIR_3_DISPLAYS" "$WALLPAPER_SYMLINK_POSITION"
    feh --bg-fill "$WALLPAPER_SYMLINK_POSITION"
fi
