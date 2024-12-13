#!/bin/bash

# Default output directory
OUTPUT_DIR="/home/ashishk/Videos/VideoSort"
mkdir -p "$OUTPUT_DIR" # Ensure the directory exists

# Default output filename
OUTPUT_FILE="$OUTPUT_DIR/recording_$(date +%Y%m%d_%H%M%S).mp4"

# Check if required tools are installed
if ! command -v wf-recorder &>/dev/null; then
  echo "Error: wf-recorder is not installed. Install it and try again."
  exit 1
fi

if ! command -v slurp &>/dev/null; then
  echo "Error: slurp is not installed. Install it and try again."
  exit 1
fi

# Display instructions
echo "Select the region to record using your mouse."

# Use slurp to select a region
REGION=$(slurp)

if [ -z "$REGION" ]; then
  echo "Error: No region selected. Exiting."
  exit 1
fi

# Start recording
echo "Recording started for region: $REGION"
echo "Audio recording is enabled."
echo "Press Ctrl+C to stop the recording."

wf-recorder -g "$REGION" -a -f "$OUTPUT_FILE"

echo "Recording saved to $OUTPUT_FILE"
