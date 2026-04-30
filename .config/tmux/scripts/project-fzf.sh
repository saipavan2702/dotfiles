#!/usr/bin/env bash
set -euo pipefail

current_path="$(tmux display-message -p '#{pane_current_path}')"

project_candidates() {
  local zoxide_dirs=""

  if command -v zoxide >/dev/null 2>&1; then
    zoxide_dirs="$(zoxide query -ls 2>/dev/null | sed -E 's/^[[:space:]]*[0-9.]+[[:space:]]+//' || true)"
  fi

  printf '%s\n' "$current_path" "$HOME/dotfiles" "$HOME/.config"

  if [[ -n "$zoxide_dirs" ]]; then
    printf '%s\n' "$zoxide_dirs"
    return
  fi

  if command -v fd >/dev/null 2>&1; then
    fd . "$HOME" --type d --hidden --max-depth 2 \
      --exclude Library \
      --exclude .Trash \
      --exclude .cache \
      --exclude .local \
      --exclude node_modules \
      --exclude .git 2>/dev/null || true
  else
    find "$HOME" -maxdepth 2 -type d \
      -not -path "$HOME/Library*" \
      -not -path "$HOME/.Trash*" \
      -not -path "*/node_modules*" \
      -not -path "*/.git*" 2>/dev/null || true
  fi
}

selected="$(
  project_candidates |
    awk 'NF && !seen[$0]++' |
    fzf --reverse \
      --border=rounded --margin=1,2 --padding=1,2 \
      --prompt='project> ' \
      --header='Enter opens/switches project session | Esc back' \
      --preview='ls -la {} 2>/dev/null | sed -n "1,80p"' \
      --preview-window='right:55%'
)" || exit 0

[[ -n "$selected" ]] || exit 0

session_name="$(basename "$selected" | tr -cs '[:alnum:]_-' '_' | sed 's/^_//; s/_$//')"
[[ -n "$session_name" ]] || session_name="project"

if tmux has-session -t "$session_name" 2>/dev/null; then
  tmux switch-client -t "$session_name"
else
  tmux new-session -d -s "$session_name" -c "$selected"
  tmux switch-client -t "$session_name"
fi
