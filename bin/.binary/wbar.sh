#!/bin/bash

pgrep -x waybar &>/dev/null && killall -q waybar -c ~/.config/waybar/config.jsonc
waybar &>/dev/null &

