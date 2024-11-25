#!/bin/bash

# File containing tasks
TASK_FILE="$HOME/.todo"

# Symbol to identify not-done tasks
NOT_DONE_SYMBOL=""

# Check if the task file exists
if [ ! -f "$TASK_FILE" ]; then
  echo "{\"text\": \" 0\", \"tooltip\": [], \"tasks\": []}"
  exit 0
fi

# Extract not-done tasks
NOT_DONE_TASKS=$(grep "^$NOT_DONE_SYMBOL" "$TASK_FILE" | cut -c 2-) # Remove the symbol

# Count the number of not-done tasks
TASK_COUNT=$(echo "$NOT_DONE_TASKS" | wc -l)

# Convert tasks into a JSON array (using jq)
#TASKS_ARRAY=$(echo "$NOT_DONE_TASKS" | jq -R -s -c 'split("\n")[:-1]')

# Output for Waybar in JSON format using EOF to format properly
cat <<EOF
{"text": " $TASK_COUNT"}
EOF
# { "text": " $TASK_COUNT", "tooltip": $TASKS_ARRAY }
