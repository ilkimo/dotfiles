#!/bin/bash

# Display names
LEFT_DISPLAY="DP-0"
CENTER_DISPLAY="DP-1"
RIGHT_DISPLAY="DP-2"

# Define directories for lock-screens
LOCK-SCREEN_DIR_3_DISPLAYS="$HOME/Pictures/lock-screens/lock-screen-7680x1440"
LOCK-SCREEN_DIR_1_DISPLAY_2560x1440="$HOME/Pictures/lock-screens/lock-screen-2560x1440"
LOCK-SCREEN_DIR_1_DISPLAY_1920x1080="$HOME/Pictures/lock-screens/lock-screen-1920x1080"

# Using xrandr to get the number of connected displays
NUM_DISPLAYS=$(xrandr --query | grep " connected" | wc -l)

# Check the number of displays and set the lock-screen accordingly
if [ "$NUM_DISPLAYS" -ge 3 ]; then
    convert ~/Pictures/lock-screens/lock-screen-7680x1440 RGB:- | i3lock -f --raw 7680x1440:rgb --image /dev/stdin
elif [ "$NUM_DISPLAYS" -eq 1 ] && xrandr | grep -q "2560x1440.* connected"; then
    convert ~/Pictures/lock-screens/lock-screen-2560x1440 RGB:- | i3lock -f --raw 2560x1440:rgb --image /dev/stdin
else
    convert ~/Pictures/lock-screens/lock-screen-1920x1080 RGB:- | i3lock -f --raw 1920x1080:rgb --image /dev/stdin
fi
