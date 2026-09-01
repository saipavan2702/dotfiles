# macOS dotfiles

Personal configurations for Zsh, Ghostty, tmux, Neovim, Vim, AeroSpace,
Starship, Zed, VS Code, Cursor, CPOS, and related command-line tools.

The repository is designed to live at `~/dotfiles` and uses GNU Stow to create
home-directory links.

## Setup

Install Git and GNU Stow, then clone the repository:

```sh
git clone git@github.com:saipavan2702/dotfiles.git "$HOME/dotfiles"
cd "$HOME/dotfiles"
```

Bootstrap the external shell, Vim, and tmux plugins:

```sh
test -d "$HOME/.zinit/bin/zinit.git" || \
  git clone https://github.com/zdharma-continuum/zinit.git \
  "$HOME/.zinit/bin/zinit.git"

test -d "$HOME/.oh-my-zsh" || \
  git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"

test -f "$HOME/.vim/autoload/plug.vim" || \
  curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

mkdir -p "$HOME/.config/tmux/plugins"
test -d "$HOME/.config/tmux/plugins/tmux-fzf-url" || \
  git clone https://github.com/wfxr/tmux-fzf-url.git \
  "$HOME/.config/tmux/plugins/tmux-fzf-url"
```

Preview the links, then apply them:

```sh
stow --simulate --verbose=1 --target="$HOME" .
stow --restow --target="$HOME" .
```

`references`, `scripts`, this README, and GitHub metadata stay inside the
repository. The Starship backup is linked to
`~/.config/starship/starship.toml.bak1`, and the BetterTouchTool preset is linked
to `~/BetterTouchTool/menubar_appswitcher.bttpreset`. Import the preset manually
inside BetterTouchTool when needed.

## Validate

Run the read-only health check after setup or configuration changes:

```sh
cd "$HOME/dotfiles"
./scripts/check.sh
```

The script reports missing tools and validates the supported shell, editor,
terminal, Stow, CPOS, and application configurations. Checks that require an
application to be running may be skipped.

## CPOS

The active C++ template is
`~/Library/Application Support/cpos/templates/template.cpp`. Builds use the
shared `~/.local/bin/cp-g++` wrapper to select the available Homebrew GCC.
