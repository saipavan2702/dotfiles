#aliases
alias mvnc='mvn clean install -DskipCodeOwnersCheck=true -Dmaven.javadoc.skip -Dspotbugs.skip -Dpmd.skip -Dcheckstyle.skip -DODOenv=true -DskipITs=true -DskipUTs=true -DskipTests -Dmaven.javadoc.skip=true -P TS1'
alias mvncit='mvn clean install -DskipTests=true'
alias ssh='ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ServerAliveInterval=30'

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
  git pull origin $branch_name
}

alias gqc='quick_commit'
alias gpob='quick_pull'

#eza
alias l="eza --icons=always"
alias ls="eza --icons=always"
alias ll="eza -lg --icons=always"
alias la="eza -lag --icons=always"
alias lt="eza -lTg --icons=always"
alias lt2="eza -lTg --level=2 --icons=always"
alias lt3="eza -lTg --level=3 --icons=always"
alias lta="eza -lTag --icons=always"
alias lta2="eza -lTag --level=2 --icons=always"
alias lta3="eza -lTag --level=3 --icons=always"
