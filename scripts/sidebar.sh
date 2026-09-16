#!/usr/bin/env bash

# Redraws the pi status sidebar once per second inside a tmux display-popup

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# tmux dismisses the popup on C-c as well, which kills us by signal; exit 0 instead
# so the popup's status isn't reported as a failure by run-shell
trap 'exit 0' INT

while :; do
  W=$(tmux display-message -p '#{window_width}')
  H=$(tmux display-message -p '#{window_height}')
  OUT=$(PI_STATUS_W=$(( W / 5 )) "$SCRIPT_DIR/pi_status.lua" 2>&1) # 2>&1: an error would be erased by the next redraw

  printf '\033[H\033[J%s\n' "$OUT" # home + erase-below: no full-screen flash

  # long list: hand off to a pager, which blocks until q, then redraws
  if [ "$(printf '%s\n' "$OUT" | wc -l)" -gt "$(( H - 3 ))" ]; then
    printf '%s\n' "$OUT" | less -R
  fi

  # same 1s wait as sleep, plus a key: q/Q exit here, tmux owns Escape and C-c
  read -rsn1 -t 1 KEY
  case "$KEY" in [qQ]) exit 0 ;; esac
done
