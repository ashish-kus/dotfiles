#!/usr/bin/env bash
#
#
##############    [ Battery [ low notification script ]    ######################
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

# Battery low notification script
# --------------------------------
# Sends a notification every 30 seconds when:
#   - Battery percentage is <= 15%
#   - Battery is NOT charging
#
# The notification is updated (not duplicated) using dunstify.
# It also reacts immediately when the AC adapter is plugged/unplugged.
#
# File used to store the notification ID
# This allows us to replace the same notification instead of spamming new ones
DUNSTIFY_ID="/tmp/bat-notify_dunstify_id"

# Function to check battery status and send notification if needed
notify() {
  # Get detailed battery information from upower
  info="$(upower -i /org/freedesktop/UPower/devices/battery_BAT1)"

  # Extract battery percentage (remove % sign)
  percent="$(echo "$info" | awk '/percentage/{ gsub(/%/, ""); print $2 }')"

  # Extract battery state (charging / discharging / fully-charged)
  charging="$(echo "$info" | awk '/state/{ print $2 }')"

  # Only notify if battery is low AND not charging
  if [[ "$percent" -le 15 && "$charging" != 'charging' ]]; then

    # If a previous notification ID exists, reuse it
    # This replaces the old notification instead of creating a new one
    [ -s "$DUNSTIFY_ID" ] && id_arg="-r $(cat "$DUNSTIFY_ID")"

    # Send critical notification and print its ID
    # The ID is saved so it can be reused next time
    dunstify \
      -a "bat-notify" \
      -u critical \
      -p $id_arg "Battery at ${percent}%!" >"$DUNSTIFY_ID"
  fi
}

# Listen for AC adapter events (plug / unplug)
# This allows instant notification when charger status changes
acpi_listen | while read -r line && [[ "$line" == ac_adapter* ]]; do
  sleep 5 # Give the system time to update battery state
  notify
done &

# Periodic battery check (every 30 seconds)
while true; do
  notify
  sleep 30
done &

# Keep the script running so background jobs don't exit
wait
