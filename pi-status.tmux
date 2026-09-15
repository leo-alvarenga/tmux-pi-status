#!/usr/bin/env bash
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

KEY=$(tmux show-option -gqv @pi_status_key)
[ -z "$KEY" ] && KEY="P"

tmux bind-key "$KEY" run-shell "$PLUGIN_DIR/scripts/open_popup.sh"
