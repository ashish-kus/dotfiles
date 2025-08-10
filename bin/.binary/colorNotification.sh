#!/bin/bash

msg=""
for i in {0..7}; do
  color=$(tput setaf "$i")
  reset=$(tput sgr0)
  msg+="${color}█ $i${reset}  "
done

# Strip escape codes (because notify-send doesn't render them)
clean_msg=$(echo "$msg" | sed 's/\x1b\[[0-9;]*m//g')

notify-send "$clean_msg"
