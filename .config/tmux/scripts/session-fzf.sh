#!/usr/bin/env bash
set -euo pipefail

action="${1:-pick}"

sanitize_name() {
  printf '%s' "$1" | tr ':' '_'
}

prompt_for() {
  printf '%s' "$1" >&2
  read -r value
  printf '%s' "$value"
}

switch_or_create() {
  local selected_id="${1:-}"
  local query="${2:-}"
  local current_path target

  if [[ -n "$selected_id" ]]; then
    tmux switch-client -t "$selected_id"
    return
  fi

  target="$(sanitize_name "$query")"
  [[ -n "$target" ]] || exit 0

  current_path="$(tmux display-message -p '#{pane_current_path}')"
  if ! tmux has-session -t "$target" 2>/dev/null; then
    tmux new-session -d -s "$target" -c "$current_path"
  fi
  tmux switch-client -t "$target"
}

case "$action" in
  new)
    name="$(sanitize_name "${2:-}")"
    [[ -n "$name" ]] || name="$(sanitize_name "$(prompt_for 'new session: ')")"
    [[ -n "$name" ]] || exit 0
    tmux new-session -d -s "$name" -c "$(tmux display-message -p '#{pane_current_path}')" 2>/dev/null || true
    tmux switch-client -t "$name"
    exit 0
    ;;
  switch)
    switch_or_create "${2:-}" "${3:-}"
    exit 0
    ;;
  rename)
    session="${2:-}"
    [[ -n "$session" ]] || exit 0
    current_name="$(tmux display-message -p -t "$session" '#S')"
    name="$(sanitize_name "$(prompt_for "rename session $current_name to: ")")"
    [[ -n "$name" ]] || exit 0
    tmux rename-session -t "$session" "$name"
    exit 0
    ;;
  kill)
    session="${2:-}"
    [[ -n "$session" ]] || exit 0
    current_name="$(tmux display-message -p -t "$session" '#S')"
    answer="$(prompt_for "kill session $current_name? [y/N] ")"
    [[ "$answer" =~ ^[Yy]$ ]] || exit 0
    tmux kill-session -t "$session"
    exit 0
    ;;
esac

script_path="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/$(basename -- "${BASH_SOURCE[0]}")"

tmux list-sessions -F '#{session_id}	#{session_name}	#{session_windows} windows	#{?session_attached,current,}' |
  fzf --reverse --delimiter='\t' --with-nth=2,3,4 \
    --border=rounded --margin=1,2 --padding=1,2 \
    --prompt='session> ' \
    --header='Enter switch/create | Ctrl-n new | Ctrl-r rename | Ctrl-d kill | Esc back' \
    --preview='tmux list-windows -t {1} -F "#{window_index}: #{window_name} #{?window_active,(active),}" 2>/dev/null' \
    --preview-window='right:55%' \
    --bind "enter:become($script_path switch {1} {q})" \
    --bind "ctrl-n:become($script_path new {q})" \
    --bind "ctrl-r:become($script_path rename {1})" \
    --bind "ctrl-d:become($script_path kill {1})"
