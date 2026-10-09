# Aliases and shell helpers

# ============================================================================
#                                   General
# ============================================================================
alias ff='fastfetch'
alias zi='zoxide query --interactive'
alias -g G='| grep'
alias grep='grep --color=auto'
alias egrep='grep -E'
alias fgrep='grep -F'
alias _='sudo '

# Preview images, PDFs, and other supported files with macOS Quick Look.
ql() {
  command qlmanage -p "$@" >/dev/null 2>&1
}

# ============================================================================
#                                     SSH
# ============================================================================
# Explicit escape hatch for disposable hosts only. Normal `ssh` keeps host-key
# verification enabled so a spoofed server cannot silently impersonate a host.
ssh-insecure-hostkey() {
  command ssh \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o ServerAliveInterval=30 \
    "$@"
}

# ============================================================================
#                                 Diagnostics
# ============================================================================
ztprof() {
  time ZSH_DEBUGRC=1 zsh -i -c exit
}

# Visual check for 24-bit terminal colour rendering; run with `truecolor`.
truecolor() {
  command awk 'BEGIN {
    s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
    for (colnum=0; colnum<77; colnum++) {
      r=255-(colnum*255/76);
      g=(colnum*510/76);
      b=(colnum*255/76);
      if (g>255) g=510-g;
      printf "\033[48;2;%d;%d;%dm", r,g,b;
      printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
      printf "%s\033[0m", substr(s,colnum+1,1);
    }
    printf "\n";
  }'
}

# ============================================================================
#                              Directory creation
# ============================================================================
mkcd() {
  if (( $# != 1 )); then
    print -u2 'usage: mkcd <directory>'
    return 2
  fi

  mkdir -p -- "$1" && builtin cd -- "$1"
}

# ============================================================================
#                             IP addresses (macOS)
# ============================================================================
# Public IPv4 seen by OpenDNS; this is a DNS lookup, not an HTTP proxy check.
alias publicip='dig +time=2 +tries=1 +short myip.opendns.com @resolver1.opendns.com'

# Usage: localip [interface]. Default to the interface used by the IPv4 route.
localip() {
  if (( $# > 1 )); then
    print -u2 'usage: localip [interface]'
    return 2
  fi

  local interface="${1-}"
  if [[ -z "$interface" ]]; then
    interface=$(command route -n get default 2>/dev/null |
      command awk '$1 == "interface:" { print $2; exit }')
  fi
  if [[ -z "$interface" ]]; then
    print -u2 'localip: no default IPv4 interface; specify one, e.g. localip en0'
    return 1
  fi

  local address
  address=$(command ifconfig "$interface") || return
  address=$(print -r -- "$address" |
    command awk '$1 == "inet" { print $2 }')
  if [[ -z "$address" ]]; then
    print -u2 "localip: no IPv4 address on $interface"
    return 1
  fi
  print -r -- "$address"
}

# List all configured IPv4/IPv6 addresses with their interface names.
ips() {
  command ifconfig | command awk '
    /^[^[:space:]]/ { interface=$1; sub(/:$/, "", interface) }
    $1 == "inet" || $1 == "inet6" {
      printf "%-12s %-5s %s\n", interface, $1, $2
    }
  '
}

# ============================================================================
#                                    Maven
# ============================================================================
alias mvnc='mvn clean install -DskipCodeOwnersCheck=true -Dmaven.javadoc.skip -Dspotbugs.skip -Dpmd.skip -Dcheckstyle.skip -DODOenv=true -DskipITs=true -DskipUTs=true -DskipTests -Dmaven.javadoc.skip=true -P TS1'
alias mvncit='mvn clean install -DskipTests=true'

# ============================================================================
#                                     Git
# ============================================================================
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

# ============================================================================
#                             File listings (eza)
# ============================================================================
export EZA_ICON_SPACING=1

alias ls='eza --icons=always --color=always --group-directories-first'
alias ll='eza -l --icons=always --color=always --group-directories-first'
alias la='eza -la --icons=always --color=always --group-directories-first'
alias llt='eza -l --sort=newest --icons=always --color=always --group-directories-first'
alias lat='eza -la --sort=newest --icons=always --color=always --group-directories-first'

# Usage: lt [depth] [eza options] [paths]; lta also includes hidden files.
# No depth means unlimited recursion. Use ./123 for a numeric directory name.
_eza_tree() {
  local -a depth_args

  if [[ ${1-} == <-> ]]; then
    if (( $1 < 1 )); then
      print -u2 'tree depth must be at least 1'
      return 2
    fi
    depth_args=(--level="$1")
    shift
  fi

  command eza -lTg \
    --icons=always \
    --color=always \
    --group-directories-first \
    "${depth_args[@]}" "$@"
}

lt() {
  _eza_tree "$@"
}

lta() {
  if [[ ${1-} == <-> ]]; then
    local depth="$1"
    shift
    _eza_tree "$depth" -a "$@"
  else
    _eza_tree -a "$@"
  fi
}

# ============================================================================
#                                   Pomodoro
# ============================================================================
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

# ============================================================================
#                                    Proxy
# ============================================================================
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
# OCI request signing helper.
alias oci-curl='bash "$HOME/.oci/oci-curl.sh"'

# Restart the SSH agent and load the existing smart-card provider on demand.
alias pk='pkill -9 ssh-agent; eval `ssh-agent`; ssh-add -s /opt/homebrew/lib/opensc-pkcs11.so'
