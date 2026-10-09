#!/usr/bin/env bash
set -euo pipefail

# Resolve Stow's file symlink before locating the repository.
script_path="${BASH_SOURCE[0]}"
while [[ -L "$script_path" ]]; do
  script_dir="$(CDPATH='' cd -- "$(dirname -- "$script_path")" && pwd -P)"
  script_path="$(readlink "$script_path")"
  [[ "$script_path" = /* ]] || script_path="$script_dir/$script_path"
done
script_dir="$(CDPATH='' cd -- "$(dirname -- "$script_path")" && pwd -P)"
dotfiles_dir="$(CDPATH='' cd -- "$script_dir/../../.." && pwd -P)"
current_path="$(tmux display-message -p '#{pane_current_path}')"

project_candidates() {
  local zoxide_dirs=""

  if command -v zoxide >/dev/null 2>&1; then
    zoxide_dirs="$(zoxide query -ls 2>/dev/null | sed -E 's/^[[:space:]]*[0-9.]+[[:space:]]+//' || true)"
  fi

  printf '%s\n' "$current_path" "$dotfiles_dir" "$HOME/.config"

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
    while IFS= read -r candidate; do
      if [[ -d "$candidate" ]]; then
        printf '%s\n' "$candidate"
      fi
    done |
    fzf --reverse \
      --border=rounded --margin=1,2 --padding=1,2 \
      --prompt='project> ' \
      --header='Enter opens/switches project session | Esc back' \
      --preview='ls -la {} 2>/dev/null | sed -n "1,80p"' \
      --preview-window='right:55%'
)" || exit 0

[[ -n "$selected" ]] || exit 0
[[ -d "$selected" ]] || {
  printf 'Directory no longer exists: %s\n' "$selected" >&2
  exit 1
}
selected="$(CDPATH='' cd -- "$selected" && pwd -P)"

session_name="$(basename "$selected" | tr -cs '[:alnum:]_-' '_' | sed 's/^_//; s/_$//')"
[[ -n "$session_name" ]] || session_name="project"
# The same basename can occur in different checkouts. Hash the canonical path,
# and use session IDs so tmux cannot match another session by prefix.
path_hash="$(printf '%s' "$selected" | shasum -a 256 | cut -c1-12)"
session_name="${session_name:0:40}-$path_hash"

find_session() {
  tmux list-sessions -F '#{session_name}	#{session_id}' |
    awk -F '\t' -v name="$session_name" '$1 == name { print $2 }'
}
session_id="$(find_session)"
if [[ -z "$session_id" ]]; then
  # A concurrent picker may create the session after the check above.
  session_id="$(tmux new-session -d -P -F '#{session_id}' -s "$session_name" -c "$selected")" || session_id="$(find_session)"
fi
[[ -n "$session_id" ]] || {
  printf 'Unable to create project session\n' >&2
  exit 1
}
tmux set-option -t "$session_id" @project_path "$selected"
tmux switch-client -t "$session_id"