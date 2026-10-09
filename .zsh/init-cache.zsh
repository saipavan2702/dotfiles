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
  (( $+commands[$tool] )) || return 1
  local bin="${commands[$tool]}"
  local resolved="${bin:A}"
  local cache="$zsh_init_cache/$tool-v3.zsh"
  local stamp="# binary: $resolved; command: $bin; zsh: $ZSH_VERSION; args: $*"
  local first_line temporary

  if [[ -z "$zsh_init_cache" ]]; then
    return 1
  fi

  [[ -r "$cache" ]] && IFS= read -r first_line < "$cache"
  if [[ ! -s "$cache" || "$first_line" != "$stamp" || "$resolved" -nt "$cache" ]]; then
    temporary="$(command mktemp "$cache.XXXXXXXX")" || return 1
    if { print -r -- "$stamp"; _dotfiles_generate_init "$bin" "$tool" "$@"; } > "$temporary"; then
      # Validate before publishing. Rename keeps concurrent readers safe.
      if ! command zsh -n "$temporary" || ! command mv -f -- "$temporary" "$cache"; then
        command rm -f -- "$temporary"
        return 1
      fi
    else
      command rm -f -- "$temporary"
      return 1
    fi
  fi
  REPLY="$cache"
  [[ -r "$cache" ]]
}