#!/bin/bash

# Check if running inside Hyprland
if [ "$XDG_SESSION_DESKTOP" = "Hyprland" ] || [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ]; then
  echo "✅ You are in a Hyprland session."
  echo "Setting animation speed to 0..."

  HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')
  if [ "$HYPRGAMEMODE" = 1 ]; then
    hyprctl --batch "\
        keyword animations:enabled 0;\
        keyword decoration:shadow:enabled 0;\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;\
        keyword general:border_size 1;\
        keyword decoration:rounding 0"
    exit
  fi
  hyprctl reload
else
  echo "❌ Not in a Hyprland session. Skipping."
  exit 1
fi

# change to no background
#
#       keyword decoration:blur:enabled 0;\
