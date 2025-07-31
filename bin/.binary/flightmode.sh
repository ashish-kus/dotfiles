#!/bin/bash

# Get current radio status
status=$(nmcli radio all)

if echo "$status" | grep -q "enabled"; then
  echo "🛫 Enabling Flight Mode (turning off radios)..."
  nmcli radio all off
else
  echo "📶 Disabling Flight Mode (turning on radios)..."
  nmcli radio all on
fi
