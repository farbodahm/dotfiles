#!/usr/bin/env bash
# wlogout power menu: one compact row of fixed-size tiles, centered on the focused monitor.

# Toggle: close if already open
if pgrep -x "wlogout" > /dev/null; then
    pkill -x "wlogout"
    exit 0
fi

TILE_W=128   # logical px
TILE_H=128
GAP=12
BUTTONS=6

read -r W H < <(hyprctl -j monitors | jq -r '.[] | select(.focused==true) | "\((.width / .scale) | floor) \((.height / .scale) | floor)"')

ROW_W=$(( BUTTONS * TILE_W + (BUTTONS - 1) * GAP ))
LR=$(( (W - ROW_W) / 2 ))
TB=$(( (H - TILE_H) / 2 ))
(( LR < 0 )) && LR=0
(( TB < 0 )) && TB=0

wlogout --protocol layer-shell -b "$BUTTONS" -c "$GAP" -L "$LR" -R "$LR" -T "$TB" -B "$TB" &
