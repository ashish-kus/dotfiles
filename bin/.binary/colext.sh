#!/bin/bash

# Ensure ImageMagick is installed
if ! command -v magick &> /dev/null; then
    echo "ImageMagick is not installed. Please install it and try again."
    exit 1
fi

# COLORS_DIR="$HOME/.colors/"

# Check if directory exists, if not, create it
# if [ ! -d "$COLORS_DIR" ]; then
#     mkdir -p "$COLORS_DIR"
# fi

# Store the directory path in a variable
# TEMPLATE_DIR=$COLORS_DIR

# Directory containing wallpapers
wallpaper_dir="$HOME/Pictures/Wallpaper"

# Transition settings
transition_bezier=".43,1.19,1,.4"
transition_fps=60
transition_type="any" # Replace with desired transition type
transition_duration=0.7

# Check if swww is running, if not start it
if ! pgrep -x "swww-daemon" > /dev/null; then
    swww init
fi

# Select a random wallpaper from the directory
wallpapers=("$wallpaper_dir"/*)
random_wallpaper=$(find "$wallpaper_dir" -type f | shuf -n 1)
# Get current cursor position
cursor_pos="$(hyprctl cursorpos)"

# Set the random wallpaper with transition
swww img "$random_wallpaper" \
    --transition-bezier $transition_bezier \
    --transition-fps=$transition_fps \
    --transition-type=$transition_type \
    --transition-duration=$transition_duration \
    --transition-pos "$cursor_pos"

notify-send "walpaper changed"
# echo $TEMPLET_DIR
# Input image file
INPUT_IMAGE="$random_wallpaper"

# Extract colors directly into a variable
ALLCOL=$(magick "$INPUT_IMAGE" -resize 100x100 -colors 256 -unique-colors txt:-)

# Array to hold bright colors
BRIGHT_COLORS=()

# Read the colors from the variable
while IFS= read -r line; do
    if [[ $line =~ \#([0-9A-Fa-f]{6}) ]]; then
        HEX="${BASH_REMATCH[1]}"
        R=$((16#${HEX:0:2}))
        G=$((16#${HEX:2:2}))
        B=$((16#${HEX:4:2}))
        BRIGHTNESS=$(( (R + G + B) / 3 ))
        if [ $BRIGHTNESS -gt 127 ]; then
            BRIGHT_COLORS+=("#$HEX")
        fi
    fi
done <<< "$ALLCOL"

# Select up to 8 bright colors
BRIGHT_COLORS=("${BRIGHT_COLORS[@]:0:8}")
COLORS=""

function raw_col() {
  for color in "${BRIGHT_COLORS[@]}"; do
      COLORS+="$color\n"
  done
  echo -e "$COLORS" > $HOME/.colors.raw
}

function waybar_col() {
    COLORS=""
    for i in "${!BRIGHT_COLORS[@]}"; do
        COLORS+="@define-color color$i ${BRIGHT_COLORS[i]};\n"
    done
    echo -e "$COLORS" > "$HOME/.config/waybar/waybar.css"
}

function hyprland_col() {
    for i in "${!BRIGHT_COLORS[@]}"; do
        # Remove the hash symbol from the color value
        color_value=${BRIGHT_COLORS[i]#"#"}
        COLORS+="\$color$i = $color_value;\n"
    done
    echo -e "$COLORS" > "$HOME/.config/hypr/colors.conf"
}

function mako_col_inj(){ 
  local file_path="$HOME/.config/mako/config"
  local file_content=""
  local total_lines=$(wc -l < "$file_path")
  local line_num=0

  while IFS= read -r line; do
      ((line_num++))
      if (( line_num <= total_lines - 2 )); then
          file_content+="$line"$'\n'
      fi
  done < "$file_path"

  local text_color="${BRIGHT_COLORS[0]}"
  local border_color="${BRIGHT_COLORS[0]}"
  file_content+="text-color=${text_color}\nborder-color=${border_color}"

  echo -e "$file_content" 
  echo -e "$file_content" > $file_path
  makoctl reload
  notify-send "mako reloaded"
}

# Call the function

hyprland_col
waybar_col
raw_col
mako_col_inj


