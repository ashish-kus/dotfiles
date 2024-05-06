#!/bin/bash

if [ -f /sys/class/power_supply/BAT*/power_now ]; then
  powerDraw="$(($(cat /sys/class/power_supply/BAT*/power_now)/1000000))W"
fi
cat << EOF
{ "text":"$powerDraw", "tooltip":"UPDATES: power Draw"}  
EOF
