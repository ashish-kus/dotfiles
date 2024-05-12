#!/bin/bash

if pgrep -x "create_ap" &>/dev/null; then
  icon="󱜠"
  class="connected"
  # list=$(sudo create_ap --list-clients ap0)
  # list=$(echo "$list" | sed -z 's/\n/\\n/g')
else
  icon="󱜡"
  class="connected"
fi

cat << EOF
{ "text":"$icon", "tooltip":"$tooltip"}  
EOF

# echo "nandu"
