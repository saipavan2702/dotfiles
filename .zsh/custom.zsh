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

if [[ -r "$HOME/.zinit/bin/zinit.git/zinit.zsh" ]]; then
  source "$HOME/.zinit/bin/zinit.git/zinit.zsh"
  autoload -Uz _zinit
fi

zsh_cache_dir_was_set=${+ZSH_CACHE_DIR}
zsh_cache_dir_save="${ZSH_CACHE_DIR-}"
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/oh-my-zsh"

plugins=(git)
if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
else
  # Keep a usable shell on a fresh install before optional frameworks exist.
  autoload -Uz compinit
  compinit -d "$ZSH_COMPDUMP"
  HISTFILE="$HOME/.zsh_history"
  HISTSIZE=50000
  SAVEHIST=50000
fi

if (( zsh_cache_dir_was_set )); then
  export ZSH_CACHE_DIR="$zsh_cache_dir_save"
else
  unset ZSH_CACHE_DIR
fi
unset zsh_cache_dir_was_set zsh_cache_dir_save

(( ${+functions[zinit]} && ${+_comps} )) && _comps[zinit]=_zinit

# fzf-tab reads completion colors; keep this static to avoid startup commands.
export LSCOLORS="${LSCOLORS:-Gxfxcxdxbxegedabagacad}"
export LS_COLORS="${LS_COLORS:-di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43}"
[[ -n "$LS_COLORS" ]] && zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# -- Plugin settings -----------------------------------------------------------
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="20"
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_AUTOSUGGEST_STRATEGY=(history)
ZSH_AUTOSUGGEST_USE_ASYNC=1

# -- Toolchains ----------------------------------------------------------------
# export LANG=en_US.UTF-8
# Load NVM only when requested; ordinary shells keep Homebrew Node startup fast.
for nvm_init in "${NVM_DIR:-$HOME/.nvm}/nvm.sh" /opt/homebrew/opt/nvm/nvm.sh /usr/local/opt/nvm/nvm.sh; do
  if [[ -r "$nvm_init" ]]; then
    typeset -g _dotfiles_nvm_init="$nvm_init"
    nvm() {
      unfunction nvm
      export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
      source "$_dotfiles_nvm_init" --no-use
      unset _dotfiles_nvm_init
      nvm "$@"
    }
    break
  fi
done
unset nvm_init

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
export MAVEN_OPTS="${MAVEN_OPTS:---add-opens java.base/java.lang=ALL-UNNAMED}"

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
(( $+commands[nvim] )) && export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-${EDITOR:-vi}}"

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
if (( ${+functions[zinit]} )); then
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
fi

# -- Prompt and generated init scripts ----------------------------------------
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

zsh_init_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/init"
[[ -d "$zsh_init_cache" ]] || command mkdir -p "$zsh_init_cache" 2>/dev/null
[[ -d "$zsh_init_cache" && -w "$zsh_init_cache" ]] || zsh_init_cache=

# Generate into a private temporary file and rename only after success. Shells
# opening concurrently must never source each other's partially written cache.
_dotfiles_generate_init() {
  emulate -L zsh
  setopt pipefail
  local bin="$1" tool="$2"
  shift 2
  if [[ "$tool" == starship ]]; then
    "$bin" "$@" | command sed '/^PROMPT2=/d' || return
    print -r -- "PROMPT2='\$(${(q)bin} prompt --continuation)'"
  else
    "$bin" "$@"
  fi
}

_dotfiles_cached_init() {
  emulate -L zsh
  local tool="$1"
  shift
  (( $+commands[$tool] )) || return 0
  local bin="${commands[$tool]}"
  local resolved="${bin:A}"
  local cache="$zsh_init_cache/$tool-v2.zsh"
  local stamp="# binary: $resolved; zsh: $ZSH_VERSION; args: $*"
  local first_line temporary

  if [[ -z "$zsh_init_cache" ]]; then
    return 1
  fi

  [[ -r "$cache" ]] && IFS= read -r first_line < "$cache"
  if [[ ! -s "$cache" || "$first_line" != "$stamp" || "$resolved" -nt "$cache" ]]; then
    temporary="$(command mktemp "$cache.XXXXXXXX")" || return 1
    if { print -r -- "$stamp"; _dotfiles_generate_init "$bin" "$tool" "$@"; } > "$temporary"; then
      command mv -f -- "$temporary" "$cache" || return 1
    else
      command rm -f -- "$temporary"
      return 1
    fi
  fi
  REPLY="$cache"
  [[ -r "$cache" ]]
}

# Source at top level: Starship's shell options must outlive the helper's
# `emulate -L` scope, and fzf/zoxide must not inherit helper-local variables.
for init_tool in starship zoxide fzf; do
  (( $+commands[$init_tool] )) || continue
  case "$init_tool" in
    starship) init_args=(init zsh) ;;
    zoxide) init_args=(init --cmd cd zsh) ;;
    fzf)
      [[ -o zle && -t 0 ]] || continue
      init_args=(--zsh)
      ;;
  esac
  if _dotfiles_cached_init "$init_tool" "${init_args[@]}"; then
    source "$REPLY"
  else
    source <(_dotfiles_generate_init "${commands[$init_tool]}" "$init_tool" "${init_args[@]}")
  fi
done
unfunction _dotfiles_cached_init _dotfiles_generate_init
unset zsh_init_cache init_tool init_args REPLY

# -- Interactive extras --------------------------------------------------------
[[ -o interactive ]] && stty -ixon 2>/dev/null

KEYTIMEOUT=20  # hundredths of a second; keep Escape responsive

[[ -r "$HOME/.zsh/fzf-git.sh" ]] && source "$HOME/.zsh/fzf-git.sh"

# -- Diagnostics report --------------------------------------------------------
if [[ -n "$ZSH_DEBUGRC" ]]; then
  zprof
fi
