# Generated integrations stay cached across shells and refresh on tool upgrades.
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
zsh_init_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/init"
[[ -d "$zsh_init_cache" ]] || command mkdir -p "$zsh_init_cache" 2>/dev/null
[[ -d "$zsh_init_cache" && -w "$zsh_init_cache" ]] || zsh_init_cache=
source "$DOTFILES_ZSH_DIR/init-cache.zsh"

# Source at top level so Starship's promptsubst option survives initialization.
for init_tool in starship zoxide; do
  (( $+commands[$init_tool] )) || continue
  case "$init_tool" in
    starship) init_args=(init zsh) ;;
    zoxide) init_args=(init --cmd cd zsh) ;;
  esac
  if _dotfiles_cached_init "$init_tool" "${init_args[@]}"; then
    source "$REPLY"
  else
    source <(_dotfiles_generate_init "${commands[$init_tool]}" "$init_tool" "${init_args[@]}")
  fi
done
unfunction _dotfiles_cached_init _dotfiles_generate_init
unset zsh_init_cache init_tool init_args REPLY

# Homebrew ships these scripts: no generated cache or fzf subprocess needed.
# Load before fzf-tab, which must own the final Tab binding.
if [[ -o zle && -t 0 ]] && (( $+commands[fzf] )); then
  fzf_shell_dir="${commands[fzf]:A:h:h}/shell"
  if [[ -r "$fzf_shell_dir/completion.zsh" && -r "$fzf_shell_dir/key-bindings.zsh" ]]; then
    source "$fzf_shell_dir/completion.zsh"
    source "$fzf_shell_dir/key-bindings.zsh"
  else
    source <(fzf --zsh)
  fi
  unset fzf_shell_dir
fi