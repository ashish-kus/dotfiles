#!/bin/bash
# hyprlock_rescue.sh
# Script to restore Hyprland lockscreen if it crashes

# Set Hyprland instance (usually 0)
INSTANCE=0

echo "[*] Allowing session lock restore..."
hyprctl --instance $INSTANCE "keyword misc:allow_session_lock_restore 1"

echo "[*] Killing any existing hyprlock processes..."
killall -9 hyprlock 2>/dev/null

echo "[*] Relaunching hyprlock..."
hyprctl --instance $INSTANCE "dispatch exec hyprlock"

echo "[+] Done! Switch back to Hyprland with Ctrl+Alt+F1 or F2 (depending on your session)."
