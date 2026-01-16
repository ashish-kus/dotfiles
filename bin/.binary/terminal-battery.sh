#!/usr/bin/env bash

### Basic configuration: Where to find stuff, how to behave.
# Script version
VERSION='20231201.02'
# Where to find the power supply stuff:
power_supply_sysdir='/sys/class/power_supply'
# The batteries to use
batteries=("${power_supply_sysdir}"/BAT*)
# The power supplies to use
power_supplies=("${power_supply_sysdir}"/{A*,*source*})

#   linux-terminal-battery-status: Prints information about batteries and power supplies.
#   Copyright (C) 2023  dreieckli (https://gitlab.com/dreieckli/)
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.

printusage() {
  msg "Prints information about batteries and power supplies."
  newline
  msg "Usage:"
  msg "    $0 [-b battery [-b battery [...]]] [-a power-supply [-a power-supply [...]]]"
  msg "or: $0 -h|--help|-V|--version"
  newline
  msg "-b: Specify a battery below '${power_supply_sysdir}/' to print information for,"
  msg "-a: Specify a power supply below '${power_supply_sysdir}/' to print information for."
  msg "-h|--help: Display this help."
  msg "-V|--version: Display version ('${VERSION}')."
  newline
  msg "-b and -a can be specified multiple times to print information for more than one."
  newline
  msg "If no '-b' or '-a' option is given, print information about all the following:"
  newline
  msg "Batteries:"
  msg "${batteries[@]}"
  newline
  msg "Power Supplies:"
  msg "${power_supplies[@]}"
  newline
  msg "As well as batteries of devices connected via KDE Connect, if 'kdeconnect-cli' and 'qdbus' executables are found."
  newline
  msg " ------------------------------------------------------------------ "
  newline
  msg "linux-terminal-battery-status, Copyright (C) 2023 dreieckli"
  msg "(https://gitlab.com/dreieckli/)."
  newline
  msg "This program is free software: you can redistribute it and/or modify"
  msg "it under the terms of the GNU General Public License as published by"
  msg "the Free Software Foundation, either version 3 of the License, or"
  msg "(at your option) any later version."
  newline
  msg "This program is distributed in the hope that it will be useful,"
  msg "but WITHOUT ANY WARRANTY; without even the implied warranty of"
  msg "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the"
  msg "GNU General Public License for more details."
  newline
  msg "You should have received a copy of the GNU General Public License"
  msg "along with this program.  If not, see <https://www.gnu.org/licenses/>."
}

### Helper functions

msg_nonl() {
  # Prints all it's arguments, without newline.
  printf '%s' "$@"
}

msg() {
  # Prints all it's arguments, line by line.
  printf '%s\n' "$@"
}

newline() {
  # Just prints a newline.
  printf '\n'
}

errmsg() {
  # Prints all it's arguments to stderr, line by line.
  msg "$@" >/dev/stderr
}

exiterror() {
  local exitcode
  local message
  # Exits the programme with a definable exitcode after printing a message to stderr.
  # Arguments:
  #   $1, optional: Error message (default: A generic error message)
  #   $2, optional: Exitcode (default: 1)
  if [ $# -ge 1 ]; then
    message="$1"
  else
    message="$0: Generic error. Aborting."
  fi
  if [ $# -ge 2 ]; then
    exitcode="$2"
  else
    exitcode=1
  fi
  errmsg "${message}"
  exit "${exitcode}"
}

calculate() {
  # Calculates '$1 <operation> $2', where <operation> is a mathematical operator specified by "$3" and defaults to '+', if not specified. If "$4" is non-empty, this sets the number of decimals to output, otherwise it defaults to 2 decimals.
  if [ $# -lt 2 ]; then
    exiterror "Error in '${FUNCNAME[0]}': Too few arguments. This is a bug in $0, please report. Aborting." 10
  fi
  VAL1="${1}"
  VAL2="${2}"
  OPERATION="+"
  DECIMALS=2
  if [ -n "${3}" ]; then
    OPERATION="${3}"
  fi
  if [ -n "${4}" ]; then
    DECIMALS="${4}"
  fi
  awk "BEGIN{printf(\"%0.${DECIMALS}f\",${VAL1}${OPERATION}${VAL2})}"
}

divide() {
  # Divides "$1" by "$2", outputting up to 2 decimals.
  if [ $# -lt 2 ]; then
    exiterror "Error in '${FUNCNAME[0]}': Too few arguments. This is a bug in $0, please report. Aborting." 10
  fi
  calculate "$1" "$2" '/' '2'
}

percentage() {
  # Calculates how much is $1 relative to $2, in percent, output with '%' symbol and one decimal.
  if [ $# -lt 2 ]; then
    exiterror "Error in '${FUNCNAME[0]}': Too few arguments. This is a bug in $0, please report. Aborting." 10
  fi
  printf '%s%%\n' "$(calculate "$(calculate "$1" '100' '*')" "$2" '/')"
}

frommicro() {
  # Divides $1 by 1000000. Output: 2 Decimal numbers.
  if [ $# -lt 1 ]; then
    exiterror "Error in '${FUNCNAME[0]}': Too few arguments. This is a bug in $0, please report. Aborting." 10
  fi
  calculate "$1" '1e6' '/'
}

checkcmd() {
  # Checks if a command is available. Returns zero exit status if it is, non zero if it is not.
  # Arguments:
  #   $1: Command to check for.
  if [ $# -lt 1 ]; then
    exiterror "Error in '${FUNCNAME[0]}': Too few arguments. This is a bug in $0, please report. Aborting." 10
  fi
  command -v "$1" >/dev/null
}

checkstring() {
  # Checks if $1 is non-empty and not equal to 'unknown' (case insensitive). Returns zero if test succeeds, 1 otherwise.
  if [ $# -lt 1 ]; then
    exiterror "Error in '${FUNCNAME[0]}': Too few arguments. This is a bug in $0, please report. Aborting." 10
  fi
  [ -n "$1" ] && [ "${1,,}" != "unknown" ]
}

### Battery status output functions

system-batteries() {
  # Displays information about system batteries.
  # Arguments: Directories of '/sys'-entry of batteries to display information for.
  for battery in "$@"; do
    [ -d "${battery}" ] || continue # Skip non-existing battery directories, e.g. if wildcards do not match.
    {
      local alarm="$(<"${battery}/alarm")"
      local charge_percentage="$(<"${battery}/capacity")"
      local charge_full="$(<"${battery}/charge_full")"
      local charge_full_design="$(<"${battery}/charge_full_design")"
      local charge_now="$(<"${battery}/charge_now")"
      local current="$(<"${battery}/current_now")"
      local cycles="$(<"${battery}/cycle_count")"
      local energy_full="$(<"${battery}/energy_full")"
      local energy_full_design="$(<"${battery}/energy_full_design")"
      local energy_now="$(<"${battery}/energy_now")"
      local name="$(<"${battery}/model_name")"
      local power="$(<"${battery}/power_now")"
      local present="$(<"${battery}/present")"
      local status="$(<"${battery}/status")"
      local technology="$(<"${battery}/technology")"
      local voltage="$(<"${battery}/voltage_now")"
      local voltage_min_design="$(<"${battery}/voltage_min_design")"
      checkcmd acpi && checkcmd grep && checkcmd sed && {
        local batnumber="$(basename "${battery}" | sed -En 's|BAT([0-9])+|\1|p')"
        if [ -n "${batnumber}" ]; then
          local acpi_output="$(acpi -b | grep -E "^Battery ${batnumber}:")"
          local time_remain="$(awk -F ',' '{print $3}' <<<"${acpi_output}" | sed -E -e 's|^[[:space:]]*||')"
        fi
      }
    } 2>/dev/null

    local title="=== $(basename "${battery}")"
    checkstring "${name}" && title+=" \"${name}\""
    checkstring "${technology}" && title+=" (${technology})"
    title+=": ==="

    # [ "${#batteries[@]}" -gt 1 ] && msg "${title}" # Print title only if there is more than one.
    msg "${title}"

    msg_nonl "Status:  "
    checkstring "${charge_percentage}" && msg_nonl "${charge_percentage}%" || msg_nonl "Unknown %"
    checkstring "${status}" && msg_nonl " ${status}" || msg_nonl " Unknown charging status"
    if [ "${present}" -eq 1 ]; then
      msg_nonl " (present)"
    elif [ "${present}" -eq 0 ]; then
      msg_nonl " (not present)"
    else
      msg_nonl " (unknown presence)"
    fi
    checkstring "${time_remain}" && {
      if [ "${time_remain}" == "charging" ]; then
        msg_nonl ", infinite time until finish"
      else
        msg_nonl ", ${time_remain}"
      fi
    }
    newline

    if checkstring "${energy_now}"; then
      msg_nonl "Charge:  $(frommicro "${energy_now}") Wh"
      if checkstring "${energy_full}"; then
        msg_nonl " / $(frommicro "${energy_full}") Wh = $(percentage "${energy_now}" "${energy_full}")"
      fi
    elif checkstring "${charge_now}"; then
      msg_nonl "Charge:  $(frommicro "${charge_now}") Ah"
      if checkstring "${charge_full}"; then
        msg_nonl " / $(frommicro "${charge_full}") Ah = $(percentage "${charge_now}" "${charge_full}")"
      fi
    fi
    newline

    if checkstring "${energy_full}"; then
      if checkstring "${energy_full_design}"; then
        msg "Health:  $(frommicro "${energy_full}") Wh / $(frommicro "${energy_full_design}") Wh = $(percentage "${energy_full}" "${energy_full_design}")"
      fi
    elif checkstring "${charge_full}"; then
      if checkstring "${charge_full_design}"; then
        msg "Health:  $(frommicro "${charge_full}") Ah / $(frommicro "${charge_full_design}") Ah = $(percentage "${charge_full}" "${charge_full_design}")"
      fi
    fi

    if checkstring "${power}"; then
      msg_nonl "Power:  "
      if [ "${status,,}" == "charging" ]; then
        msg_nonl '+'
      elif [ "${status,,}" == "discharging" ]; then
        msg_nonl '-'
      else
        msg_nonl ' '
      fi
      msg_nonl "$(frommicro "${power}") W"
      checkstring "${voltage}" && msg_nonl " ($(calculate "$(frommicro "${power}")" "$(frommicro "${voltage}")" '/') A)"
      newline
    elif checkstring "${current}"; then
      msg_nonl "Current:"
      if [ "${status,,}" == "charging" ]; then
        msg_nonl '+'
      elif [ "${status,,}" == "discharging" ]; then
        msg_nonl '-'
      else
        msg_nonl ' '
      fi
      msg_nonl "$(frommicro "${current}") A"
      checkstring "${voltage}" && msg_nonl " ($(calculate "$(frommicro "${current}")" "$(frommicro "${voltage}")" '*') W)"
      newline
    fi

    checkstring "${voltage}" && {
      msg_nonl "Voltage: $(frommicro "${voltage}") V"
      checkstring "${voltage_min_design}" && msg_nonl " (Min.: $(frommicro "${voltage_min_design}") V)"
      newline
    }

    checkstring "${cycles}" && [ "${cycles}" -ne 0 ] && msg "Cycles:  ${cycles}"

    ## Try to guess the unit that is used by the battery for the 'alarm' value.
    if checkstring "${energy_now}"; then
      alarmunit=' Wh'
    elif checkstring "${charge_now}"; then
      alarmunit=' Ah'
    else
      alarmunit=''
    fi
    checkstring "${alarm}" && msg "Alarm:   $(frommicro "${alarm}")${alarmunit}"

    newline
  done
}

power-supplies() {
  # Displays information about system power supplies.
  # Arguments: Directories of '/sys'-entry of power supplies to display information for.
  for power_supply in "$@"; do
    [ -d "${power_supply}" ] || continue # Skip non-existing power supply directories, e.g. if wildcards do not match.
    {
      local type="$(<"${power_supply}/type")"
      local current_max="$(<"${power_supply}/current_max")"
      local current_now="$(<"${power_supply}/current_now")"
      local name="$(<"${power_supply}/model_name")"
      local online="$(<"${power_supply}/online")"
      local usb_type="$(<"${power_supply}/usb_type")"
      local voltage_max="$(<"${power_supply}/voltage_max")"
      local voltage_min="$(<"${power_supply}/voltage_min")"
      local voltage_now="$(<"${power_supply}/voltage_now")"
    } 2>/dev/null

    local title="=== $(basename "${power_supply}")"
    checkstring "${name}" && title+=" \"${name}\""
    checkstring "${type}" && title+=" (${type}"
    checkstring "${usb_type}" && title+=" ${usb_type}"
    title+=")"
    title+=": ==="

    msg "${title}"

    msg_nonl "Status:  "
    if [ "${online}" -eq 1 ]; then
      msg_nonl "online"
    elif [ "${online}" -eq 0 ]; then
      msg_nonl "offline"
    else
      msg_nonl "(unknown status)"
    fi
    newline

    checkstring "${voltage_now}" && [ "${voltage_now}" -ne 0 ] && {
      msg_nonl "Voltage: $(frommicro "${voltage_now}") V"
      checkstring "${voltage_min}" || checkstring "${voltage_max}" && {
        msg_nonl " ("
        if checkstring "${voltage_min}" && checkstring "${voltage_max}"; then
          msg_nonl "Min.: $(frommicro "${voltage_min}") V, "
          msg_nonl "Max.: $(frommicro "${voltage_max}") V"
        elif checkstring "${voltage_min}"; then
          msg_nonl "Min.: $(frommicro "${voltage_min}") V"
        elif checkstring "${voltage_max}"; then
          msg_nonl "Max.: $(frommicro "${voltage_max}") V"
        fi
        msg_nonl ")"
      }
      newline
    }

    checkstring "${current_now}" && [ "${current_now}" -ne 0 ] && {
      msg_nonl "Current: $(frommicro "${current_now}") A"
      checkstring "${current_max}" && msg_nonl " (Max.: $(frommicro "${current_max}") A)"
      newline
    }

    newline
  done
}

otherdevices() {
  checkcmd kdeconnect-cli || return
  checkcmd qdbus || return

  mdata="$(kdeconnect-cli -a 2>/dev/null)" # meta data returned from kdeconnect-cli

  [ -z "$mdata" ] && return # return if no meta data is available

  id="$(awk "BEGIN{print ${mdata#*:}}")"
  devicename="$(awk "BEGIN{print ${mdata}")"

  battery="$(
    qdbus \
      org.kde.kdeconnect.daemon \
      /modules/kdeconnect/devices/"${id}"/battery \
      org.kde.kdeconnect.device.battery.charge
  )"

  state="$(
    qdbus \
      org.kde.kdeconnect.daemon \
      /modules/kdeconnect/devices/"${id}"/battery \
      org.kde.kdeconnect.device.battery.isCharging
  )" # returns boolean based on chrarging state

  "${state}" && state="Charging" || state="Not Charging"

  msg "=== ${devicename}: ==="
  msg "Status:  ${battery}% ${state}"
}

custom_batteries=()
custom_power_supplies=()
if [ $# -ge 1 ]; then
  case "$1" in
  "-h" | "--help")
    printusage
    exit 0
    ;;
  "-V" | "--version")
    msg "${VERSION}"
    exit 0
    ;;
  "-b")
    if [ $# -lt 2 ]; then
      errmsg "$0: Error: '$1' option needs an argument."
      errmsg "Run '$0 -h' for usage information."
      exiterror "Aborting." 1
    else
      custom_batteries+=("${power_supply_sysdir}/$2")
    fi
    shift
    ;;
  "-a")
    if [ $# -lt 2 ]; then
      errmsg "$0: Error: '$1' option needs an argument."
      errmsg "Run '$0 -h' for usage information."
      exiterror "Aborting." 1
    else
      custom_power_supplies+=("${power_supply_sysdir}/$2")
    fi
    shift
    ;;
  *)
    errmsg "$0: Error: Unsupported argument '$1'."
    errmsg "Run '$0 -h' for usage information."
    exiterror "Aborting." 1
    ;;
  esac
  shift
fi

if [ "${#custom_batteries[@]}" -ge 1 ] || [ "${#custom_power_supplies[@]}" -ge 1 ]; then
  for custom_battery in "${custom_batteries[@]}"; do
    system-batteries "${custom_battery}"
  done
  for custom_power_supply in "${custom_power_supplies[@]}"; do
    power-supplies "${custom_power_supply}"
  done
else
  system-batteries "${batteries[@]}"
  power-supplies "${power_supplies[@]}"
  otherdevices
fi
