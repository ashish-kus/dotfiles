#!/bin/bash

# Check if QuickTerm already exists (match by class/app-id)
winid=$(hyprctl clients -j | jq -r '.[] | select(.class=="qterm") | .address')

if [ -n "$winid" ]; then
  # If exists, close it
  hyprctl dispatch closewindow address:$winid
  exit 0
fi

# Otherwise launch foot with fixed app-id and tmux
foot --app-id=Qterm sh -c "tmux new-session -A -s Qterm" >/dev/null 2>&1 &
