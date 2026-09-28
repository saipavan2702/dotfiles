# macOS dotfiles

Personal settings deployed from `~/dotfiles` with GNU Stow.

## Install

Install Homebrew if needed, then clone the repository and link the configs:

```sh
brew install stow
git clone git@github.com:saipavan2702/dotfiles.git "$HOME/dotfiles"
cd "$HOME/dotfiles"
stow --restow --target="$HOME" .
```

Install the tools and plugins used by these configs:

```sh
brew install tmux fzf fd ripgrep zoxide lazygit
mkdir -p "$HOME/.zinit/bin"
git clone https://github.com/zdharma-continuum/zinit.git "$HOME/.zinit/bin/zinit.git"
git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
mkdir -p "$HOME/.config/tmux/plugins"
git clone https://github.com/wfxr/tmux-fzf-url.git "$HOME/.config/tmux/plugins/tmux-fzf-url"
vim +PlugInstall +qall
```

## CPOS

The C++ template is `~/Library/Application Support/cpos/templates/template.cpp`.
Builds use `~/.local/bin/cp-g++` to select the available Homebrew GCC.
