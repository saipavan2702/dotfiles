#!/usr/bin/env bash

# Read-only health checks for the tracked configuration. Nothing is installed,
# updated, or cleaned by this script.

set -u

repo_root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
check_tmp="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-check.XXXXXX")" || exit 1
check_log="$check_tmp/output.log"
stow_target="$check_tmp/home"
tmux_socket="/private/tmp/dotfiles-tmux-$$.sock"
failures=0

mkdir -p "$stow_target"

cleanup() {
  tmux -S "$tmux_socket" kill-server >/dev/null 2>&1 || true
  rm -f "$check_log" "$check_tmp/nvim.log" "$check_tmp/tmux-error.log" "$tmux_socket"
  rmdir "$stow_target" "$check_tmp" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

pass() {
  printf '  [ok] %s\n' "$1"
}

fail() {
  printf '  [fail] %s\n' "$1"
  sed 's/^/         /' "$check_log"
  failures=$((failures + 1))
}

skip() {
  printf '  [skip] %s\n' "$1"
}

run_check() {
  local label="$1" status
  shift
  : >"$check_log"
  "$@" >"$check_log" 2>&1
  status=$?
  case "$status" in
    0) pass "$label" ;;
    77) skip "$label (blocked by the current sandbox)" ;;
    *) fail "$label" ;;
  esac
}

required_tools() {
  local tool missing=0
  for tool in \
    aerospace bat cpos deno eza fastfetch fd fzf ghostty git jq lazygit nvim node \
    pngpaste rg ruby starship stow terminal-notifier thefuck timer tmux tree \
    tree-sitter vim zoxide; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      printf 'missing command: %s\n' "$tool"
      missing=1
    fi
  done
  return "$missing"
}

shell_syntax() {
  zsh -n "$repo_root/.zshrc" "$repo_root/.zsh/aliases.zsh" \
    "$repo_root/.zsh/custom.zsh" "$repo_root/.zsh/fzf-git.sh" || return
  find "$repo_root/.config/tmux/scripts" "$repo_root/scripts" \
    -type f -name '*.sh' -exec bash -n {} +
}

toml_syntax() {
  python3 - \
    "$repo_root/.aerospace.toml" \
    "$repo_root/.config/neru/config.toml" \
    "$repo_root/.config/starship/starship.toml" \
    "$repo_root/.config/zsh-patina/config.toml" \
    "$repo_root/.config/zsh-patina/current-highlighting.toml" \
    "$repo_root/.config/zsh-patina/tokyo-night-darker.toml" \
    "$repo_root/Library/Application Support/cpos/config.toml" <<'PY'
import pathlib
import sys
import tomllib

for name in sys.argv[1:]:
    with pathlib.Path(name).open("rb") as handle:
        tomllib.load(handle)
PY
}

jsonc_syntax() {
  local parser="/Applications/Cursor.app/Contents/Resources/app/node_modules/jsonc-parser"
  if [[ ! -d "$parser" ]]; then
    printf 'Cursor jsonc-parser not found: %s\n' "$parser"
    return 1
  fi

  node - "$parser" \
    "$repo_root/.config/fastfetch/config.jsonc" \
    "$repo_root/.config/zed/keymap.json" \
    "$repo_root/.config/zed/settings.json" \
    "$repo_root/.config/zed/snippets/python.json" \
    "$repo_root/.config/zed/tasks.json" \
    "$repo_root/.config/sublime-text/Packages/User/Package Control.sublime-settings" \
    "$repo_root/.config/sublime-text/Packages/User/Preferences.sublime-settings" \
    "$repo_root/.config/sublime-text/Packages/User/cpp.sublime-build" \
    "$repo_root/Library/Application Support/Code/User/keybindings.json" \
    "$repo_root/Library/Application Support/Code/User/settings.json" \
    "$repo_root/Library/Application Support/Cursor/User/keybindings.json" \
    "$repo_root/Library/Application Support/Cursor/User/settings.json" \
    "$repo_root/BetterTouchTool/menubar_appswitcher.bttpreset" <<'NODE'
const fs = require("fs");
const jsonc = require(process.argv[2]);

let failed = false;
for (const name of process.argv.slice(3)) {
  const errors = [];
  jsonc.parse(fs.readFileSync(name, "utf8"), errors, {
    allowTrailingComma: true,
    disallowComments: false,
  });
  if (errors.length > 0) {
    failed = true;
    console.error(`${name}: ${JSON.stringify(errors)}`);
  }
}
process.exitCode = failed ? 1 : 0;
NODE
}

yaml_syntax() {
  ruby -e 'require "yaml"; ARGV.each { |f| YAML.safe_load_file(f, aliases: true) }' \
    "$repo_root/.config/lazygit/config.yml"
}

lua_syntax() {
  local lua_file status=0
  while IFS= read -r -d '' lua_file; do
    NVIM_LOG_FILE="$check_tmp/nvim.log" nvim --headless -u NONE -i NONE \
      -c "lua assert(loadfile([==[$lua_file]==]))" -c qa || status=1
  done < <(find "$repo_root/.config/nvim" -type f -name '*.lua' -print0)
  return "$status"
}

tmux_config() {
  local tmux_error="$check_tmp/tmux-error.log"
  if ! tmux -S "$tmux_socket" -f "$repo_root/.config/tmux/tmux.conf" \
    new-session -d -s dotfiles-check 'sleep 2' 2>"$tmux_error"; then
    if grep -q 'Operation not permitted' "$tmux_error"; then
      return 77
    fi
    cat "$tmux_error"
    return 1
  fi
  if [[ ! -S "$tmux_socket" ]]; then
    if grep -q 'Operation not permitted' "$tmux_error"; then
      return 77
    fi
    cat "$tmux_error"
    return 1
  fi
  tmux -S "$tmux_socket" \
    show-options -gqv default-terminal | \
    grep -Fx 'tmux-256color' >/dev/null || return
  tmux -S "$tmux_socket" kill-server
}

stow_layout() {
  (cd "$repo_root" && stow --simulate --verbose=1 --target "$stow_target" .)
}

cpos_template() {
  "$repo_root/.local/bin/cp-g++" -std=gnu++20 -Wall -Wextra -Wshadow \
    -fsyntax-only \
    "$repo_root/Library/Application Support/cpos/templates/template.cpp"
}

printf 'Dotfiles health check\n'
run_check 'required commands' required_tools
run_check 'Zsh and Bash syntax' shell_syntax
run_check 'TOML syntax' toml_syntax
run_check 'JSON and JSONC syntax' jsonc_syntax
run_check 'YAML syntax' yaml_syntax
run_check 'Neovim Lua syntax' lua_syntax
run_check 'Vim config' vim -Nu "$repo_root/.vimrc" -n -i NONE -es '+qa'
run_check 'Ghostty config' ghostty +validate-config \
  --config-file="$repo_root/.config/ghostty/config"
run_check 'Starship config' env \
  STARSHIP_CONFIG="$repo_root/.config/starship/starship.toml" \
  starship print-config
run_check 'tmux config' tmux_config
run_check 'Stow layout (simulation)' stow_layout
run_check 'CPOS C++ template' cpos_template
if pgrep -x AeroSpace >/dev/null 2>&1; then
  run_check 'AeroSpace config' aerospace reload-config --dry-run --warnings-as-errors
else
  skip 'AeroSpace config (AeroSpace.app is not running)'
fi

if (( failures > 0 )); then
  printf '\n%d check(s) failed.\n' "$failures"
  exit 1
fi

printf '\nAll available checks passed.\n'
