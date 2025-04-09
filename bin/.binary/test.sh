#!/bin/bash

INTERNAL_MONITOR="eDP-1"
EXTERNAL_MONITOR=$(hyprctl -j monitors | jq -r ".[] | select(.name != \"$INTERNAL_MONITOR\") | .name" | head -n 1)
MONITOR_CONF="/home/ashishk/.config/hypr/hyprland/monitors.conf"

apply_monitor_config() {
  while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ "$line" =~ ^[[:space:]]*$ ]] && continue
    if [[ "$line" =~ ^monitor[[:space:]]*=[[:space:]]*(.*) ]]; then
      hyprctl keyword monitor "${BASH_REMATCH[1]}"
    fi
  done <"$MONITOR_CONF"
}

LID_STATE=$(awk '{print $2}' /proc/acpi/button/lid/LID/state)

acpi_listen | while read -r event; do
  case "$event" in
  *LID\ close*)
    echo "Lid closed"
    hyprctl keyword monitor "$INTERNAL_MONITOR,disable"
    ;;
  *LID\ open*)
    echo "Lid opened"
    apply_monitor_config
    ;;
  esac
done
