# Paths are arrays in Zsh: keep their first occurrence and avoid subprocesses.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
typeset -U path PATH fpath
# Do not export completion paths to child shells.
typeset +x FPATH fpath
export LSCOLORS="${LSCOLORS:-Gxfxcxdxbxegedabagacad}"
export LS_COLORS="${LS_COLORS:-di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43}"
path+=("$HOME/.lmstudio/bin")
export PAGER="${PAGER:-less}"
export LESS="${LESS:--R}"
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHDMINUS
setopt MULTIOS LONG_LIST_JOBS INTERACTIVE_COMMENTS
unsetopt FLOW_CONTROL
KEYTIMEOUT=20
[[ -t 0 ]] && stty -ixon 2>/dev/null
