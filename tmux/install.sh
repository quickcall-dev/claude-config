#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$ROOT_DIR/lib/common.sh"

step "Installing tmux config"

# Ensure tmux is installed
ensure_cmd tmux

# ─── TPM ───

TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ -d "$TPM_DIR" ]]; then
    ok "TPM already installed"
else
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    ok "TPM installed"
fi

# ─── Config ───

DEST="$HOME/.tmux.conf"

backup_file "$DEST"
[[ -L "$DEST" ]] && rm "$DEST"

ln -sf "$SCRIPT_DIR/.tmux.conf" "$DEST"
ok "tmux config ${D}→ ~/.tmux.conf (symlinked)${R}"

# ─── Shell helpers (auto-name tmux sessions from CWD) ───

HELPERS_SRC="$SCRIPT_DIR/shell-helpers.sh"
SNIPPET="[ -f \"$HELPERS_SRC\" ] && source \"$HELPERS_SRC\"  # claude-config tmux helpers"

for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
    [[ -f "$rc" ]] || continue
    if ! grep -Fq "claude-config tmux helpers" "$rc" 2>/dev/null; then
        printf '\n%s\n' "$SNIPPET" >> "$rc"
        ok "shell helpers ${D}→ $(basename "$rc")${R}"
    else
        ok "shell helpers already in $(basename "$rc")"
    fi
done

# macOS: fix provenance xattr that blocks TPM
if [[ "$PLATFORM" == "mac" ]]; then
    xattr -r -d com.apple.provenance "$TPM_DIR" 2>/dev/null || true
    xattr -r -d com.apple.quarantine "$TPM_DIR" 2>/dev/null || true
fi

# ─── Install plugins ───

step "Installing tmux plugins"

if [[ -n "${TMUX:-}" ]]; then
    tmux source-file "$DEST" 2>/dev/null
    "$TPM_DIR/bin/install_plugins" 2>/dev/null && ok "plugins installed" || warn "run prefix+I inside tmux to install plugins"
else
    tmux start-server
    tmux new-session -d -s _install
    "$TPM_DIR/bin/install_plugins" 2>/dev/null && ok "plugins installed" || warn "run prefix+I inside tmux to install plugins"
    tmux kill-session -t _install 2>/dev/null
fi

# ─── VS Code / Cursor ───

step "Checking editors"

fix_editor_settings() {
    local settings_file="$1" editor_name="$2" profile_key="$3"
    [[ ! -f "$settings_file" ]] && return
    if grep -q "gpuAcceleration" "$settings_file"; then
        ok "$editor_name already configured"
        return
    fi
    local tmp=$(mktemp)
    sed "1 a\\
  \"terminal.integrated.gpuAcceleration\": \"off\",\\
  \"terminal.integrated.profiles.${profile_key}\": { \"tmux\": { \"path\": \"tmux\", \"args\": [\"new-session\", \"-A\", \"-s\", \"main\"], \"icon\": \"terminal-tmux\" } },\\
  \"terminal.integrated.defaultProfile.${profile_key}\": \"tmux\",
" "$settings_file" > "$tmp" && mv "$tmp" "$settings_file"
    ok "$editor_name patched for tmux"
}

if [[ "$PLATFORM" == "mac" ]]; then
    fix_editor_settings "$HOME/Library/Application Support/Code/User/settings.json" "VS Code" "osx"
    fix_editor_settings "$HOME/Library/Application Support/Cursor/User/settings.json" "Cursor" "osx"
else
    fix_editor_settings "$HOME/.config/Code/User/settings.json" "VS Code" "linux"
    fix_editor_settings "$HOME/.config/Cursor/User/settings.json" "Cursor" "linux"
fi

echo ""
echo -e "  ${GRN}Done!${R} Run ${CYN}tmux${R} to start"
echo -e "  ${D}Prefix: Ctrl+b  |  Reload: prefix r  |  Splits: prefix | and prefix -${R}"
echo ""
