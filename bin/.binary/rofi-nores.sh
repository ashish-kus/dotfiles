#!/bin/bash
NOTES_FILE="$HOME/.rofi_notes"
ROFI_THEME="$HOME/.config/rofi/themes/notes.rasi"
[ -f "$NOTES_FILE" ] || touch "$NOTES_FILE"
NOTES=$(cat "$NOTES_FILE")
CHOSEN=$(echo "$NOTES" | rofi -dmenu -p "Importants " -theme "$ROFI_THEME" \
  -kb-accept-entry "Return" \
  -kb-custom-1 "Ctrl+x")
ROFI_EXIT_CODE=$?
[ -z "$CHOSEN" ] && exit
echo -n "$CHOSEN" | wl-copy
if [ "$ROFI_EXIT_CODE" -eq 10 ]; then
  ESCAPED_CHOSEN=$(printf '%s\n' "$CHOSEN" | sed 's/[\/&]/\\&/g')
  sed -i "/^$ESCAPED_CHOSEN$/d" "$NOTES_FILE"
else
  if ! grep -Fxq "$CHOSEN" "$NOTES_FILE"; then
    echo "$CHOSEN" >>"$NOTES_FILE"
  fi
fi
exec "$0"
