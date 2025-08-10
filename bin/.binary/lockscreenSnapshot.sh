#!/bin/bash
# hyprlock_fix_and_capture.sh
# Fully independent rescue + screenshot script for Hyprland lockscreen

INSTANCE=0
OUTPUT="$HOME/lockscreen.png"

echo "[*] Allowing session lock restore..."
hyprctl --instance $INSTANCE "keyword misc:allow_session_lock_restore 1"

echo "[*] Killing any running hyprlock..."
killall -9 hyprlock 2>/dev/null

echo "[*] Starting hyprlock..."
hyprctl --instance $INSTANCE "dispatch exec hyprlock"

echo "[*] Waiting 3 seconds..."
sleep 1

echo "[*] Capturing screenshot to $OUTPUT ..."
# Requires grim (Wayland screenshot utility)
if ! command -v grim &>/dev/null; then
  echo "[!] grim is not installed. Install with: sudo pacman -S grim"
  exit 1
fi

grim "$OUTPUT"

echo "[+] Done! Screenshot saved at: $OUTPUT"
echo "[+] Return to Hyprland with Ctrl+Alt+F1 or F2."
