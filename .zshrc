# Main interactive shell config.
[[ -r "$HOME/.zsh/custom.zsh" ]] && source "$HOME/.zsh/custom.zsh"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/mmacha/.lmstudio/bin"
# End of LM Studio CLI section


#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
if [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
  # SDKMAN is available on first use without adding its framework and
  # completion setup to every interactive shell.
  sdk() {
    unfunction sdk
    source "$SDKMAN_DIR/bin/sdkman-init.sh"
    sdk "$@"
  }
fi
