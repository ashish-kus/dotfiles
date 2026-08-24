#!/usr/bin/env bash

# reminder — schedule desktop notifications via systemd user timers.
#
#   reminder 10m "Check database"     reminder list
#   reminder 1h  "Take a break"       reminder cancel 3
#   reminder 30s "Check build"        reminder clear
#
# Sound file is overridable:  REMINDER_SOUND=/path/to/file.oga reminder 5m "..."

set -euo pipefail

UNIT_PREFIX="reminder"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/reminder"
SOUND_FILE="${REMINDER_SOUND:-/usr/share/sounds/freedesktop/stereo/complete.oga}"

usage() {
  cat <<'EOF'
Usage:
  reminder <time> <message>   set a reminder
  reminder list               show pending reminders
  reminder cancel <id>        cancel one reminder
  reminder clear              cancel all reminders reminder help               show this help
Time formats:
  30s  seconds   10m  minutes   2h  hours   1d  days
EOF
}

parse_duration() {
  local value="$1"
  if [[ "$value" =~ ^([0-9]+)(s|m|h|d)$ ]]; then
    local n="${BASH_REMATCH[1]}" unit="${BASH_REMATCH[2]}"
    case "$unit" in
    s) echo "$n" ;;
    m) echo $((n * 60)) ;;
    h) echo $((n * 3600)) ;;
    d) echo $((n * 86400)) ;;
    esac
  else
    echo "reminder: invalid duration '$value' (use 30s, 10m, 2h, 1d)" >&2
    exit 1
  fi
}

# Human-readable countdown from a number of seconds.
fmt_remaining() {
  local s=$1 out=""
  if ((s <= 0)); then
    printf 'due'
    return
  fi
  if ((s >= 86400)); then
    out+="$((s / 86400))d "
    s=$((s % 86400))
  fi
  if ((s >= 3600)); then
    out+="$((s / 3600))h "
    s=$((s % 3600))
  fi
  if ((s >= 60)); then
    out+="$((s / 60))m "
    s=$((s % 60))
  fi
  if ((s > 0)); then out+="${s}s "; fi
  printf '%s' "${out% }"
}

# Transient systemd timers do not survive a reboot. Drop any state files
# whose timer unit no longer exists so `list` never lies.
reconcile() {
  local file id
  for file in "$STATE_DIR"/*.message; do
    [[ -e "$file" ]] || continue
    id="${file##*/}"
    id="${id%.message}"
    systemctl --user cat "${UNIT_PREFIX}-${id}.timer" &>/dev/null ||
      rm -f "$STATE_DIR/$id".{message,duration,fires_at}
  done
}

next_id() {
  local max=0 file id
  for file in "$STATE_DIR"/*.message; do
    [[ -e "$file" ]] || continue
    id="${file##*/}"
    id="${id%.message}"
    [[ "$id" =~ ^[0-9]+$ ]] || continue
    if ((id > max)); then max=$id; fi
  done
  echo $((max + 1))
}

create_reminder() {
  [[ $# -ge 2 ]] || {
    echo "Usage: reminder <time> <message>" >&2
    exit 1
  }
  local duration="$1"
  shift
  local message="$*"
  [[ -n "$message" ]] || {
    echo "reminder: a message is required." >&2
    exit 1
  }

  local seconds
  seconds="$(parse_duration "$duration")"

  reconcile
  local id
  id="$(next_id)"

  printf '%s\n' "$message" >"$STATE_DIR/$id.message"
  printf '%s\n' "$duration" >"$STATE_DIR/$id.duration"
  printf '%s\n' "$(($(date +%s) + seconds))" >"$STATE_DIR/$id.fires_at"

  # The fired command reads the message, plays a sound (best effort across
  # PipeWire / PulseAudio / libcanberra), then deletes its own state.
  systemd-run \
    --user \
    --unit="${UNIT_PREFIX}-${id}.service" \
    --on-active="${seconds}s" \
    --timer-property=AccuracySec=1s \
    bash -c '
      msg_file="$1"; snd="$2"
      ( pw-play "$snd" || paplay "$snd" || canberra-gtk-play -f "$snd" ) 2>/dev/null &
      notify-send --app-name="reminder" --urgency=normal \
        "🔔 Reminder" "$(cat "$msg_file" 2>/dev/null)"
      rm -f "$msg_file" "${msg_file%.message}.duration" "${msg_file%.message}.fires_at"
    ' _ "$STATE_DIR/$id.message" "$SOUND_FILE" >/dev/null

  echo "✓ Reminder $id set for $duration"
  echo "  $message"
}

list_reminders() {
  reconcile
  local found=false file id fires_at left message now
  now=$(date +%s)

  printf "%-4s %-10s %s\n" "ID" "LEFT" "MESSAGE"
  printf "%-4s %-10s %s\n" "----" "----------" "-------------------------"

  for file in "$STATE_DIR"/*.message; do
    [[ -e "$file" ]] || continue
    found=true
    id="${file##*/}"
    id="${id%.message}"
    fires_at=$(cat "$STATE_DIR/$id.fires_at" 2>/dev/null || echo 0)
    left=$(fmt_remaining $((fires_at - now)))
    message=$(cat "$file")
    printf "%-4s %-10s %s\n" "$id" "$left" "$message"
  done

  [[ "$found" == true ]] || echo "No active reminders."
}

cancel_reminder() {
  local id="$1"
  [[ "$id" =~ ^[0-9]+$ ]] || {
    echo "reminder: invalid ID '$id'." >&2
    exit 1
  }

  systemctl --user stop "${UNIT_PREFIX}-${id}.timer" 2>/dev/null || true
  systemctl --user stop "${UNIT_PREFIX}-${id}.service" 2>/dev/null || true
  systemctl --user reset-failed \
    "${UNIT_PREFIX}-${id}.timer" "${UNIT_PREFIX}-${id}.service" 2>/dev/null || true

  rm -f "$STATE_DIR/$id".{message,duration,fires_at}
  echo "✓ Reminder $id cancelled."
}

clear_reminders() {
  local count=0 file id
  for file in "$STATE_DIR"/*.message; do
    [[ -e "$file" ]] || continue
    id="${file##*/}"
    id="${id%.message}"
    systemctl --user stop "${UNIT_PREFIX}-${id}.timer" 2>/dev/null || true
    systemctl --user stop "${UNIT_PREFIX}-${id}.service" 2>/dev/null || true
    systemctl --user reset-failed \
      "${UNIT_PREFIX}-${id}.timer" "${UNIT_PREFIX}-${id}.service" 2>/dev/null || true
    rm -f "$STATE_DIR/$id".{message,duration,fires_at}
    count=$((count + 1))
  done
  echo "✓ Cleared $count reminder(s)."
}

# --- entry point ------------------------------------------------------------

mkdir -p "$STATE_DIR"

for cmd in systemctl systemd-run notify-send; do
  command -v "$cmd" >/dev/null 2>&1 ||
    {
      echo "reminder: missing dependency: $cmd" >&2
      exit 1
    }
done

case "${1:-help}" in
list | ls) list_reminders ;;
cancel | rm)
  [[ $# -eq 2 ]] || {
    echo "Usage: reminder cancel <id>" >&2
    exit 1
  }
  cancel_reminder "$2"
  ;;
clear) clear_reminders ;;
help | -h | --help) usage ;;
add)
  shift
  create_reminder "$@"
  ;;
*) create_reminder "$@" ;;
esac
