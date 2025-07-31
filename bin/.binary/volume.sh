#!/bin/bash

iDIR="$HOME/.config/hypr/mako/icons"

# Get Volume
get_volume() {
  pamixer --get-volume
}

# Get icon based on volume
get_icon() {
  local current=$(get_volume)
  if [[ "$current" -eq 0 ]]; then
    echo "$iDIR/volume-mute.png"
  elif [[ "$current" -le 30 ]]; then
    echo "$iDIR/volume-low.png"
  elif [[ "$current" -le 60 ]]; then
    echo "$iDIR/volume-mid.png"
  else
    echo "$iDIR/volume-high.png"
  fi
}

# Notify Volume
notify_user() {
  local volume=$(get_volume)
  notify-send -t 1000 -a 'volume' \
    -h string:x-canonical-private-synchronous:volume \
    -h int:value:$volume \
    -u low \
    -i "$(get_icon)" \
    "Volume: ${volume}%"
}

# Volume control
inc_volume() { pamixer -i 5 && notify_user; }
dec_volume() { pamixer -d 5 && notify_user; }

# Toggle Mute
toggle_mute() {
  if pamixer --get-mute | grep -q false; then
    pamixer -m && notify-send -t 1000 -a 'volume' \
      -h string:x-canonical-private-synchronous:volume \
      -u low -i "$iDIR/volume-mute.png" "Volume Muted"
  else
    pamixer -u && notify_user
  fi
}
# Mic icon
get_mic_icon() {
  echo "$iDIR/microphone.png"
}

# Notify Mic Volume
notify_mic_user() {
  local volume=$(pamixer --default-source --get-volume)
  notify-send -t 1000 -a 'volume' \
    -h string:x-canonical-private-synchronous:mic \
    -h int:value:$volume \
    -u low \
    -i "$(get_mic_icon)" \
    "Mic Level: ${volume}%"
}

# Mic Volume control
inc_mic_volume() { pamixer --default-source -i 5 && notify_mic_user; }
dec_mic_volume() { pamixer --default-source -d 5 && notify_mic_user; }

# Toggle Mic
toggle_mic() {
  if pamixer --default-source --get-mute | grep -q false; then
    pamixer --default-source -m && notify-send -t 1000 -a 'volume' \
      -h string:x-canonical-private-synchronous:mic \
      -u low -i "$iDIR/microphone-mute.png" "Microphone Muted"
  else
    pamixer --default-source -u && notify_mic_user
  fi
}

# Execute accordingly
case "$1" in
--get) get_volume ;;
--inc) inc_volume ;;
--dec) dec_volume ;;
--toggle) toggle_mute ;;
--toggle-mic) toggle_mic ;;
--get-icon) get_icon ;;
--get-mic-icon) get_mic_icon ;;
--mic-inc) inc_mic_volume ;;
--mic-dec) dec_mic_volume ;;
*) get_volume ;;
esac
