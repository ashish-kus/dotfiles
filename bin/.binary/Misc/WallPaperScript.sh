#!/bin/bash

colors=(
  "#c0caf5" # Foreground
  "#a9b1d6" # Light Foreground
  "#f7768e" # Red
  "#d7daec" # Bright Foreground
  "#db4b4b" # Crimson Red
  "#ff7a45" # Vibrant Orange
  "#f4c542" # Gold Yellow
  "#81c784" # Spring Green
  "#4fc3f7" # Sky Blue
  "#5eafff" # Deep Cyan
  "#ab47bc" # Orchid Purple
  "#4b5263" # Dim Comment
  "#a3b9d4" # Cool Foreground
  "#cdd3e6" # Frost Foreground
  "#ed4245" # Rose Red
  "#ffb870" # Peach Orange
  "#ffc96b" # Sand Yellow
  "#99c794" # Lime Green
  "#6fcfe3" # Aqua Blue
  "#59c2ff" # Teal Cyan
  "#b39ddb" # Lavender Purple
  "#424a5d" # Muted Comment

)
check_command() {
  command -v "$1" &>/dev/null || {
    notify-send "Error: '$1' is not installed or not in PATH." >&2
    exit 1
  }
}

check_command magick
check_command swww

# Define cache directory
cache_dir="$HOME/.cache/wallpaper"

# Ensure cache directory exists; create it only if it doesn't
if [[ ! -d "$cache_dir" ]]; then
  mkdir -p "$cache_dir" || {
    notify-send "Error: Failed to create cache directory '$cache_dir'." >&2
    exit 1
  }
fi

# File paths
svg_file="$cache_dir/wallpaper.svg"
png_file="$cache_dir/wallpaper.png"

# Default color values
bg_color="#000000" # Default background color
base_color=""      # Default base color

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
  -bg)
    bg_color="$2"
    shift 2
    ;;
  -base)
    base_color="$2"
    shift 2
    ;;
  *)
    echo "Unknown argument: $1"
    exit 1
    ;;
  esac
done
# If no base_color is provided, select a random one from the list
if [[ -z "$base_color" ]]; then
  base_color=${colors[$((RANDOM % ${#colors[@]}))]}
fi
# Notify about color scheme change
# echo "Color scheme updated: Background color = $bg_color, Base color = $base_color"

# SVG content
svg_content="<svg width=\"100%\" height=\"100%\" viewBox=\"40 42 1920 1036\" xmlns=\"http://www.w3.org/2000/svg\">
  <path d=\"M40 42C40 40.8954 40.8954 40 42 40H1958C1959.1 40 1960 40.8954 1960 42V1118C1960 1119.1 1959.1 1120 1958 1120H42C40.8954 1120 40 1119.1 40 1118V42Z\" fill=\"$bg_color\" stroke=\"none\" />
  <g clip-path=\"url(#clip0_15_2)\">
    <path d=\"M1292.5 580C1292.5 418.457 1161.54 287.5 1000 287.5C838.457 287.5 707.5 418.457 707.5 580C707.5 741.543 838.457 872.5 1000 872.5C1161.54 872.5 1292.5 741.543 1292.5 580Z\" stroke=\"$base_color\" fill=\"$bg_color\" stroke-width=\"15\"/>
    <mask id=\"mask0_15_2\" style=\"mask-type:alpha\" maskUnits=\"userSpaceOnUse\" x=\"850\" y=\"430\" width=\"40\" height=\"238\">
      <g mask=\"url(#mask1_15_2)\">
       <path d=\"M850 430H890V629.92L850 668\" fill=\"$base_color\" />
      </g>
    </mask>  
    <g mask=\"url(#mask0_15_2)\">
      <path d=\"M890 430H850V668H890V430Z\" fill=\"$base_color\" />
    </g>
    <mask id=\"mask2_15_2\" style=\"mask-type:alpha\" maskUnits=\"userSpaceOnUse\" x=\"1110\" y=\"430\" width=\"40\" height=\"300\">
      <g mask=\"url(#mask3_15_2)\">
        <path d=\"M1110 472L1150 430V730H1110\" fill=\"$base_color\" />
      </g>
    </mask>
    <g mask=\"url(#mask2_15_2)\">
      <path d=\"M1150 430H1110V730H1150V430Z\" fill=\"$base_color\" />
    </g>    
    <mask id=\"mask4_15_2\" style=\"mask-type:alpha\" maskUnits=\"userSpaceOnUse\" x=\"850\" y=\"430\" width=\"241\" height=\"241\">
        <path d=\"M1090.7 430.285L1062.42 402L822.001 642.415L850.286 670.7L1090.7 430.285Z\" fill=\"$base_color\" />
    </mask>
    <g mask=\"url(#mask4_15_2)\">
      <path d=\"M1090.7 430.285L1062.42 402L822.001 642.415L850.286 670.7L1090.7 430.285Z\" fill=\"$base_color\" />
    </g>
    <mask id=\"mask6_15_2\" style=\"mask-type:alpha\" maskUnits=\"userSpaceOnUse\" x=\"850\" y=\"429\" width=\"301\" height=\"303\">
        <path d=\"M1178.8 457.76L1150.52 429.48L850 730L878.28 758.28L1178.8 457.76Z\"  fill=\"$base_color\" />
    </mask>
    <g mask=\"url(#mask6_15_2)\">
      <path d=\"M1178.8 457.76L1150.52 429.48L850 730L878.28 758.28L1178.8 457.76Z\" fill=\"$base_color\" />
    </g>
     <path d=\"M977.064 540.496L948.78 568.78L1110 730L1138.28 701.716L977.064 540.496Z\"  fill=\"$base_color\" />
  </g>
</svg>"

echo "$svg_content" >"$svg_file"

if ! magick "$svg_file" "$png_file"; then
  notify-send "Error: Failed to convert SVG to PNG using ImageMagick."
  rm -f "$svg_file"
  exit 1
fi

if ! swww img "$png_file"; then
  notify-send "Error: Failed to set wallpaper using 'swww'."
  rm -f "$svg_file" "$png_file"
  exit 1
fi

ln -sf "$png_file" "$HOME/.wallpaper.png"

function color_raw() {
  echo -e "$base_color" >$HOME/.colors.raw
  echo -e "$bg_color" >>$HOME/.colors.raw
}

function color_waybar() {
  echo -e "@define-color color0 $base_color;" >$HOME/.config/waybar/waybar.css
  echo -e "@define-color color1 $bg_color;" >>$HOME/.config/waybar/waybar.css
}

function color_hyprland() {
  echo -e "\$color0 = ${base_color//#/}" >$HOME/.config/hypr/colors.conf
  echo -e "\$color1 = ${bg_color//#/}" >>$HOME/.config/hypr/colors.conf
}

function color_rofi() {
  COLORS="* {\n"
  COLORS+="color0: $base_color;"
  COLORS+="color1: $bg_color;"
  COLORS+="}\n"
  echo -e "$COLORS" >$HOME/.config/rofi/wal_color.rasi
}

function color_mako() {
  local file_path="$HOME/.config/mako/config"
  local file_content=""
  local total_lines=$(wc -l <"$file_path")
  local line_num=0

  while IFS= read -r line; do
    ((line_num++))
    if ((line_num <= total_lines - 2)); then
      file_content+="$line"$'\n'
    fi
  done <"$file_path"

  file_content+="text-color=$base_color\nborder-color=$base_color"
  echo -e "$file_content" >$file_path
  makoctl reload
}

rm -f "$svg_file" || {
  notify-send "Warning: Failed to delete temporary files in '$cache_dir'." >&2
}

color_raw
color_waybar
color_hyprland
color_rofi
color_mako
notify-send "Wallpaper changed $base_color & $bg_color"
