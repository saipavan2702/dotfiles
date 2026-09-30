# macOS dotfiles

My Zsh, Neovim, Vim, tmux, Ghostty, Starship, and other app settings.
Managed with GNU Stow from `~/dotfiles`.

## Setup

Install Homebrew, GNU Stow, and the apps you use, then:

```sh
git clone git@github.com:saipavan2702/dotfiles.git "$HOME/dotfiles"
cd "$HOME/dotfiles"
stow --simulate --restow --target="$HOME" .
stow --restow --target="$HOME" .
```

Use JetBrainsMono Nerd Font for the configured terminal icons.
The shell uses Oh My Zsh and Zinit; Vim plugins use vim-plug.
In Neovim, run `:Lazy restore` to install the locked plugin versions.

## Shortcuts

- **tmux prefix:** `Ctrl-S`. Split with prefix + `-` or `\`.
- **Close pane:** prefix + `x`, then `y` to confirm.
- **Reload tmux:** prefix + `r`.
- **Pick project/session:** prefix + `o` / prefix + `s`.
- **Previous session:** prefix + `B`.
- **Neovim leader:** `Space`. Harpoon file 4 is `Space`, then `4`.
- **Reload Zsh:** `exec zsh`.

## Notes

- Keep `lazy-lock.json`; use `:Lazy update` to update Neovim plugins.
- Commented shader and plugin options are saved alternatives for later use.
- C++ builds use `cp-g++` and require Homebrew GCC.
- Codeforces reads new templates from the Sublime snippet at
  `~/Library/Application Support/Sublime Text/Packages/User/batman.sublime-snippet`.
- Only configs managed here need links in `~/.config`; other apps can keep their
  own local settings.
