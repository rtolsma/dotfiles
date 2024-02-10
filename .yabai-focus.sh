#!/bin/bash
#
set +e

# The target display ID
CURR_DISPLAY=$(yabai -m query --displays --display | jq '.id' | head -n 1)
TARGET_DISPLAY=${1:-$CURR_DISPLAY}

# Find the first visible window on the target display
VISIBLE_WINDOW_ID=$(yabai -m query --windows --display $TARGET_DISPLAY  | jq 'sort_by(.stack_index) | .[] | select(.["is-visible"] == true and .["is-hidden"] == false and .["is-minimized"] == false and .["subrole"] == "AXStandardWindow" and .["layer"] == "normal") | .id' | head -n 1)

echo $VISIBLE_WINDOW_ID

QUERY=$(yabai -m query --windows --display $TARGET_DISPLAY  | jq 'sort_by(.stack_index) | .[] | select(.["is-visible"] == true and .["is-hidden"] == false and .["is-minimized"] == false and .["subrole"] == "AXStandardWindow" and .["layer"] != "normal")')

echo $QUERY

# If a visible window is found, focus on it
if [ ! -z "$VISIBLE_WINDOW_ID" ]; then
    yabai -m window --focus $VISIBLE_WINDOW_ID
else
    echo "No visible window found on display $TARGET_DISPLAY"
fi
