#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$ROOT_DIR/lib/common.sh"

step "Installing Karabiner-Elements"

# ─── macOS only ───

if [[ "$PLATFORM" != "mac" ]]; then
    warn "Karabiner-Elements is macOS only — skipping"
    exit 0
fi

# ─── Install app ───

if command -v karabiner_cli &>/dev/null || [[ -d "/Applications/Karabiner-Elements.app" ]]; then
    ok "Karabiner-Elements already installed"
else
    warn "Karabiner-Elements not found — installing via brew cask"
    brew install --cask karabiner-elements
    ok "Karabiner-Elements installed"
fi

# ─── Config (sagarsrc/karabiner_scripts) ───

step "Installing karabiner config"

KARABINER_SCRIPTS_DIR="$HOME/.config/karabiner/karabiner_scripts"

if [[ -d "$KARABINER_SCRIPTS_DIR/.git" ]]; then
    ok "karabiner_scripts already cloned — pulling latest"
    git -C "$KARABINER_SCRIPTS_DIR" pull --ff-only
else
    git clone https://github.com/sagarsrc/karabiner_scripts "$KARABINER_SCRIPTS_DIR"
    ok "karabiner_scripts cloned"
fi

bash "$KARABINER_SCRIPTS_DIR/install.sh"
ok "karabiner.json installed"

echo ""
echo -e "  ${GRN}Done!${R} Karabiner-Elements is running with your config"
echo -e "  ${D}Config: sagarsrc/karabiner_scripts${R}"
echo ""
