# Personal zsh config

# -- Diagnostics ---------------------------------------------------------------
if [[ -n "$ZSH_DEBUGRC" ]]; then
  zmodload zsh/zprof
fi

# -- Environment and caches ----------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

zsh_cache_home="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
export ZSH_COMPDUMP="$zsh_cache_home/.zcompdump-${HOST%%.*}-${ZSH_VERSION}"
[[ -d "$zsh_cache_home" ]] || command mkdir -p "$zsh_cache_home" 2>/dev/null
unset zsh_cache_home

# Keep inherited plugin paths from forcing fresh compdump work in child shells.
fpath=(${fpath:#$ZSH/*})
fpath=(${fpath:#$HOME/.zinit/*})
fpath=(${fpath:#$HOME/.cache/zinit/*})
# Keep the Homebrew completion directory in one deterministic position so
# Oh My Zsh can reuse its compdump between login and non-login shells.
fpath=(${fpath:#/opt/homebrew/share/zsh/site-functions})
[[ -d /opt/homebrew/share/zsh/site-functions ]] && fpath+=(/opt/homebrew/share/zsh/site-functions)
typeset -U fpath path
typeset +x FPATH fpath

# -- Oh My Zsh -----------------------------------------------------------------
HYPHEN_INSENSITIVE="true"
DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"

setopt AUTO_CD
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY

zstyle ':omz:update' mode disabled

source "$HOME/.zinit/bin/zinit.git/zinit.zsh"
autoload -Uz _zinit

zsh_cache_dir_was_set=${+ZSH_CACHE_DIR}
zsh_cache_dir_save="${ZSH_CACHE_DIR-}"
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/oh-my-zsh"

plugins=(git)
source "$ZSH/oh-my-zsh.sh"

if (( zsh_cache_dir_was_set )); then
  export ZSH_CACHE_DIR="$zsh_cache_dir_save"
else
  unset ZSH_CACHE_DIR
fi
unset zsh_cache_dir_was_set zsh_cache_dir_save

(( ${+_comps} )) && _comps[zinit]=_zinit

# fzf-tab reads completion colors; keep this static to avoid startup commands.
export LSCOLORS="${LSCOLORS:-Gxfxcxdxbxegedabagacad}"
export LS_COLORS="${LS_COLORS:-di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43}"
[[ -n "$LS_COLORS" ]] && zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# -- Plugin settings -----------------------------------------------------------
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="20"
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_AUTOSUGGEST_STRATEGY=(history)
ZSH_AUTOSUGGEST_USE_ASYNC=1

export NVM_LAZY_LOAD=true

# -- Toolchains ----------------------------------------------------------------
# export LANG=en_US.UTF-8

if [[ -z ${JAVA_HOME:-} || ! -d "$JAVA_HOME" ]]; then
  java_home_candidate=""

  if [[ -x /usr/libexec/java_home ]]; then
    java_home_candidate="$(/usr/libexec/java_home -v 17 2>/dev/null)"
  elif (( $+commands[java] )); then
    java_home_candidate="${commands[java]:A:h:h}"
  fi

  [[ -d "$java_home_candidate" ]] && export JAVA_HOME="$java_home_candidate"
  unset java_home_candidate
fi

# Prefer package-manager installs before inherited variables or PATH entries.
# This lets an SDKMAN/Homebrew upgrade supersede an older parent-shell value.
maven_home_candidate=""
for candidate in \
  /opt/homebrew/opt/maven \
  /usr/local/opt/maven \
  "$HOME/.sdkman/candidates/maven/current" \
  "${M3_HOME:-}" \
  "${MAVEN_HOME:-}"; do
  if [[ -n "$candidate" && -x "$candidate/bin/mvn" ]]; then
    maven_home_candidate="$candidate"
    break
  fi
done

if [[ -z "$maven_home_candidate" ]] && (( $+commands[mvn] )); then
  maven_home_candidate="${commands[mvn]:A:h:h}"
fi

if [[ -x "$maven_home_candidate/bin/mvn" ]]; then
  export M3_HOME="$maven_home_candidate"
  export MAVEN_HOME="$maven_home_candidate"
else
  unset M3_HOME MAVEN_HOME
fi
unset candidate maven_home_candidate
export MAVEN_OPTS="--add-opens java.base/java.lang=ALL-UNNAMED"

# Drop legacy entries inherited from an older parent shell before rebuilding
# PATH, otherwise an upgraded tool can still resolve to the retired version.
path=(${path:#/opt/homebrew/lib/ruby/gems/3.4.0/bin})
path=(${path:#$HOME/Library/Python/3.9/bin})
path=(${path:#$HOME/Downloads/apache-maven-*/bin})

toolchain_paths=()
[[ -d /opt/homebrew/opt/ruby/bin ]] && toolchain_paths+=(/opt/homebrew/opt/ruby/bin)
[[ -d /opt/homebrew/bin ]] && toolchain_paths+=(/opt/homebrew/bin)
[[ -n ${JAVA_HOME:-} && -d "$JAVA_HOME/bin" ]] && toolchain_paths+=("$JAVA_HOME/bin")
toolchain_paths+=("$HOME/.local/bin")

path=($toolchain_paths $path)
[[ -n ${M3_HOME:-} && -d "$M3_HOME/bin" ]] && path+=("$M3_HOME/bin")
typeset -U path PATH
unset toolchain_paths

# -- Aliases and shell helpers -------------------------------------------------
# Load before zsh-patina so aliases/functions are highlighted as known callables.
[[ -r "$HOME/.zsh/aliases.zsh" ]] && source "$HOME/.zsh/aliases.zsh"

# -- fzf -----------------------------------------------------------------------
# Legacy fzf style kept for reference.
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

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules --exclude .DS_Store --exclude "*.pyc"'
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git --exclude node_modules --exclude .DS_Store'

export FZF_CTRL_R_OPTS="
--color header:italic
--bind 'ctrl-/:toggle-sort'
--bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
--header 'CTRL-Y: Copy command into clipboard, CTRL-/: Toggle sorting by relevance'
"

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="
--preview 'bat --style=numbers --color=always --pager=never -- {}'
--preview-window 'right:60%:wrap'
--bind 'ctrl-v:execute(code {})+abort'
--bind 'ctrl-o:execute(open {})+abort'
--bind 'ctrl-/:change-preview-window(down,50%|hidden|)'
--header 'CTRL-V: open in VSCode | CTRL-O: open in Finder | CTRL-/: toggle preview'
"

export FZF_ALT_C_OPTS="
--preview 'eza -la --icons=always --color=always --group-directories-first -- {} 2>/dev/null || tree -C -L 2 {} | head -200'
--preview-window 'right:60%:wrap'
--bind 'ctrl-v:execute(code {})+abort'
--bind 'ctrl-/:change-preview-window(down,50%|hidden|)'
--header 'CTRL-V: open in VSCode | CTRL-/: toggle preview'
"

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

# -- Legacy zsh-syntax-highlighting palette -----------------------------------
# Kept as the source palette for the zsh-patina Tokyo/legacy theme files.
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

# -- Zinit plugins -------------------------------------------------------------
zinit light Aloxaf/fzf-tab

zinit ice wait lucid atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

# Patina is delayed so the first prompt wins, then a Rust daemon handles input
# highlighting without the old zsh-syntax-highlighting overhead.
zinit ice wait lucid \
  as"program" \
  from"gh-r" \
  pick"zsh-patina-*/zsh-patina" \
  atload'eval "$(zsh-patina activate)"'
zinit light michel-kraemer/zsh-patina

# -- Prompt and generated init scripts ----------------------------------------
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

zsh_init_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/init"
[[ -d "$zsh_init_cache" ]] || command mkdir -p "$zsh_init_cache" 2>/dev/null
[[ -d "$zsh_init_cache" && -w "$zsh_init_cache" ]] || zsh_init_cache=

if (( $+commands[starship] )); then
  if [[ -n "$zsh_init_cache" ]]; then
    starship_bin="${commands[starship]}"
    starship_cache="$zsh_init_cache/starship.zsh"

    if [[ ! -s "$starship_cache" || "$starship_bin" -nt "$starship_cache" ]]; then
      starship init zsh 2>/dev/null | command grep -v '^PROMPT2=' >| "$starship_cache"
      print -r -- "PROMPT2='\$($starship_bin prompt --continuation)'" >> "$starship_cache"
    fi

    source "$starship_cache"
  else
    eval "$(starship init zsh)"
  fi
fi

if (( $+commands[zoxide] )); then
  if [[ -n "$zsh_init_cache" ]]; then
    zoxide_bin="${commands[zoxide]}"
    zoxide_cache="$zsh_init_cache/zoxide.zsh"

    if [[ ! -s "$zoxide_cache" || "$zoxide_bin" -nt "$zoxide_cache" ]]; then
      zoxide init --cmd cd zsh >| "$zoxide_cache"
    fi

    source "$zoxide_cache"
  else
    eval "$(zoxide init --cmd cd zsh)"
  fi
fi

if [[ -o zle && -t 0 ]] && (( $+commands[fzf] )); then
  if [[ -n "$zsh_init_cache" ]]; then
    fzf_bin="${commands[fzf]}"
    fzf_cache="$zsh_init_cache/fzf.zsh"

    if [[ ! -s "$fzf_cache" || "$fzf_bin" -nt "$fzf_cache" ]]; then
      fzf --zsh >| "$fzf_cache"
    fi

    source "$fzf_cache"
  else
    source <(fzf --zsh)
  fi
fi
unset zsh_init_cache starship_bin starship_cache zoxide_bin zoxide_cache fzf_bin fzf_cache

# -- Interactive extras --------------------------------------------------------
[[ -o interactive ]] && stty -ixon 2>/dev/null

KEYTIMEOUT=300

[[ -r "$HOME/.zsh/fzf-git.sh" ]] && source "$HOME/.zsh/fzf-git.sh"

alias fk='eval "$(TF_ALIAS=fk PYTHONIOENCODING=utf-8 thefuck "$(fc -ln -1)")"'

# -- Diagnostics report --------------------------------------------------------
if [[ -n "$ZSH_DEBUGRC" ]]; then
  zprof
fi
