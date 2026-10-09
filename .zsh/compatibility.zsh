# Keep existing history, keys, directory shortcuts and Git aliases without
# booting the entire Oh My Zsh framework. Personal aliases load afterwards.
autoload -Uz add-zsh-hook is-at-least
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE HIST_VERIFY SHARE_HISTORY
bindkey -e
for omz_file in lib/history.zsh lib/key-bindings.zsh lib/directories.zsh lib/git.zsh plugins/git/git.plugin.zsh; do
  [[ -r "$HOME/.oh-my-zsh/$omz_file" ]] && source "$HOME/.oh-my-zsh/$omz_file"
done
unset omz_file
