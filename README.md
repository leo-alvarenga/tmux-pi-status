# tmux-pi-status

Shows the sessions reported by
[`@leo-alvarenga/pi-status-broadcaster`](https://www.npmjs.com/package/@leo-alvarenga/pi-status-broadcaster)
in a tmux popup.

`prefix + P` opens a sidebar next to your pane. It redraws once a second,
`Escape` or `C-c` closes it.

## Requirements

- tmux 3.2 or newer (`display-popup`)
- `lua`, `jq`
- the broadcaster package, which writes `/tmp/pi-status-broadcaster/status.json`

## Install

With [TPM](https://github.com/tmux-plugins/tpm), add to `~/.tmux.conf`:

```tmux
set -g @plugin 'leo-alvarenga/tmux-pi-status'
```

Then press `prefix + I`.

## Options

| Option            | Default | Notes             |
| ----------------- | ------- | ----------------- |
| `@pi_status_key`  | `P`     | Open the sidebar  |
| `@pi_status_side` | `left`  | `left` or `right` |

```tmux
set -g @pi_status_key 'p'
set -g @pi_status_side 'right'
```

## Layout

The popup takes 20% of the window width. Long session lists are piped through
`less -R`, which blocks until you quit it and then returns to the sidebar.
