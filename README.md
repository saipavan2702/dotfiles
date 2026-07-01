## Steps to install

Clone the repo in home directory, and run the below command
```bash
stow .
```
> Mac tips
> `defaults write com.apple.screencaptureui "thumbnailExpiration" -float 20 && killall SystemUIServer`

### Reference links
- [ghostty-config-ref-1](https://github.com/ghostty-org/ghostty/discussions/3527)
- [ghostty-small-icons-issue](https://github.com/ghostty-org/ghostty/discussions/3501)
- [speeding-up-shell](https://scottspence.com/posts/speeding-up-my-zsh-shell)

### Competitive programming

GCC is routed through `~/.local/bin/cp-g++` in the CP editor flow. That wrapper
auto-selects the newest Homebrew compiler matching `/opt/homebrew/bin/g++-[0-9]*`
or `/usr/local/bin/g++-[0-9]*`.

These places should point to `~/.local/bin/cp-g++`:

- `Library/Application Support/cpos/config.toml`
- `Library/Application Support/Cursor/User/settings.json`
- `Library/Application Support/Code/User/settings.json`
- `.config/zed/tasks.json`
- `~/Library/Application Support/cpos/config.toml`

If Homebrew changes the GCC naming scheme someday, update `.local/bin/cp-g++`.
Zed/clangd and Neovim/clangd use `/opt/homebrew/bin/g++-*` query-driver
wildcards for header discovery, not for actually running builds.

The active CPOS C++ template is:

- `Library/Application Support/cpos/templates/luv.cpp`
