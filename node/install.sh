#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$ROOT_DIR/lib/common.sh"

step "Installing Node.js (npm + npx)"

if command -v node &>/dev/null; then
    ok "node ${D}$(node --version) → $(command -v node)${R}"
else
    warn "node not found — installing"
    pkg_install node
    ok "node installed ${D}$(node --version)${R}"
fi

if command -v npm &>/dev/null; then
    ok "npm ${D}$(npm --version)${R}"
fi

if command -v npx &>/dev/null; then
    ok "npx ${D}$(npx --version)${R}"
fi

echo ""
echo -e "  ${GRN}Done!${R} node $(node --version) ready"
echo ""
