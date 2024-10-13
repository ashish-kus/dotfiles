#!/usr/bin/env bash

check() {
  command -v "$1" 1>/dev/null
}

notify() {
  check notify-send && {
    notify-send -a "UpdateCheck Waybar" "$@"
    return
  }
  echo "$@"
}



check aur || {
  notify "Ensure aurutils is installed"
  cat <<EOF
  {"text":"ERR","tooltip":"aurutils or pacman-contrib is not installed"}
EOF
  exit 1
}

check checkupdates || {
  notify "Ensure pacman-contrib is installed"
  exit 1
}
IFS=$'\n'$'\r'

killall -q checkupdates

cup() {
  checkupdates --nocolor
  pacman -Qm | aur vercmp
}
mapfile -t updates < <(cup)

text=${#updates[@]}


tooltip="<b>$text  updates (arch+aur) </b>\n"
# tooltip+=" <b>$(stringToLen "PkgName" 20) $(stringToLen "PrevVersion" 20) $(stringToLen "NextVersion" 20)</b>\n"
[ "$text" -eq 0 ] && text="" || text=" $text"

cat <<EOF
{ "text":"$text", "tooltip":"$tooltip"}
EOF
