#!/bin/bash

# Get ID of the currently focused window
FOCUSED_WINDOW_ID=$(xprop -root _NET_ACTIVE_WINDOW | grep -oP '0x\w+')

# Get class of the focused window
WINDOW_CLASS=$(xprop -id $FOCUSED_WINDOW_ID WM_CLASS | awk -F '"' '{print $4}')

# Check if we got a window class
if [ -n "$WINDOW_CLASS" ]; then
    # Write the configuration with the current window class
    echo "bindsym \$mod+period [class=\"$WINDOW_CLASS\"] scratchpad show" > ~/.config/i3/dynamic_bindsym.conf
    # Reload i3 configuration
    i3-msg reload
else
    echo "No focused window found."
fi
