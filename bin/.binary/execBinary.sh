#!/bin/bash

# Resolve symlink to absolute path
BINARY_DIR=$(realpath "$HOME/.binary")

# Check if the directory exists and is accessible
if [ ! -d "$BINARY_DIR" ]; then
  notify-send "󰊠   Error: Directory $BINARY_DIR not found or inaccessible."
  exit 1
fi

# Find all executables in the directory
BINARIES=$(find "$BINARY_DIR" -maxdepth 1 -type f -executable -printf "%f\n")

# Show Rofi menu (even if no binaries exist, allow typing commands)
CHOSEN_BINARY=$(echo -e "$BINARIES\n" | rofi -dmenu -i -p "" -theme ~/.config/rofi/themes/execBinary.rasi -no-show-icons -normal-window)

# If input is empty, show a message and exit
if [ -z "$CHOSEN_BINARY" ]; then
  notify-send "⚠️  No selection made."
  exit 0
fi

# Check if the chosen binary exists in ~/.binary
if echo "$BINARIES" | grep -Fxq "$CHOSEN_BINARY"; then
  notify-send "󰊠   Launching: $CHOSEN_BINARY"
  "$BINARY_DIR/$CHOSEN_BINARY" &
else
  # Ask for confirmation before running an unknown command
  CONFIRM=$(echo -e "No\nYes" | rofi -dmenu -i -p "❓ Execute '$CHOSEN_BINARY'?" -theme ~/.config/rofi/themes/execBinary.rasi)

  if [ "$CONFIRM" = "Yes" ]; then
    notify-send "󰊠   Running custom command: $CHOSEN_BINARY"
    eval "$CHOSEN_BINARY" &
  else
    notify-send "❌ Command execution cancelled."
    exit 0
  fi
fi
