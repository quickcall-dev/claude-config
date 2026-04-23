#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$ROOT_DIR/lib/common.sh"

step "Installing QuickCall skills"

# ─── Requires npx ───

if ! command -v npx &>/dev/null; then
    warn "npx not found — installing node first"
    bash "$ROOT_DIR/node/install.sh"
fi

npx skills add https://github.com/quickcall-dev/skills --yes --global

ok "QuickCall skills installed"

echo ""
echo -e "  ${GRN}Done!${R} QuickCall skills ready in Claude Code"
echo ""
