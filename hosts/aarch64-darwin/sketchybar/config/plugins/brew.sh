#!/bin/sh

source "$SKETCHYBAR_CONFIG_DIR/colors.sh"

# args+=(--set $NAME icon.color=$COLOR)
# args+=(--animate tanh 15 --set $NAME label.y_offset=5 label.y_offset=0)
sketchybar -m "${args[@]}"
