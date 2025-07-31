#!/usr/bin/env bash
# Sends a notification once per 30 seconds if the battery is at or below 15%
# and is not charging.
#
# Author: metakirby5

DUNSTIFY_ID="/tmp/bat-notify_dunstify_id"

notify() {
  info="$(upower -i /org/freedesktop/UPower/devices/battery_BAT1)"
  percent="$(echo "$info" | awk '/percentage/{ gsub(/%/, ""); print $2 }')"
  charging="$(echo "$info" | awk '/state/{ print $2 }')"

  if [[ "$percent" -le 15 && "$charging" != 'charging' ]]; then
    # Get the dunstify id
    [ ! -z "$(cat "$DUNSTIFY_ID")" ] && id_arg="-r $(cat "$DUNSTIFY_ID")"

    dunstify \
      -a "bat-notify" \
      -p $id_arg > "$DUNSTIFY_ID" \
      -u C "Battery at ${percent}%!"
  fi
}

acpi_listen | while read -r line && [[ "$line" == ac_adapter* ]]; do
  sleep 5
  notify
done &

while true; do
  notify
  sleep 30
done &

wait
