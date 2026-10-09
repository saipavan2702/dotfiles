# Own completion initialization here; plugins must never run a second compinit.
fpath=(${fpath:#$HOME/.oh-my-zsh/*})
fpath=(${fpath:#$HOME/.zinit/*})
fpath=(${fpath:#$HOME/.cache/zinit/*})
for completion_dir in /opt/homebrew/share/zsh/site-functions /usr/local/share/zsh/site-functions; do
  [[ -d "$completion_dir" ]] && fpath+=("$completion_dir")
done
unset completion_dir

typeset -g ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompdump-native-${HOST%%.*}-${ZSH_VERSION}"
[[ -d ${ZSH_COMPDUMP:h} ]] || command mkdir -p "${ZSH_COMPDUMP:h}"
autoload -Uz compinit
# Keep the normal permission audit and file-count invalidation on every start.
# compinit already reuses its dump; -C would skip these checks.
compinit -i -d "$ZSH_COMPDUMP"
zmodload zsh/complist
setopt AUTO_MENU COMPLETE_IN_WORD ALWAYS_TO_END
unsetopt MENU_COMPLETE
WORDCHARS=''
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "${ZSH_COMPDUMP:h}/completion"
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*' menu select
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:git-switch:*' sort false
