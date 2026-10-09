# Interactive shell entry point. Resolve symlinks before locating the modules.
typeset -g DOTFILES_ZSH_DIR="${${(%):-%x}:A:h}/.zsh"
[[ -n ${ZSH_DEBUGRC:-} ]] && zmodload zsh/zprof

# Order matters: paths first, then completion, integrations and plugins.
# Personal aliases load last so they can override framework defaults.
for zsh_module in environment toolchains completion compatibility fzf integrations plugins aliases; do
  source "$DOTFILES_ZSH_DIR/$zsh_module.zsh"
done
unset zsh_module

[[ -r "$DOTFILES_ZSH_DIR/fzf-git.sh" ]] && source "$DOTFILES_ZSH_DIR/fzf-git.sh"
[[ -n ${ZSH_DEBUGRC:-} ]] && zprof
true
