#aliases
alias mvnc='mvn clean install -DskipCodeOwnersCheck=true -Dmaven.javadoc.skip -Dspotbugs.skip -Dpmd.skip -Dcheckstyle.skip -DODOenv=true -DskipITs=true -DskipUTs=true -DskipTests -Dmaven.javadoc.skip=true -P TS1'
alias mvncit='mvn clean install -DskipTests=true'
alias ssh='ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ServerAliveInterval=30'
alias ztprof='time ZSH_DEBUGRC=1 zsh -i -c exit'
alias ff='fastfetch'
alias cds='cd ~/Downloads/work-util/escs-sm'

#git
alias gcd='git checkout main'
alias gb='git branch'
alias gf='git fetch'
alias gs='git status'
alias gd='git diff'

quick_commit() {
  local commit_message 
  commit_message="$*"
  
  git commit --no-verify -am "$commit_message"
}

quick_pull() {
  local branch_name
  branch_name=$(git branch --show-current)
  git fetch origin
  git pull origin $branch_name
}

alias gqc='quick_commit'
alias gpob='quick_pull'

#eza
export EZA_ICON_SPACING=1  # Ensures proper icon alignment

alias ls="eza --icons=always --color=always --group-directories-first"

# Long list
alias ll='eza -l --icons=always --color=always --group-directories-first'

# Long + hidden
alias la='eza -la --icons=always --color=always --group-directories-first'

# Newest first
alias llt='eza -l --sort=newest --icons=always --color=always --group-directories-first'
alias lat='eza -la --sort=newest --icons=always --color=always --group-directories-first'

# Tree views
alias lt="eza -lTg --icons=always --color=always --group-directories-first"
alias lt2="eza -lTg --level=2 --icons=always --color=always --group-directories-first"
alias lt3="eza -lTg --level=3 --icons=always --color=always --group-directories-first"
alias lta="eza -lTag --icons=always --color=always --group-directories-first"
alias lta2="eza -lTag --level=2 --icons=always --color=always --group-directories-first"
alias lta3="eza -lTag --level=3 --icons=always --color=always --group-directories-first"

alias -g G='| grep'
alias zi="zoxide query --interactive"

#pomodoro
alias work="timer 60m && terminal-notifier -message 'Pomodoro'\
        -title 'Work Timer is up! Take a Break 😊'\
        -appIcon '~/Pictures/pumpkin.png'\
        -sound Crystal"
        
alias rest="timer 10m && terminal-notifier -message 'Pomodoro'\
        -title 'Break is over! Get back to work 😬'\
        -appIcon '~/Pictures/pumpkin.png'\
        -sound Crystal"


#proxies
alias proxy-on='export http_proxy=http://www-proxy.us.oracle.com:80 https_proxy=http://www-proxy.us.oracle.com:80 no_proxy="localhost,127.0.0.1,.oracle.com,.oraclecorp.com" && echo "✓ Proxy enabled"'

alias proxy-off='unset http_proxy https_proxy no_proxy && echo "✓ Proxy disabled"'
alias proxy-status='if [ -n "$http_proxy" ]; then echo "Proxy: ON ($http_proxy)"; else echo "Proxy: OFF"; fi'
