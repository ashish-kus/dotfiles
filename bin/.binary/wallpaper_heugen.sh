#!/bin/bash

# DEFAULT_WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
DEFAULT_WALLPAPER_DIR="$HOME/Pictures/MinecraftWallpapers/"

if ! pgrep -x "swww-daemon" >/dev/null; then
  swww-daemon
fi

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

CURSOR_POS="$(hyprctl cursorpos)"

# Transition settings
TRANSITION_BEZIER="0.0,0.0,1.0,1.0"
TRANSITION_FPS=60
TRANSITION_TYPE="any"
TRANSITION_DURATION=1.7

# Set wallpaper with transition
swww img "$SELECTED_WALLPAPER" \
  --transition-bezier "$TRANSITION_BEZIER" \
  --transition-fps="$TRANSITION_FPS" \
  --transition-type="$TRANSITION_TYPE" \
  --transition-duration="$TRANSITION_DURATION" \
  --transition-pos "$CURSOR_POS"

~/.binary/heugen ~/.wallpaper.png
cat ~/.config/mako/base.conf ~/.config/huegen/themes/colors-mako.conf >~/.config/mako/config
makoctl reload

sleep 0.5
pkill -SIGUSR2 waybar

ps -t $(who | awk '{print $2}') -o pid=,comm= | grep -E 'zsh|bash' | awk '{print $1}' | while read pid; do
  kill -USR1 "$pid"
done

# Top Row (0-7)
for i in {0..7}; do
  printf "\e[48;5;${i}m   \e[0m" # 8 spaces wide
done
echo

# Bottom Row (8-15)
for i in {8..15}; do
  printf "\e[48;5;${i}m   \e[0m" # 8 spaces wide
done
echo

~/.config/huegen/themes/termcol.sh
