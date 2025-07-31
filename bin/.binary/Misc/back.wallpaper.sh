#!/bin/bash

# Ensure ImageMagick is installed
if ! command -v magick &>/dev/null; then
  notify-send "Error: ImageMagick is not installed!"
  exit 1
fi

# Default wallpaper directory
DEFAULT_WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
# DEFAULT_WALLPAPER_DIR="$HOME/Pictures/MinecraftWallpapers/"

# Check if swww-daemon is running, start if not
if ! pgrep -x "swww-daemon" >/dev/null; then
  swww-daemon
fi

# Determine whether input is a directory or a file
if [[ -d "$1" ]]; then
  # User provided a directory, pick a random image from it
  WALLPAPER_DIR="$1"
  SELECTED_WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)
elif [[ -f "$1" ]]; then
  # User provided a single image, use that
  SELECTED_WALLPAPER="$1"
else
  # No argument provided, use default wallpaper directory
  WALLPAPER_DIR="$DEFAULT_WALLPAPER_DIR"
  SELECTED_WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)
fi

# Validate selected wallpaper
if [[ ! -f "$SELECTED_WALLPAPER" ]]; then
  notify-send "❌ Error: No valid wallpaper found!"
  exit 1
fi

# Create symlinks for the selected wallpaper
ln -sf "$SELECTED_WALLPAPER" "$HOME/.wallpaper.png"
# ln -sf "$SELECTED_WALLPAPER" "$HOME/.mozilla/firefox/kk9zw8qh.default-release/chrome/styles/ASSETS/wallpaper/wallpaper.png"

# Get cursor position
CURSOR_POS="$(hyprctl cursorpos)"

# Transition settings
TRANSITION_BEZIER="0.0,0.0,1.0,1.0"
TRANSITION_FPS=60
TRANSITION_TYPE="any"
TRANSITION_DURATION=0.7

# Set wallpaper with transition
swww img "$SELECTED_WALLPAPER" \
  --transition-bezier "$TRANSITION_BEZIER" \
  --transition-fps="$TRANSITION_FPS" \
  --transition-type="$TRANSITION_TYPE" \
  --transition-duration="$TRANSITION_DURATION" \
  --transition-pos "$CURSOR_POS"

# Extract colors from wallpaper
ALLCOL=$(magick "$SELECTED_WALLPAPER" -resize 100x100 -colors 256 -format %c histogram:info:-)

# Array to store bright colors
BRIGHT_COLORS=()

# Parse colors and select bright ones
while IFS= read -r line; do
  if [[ $line =~ \#([0-9A-Fa-f]{6}) ]]; then
    HEX="${BASH_REMATCH[1]}"
    R=$((16#${HEX:0:2}))
    G=$((16#${HEX:2:2}))
    B=$((16#${HEX:4:2}))
    BRIGHTNESS=$(((R + G + B) / 3))

    if [ "$BRIGHTNESS" -gt 127 ]; then
      BRIGHT_COLORS+=("#$HEX")
    fi
  fi
done <<<"$ALLCOL"

# Select only the top 8 bright colors
BRIGHT_COLORS=("${BRIGHT_COLORS[@]:0:8}")

# Function to save raw colors
save_raw_colors() {
  printf "%s\n" "${BRIGHT_COLORS[@]}" >"$HOME/.colors.raw"
}

# Function to generate Waybar colors
generate_waybar_colors() {
  local output=""
  for i in "${!BRIGHT_COLORS[@]}"; do
    output+="@define-color color$i ${BRIGHT_COLORS[i]};\n"
  done
  echo -e "$output" >"$HOME/.config/waybar/waybar.css"
}

# Function to generate Hyprland colors
generate_hyprland_colors() {

  hyprctl keyword general:col.active_border 0xFF${BRIGHT_COLORS[i]#"#"}

  echo -n "" >"$HOME/.config/hypr/colors.conf" # Clear file
  for i in "${!BRIGHT_COLORS[@]}"; do
    echo -e "\$color$i = ${BRIGHT_COLORS[i]#"#"}" >>"$HOME/.config/hypr/colors.conf"
  done
}

# Function to update Mako notification colors
update_mako_colors() {
  local file_path="$HOME/.config/mako/config"
  local temp_file="$(mktemp)"

  # Copy everything except the last two lines
  head -n -2 "$file_path" >"$temp_file"

  # Append new colors
  local text_color="${BRIGHT_COLORS[0]}"
  local border_color="${BRIGHT_COLORS[0]}"
  echo -e "text-color=${text_color}\nborder-color=${border_color}" >>"$temp_file"

  # Overwrite original config
  mv "$temp_file" "$file_path"

  # Reload Mako and notify user
  makoctl reload
  notify-send "🔄 Mako reloaded!"
}

# Function to update Rofi color theme
update_rofi_colors() {
  echo -e "* {\n" >"$HOME/.config/rofi/wal_color.rasi"
  for i in {0..7}; do
    echo -e "    color$i: ${BRIGHT_COLORS[i]};" >>"$HOME/.config/rofi/wal_color.rasi"
  done
  echo "}" >>"$HOME/.config/rofi/wal_color.rasi"
}

# Execute functions
# generate_hyprland_colors
# generate_waybar_colors
# save_raw_colors
# update_mako_colors
# update_rofi_colors

notify-send "Wallpaper Updated" "New wallpaper set from: $SELECTED_WALLPAPER"
