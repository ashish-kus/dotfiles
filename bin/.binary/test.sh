#!/bin/bash

INTERNAL_MONITOR="eDP-1"
EXTERNAL_MONITOR=$(hyprctl -j monitors | jq -r ".[] | select(.name != \"$INTERNAL_MONITOR\") | .name" | head -n 1)
MONITOR_CONF="/home/ashishk/.config/hypr/hyprland/monitors.conf"

LID_STATE=$(awk '{print $2}' /proc/acpi/button/lid/LID/state)
ACTIVE_MONITORS=$(hyprctl -j monitors | jq -r '.[].name')

get_focused_workspace() {
  hyprctl -j monitors | jq -r ".[] | select(.name == \"$1\") | .activeWorkspace.id"
}

apply_monitor_config() {
  while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ "$line" =~ ^[[:space:]]*$ ]] && continue
    if [[ "$line" =~ ^monitor[[:space:]]*=[[:space:]]*(.*) ]]; then
      hyprctl keyword monitor "${BASH_REMATCH[1]}"
    fi
  done <"$MONITOR_CONF"
}

if [[ "$LID_STATE" == "closed" ]]; then
  if echo "$ACTIVE_MONITORS" | grep -q "$INTERNAL_MONITOR"; then
    FOCUSED_EXTERNAL_WS=$(get_focused_workspace "$EXTERNAL_MONITOR")
    #    move_windows_off_monitor "$INTERNAL_MONITOR" "$FOCUSED_EXTERNAL_WS"
    hyprctl dispatch focusmonitor "$EXTERNAL_MONITOR"
    hyprctl keyword monitor "$INTERNAL_MONITOR, disable"
  fi

else
  if ! echo "$ACTIVE_MONITORS" | grep -q "$INTERNAL_MONITOR"; then
    #    hyprctl keyword monitor "$INTERNAL_MONITOR, preferred, auto, 1"
    #    hyprctl dispatch focusmonitor "$INTERNAL_MONITOR"
    apply_monitor_config
  fi
fi

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
