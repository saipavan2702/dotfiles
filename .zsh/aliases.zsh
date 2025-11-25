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
export EXA_ICON_SPACING=1  # Ensures proper icon alignment

_eza() {
    eza --icons=always --color=always --group-directories-first "$@"
}

alias ls="_eza"                 # Basic list
alias ll='_eza -l'              # Long list (no time sort)
alias la='_eza -la'             # Long list + hidden

alias llt='_eza -l --sort=newest'      # Long list, newest first
alias lat='_eza -la --sort=newest'     # Long list + hidden, newest first

alias lt="_eza -lTg"            # Tree view (default depth)
alias lt2="_eza -lTg --level=2" # Tree view (depth 2)
alias lt3="_eza -lTg --level=3" # Tree view (depth 3)
alias lta="_eza -lTag"          # Tree view + hidden
alias lta2="_eza -lTag --level=2"
alias lta3="_eza -lTag --level=3"

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
