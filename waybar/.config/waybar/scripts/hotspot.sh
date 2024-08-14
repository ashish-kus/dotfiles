#!/bin/bash

# Define default values
# Function to display usage
usage() {
    echo "Usage: $0 [-i wifi_interface] [-s share_interface] [-n ssid] [-p passphrase] [-c channel] [-a action]"
    echo "  -i wifi_interface   Wi-Fi interface to use (default: wlan0)"
    echo "  -s share_interface  Internet-sharing interface (default: eth0)"
    echo "  -n ssid             SSID for the hotspot (default: MyHotspot)"
    echo "  -p passphrase       Passphrase for the hotspot (default: 12345678)"
    echo "  -c channel          Channel to use (default: auto)"
    echo "  -a action           Action to perform: start, stop, or toggle (default: toggle)"
    exit 1
}

WIFI_INTERFACE="wlan0"
SHARE_INTERFACE="eth0"
SSID="MyHotspot"
PASSPHRASE="12345678"
CHANNEL="default"
ACTION="toggle"

# check command exist or not.
check() {
  command -v "$1" 1>/dev/null
}

# notify function
notify() {
  check notify-send && {
    notify-send -a "waybar-Hotspot" "$@"
    return
  }
  echo "$@"
}

# json formatter function for waybar
function json() {
  jq --unbuffered --null-input --compact-output \
    --arg text "$1" \
    --arg alt "$2" \
    --arg tooltip "$3" \
    --arg class "$4" \
    '{"text": $text, "alt": $alt, "tooltip": $tooltip, "class": $class}'
}

# Display a form to the user using zenity
form_output=$(zenity --forms --title="Hotspot Toggle" --text="Enter Hotspot Details" \
    --add-entry="Wi-Fi Interface (default: wlan0)" \
    --add-entry="Share Interface (default: eth0)" \
    --add-entry="SSID (default: MyHotspot)" \
    --add-entry="Passphrase (default: 12345678)" \
    --add-entry="Channel (default: auto)" \
    --add-combo="Action" --combo-values="toggle|start|stop")

if [ $? -eq 0 ]; then
    IFS="|" read WIFI_INTERFACE SHARE_INTERFACE SSID PASSPHRASE CHANNEL ACTION <<< "$form_output"

# Parse command-line options
while getopts ":i:s:n:p:c:a:h" opt; do
    case ${opt} in
        i)
            WIFI_INTERFACE=$OPTARG
            ;;
        s)
            SHARE_INTERFACE=$OPTARG
            ;;
        n)
            SSID=$OPTARG
            ;;
        p)
            PASSPHRASE=$OPTARG
            ;;
        c)
            CHANNEL=$OPTARG
            ;;
        a)
            ACTION=$OPTARG
            ;;
        h)
            usage
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage
            ;;
    esac
done


# Use default values if inputs are empty
WIFI_INTERFACE=${WIFI_INTERFACE:-wlan0}
SHARE_INTERFACE=${SHARE_INTERFACE:-eth0}
SSID=${SSID:-MyHotspot}
PASSPHRASE=${PASSPHRASE:-12345678}
CHANNEL=${CHANNEL:-default}
ACTION=${ACTION:-toggle}

# Function to start the hotspot
start_hotspot() {
    echo "Starting hotspot..."
    if [ "$CHANNEL" == "default" ]; then
        sudo create_ap $WIFI_INTERFACE $SHARE_INTERFACE $SSID $PASSPHRASE
    else
        sudo create_ap -c $CHANNEL $WIFI_INTERFACE $SHARE_INTERFACE $SSID $PASSPHRASE
    fi
    notify "Hotspot started $SSID : $PASSPHRASE"
}

# Function to stop the hotspot
stop_hotspot() {
    echo "Stopping hotspot..."
    sudo pkill create_ap
}

# Function to toggle the hotspot
toggle_hotspot() {
    if pgrep -x "create_ap" > /dev/null; then
        stop_hotspot
    else
        start_hotspot
    fi
}

# Execute the action
case $ACTION in
    start)
        start_hotspot
        ;;
    stop)
        stop_hotspot
        ;;
    toggle)
        toggle_hotspot
        ;;
    *)
        echo "Invalid action: $ACTION" >&2
        usage
        ;;
esac

while true; do


  sleep "$interval"
done
exit 0

