#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SIDE=$(tmux show-option -gqv @pi_status_side)
[ "$SIDE" = "right" ] && X_POS=R || X_POS=0

tmux display-popup \
  -x "$X_POS" -y 0 \
  -w "20%" -h "100%" \
  -T " Pi Sessions " \
  -E "$SCRIPT_DIR/sidebar.sh"
