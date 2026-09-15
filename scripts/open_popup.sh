#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SIDE=$(tmux show-option -gqv @pi_status_side)
[ -z "$SIDE" ] && SIDE="left"

WIN_W=$(tmux display-message -p "#{window_width}")

if [ "$SIDE" = "right" ]; then
  X_POS=$(( WIN_W * 4 / 5 ))
else
  X_POS=0
fi

tmux display-popup \
  -x "$X_POS" -y 0 \
  -w "20%" -h "100%" \
  -E "lua '$SCRIPT_DIR/pi_status.lua' | less -sR"
