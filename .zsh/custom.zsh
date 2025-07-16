# My ZSH config

if [[ -n "$ZSH_DEBUGRC" ]]; then
  zmodload zsh/zprof
fi

export ZSH="$HOME/.oh-my-zsh"

HYPHEN_INSENSITIVE="true"
DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_COMPFIX="true"
ENABLE_CORRECTION="true"
setopt AUTO_CD               # Allow cd by typing folder name
setopt HIST_IGNORE_DUPS      # No duplicate history entries
setopt SHARE_HISTORY         # Share history across terminals

zstyle ':omz:update' mode disabled  # disable automatic updates


autoload -Uz compinit
if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
    compinit
else
    compinit -C
fi

plugins=(
  git
  web-search
  zsh-autosuggestions
  zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh

ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="20"
ZSH_AUTOSUGGEST_USE_ASYNC=1

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
export STARSHIP_COCKPIT_MEMORY_USAGE_ENABLED=true
export STARSHIP_COCKPIT_BATTERY_ENABLED=true
export STARSHIP_COCKPIT_BATTERY_THRESHOLD=100
export STARSHIP_COCKPIT_KEYBOARD_LAYOUT_ENABLED=true
# export STARSHIP_COCKPIT_KEYBOARD_LAYOUT_US=ENG

eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"
source <(fzf --zsh)
eval $(thefuck --alias fk)

export FZF_DEFAULT_OPTS="
--height=80%
--layout=reverse
--inline-info
--color=16
--style=full
--prompt='❯ '
--marker='✓'
--border=rounded 
"

export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow 
--exclude .git 
--exclude node_modules 
--exclude .DS_Store 
--exclude '*.pyc'
"

export FZF_ALT_C_COMMAND="fd --type d --hidden --follow
--exclude .git 
--exclude node_modules 
--exclude .DS_Store
"


export FZF_CTRL_R_OPTS="
--color header:italic
--bind 'ctrl-/:toggle-sort'
--bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
--header 'CTRL-Y: Copy command into clipboard, CTRL-/: Toggle sorting by relevance'
"

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="
--preview 'bat  --style=numbers --color=always {}'
--preview-window 'right:60%:wrap'
--bind 'ctrl-v:execute(code {})+abort'
--bind 'ctrl-o:execute(open {})+abort'
--bind 'ctrl-/:change-preview-window(down,50%|hidden|)'
--header $'CTRL-V: open in VSCode  CTRL-O: open in Finder  CTRL-/: toggle preview\n───'
"

export FZF_ALT_C_OPTS="
--preview 'tree -C -L 2 {} | head -200'
--preview-window 'right:60%:wrap'
--bind 'ctrl-v:execute(code {})+abort'
--bind 'ctrl-/:change-preview-window(down,50%|hidden|)'
--header $'CTRL-V: open in VSCode  CTRL-/: toggle preview\n───'
"

if [[ -n "$ZSH_DEBUGRC" ]]; then
  zprof
fi

