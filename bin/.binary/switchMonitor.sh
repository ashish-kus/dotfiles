#!/usr/bin/env bash

# Automatically disables internal monitor when the lid is closed
# and moves all windows on internal to external monitor's focused workspace.
# Re-enables internal monitor when lid is opened.

INTERNAL_MONITOR="eDP-1"
EXTERNAL_MONITOR=$(hyprctl -j monitors | jq -r ".[] | select(.name != \"$INTERNAL_MONITOR\") | .name" | head -n 1)

# Get lid state
LID_STATE=$(awk '{print $2}' /proc/acpi/button/lid/LID/state)
ACTIVE_MONITORS=$(hyprctl -j monitors | jq -r '.[].name')

# Get focused workspace on a given monitor
get_focused_workspace() {
  hyprctl -j monitors | jq -r ".[] | select(.name == \"$1\") | .activeWorkspace.id"
}

# Move all windows from one monitor to a target workspace
move_windows_off_monitor() {
  FROM_MONITOR="$1"
  TO_WORKSPACE="$2"

  hyprctl -j clients | jq -c ".[] | select(.monitor == \"$FROM_MONITOR\")" | while read -r win; do
    WINDOW_ADDRESS=$(echo "$win" | jq -r '.address')
    hyprctl dispatch movetoworkspace "$TO_WORKSPACE,address:$WINDOW_ADDRESS"
  done
}

if [[ "$LID_STATE" == "closed" ]]; then
  echo "Lid is closed. Switching to external monitor: $EXTERNAL_MONITOR"

  if echo "$ACTIVE_MONITORS" | grep -q "$INTERNAL_MONITOR"; then
    FOCUSED_EXTERNAL_WS=$(get_focused_workspace "$EXTERNAL_MONITOR")
    move_windows_off_monitor "$INTERNAL_MONITOR" "$FOCUSED_EXTERNAL_WS"
    hyprctl dispatch focusmonitor "$EXTERNAL_MONITOR"
    hyprctl keyword monitor "$INTERNAL_MONITOR, disable"
  fi

else
  echo "Lid is open. Ensuring internal display is active."

  if ! echo "$ACTIVE_MONITORS" | grep -q "$INTERNAL_MONITOR"; then
    hyprctl keyword monitor "$INTERNAL_MONITOR, preferred, auto, 1"
    hyprctl dispatch focusmonitor "$INTERNAL_MONITOR"
  fi
fi
