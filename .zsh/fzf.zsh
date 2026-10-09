# Personal fzf settings. Loaded before shell integration and fzf-tab.

# ============================================================================
#                        File and directory candidates
# ============================================================================
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules --exclude .DS_Store --exclude "*.pyc"'
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git --exclude node_modules --exclude .DS_Store'

# ============================================================================
#                            Ctrl-R: history search
# ============================================================================
export FZF_CTRL_R_OPTS="
--color header:italic
--bind 'ctrl-/:toggle-sort'
--bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
--header 'CTRL-Y: Copy command into clipboard, CTRL-/: Toggle sorting by relevance'
"

# ============================================================================
#                             Ctrl-T: file picker
# ============================================================================
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="
--preview 'bat --style=numbers --color=always --pager=never -- {}'
--preview-window 'right:60%:wrap'
--bind 'ctrl-v:execute(code {})+abort'
--bind 'ctrl-o:execute(open {})+abort'
--bind 'ctrl-/:change-preview-window(down,50%|hidden|)'
--header 'CTRL-V: open in VSCode | CTRL-O: open in Finder | CTRL-/: toggle preview'
"

# ============================================================================
#                           Alt-C: directory picker
# ============================================================================
export FZF_ALT_C_OPTS="
--preview 'eza -la --icons=always --color=always --group-directories-first -- {} 2>/dev/null || tree -C -L 2 {} | head -200'
--preview-window 'right:60%:wrap'
--bind 'ctrl-v:execute(code {})+abort'
--bind 'ctrl-/:change-preview-window(down,50%|hidden|)'
--header 'CTRL-V: open in VSCode | CTRL-/: toggle preview'
"

# ============================================================================
#                        Layout and Tokyo Night colours
# ============================================================================
export FZF_DEFAULT_OPTS="
--height 40%
--layout=reverse
--border
--inline-info
--color=fg:#c0caf5,bg:#1a1b26,hl:#7aa2f7
--color=fg+:#c0caf5,bg+:#1f2335,hl+:#7dcfff
--color=info:#7dcfff,prompt:#7aa2f7,pointer:#f7768e
--color=marker:#9eceba,spinner:#9ece6a,header:#bb9af7
"