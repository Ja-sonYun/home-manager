#!/bin/sh

function make_alias() {
    local name="$1"
    local click_script="$2"

    sketchybar --add alias "$1" right                                   \
        --set "$1" alias.color=$LABEL_COLOR                             \
                   drawing=on                                           \
                   padding_right=-20                                    \
                   padding_left=-2                                      \
                   script='sketchybar --set calendar popup.drawing=off' \
                   click_script="$click_script"                         \
        --subscribe "$1" mouse.entered
}

# make_alias "Control Center,com.apple.TextInputMenuAgent" "open /System/Library/PreferencePanes/Keyboard.prefPane"
# make_alias "Control Center,FocusModes"                   "$PLUGIN_DIR/open_menubar_controlcenter"
make_alias "Control Center,WiFi"                         "$PLUGIN_DIR/open_menubar_controlcenter"
# make_alias "Control Center,com.apple.weather.menu"       "open /System/Applications/Weather.app"
