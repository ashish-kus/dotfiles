#!/bin/bash

net_icon=""
default_iface=$(ip route | awk '/^default/ {print $5}' | head -n1)

# Check if default interface exists
if [[ -n "$default_iface" ]]; then
  # Ping to check internet connectivity
  if ping -q -c 1 -W 1 1.1.1.1 &>/dev/null; then
    if [[ "$default_iface" == wl* ]]; then
      net_icon="" # Wi-Fi
    elif [[ "$default_iface" == en* || "$default_iface" == eth* ]]; then
      net_icon="󰈀" # Ethernet
    fi
  else
    net_icon="󱐅"
  fi
else
  net_icon="󱐅"
fi

echo "$net_icon"
