#!/bin/bash

battery_percentage=$(cat /sys/class/power_supply/BAT0/capacity)
battery_status=$(cat /sys/class/power_supply/BAT0/status)
battery_icons=("󰂃" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰁹")
charging_icon="󰂄"
icon_index=$(((battery_percentage / 10) - 1))
battery_icon=${battery_icons[icon_index]}
if [ "$battery_status" = "Charging" ]; then
  battery_icon="$charging_icon"
fi

# Hotspot
if pgrep -x create_ap >/dev/null; then
  hotspot="󱜠"
fi
# Output the battery percentage and icons ( Hotspot, battery )
echo "$hotspot" "$net_icon" "$battery_icon"
