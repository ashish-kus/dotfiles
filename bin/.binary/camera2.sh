#!/bin/bash

#########    [ Camera [ camera app without Application ]    #################

DEFAULT_CAMERA="/dev/video0"
MPV_PROFILE="camera"
MPV_TITLE="CameraApp"
DIALOG_HEIGHT=15
DIALOG_WIDTH=60

# ---------- functions ----------

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

show_error() {
  dialog --title "Error" --msgbox "$1" 7 60
  clear
  exit 1
}

# ---------- checks ----------

command_exists mpv || show_error "mpv is not installed.\nInstall it first."
command_exists dialog || show_error "dialog is not installed.\nInstall it first."

# ---------- camera selection ----------

CAM_LIST=()
for dev in /dev/video*; do
  [ -e "$dev" ] && CAM_LIST+=("$dev" "")
done

[ ${#CAM_LIST[@]} -eq 0 ] && show_error "No camera devices found."

CAMERA_DEV=$(dialog --stdout \
  --title "Select Camera Device" \
  --menu "Choose camera:" \
  $DIALOG_HEIGHT $DIALOG_WIDTH 6 \
  "${CAM_LIST[@]}")

[ -z "$CAMERA_DEV" ] && exit 0

# ---------- video output selection ----------

VO=$(dialog --stdout \
  --title "Select Video Output" \
  --menu "Choose MPV video output:" \
  $DIALOG_HEIGHT $DIALOG_WIDTH 6 \
  gpu "Recommended (default)" \
  gpu-next "Low latency GPU backend" \
  x11 "X11 output" \
  wayland "Wayland output" \
  drm "Direct rendering" \
  fbdev "Framebuffer")

[ -z "$VO" ] && exit 0

# ---------- lua script check ----------

LUA_SCRIPT="$HOME/.config/mpv/custom/camera.lua"
if [ ! -f "$LUA_SCRIPT" ]; then
  dialog --yesno \
    "camera.lua not found.\nContinue without custom controls?" \
    7 60 || exit 0
fi

clear

# ---------- launch mpv ----------

echo "📹 Camera  : $CAMERA_DEV"
echo "🎥 Output  : $VO"
echo "🚀 Launching MPV..."

mpv av://v4l2:"$CAMERA_DEV" \
  --vo="$VO" \
  --title="$MPV_TITLE" \
  --profile="$MPV_PROFILE" \
  --untimed \
  --cache=no \
  --demuxer-thread=no
