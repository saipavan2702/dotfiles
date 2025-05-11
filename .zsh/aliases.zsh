#aliases
alias mvnc='mvn clean install -DskipCodeOwnersCheck=true -Dmaven.javadoc.skip -Dspotbugs.skip -Dpmd.skip -Dcheckstyle.skip -DODOenv=true -DskipITs=true -DskipUTs=true -DskipTests -Dmaven.javadoc.skip=true -P TS1'
alias mvncit='mvn clean install -DskipTests=true'
alias ssh='ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ServerAliveInterval=30'

#ls
alias ls='colorls -A --sort-dirs'
alias ll='colorls -l'
alias lst='colorls --tree -a'


#git
alias gcd='git checkout development'
alias gpod='git pull origin development'
alias gb='git branch'
alias gf='git fetch'
alias gs='git status'
alias gd='git diff'

quick_commit() {
  local commit_message 
  commit_message="$*"
  
  git commit --no-verify -m "$commit_message"
}

quick_pull() {
  local branch_name
  branch_name=$(git branch --show-current)
  git pull origin $branch_name
}

alias gqc='quick_commit'
alias gpob='quick_pull'
