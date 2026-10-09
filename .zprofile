# Login environment. Interactive aliases and toolchains belong in .zsh/.
typeset -U path PATH
[[ -d /Library/Frameworks/Python.framework/Versions/3.12/bin ]] &&
  path=(/Library/Frameworks/Python.framework/Versions/3.12/bin $path)

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
path+=("$HOME/.local/bin")