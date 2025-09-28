#!/bin/bash

# Check if QuakeTerminal already exists
winid=$(hyprctl clients -j | jq -r '.[] | select(.title=="QuakeTerminal") | .address')

if [ -n "$winid" ]; then
  # If exists, kill it
  hyprctl dispatch closewindow address:$winid
  exit 0
fi

# Otherwise launch foot with special title, running tmux
foot -T QuakeTerminal sh -c "tmux new-session -A -s quickTerminal" 2>/dev/null &
pid=$!
