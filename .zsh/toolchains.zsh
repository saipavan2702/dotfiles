# Node.js (lazy NVM loading)
# Load NVM only when requested; ordinary shells keep Homebrew Node startup fast.
for nvm_init in "${NVM_DIR:-$HOME/.nvm}/nvm.sh" /opt/homebrew/opt/nvm/nvm.sh /usr/local/opt/nvm/nvm.sh; do
  if [[ -r "$nvm_init" ]]; then
    typeset -g _dotfiles_nvm_init="$nvm_init"
    nvm() {
      unfunction nvm
      export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
      source "$_dotfiles_nvm_init" --no-use
      unset _dotfiles_nvm_init
      nvm "$@"
    }
    break
  fi
done
unset nvm_init

# Java 17: reuse a valid inherited JAVA_HOME before asking macOS.
if [[ -z ${JAVA_HOME:-} || ! -d "$JAVA_HOME" ]]; then
  java_home_candidate=""

  if [[ -x /usr/libexec/java_home ]]; then
    java_home_candidate="$(/usr/libexec/java_home -v 17 2>/dev/null)"
  elif (( $+commands[java] )); then
    java_home_candidate="${commands[java]:A:h:h}"
  fi

  [[ -d "$java_home_candidate" ]] && export JAVA_HOME="$java_home_candidate"
  unset java_home_candidate
fi

# Maven: prefer package-manager installs before inherited variables or PATH entries.
# This lets an SDKMAN/Homebrew upgrade supersede an older parent-shell value.
maven_home_candidate=""
for candidate in \
  /opt/homebrew/opt/maven \
  /usr/local/opt/maven \
  "$HOME/.sdkman/candidates/maven/current" \
  "${M3_HOME:-}" \
  "${MAVEN_HOME:-}"; do
  if [[ -n "$candidate" && -x "$candidate/bin/mvn" ]]; then
    maven_home_candidate="$candidate"
    break
  fi
done

if [[ -z "$maven_home_candidate" ]] && (( $+commands[mvn] )); then
  maven_home_candidate="${commands[mvn]:A:h:h}"
fi

if [[ -x "$maven_home_candidate/bin/mvn" ]]; then
  export M3_HOME="$maven_home_candidate"
  export MAVEN_HOME="$maven_home_candidate"
else
  unset M3_HOME MAVEN_HOME
fi
unset candidate maven_home_candidate
export MAVEN_OPTS="${MAVEN_OPTS:---add-opens java.base/java.lang=ALL-UNNAMED}"

# PATH and editor. Drop legacy entries inherited from an older parent shell before rebuilding
# PATH, otherwise an upgraded tool can still resolve to the retired version.
path=(${path:#/opt/homebrew/lib/ruby/gems/3.4.0/bin})
path=(${path:#$HOME/Library/Python/3.9/bin})
path=(${path:#$HOME/Downloads/apache-maven-*/bin})

toolchain_paths=()
[[ -d /opt/homebrew/opt/ruby/bin ]] && toolchain_paths+=(/opt/homebrew/opt/ruby/bin)
[[ -d /opt/homebrew/bin ]] && toolchain_paths+=(/opt/homebrew/bin)
[[ -n ${JAVA_HOME:-} && -d "$JAVA_HOME/bin" ]] && toolchain_paths+=("$JAVA_HOME/bin")
toolchain_paths+=("$HOME/.local/bin")

path=($toolchain_paths $path)
[[ -n ${M3_HOME:-} && -d "$M3_HOME/bin" ]] && path+=("$M3_HOME/bin")
typeset -U path PATH
unset toolchain_paths
(( $+commands[nvim] )) && export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-${EDITOR:-vi}}"

# SDKMAN: initialise only when the sdk command is first used.
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