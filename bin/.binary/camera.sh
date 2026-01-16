#!/bin/bash

#########    [ Camera [ camera app without Application ]    #################
#
#
#  █████╗ ███████╗██╗  ██╗██╗███████╗██╗  ██╗      ██╗  ██╗██╗   ██╗███████╗
# ██╔══██╗██╔════╝██║  ██║██║██╔════╝██║  ██║      ██║ ██╔╝██║   ██║██╔════╝
# ███████║███████╗███████║██║███████╗███████║█████╗█████╔╝ ██║   ██║███████╗
# ██╔══██║╚════██║██╔══██║██║╚════██║██╔══██║╚════╝██╔═██╗ ██║   ██║╚════██║
# ██║  ██║███████║██║  ██║██║███████║██║  ██║      ██║  ██╗╚██████╔╝███████║
# ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝╚══════╝╚═╝  ╚═╝      ╚═╝  ╚═╝ ╚═════╝ ╚══════╝
#
#                                         Gmail: ashish.kus2408@gmail.com
##################################################################################

# Configuration
DEFAULT_CAMERA="/dev/video0"
MPV_PROFILE="camera"
MPV_TITLE="CameraApp"

# Function to display help
show_help() {
  cat <<EOF
Camera Viewer - MPV Camera Application

USAGE:
  $0 [OPTIONS] [CAMERA_DEVICE]

OPTIONS:
  -h, --help          Show this help message and exit
  -d, --device PATH   Specify camera device (default: /dev/video0)

ARGUMENTS:
  CAMERA_DEVICE       Optional camera device path (e.g., /dev/video1)

EXAMPLES:
  $0                  # Use default camera (/dev/video0)
  $0 /dev/video1      # Use specific camera device
  $0 -d /dev/video2   # Use specific camera device with flag

CAMERA CONTROLS (via camera.lua script):
  s         - Take screenshot (saved to ~/Pictures/camera/)
  ↑         - Increase brightness
  ↓         - Decrease brightness
  q         - Quit camera viewer

REQUIREMENTS:
  - mpv (media player)
  - camera.lua script at ~/.config/mpv/scripts/camera.lua
  - Optional: paplay for shutter sound

NOTES:
  - Screenshots are saved to ~/Pictures/camera/ with timestamps
  - Script will attempt to find fallback camera if default not found
  - Ensure you have read permissions for the camera device

EOF
}

# Function to check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Parse command line arguments
CAMERA_DEV="$DEFAULT_CAMERA"

while [[ $# -gt 0 ]]; do
  case $1 in
  -h | --help)
    show_help
    exit 0
    ;;
  -d | --device)
    if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
      CAMERA_DEV="$2"
      shift 2
    else
      echo "❌ Error: --device requires a path argument"
      exit 1
    fi
    ;;
  -*)
    echo "❌ Error: Unknown option: $1"
    echo "Use -h or --help for usage information"
    exit 1
    ;;
  *)
    # Positional argument - treat as camera device
    CAMERA_DEV="$1"
    shift
    ;;
  esac
done

# Check for MPV
if ! command_exists mpv; then
  echo "❌ Error: 'mpv' is not installed. Install it and try again."
  echo "   Install with: sudo apt install mpv (Debian/Ubuntu)"
  echo "                sudo dnf install mpv (Fedora)"
  echo "                sudo pacman -S mpv (Arch)"
  exit 1
fi

# Check if camera device exists
if [ ! -e "$CAMERA_DEV" ]; then
  echo "⚠️ Warning: $CAMERA_DEV not found. Trying fallback devices..."
  # Look for any /dev/video* device
  fallback_device=$(find /dev -name "video*" | head -n 1)
  if [ -z "$fallback_device" ]; then
    echo "❌ Error: No video device found."
    echo "   Make sure your camera is connected and recognized by the system."
    echo "   Check with: ls -l /dev/video*"
    exit 1
  else
    echo "ℹ️ Using fallback device: $fallback_device"
    CAMERA_DEV="$fallback_device"
  fi
fi

# Check read permission
if [ ! -r "$CAMERA_DEV" ]; then
  echo "❌ Error: Cannot read from $CAMERA_DEV. Check permissions."
  echo "   You may need to add your user to the 'video' group:"
  echo "   sudo usermod -a -G video $USER"
  echo "   Then log out and log back in."
  exit 1
fi

# Check if camera.lua script exists
LUA_SCRIPT="$HOME/.config/mpv/custom/camera.lua"
if [ ! -f "$LUA_SCRIPT" ]; then
  echo "⚠️ Warning: camera.lua script not found at $LUA_SCRIPT"
  echo "   Custom keybindings (s for screenshot, etc.) will not work."
  echo "   Camera will still open, but without enhanced features."
  read -p "   Continue anyway? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# Run MPV with camera input
# Using v4l2 (Video4Linux2) protocol for direct camera access
# --untimed: disables frame timing for live input to prevent frame drops
# --cache=no: disables caching to reduce latency for real-time viewing
# --demuxer-thread=no: processes frames in main thread for lower latency
echo "📹 Launching MPV with $CAMERA_DEV..."
echo "   Press 's' for screenshot, ↑/↓ for brightness, 'q' to quit"
mpv av://v4l2:"$CAMERA_DEV" \
  --title="$MPV_TITLE" \
  --profile="$MPV_PROFILE" \
  --untimed \
  --cache=no \
  --demuxer-thread=no
