#!/bin/bash

pgrep -x waybar &>/dev/null && killall -q waybar 
waybar &>/dev/null &

