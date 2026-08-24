#!/usr/bin/env bash
#
# reminder — a single-reminder CLI that notifies you when time's up.
#
#   reminder add 30s "Check database"   set the reminder
#   reminder show      (or: s)          message, duration, time left
#   reminder snooze                     restart it for the same duration
#   reminder cancel                     cancel it
#
# Only one reminder exists at a time; add replaces whatever was set.
# Sound override:  REMINDER_SOUND=/path/to/file.oga reminder add 5m "..."

set -euo pipefail

UNIT="reminder" # -> reminder.service / .timer
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/reminder"
SOUND_FILE="${REMINDER_SOUND:-/usr/share/sounds/freedesktop/stereo/complete.oga}"

usage() {
  cat <<'EOF'
Usage:
  reminder add <time> <message>   set the reminder
  reminder show   (or s)          show message, duration, time left
  reminder snooze                 restart it for the same duration
  reminder cancel                 cancel it

Time formats:
  30s seconds   10m minutes   2h hours   1d days
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

stop_units() {
  systemctl --user stop "$UNIT.timer" 2>/dev/null || true
  systemctl --user stop "$UNIT.service" 2>/dev/null || true
  systemctl --user reset-failed "$UNIT.timer" "$UNIT.service" 2>/dev/null || true
}

# A transient timer doesn't survive a reboot. If the state file is here but
# its timer isn't, the reminder is stale — drop it so `show` doesn't lie.
reconcile() {
  [[ -e "$STATE_DIR/current.message" ]] || return 0
  systemctl --user cat "$UNIT.timer" &>/dev/null ||
    rm -f "$STATE_DIR/current".{message,duration,fires_at}
}

# Schedule the notification. On fire it reads the message, plays a sound
# (PipeWire / PulseAudio / libcanberra, best effort), then wipes its state.
arm() {
  local seconds="$1"
  stop_units
  systemd-run \
    --user \
    --unit="$UNIT.service" \
    --on-active="${seconds}s" \
    --timer-property=AccuracySec=1s \
    bash -c '
      msg_file="$1"; snd="$2"; base="${msg_file%.message}"
      ( pw-play "$snd" || paplay "$snd" || canberra-gtk-play -f "$snd" ) 2>/dev/null &
      notify-send --app-name="reminder" --urgency=normal \
        "🔔 Reminder" "$(cat "$msg_file" 2>/dev/null)"
      rm -f "$base.message" "$base.duration" "$base.fires_at"
    ' _ "$STATE_DIR/current.message" "$SOUND_FILE" >/dev/null
}

cmd_add() {
  [[ $# -ge 2 ]] || {
    echo "Usage: reminder add <time> <message>" >&2
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
  [[ -e "$STATE_DIR/current.message" ]] && echo "Replaced the previous reminder."

  printf '%s\n' "$message" >"$STATE_DIR/current.message"
  printf '%s\n' "$duration" >"$STATE_DIR/current.duration"
  printf '%s\n' "$(($(date +%s) + seconds))" >"$STATE_DIR/current.fires_at"

  arm "$seconds"
  echo "✓ Reminder set for $duration"
  echo "  $message"
}

cmd_show() {
  reconcile
  if [[ ! -e "$STATE_DIR/current.message" ]]; then
    echo "No reminder set."
    return
  fi
  local message duration fires_at now
  message=$(cat "$STATE_DIR/current.message")
  duration=$(cat "$STATE_DIR/current.duration")
  fires_at=$(cat "$STATE_DIR/current.fires_at")
  now=$(date +%s)

  printf "Message:   %s\n" "$message"
  printf "Set for:   %s\n" "$duration"
  printf "Remaining: %s\n" "$(fmt_remaining $((fires_at - now)))"
}

cmd_snooze() {
  reconcile
  if [[ ! -e "$STATE_DIR/current.message" ]]; then
    echo "No reminder to snooze." >&2
    exit 1
  fi
  local message duration seconds
  message=$(cat "$STATE_DIR/current.message")
  duration=$(cat "$STATE_DIR/current.duration")
  seconds="$(parse_duration "$duration")"

  printf '%s\n' "$(($(date +%s) + seconds))" >"$STATE_DIR/current.fires_at"
  arm "$seconds"
  echo "✓ Snoozed for $duration"
  echo "  $message"
}

cmd_cancel() {
  reconcile
  if [[ ! -e "$STATE_DIR/current.message" ]]; then
    echo "No reminder to cancel."
    return
  fi
  stop_units
  rm -f "$STATE_DIR/current".{message,duration,fires_at}
  echo "✓ Reminder cancelled."
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

case "${1:-show}" in
add)
  shift
  cmd_add "$@"
  ;;
show | s) cmd_show ;;
snooze) cmd_snooze ;;
cancel) cmd_cancel ;;
help | -h | --help) usage ;;
*)
  usage
  exit 1
  ;;
esac
