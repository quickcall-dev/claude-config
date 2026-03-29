#!/usr/bin/env bash
set -e

CLAUDE_DIR="$HOME/.claude"
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

R='\033[0m' B='\033[1m' D='\033[2m'
GRN='\033[32m' YLW='\033[33m' RED='\033[31m'
CYN='\033[36m' BLU='\033[34m' MAG='\033[35m'

trap 'printf "\033[?25h"' EXIT
printf "\033[?25l"

TOTAL_STEPS=4

draw_progress() {
    local current=$1 label=$2 width=30
    local pct=$(( current * 100 / TOTAL_STEPS ))
    local filled=$(( current * width / TOTAL_STEPS ))
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="━"; done
    for ((i=filled; i<width; i++)); do bar+="─"; done
    printf "\033[s"
    printf "\033[K  ${CYN}%s${R} ${D}%d%%${R}\n" "$bar" "$pct"
    printf "\033[K  ${D}%s${R}" "$label"
    printf "\033[u"
}

step_ok()   { printf "\r\033[K  ${GRN}${B} ✓ ${R} %b\n" "$1"; }
step_warn() { printf "\r\033[K  ${YLW}${B} ! ${R} %b\n" "$1"; }
step_fail() { printf "\r\033[K  ${RED}${B} ✗ ${R} %b\n" "$1"; }
pause()     { sleep "${1:-0.3}"; }

# ─── Header ─────────────────────────────────────────

echo ""
ascii=(
    "  ${CYN}${B}  ____ ____ ____${R}"
    "  ${CYN}${B} / ___/ ___/ ___|${R}"
    "  ${CYN}${B}| |  | |  | |${R}"
    "  ${CYN}${B}| |__| |__| |___${R}"
    '  '"${CYN}${B}"' \____\____\____|'"${R}"
)
for line in "${ascii[@]}"; do echo -e "$line"; sleep 0.05; done
echo -e "  ${B}Claude Code Config${R} ${D}by QuickCall${R}"
echo ""

# ─── Dependencies ───────────────────────────────────

errors=0
printf "\r\033[K  ${D}...${R} jq"; pause 0.2
if command -v jq &> /dev/null; then step_ok "jq ${D}$(jq --version 2>&1)${R}"
else step_fail "jq not found  ${D}brew install jq / apt install jq${R}"; errors=1; fi

printf "\r\033[K  ${D}...${R} git"; pause 0.2
if command -v git &> /dev/null; then step_ok "git ${D}$(git --version | awk '{print $3}')${R}"
else step_fail "git not found"; errors=1; fi

printf "\r\033[K  ${D}...${R} claude"; pause 0.2
if command -v claude &> /dev/null; then step_ok "claude cli"
else step_warn "claude cli not in PATH ${D}(continuing)${R}"; fi

if [[ $errors -gt 0 ]]; then step_fail "missing required dependencies"; exit 1; fi
echo ""

# ─── Install ────────────────────────────────────────

mkdir -p "$CLAUDE_DIR"
echo ""

draw_progress 0 "copying statusline.sh..."
pause 0.3
cp "$ROOT_DIR/statusline/statusline.sh" "$CLAUDE_DIR/statusline-command.sh"
chmod +x "$CLAUDE_DIR/statusline-command.sh"
step_ok "statusline.sh ${D}-> ~/.claude/${R}"
draw_progress 1 "copying turn-counter.sh..."
pause 0.3

cp "$ROOT_DIR/hooks/turn-counter.sh" "$CLAUDE_DIR/turn-counter.sh"
chmod +x "$CLAUDE_DIR/turn-counter.sh"
step_ok "turn-counter.sh ${D}-> ~/.claude/${R}"
draw_progress 2 "merging settings.json..."
pause 0.3

if [[ -f "$SETTINGS_FILE" ]]; then
    # Keep only one backup, overwrite previous
    cp "$SETTINGS_FILE" "$CLAUDE_DIR/settings.json.bak"
    existing=$(cat "$SETTINGS_FILE")
else
    existing="{}"
fi

updated=$(echo "$existing" | jq '
  .statusLine = {
    "type": "command",
    "command": ($home + "/.claude/statusline-command.sh")
  } |
  .hooks.Stop = (
    [(.hooks.Stop // [])[] | select(.hooks[0].command | test("turn-counter\\.sh$") | not)] +
    [{"hooks": [{"type": "command", "command": ($home + "/.claude/turn-counter.sh")}]}]
  )
' --arg home "$HOME")

echo "$updated" > "$SETTINGS_FILE"
step_ok "settings.json ${D}(merged, backup saved)${R}"
draw_progress 3 "verifying..."
pause 0.3

all_good=true
[[ -x "$CLAUDE_DIR/statusline-command.sh" ]] || all_good=false
[[ -x "$CLAUDE_DIR/turn-counter.sh" ]] || all_good=false
settings_ok=$(cat "$SETTINGS_FILE" | jq 'has("statusLine") and has("hooks")' 2>/dev/null)
[[ "$settings_ok" == "true" ]] || all_good=false

if [[ "$all_good" == true ]]; then step_ok "all checks passed"
else step_warn "installed with issues"; fi

if [[ "$all_good" == true ]]; then draw_progress 4 "complete"
else draw_progress 4 "completed with warnings"; fi
pause 0.2

echo ""
echo ""
echo -e "  ${D}preview:${R}  ${BLU}my-project${R} ${D}•${R} ${GRN}main${R} ${D}•${R} ${MAG}Opus 4.6${R} ${D}•${R} ${GRN}[█░░░░░░░]${R} ${D}5%${R} ${D}•${R} ${CYN}T3${R}"
echo -e "  ${D}turns:${R}    ${CYN}T1-19${R} ok  ${YLW}T20-29${R} long  ${RED}T30+${R} reset"
echo ""
echo -e "  ${CYN}>${R} restart claude code to activate"
echo ""
sleep 3
