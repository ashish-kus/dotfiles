#!/bin/bash

# Source directory containing icons
SRC_DIR="./icons"
# Destination directory for system icons
DEST_DIR="/usr/share/pixmaps"

# Check if script is run with sudo
if [[ $EUID -ne 0 ]]; then
  echo "❌ Please run as root using sudo"
  exit 1
fi

echo " Copying icons from $SRC_DIR to $DEST_DIR..."

# Loop through all PNG files in the source directory
for icon in "$SRC_DIR"/*.png; do
  icon_name=$(basename "$icon")
  dest_icon="$DEST_DIR/$icon_name"

  # If destination doesn't exist or source is newer, copy it
  if [[ ! -f "$dest_icon" ]]; then
    echo "📥 Installing new icon: $icon_name"
    cp "$icon" "$dest_icon"
  elif [[ "$icon" -nt "$dest_icon" ]]; then
    echo "♻️ Replacing outdated icon: $icon_name"
    cp "$icon" "$dest_icon"
  else
    echo "✅ Icon already up-to-date: $icon_name"
  fi
done

echo "🎉 Icon installation complete."
