if [[ -n "$ZSH_DEBUGRC" ]]; then
  zmodload zsh/zprof
fi

export ZSH="$HOME/.oh-my-zsh"

HYPHEN_INSENSITIVE="true"
DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_COMPFIX="true"

zstyle ':omz:update' mode disabled  # disable automatic updates

# ENABLE_CORRECTION="true"

plugins=(
  git
  web-search
  zsh-autosuggestions
  zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh

# export LANG=en_US.UTF-8

# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

export PATH="/Users/mmacha/Library/Python/3.9/bin:$PATH"
export JAVA_HOME=$(/usr/libexec/java_home -v 17.0.9)
export PATH=$JAVA_HOME/bin:$PATH
export M3_HOME=/Users/mmacha/Downloads/apache-maven-3.9.3
export PATH=$PATH:$M3_HOME/bin
export MAVEN_OPTS="--add-opens java.base/java.lang=ALL-UNNAMED"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/lib/ruby/gems/3.4.0/bin:$PATH"

# export http_proxy=http://www-proxy.us.oracle.com:80
# export https_proxy=http://www-proxy.us.oracle.com:80
# export no_proxy='localhost,127.0.0.1,.oracle.com,.oraclecorp.com'


autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C

#-------- Global Alias -------#
#
globalias() {
  if [[ $LBUFFER =~ '[a-zA-Z0-9]+$' ]]; then
    zle _expand_alias
    zle expand-word
  fi
  zle self-insert
}

zle -N globalias
bindkey " " globalias                 # space key to expand globalalias
# bindkey "^ " magic-space            # control-space to bypass completion
bindkey "^[[Z" magic-space            # shift-tab to bypass completion
bindkey -M isearch " " magic-space    # normal space during searches
. ~/.zsh/aliases.zsh

#-----------------------------#


export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"
source <(fzf --zsh)
eval $(thefuck --alias fk)

export FZF_CTRL_R_OPTS="
--style=full
--color header:italic
--height=80%
--bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
--header 'CTRL-Y: Copy command into clipboard, CTRL-/: Toggle line wrapping, CTRL-R: Toggle sorting by relevance'
"

export FZF_CTRL_T_OPTS="
--style=full
--walker-skip .git,node_modules,target
--preview 'bat -n --color=always {}'
--height=80%
--bind 'ctrl-/:change-preview-window(down|hidden|)'
--header 'CTRL-/: Toggle preview window position'
"

export FZF_ALT_C_OPTS="
--walker-skip .git,node_modules,target
--preview 'tree -C {}'
--height=80%
--bind 'ctrl-/:change-preview-window(down|hidden|)'
--header 'CTRL-/: Toggle preview window position'
"

if [[ -n "$ZSH_DEBUGRC" ]]; then
  zprof
fi

