#!/usr/bin/env bash
set -euo pipefail

current_path="$(tmux display-message -p '#{pane_current_path}')"
script_dir="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

prompt_for() {
  printf '%s' "$1" >&2
  read -r value
  printf '%s' "$value"
}

while true; do
  choice="$(
    printf '%s\n' \
      'Sessions	switch, create, rename, kill' \
      'Windows	switch, create, rename, kill' \
      'Projects	open directory as session' \
      'Rename session	current session' \
      'Rename window	current window' \
      'Kill session	current session' \
      'Shell	floating shell here' \
      'Lazygit	floating git UI here' \
      'Keys	search tmux key bindings' \
      'Reload	source tmux.conf' \
      'Exit	close palette' |
      fzf --reverse --border=rounded --margin=1,2 --padding=1,2 \
        --delimiter='\t' --with-nth=1,2 \
        --prompt='tmux  ' \
        --header='Enter open | Esc close | submenus return here'
  )" || exit 0

  action="${choice%%$'\t'*}"

  case "$action" in
    Sessions)
      "$script_dir/session-fzf.sh" || true
      ;;
    Windows)
      "$script_dir/window-fzf.sh" || true
      ;;
    Projects)
      "$script_dir/project-fzf.sh" || true
      ;;
    Rename\ session)
      current_session="$(tmux display-message -p '#S')"
      name="$(prompt_for "rename session $current_session to: ")"
      [[ -n "$name" ]] && tmux rename-session -t "$current_session" "${name//:/_}"
      ;;
    Rename\ window)
      current_window="$(tmux display-message -p '#W')"
      name="$(prompt_for "rename window $current_window to: ")"
      [[ -n "$name" ]] && tmux rename-window "$name"
      ;;
    Kill\ session)
      current_session="$(tmux display-message -p '#S')"
      answer="$(prompt_for "kill session $current_session? [y/N] ")"
      [[ "$answer" =~ ^[Yy]$ ]] && tmux kill-session -t "$current_session"
      ;;
    Shell)
      cd "$current_path"
      exec "$SHELL" -l
      ;;
    Lazygit)
      cd "$current_path"
      exec lazygit
      ;;
    Keys)
      tmux list-keys | fzf --reverse --border=rounded --prompt='keys  ' --header='Esc returns to palette' || true
      ;;
    Reload)
      tmux source-file "$HOME/.config/tmux/tmux.conf"
      tmux display-message "tmux.conf reloaded"
      ;;
    Exit)
      exit 0
      ;;
  esac
done
