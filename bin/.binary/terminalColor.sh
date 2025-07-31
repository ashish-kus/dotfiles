#!/bin/bash

THEME_DIR="${HOME}/.config/huegen/themes"
SEQUENCE_FILE="$THEME_DIR/sequence"

notify() {
  command -v notify-send &>/dev/null && notify-send "Huegen Theme Loader" "$1"
}

# Ensure $HOME is set
if [ -z "$HOME" ]; then
  notify "Error: HOME variable is not set."
  exit 1
fi

# Ensure theme directory exists
if [ ! -d "$THEME_DIR" ]; then
  notify "Theme directory not found: $THEME_DIR"
  exit 0
fi

# Source the sequence file
if [ -f "$SEQUENCE_FILE" ] && [ -r "$SEQUENCE_FILE" ]; then
  # shellcheck source=/dev/null
  source "$SEQUENCE_FILE"
else
  notify "Missing or unreadable 'sequence' file."
  exit 0
fi

# ───────────────────────────────────────────────────────────────
# Reload terminal colors
# ───────────────────────────────────────────────────────────────

# Reload Kitty
reload_kitty() {
  command -v kitty &>/dev/null || return
  for pid in $(pgrep -x kitty); do
    kitty @ --to "unix:/tmp/kitty-$pid" set-colors --all ~/.config/kitty/current-theme.conf 2>/dev/null
  done
}

# Reload Alacritty (must be configured to reload on SIGUSR1)
reload_alacritty() {
  command -v alacritty &>/dev/null && pkill -SIGUSR1 alacritty 2>/dev/null
}

# Reload Foot (also listens to SIGUSR1)
reload_foot() {
  command -v foot &>/dev/null && pkill -SIGUSR1 foot 2>/dev/null
}

# Reload tmux panes by sending "source" command into each
reload_tmux() {
  if command -v tmux &>/dev/null; then
    tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index}' | while read -r pane; do
      tmux send-keys -t "$pane" "source $SEQUENCE_FILE" C-m
    done
  fi
}

# Run all reloads
reload_kitty
reload_alacritty
reload_foot
reload_tmux
