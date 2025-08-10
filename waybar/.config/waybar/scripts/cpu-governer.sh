#!/bin/bash

# Get current governor from the first CPU
governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)

# Pick icon based on governor
case "$governor" in
performance)
  icon="" # Nerd Font chip icon
  ;;
powersave)
  icon="󱤅" # Nerd Font plug-off
  ;;
schedutil)
  icon="󱠆" # Nerd Font heartbeat
  ;;
conservative)
  icon="" # Nerd Font leaf
  ;;
*)
  icon="" # Nerd Font question mark
  ;;
esac

# Output JSON for Waybar
echo "{\"text\": \"$icon\", \"tooltip\": \"Governor: $governor\"}"
