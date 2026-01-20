# My ZSH config

if [[ -n "$ZSH_DEBUGRC" ]]; then
  zmodload zsh/zprof
fi

export ZSH="$HOME/.oh-my-zsh"

HYPHEN_INSENSITIVE="true"
DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_COMPFIX="true"
setopt AUTO_CD               # Allow cd by typing folder name
setopt HIST_IGNORE_DUPS      # No duplicate history entries
setopt SHARE_HISTORY         # Share history across terminals

zstyle ':omz:update' mode disabled  # disable automatic updates

source "${HOME}/.zinit/bin/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

autoload -Uz compinit
if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
    compinit
else
    compinit -C
fi

plugins=(git)
source $ZSH/oh-my-zsh.sh

ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="20"
ZSH_AUTOSUGGEST_USE_ASYNC=1
. ~/.zsh/aliases.zsh

# export LANG=en_US.UTF-8

export PATH="/Users/mmacha/Library/Python/3.9/bin:$PATH"
export JAVA_HOME=$(/usr/libexec/java_home -v 17.0.9)
export PATH=$JAVA_HOME/bin:$PATH
export M3_HOME=/Users/mmacha/Downloads/apache-maven-3.9.3
export PATH=$PATH:$M3_HOME/bin
export MAVEN_OPTS="--add-opens java.base/java.lang=ALL-UNNAMED"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/lib/ruby/gems/3.4.0/bin:$PATH"

#---------Zinit PLugins -------#
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting


#-----------------------------#

export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
export STARSHIP_COCKPIT_MEMORY_USAGE_ENABLED=true
export STARSHIP_COCKPIT_BATTERY_ENABLED=true
export STARSHIP_COCKPIT_BATTERY_THRESHOLD=100
export STARSHIP_COCKPIT_KEYBOARD_LAYOUT_ENABLED=true

eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"
source <(fzf --zsh)
eval $(thefuck --alias fk)

#export FZF_DEFAULT_OPTS="
#--height=80%
#--layout=reverse
#--inline-info
#--color=16
#--style=full
#--prompt='❯ '
#--marker='✓'
#--border=rounded 
#"

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

export NVM_LAZY_LOAD=true


export FZF_DEFAULT_OPTS="
--height 40%
--layout=reverse
--border
--inline-info
--color=fg:#c0caf5,bg:#1a1b26,hl:#7aa2f7
--color=fg+:#c0caf5,bg+:#1f2335,hl+:#7dcfff
--color=info:#7dcfff,prompt:#7aa2f7,pointer:#f7768e
--color=marker:#9eceba,spinner:#9ece6a,header:#bb9af7
"

#=== Tokyo Night Darker (Gritty) ZSH Syntax Highlighting ===
#ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)
#ZSH_HIGHLIGHT_STYLES[command]='fg=#7aa2f7'
#ZSH_HIGHLIGHT_STYLES[precommand]='fg=#bb9af7'
#ZSH_HIGHLIGHT_STYLES[alias]='fg=#9ece6a'
#ZSH_HIGHLIGHT_STYLES[builtin]='fg=#7dcfff'
#ZSH_HIGHLIGHT_STYLES[function]='fg=#2ac3de'
#ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#565f89'
#ZSH_HIGHLIGHT_STYLES[argument]='fg=#c0caf5'
##ZSH_HIGHLIGHT_STYLES[default]='fg=#1a1b26'
#ZSH_HIGHLIGHT_STYLES[globbing]='fg=#f7768e'
#ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#ff9e64'
#ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#e0af68'
#ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#e0af68'
#ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#7aa2F7'
#ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#9aa5ce'
#ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#9aa5ce'
#ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red, bold'


if [[ -n "$ZSH_DEBUGRC" ]]; then
  zprof
fi

