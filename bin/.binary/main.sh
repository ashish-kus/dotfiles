BF_SEP=" "
BF_GAP=4
BF_COL1=2
BF_COL2=7
BF_COL3=6


  # shellcheck disable=2034
  {
      c1='[31m'; c2='[32m'
      c3='[33m'; c4='[34m'
      c5='[35m'; c6='[36m'
      c7='[37m'; c8='[38m'
  }


log(){
    [ "$2" ] || return
    name=$1
    # shellcheck disable=2046,2086
    {
        set -f
        set +f -- $2
        info=$*
    }
    printf '[%sC' "$(($ascii_width + $BF_GAP))"
    printf '[3%s;1m%s[m' "${BF_COL1}" "$name"
    printf '[%sD[%sC' "${#name}" "${PF_INFOALIGN:-$(($info_length + 1))}"
    printf %s "$BF_SEP"
    printf '[3%sm%s[m\n' "${BF_COL2}" "$info"
    info_height=$((${info_height:-0} + 1))
}

get_title() {
    user=${USER:-$(id -un)}
    hostname=${HOSTNAME:-${hostname:-$(hostname)}}
    log "[3${BF_COL3:-1}m${user}${c7}@[3${BF_COL3:-1}m${hostname}" " "
}

get_model(){
  vandor=$(cat /sys/class/power_supply/BAT*/manufacturer)
  model=$(cat /sys/class/power_supply/BAT*/model_name)
  log "model" "$vandor $model"
}

get_charge(){
  charge="$(cat /sys/class/power_supply/BAT0/capacity)%"
  Energy_now="$(cat /sys/class/power_supply/BAT0/energy_now)"
  Draw="$(cat /sys/class/power_supply/BAT0/power_now)"
  log "charge" "$charge $TIME"
}

get_power(){
  powerDraw="$(($(cat /sys/class/power_supply/BAT0/power_now)/1000000))W"
  governer="$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
  log "power" "$powerDraw $governer"
}

get_state(){
  online=$(cat /sys/class/power_supply/AC/online)
  if [[ $online -eq 1 ]]; then
     powerInput="connected"
  else
    powerInput="not connected"
  fi
  status="$(cat /sys/class/power_supply/BAT0/status)"
  log "state" "$powerInput & $status"
}

get_health(){
   health=$(($(cat /sys/class/power_supply/BAT0/energy_full) * 100 / $(cat /sys/class/power_supply/BAT0/energy_full_design)))
   cycle=$(cat /sys/class/power_supply/BAT0/cycle_count)
   log "health" "$health% |  cycles $cycle"
}

# get_ascii() {
#   printf '[3${BF_COL3:-1}m'
#   _header="🬭🬭🬭█████🬭🬭🬭"

#   _footer="🮂🮂🮂🮂🮂🮂🮂🮂🮂🮂🮂"
#   _blank="█         █"
#   _full="█░░░░░░░░░█"
#   _ascii_height=5 # Changing this will change the height of the battery (Width can be manipulated using the upper string variables)

#   _charge=$(cat /sys/class/power_supply/BAT*/capacity) # This is the battery percentage
#   _div=$((100 / _ascii_height))                        # The divisor for the battery
#   _level=$((_charge / _div))                           # Level corresponds to the print level
#   printf '\n'
#   printf '%s\n' "$_header"
#   printf "$_blank%.0s\n" $(seq 1 $((_ascii_height - _level)))
#   printf "$_full%.0s\n" $(seq 1 $_level)
#   printf '%s\n' "$_footer"
#   ascii_width=10
#   ascii_height=7
#   printf '[m[%sA' "$ascii_height"
# }


get_ascii(){
  _charge=$(cat /sys/class/power_supply/BAT*/capacity) # This is the battery percentage
  
  if [[ $_charge == 100 ]]; then
     var1="  █   FULL  █"
  else
    var1="  █   $_charge%   █"
  fi  
  online=${online:-$(cat /sys/class/power_supply/AC/online)}
    if [[ $online -eq 1 ]]; then
       var2=${var2:-"🗲"}
    else
       var2=${var2:-" "}
    fi

  

cat << EOF
  🬭🬭🬭█████🬭🬭🬭
  █         █
$var1
  █         █
  █    $var2    █
  █         █
  🮂🮂🮂🮂🮂🮂🮂🮂🮂🮂🮂
EOF
   ascii_width=10
   ascii_height=7
   printf '[m[%sA' "$ascii_height"

}

main(){
        set -f
        set +f ascii title model charge power state health  
        for info; do
            command -v "get_$info" >/dev/null || continue
            [ "${#info}" -gt "${info_length:-0}" ] &&
                info_length=${#info}
        done
       info_length=$((info_length + 1 ))
        for info; do "get_$info"; done
    [ "${info_height:-0}" -lt "${ascii_height:-0}" ] &&
        cursor_pos=$((ascii_height - info_height - 1 ))

    while [ "${i:=0}" -le "${cursor_pos:-0}" ]; do 
      printf '\n' 
      i=$((i + 1))
    done

  }
main "$@"
