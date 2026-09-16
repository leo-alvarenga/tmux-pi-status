#!/usr/bin/env bash

# Redraws the pi status sidebar once per second inside a tmux display-popup

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

while :; do
  W=$(tmux display-message -p '#{window_width}')
  H=$(tmux display-message -p '#{window_height}')
  OUT=$(PI_STATUS_W=$(( W / 5 )) "$SCRIPT_DIR/pi_status.lua" 2>&1) # 2>&1: an error would be erased by the next redraw

  printf '\033[H\033[J%s\n' "$OUT" # home + erase-below: no full-screen flash

  # long list: hand off to a pager, which blocks until q, then redraws
  if [ "$(printf '%s\n' "$OUT" | wc -l)" -gt "$(( H - 3 ))" ]; then
    printf '%s\n' "$OUT" | less -R
  fi

  sleep 1
done
