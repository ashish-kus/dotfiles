#!/bin/bash

# Define monitor layouts
declare -A layouts

layouts["Default"]="hyprctl keyword monitor \"eDP-1,preferred,0x1080,1,bitdepth,10\" && hyprctl keyword monitor \"HDMI-A-2,preferred,0x0,1,bitdepth,10\""
layouts["Vertical Layout"]="hyprctl keyword monitor \"eDP-1,preferred,0x1080,1\" && hyprctl keyword monitor \"HDMI-A-2,preferred,0x0,1\""
layouts["Left-to-Right Layout"]="hyprctl keyword monitor \"eDP-1,preferred,0x0,1\" && hyprctl keyword monitor \",preferred,1920x0,1\""
layouts["Right-to-Left Layout"]="hyprctl keyword monitor \"eDP-1,preferred,1920x0,1\" && hyprctl keyword monitor \"HDMI-A-2,preferred,0x0,1\""

# Show options in Rofi
choice=$(printf "%s\n" "${!layouts[@]}" | rofi -dmenu -p "Select Monitor Layout")

# Apply the selected layout
if [[ -n "$choice" ]]; then
  eval "${layouts[$choice]}"
  notify-send "Hyprland" "Switched to $choice layout"
fi
