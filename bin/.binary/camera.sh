#!/bin/bash

# Configuration
CAMERA_DEV="/dev/video10"
MPV_PROFILE="camera"
MPV_TITLE="CameraApp"

# Function to check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check for MPV
if ! command_exists mpv; then
  echo "❌ Error: 'mpv' is not installed. Install it and try again."
  exit 1
fi

# Check if camera device exists
if [ ! -e "$CAMERA_DEV" ]; then
  echo "⚠️ Warning: $CAMERA_DEV not found. Trying fallback devices..."
  # Look for any /dev/video* device
  fallback_device=$(find /dev -name "video*" | head -n 1)
  if [ -z "$fallback_device" ]; then
    echo "❌ Error: No video device found."
    exit 1
  else
    echo "ℹ️ Using fallback device: $fallback_device"
    CAMERA_DEV="$fallback_device"
  fi
fi

# Check read permission
if [ ! -r "$CAMERA_DEV" ]; then
  echo "❌ Error: Cannot read from $CAMERA_DEV. Check permissions."
  exit 1
fi

# Run MPV with camera input
echo "Launching MPV with $CAMERA_DEV..."

mpv av://v4l2:"$CAMERA_DEV" --title="$MPV_TITLE" --profile="$MPV_PROFILE" --untimed --cache=no --demuxer-thread=no
