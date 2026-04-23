#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$ROOT_DIR/lib/common.sh"

step "Installing caveman (Claude Code plugin)"

# ─── Requires claude CLI ───

if ! command -v claude &>/dev/null; then
    warn "claude CLI not found — install Claude Code first: https://claude.ai/code"
    exit 1
fi

claude plugin marketplace add JuliusBrussee/caveman
claude plugin install caveman@caveman

ok "caveman installed"

echo ""
echo -e "  ${GRN}Done!${R} Use ${CYN}/caveman${R} in Claude Code to activate"
echo -e "  ${D}Levels: /caveman lite | full | ultra  |  Stop: 'normal mode'${R}"
echo ""
