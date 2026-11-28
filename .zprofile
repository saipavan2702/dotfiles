# Login environment. Interactive aliases and toolchains belong in .zsh/.
typeset -U path PATH
[[ -d /Library/Frameworks/Python.framework/Versions/3.12/bin ]] &&
  path=(/Library/Frameworks/Python.framework/Versions/3.12/bin $path)

if [[ -x /opt/homebrew/bin/brew && -d /opt/homebrew/Library/Homebrew ]]; then
  # Standard Apple Silicon installation. Set up the same paths without
  # spawning Homebrew on every login shell.
  export HOMEBREW_PREFIX=/opt/homebrew
  export HOMEBREW_CELLAR=/opt/homebrew/Cellar
  export HOMEBREW_REPOSITORY=/opt/homebrew
  path=(/opt/homebrew/bin /opt/homebrew/sbin $path)
  typeset -U fpath
  fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
  export FPATH
  if [[ -n ${MANPATH:-} ]]; then
    MANPATH=${MANPATH%"${MANPATH##*[!:]}"}
    export MANPATH=":${MANPATH#"${MANPATH%%[!:]*}"}"
  fi
  if [[ ${INFOPATH:-} != /opt/homebrew/share/info:* ]]; then
    export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
  fi
elif [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv zsh)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv zsh)"
fi
path+=("$HOME/.local/bin")
