# Installed plugins only: opening a shell must not install or update software.
# Zinit retains update management and defers the two widget-wrapping plugins.
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_AUTOSUGGEST_STRATEGY=(history)
ZSH_AUTOSUGGEST_USE_ASYNC=1

if [[ -r "$HOME/.zinit/plugins/Aloxaf---fzf-tab/fzf-tab.zsh" ]]; then
  source "$HOME/.zinit/plugins/Aloxaf---fzf-tab/fzf-tab.zsh"
fi

if [[ -r "$HOME/.zinit/bin/zinit.git/zinit.zsh" ]]; then
  source "$HOME/.zinit/bin/zinit.git/zinit.zsh"
  autoload -Uz _zinit
  _comps[zinit]=_zinit

  if [[ -r "$HOME/.zinit/plugins/zsh-users---zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    zinit ice wait lucid atload'_zsh_autosuggest_start'
    zinit light zsh-users/zsh-autosuggestions
  fi

  patina_binaries=("$HOME"/.zinit/plugins/michel-kraemer---zsh-patina/zsh-patina-*/zsh-patina(N*))
  if (( ${#patina_binaries} )); then
    zinit ice wait lucid as"program" from"gh-r" pick"zsh-patina-*/zsh-patina" \
      atload'eval "$(zsh-patina activate)"'
    zinit light michel-kraemer/zsh-patina
  fi
  unset patina_binaries
fi