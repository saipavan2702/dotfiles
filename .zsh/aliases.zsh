# Aliases and shell helpers

# General
alias ff='fastfetch'
alias zi='zoxide query --interactive'
alias -g G='| grep'

# Explicit escape hatch for disposable hosts only. Normal `ssh` keeps host-key
# verification enabled so a spoofed server cannot silently impersonate a host.
ssh-insecure-hostkey() {
  command ssh \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o ServerAliveInterval=30 \
    "$@"
}

ztprof() {
  time ZSH_DEBUGRC=1 zsh -i -c exit
}

mkcd() {
  if (( $# != 1 )); then
    print -u2 'usage: mkcd <directory>'
    return 2
  fi

  mkdir -p -- "$1" && builtin cd -- "$1"
}

# Maven
alias mvnc='mvn clean install -DskipCodeOwnersCheck=true -Dmaven.javadoc.skip -Dspotbugs.skip -Dpmd.skip -Dcheckstyle.skip -DODOenv=true -DskipITs=true -DskipUTs=true -DskipTests -Dmaven.javadoc.skip=true -P TS1'
alias mvncit='mvn clean install -DskipTests=true'

# Git
alias gcd='git checkout main'
alias gb='git branch'
alias gf='git fetch'
alias gs='git status'
alias gd='git diff'

git() {
  if [[ "$1" == "lg" ]]; then
    shift
    command git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit "$@"
  else
    command git "$@"
  fi
}

quick_commit() {
  local commit_message="$*"

  if [[ -z "$commit_message" ]]; then
    print -u2 'usage: quick_commit <message>'
    return 2
  fi

  git add --all -- . && git commit -m "$commit_message"
}

quick_pull() {
  local branch_name

  branch_name=$(git symbolic-ref --quiet --short HEAD) || {
    print -u2 'quick_pull: detached HEAD; check out a branch first'
    return 1
  }

  git pull --ff-only origin "$branch_name"
}

alias gqc='quick_commit'
alias gpob='quick_pull'

# eza
export EZA_ICON_SPACING=1

alias ls='eza --icons=always --color=always --group-directories-first'
alias ll='eza -l --icons=always --color=always --group-directories-first'
alias la='eza -la --icons=always --color=always --group-directories-first'
alias llt='eza -l --sort=newest --icons=always --color=always --group-directories-first'
alias lat='eza -la --sort=newest --icons=always --color=always --group-directories-first'
alias lt='eza -lTg --icons=always --color=always --group-directories-first'
alias lt2='eza -lTg --level=2 --icons=always --color=always --group-directories-first'
alias lt3='eza -lTg --level=3 --icons=always --color=always --group-directories-first'
alias lta='eza -lTag --icons=always --color=always --group-directories-first'
alias lta2='eza -lTag --level=2 --icons=always --color=always --group-directories-first'
alias lta3='eza -lTag --level=3 --icons=always --color=always --group-directories-first'

# Pomodoro
work() {
  timer 60m && terminal-notifier \
    -message 'Pomodoro' \
    -title 'Work Timer is up! Take a Break 😊' \
    -appIcon "$HOME/Pictures/pumpkin.png" \
    -sound Crystal
}

rest() {
  timer 10m && terminal-notifier \
    -message 'Pomodoro' \
    -title 'Break is over! Get back to work 😬' \
    -appIcon "$HOME/Pictures/pumpkin.png" \
    -sound Crystal
}

# Proxy
proxy-on() {
  export http_proxy='http://www-proxy.us.oracle.com:80'
  export https_proxy='http://www-proxy.us.oracle.com:80'
  export no_proxy='localhost,127.0.0.1,.oracle.com,.oraclecorp.com'
  echo '✓ Proxy enabled'
}

proxy-off() {
  unset http_proxy https_proxy no_proxy
  echo '✓ Proxy disabled'
}

proxy-status() {
  if [[ -n "$http_proxy" ]]; then
    echo "Proxy: ON ($http_proxy)"
  else
    echo 'Proxy: OFF'
  fi
}
