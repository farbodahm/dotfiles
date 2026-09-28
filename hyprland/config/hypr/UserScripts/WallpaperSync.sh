#!/usr/bin/env bash
# Give any output that awww shows as a plain color (e.g. a freshly plugged
# monitor) the wallpaper that is already displayed on another output.
sleep 1
query="$(awww query 2>/dev/null)" || exit 0
img="$(sed -n 's/.*currently displaying: image: //p' <<<"$query" | head -n1)"
[ -n "$img" ] && [ -f "$img" ] || exit 0
sed -n 's/^: \([^:]*\): .*currently displaying: color.*/\1/p' <<<"$query" |
  while read -r out; do
    awww img -o "$out" "$img" --transition-type none
  done
