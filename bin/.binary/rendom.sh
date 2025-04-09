#!/bin/bash

INTERNAL_MONITOR="eDP-1"
EXTERNAL_MONITOR=$(hyprctl -j monitors | jq -r ".[] | select(.name != \"$INTERNAL_MONITOR\") | .name" | head -n 1)

echo $EXTERNAL_MONITOR
