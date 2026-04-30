#!/usr/bin/env bash
set -euo pipefail

action="${1:-pick}"

prompt_for() {
  printf '%s' "$1" >&2
  read -r value
  printf '%s' "$value"
}

case "$action" in
  new)
    name="${2:-}"
    [[ -n "$name" ]] || name="$(prompt_for 'new window: ')"
    tmux new-window -n "${name:-shell}" -c "$(tmux display-message -p '#{pane_current_path}')"
    exit 0
    ;;
  switch)
    window="${2:-}"
    [[ -n "$window" ]] || exit 0
    tmux select-window -t "$window"
    exit 0
    ;;
  rename)
    window="${2:-}"
    [[ -n "$window" ]] || exit 0
    current_name="$(tmux display-message -p -t "$window" '#W')"
    new_name="$(prompt_for "rename window $current_name to: ")"
    [[ -n "$new_name" ]] || exit 0
    tmux rename-window -t "$window" "$new_name"
    exit 0
    ;;
  kill)
    window="${2:-}"
    [[ -n "$window" ]] || exit 0
    name="$(tmux display-message -p -t "$window" '#W')"
    answer="$(prompt_for "kill window $name? [y/N] ")"
    [[ "$answer" =~ ^[Yy]$ ]] || exit 0
    tmux kill-window -t "$window"
    exit 0
    ;;
esac

script_path="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/$(basename -- "${BASH_SOURCE[0]}")"

tmux list-windows -F '#{window_index}	#{window_name}	#{window_panes} panes	#{?window_active,active,}' |
  fzf --reverse --delimiter='\t' --with-nth=1,2,3,4 \
    --border=rounded --margin=1,2 --padding=1,2 \
    --prompt='window> ' \
    --header='Enter switch | Ctrl-n new | Ctrl-r rename | Ctrl-d kill | Esc back' \
    --preview='tmux list-panes -t {1} -F "#{pane_index}: #{pane_current_command}  #{pane_current_path}" 2>/dev/null' \
    --preview-window='right:55%' \
    --bind "enter:become($script_path switch {1})" \
    --bind "ctrl-n:become($script_path new {q})" \
    --bind "ctrl-r:become($script_path rename {1})" \
    --bind "ctrl-d:become($script_path kill {1})"
