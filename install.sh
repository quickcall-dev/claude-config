#!/usr/bin/env bash
set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/lib/common.sh"

# ─── Header ─────────────────────────────────────────

echo ""
echo -e "  ${CYN}${B}claude-config${R} ${D}by QuickCall${R}"
echo ""

# ─── Discover modules ───────────────────────────────
# Each directory with an install.sh is a module

modules=()
module_names=()
for dir in "$ROOT_DIR"/*/; do
    if [[ -f "$dir/install.sh" ]] && [[ "$(basename "$dir")" != "lib" ]]; then
        name="$(basename "$dir")"
        modules+=("$name")
        # Read description from first comment line of install.sh, or use dir name
        module_names+=("$name")
    fi
done

if [[ ${#modules[@]} -eq 0 ]]; then
    fail "No modules found"
    exit 1
fi

# ─── Module descriptions ────────────────────────────

describe() {
    case "$1" in
        caveman)    echo "caveman Claude Code plugin — ~75% fewer output tokens" ;;
        ghostty)    echo "ghostty terminal, GitHub Light theme, symlinked config" ;;
        karabiner)  echo "Karabiner-Elements + sagarsrc/karabiner_scripts config" ;;
        statusline) echo "status bar + turn counter for Claude Code" ;;
        tmux)       echo "tmux config, TPM, vim nav, clipboard" ;;
        nvim)       echo "neovim config with Lazy, treesitter, fzf" ;;
        *)          echo "$1" ;;
    esac
}

# ─── Usage ──────────────────────────────────────────

if [[ $# -gt 0 ]]; then
    # Direct install: ./install.sh tmux nvim
    for mod in "$@"; do
        if [[ -f "$ROOT_DIR/$mod/install.sh" ]]; then
            bash "$ROOT_DIR/$mod/install.sh"
        else
            fail "Unknown module: $mod"
            echo -e "  ${D}Available: ${modules[*]}${R}"
            exit 1
        fi
    done
    exit 0
fi

# ─── Interactive picker ─────────────────────────────

echo -e "  ${B}Available modules:${R}"
echo ""

for i in "${!modules[@]}"; do
    num=$((i + 1))
    mod="${modules[$i]}"
    desc="$(describe "$mod")"
    echo -e "    ${CYN}${B}$num${R}) ${B}$mod${R}  ${D}— $desc${R}"
done

echo ""
echo -e "    ${CYN}${B}a${R}) ${B}all${R}  ${D}— install everything${R}"
echo ""

read -rp "  Select modules (e.g. 1 3, or a for all): " selection

if [[ -z "$selection" ]]; then
    echo -e "  ${D}Nothing selected${R}"
    exit 0
fi

selected=()

if [[ "$selection" == "a" ]] || [[ "$selection" == "all" ]]; then
    selected=("${modules[@]}")
else
    for token in $selection; do
        # Support both numbers and names
        if [[ "$token" =~ ^[0-9]+$ ]]; then
            idx=$((token - 1))
            if [[ $idx -ge 0 ]] && [[ $idx -lt ${#modules[@]} ]]; then
                selected+=("${modules[$idx]}")
            else
                warn "Invalid number: $token"
            fi
        elif [[ -f "$ROOT_DIR/$token/install.sh" ]]; then
            selected+=("$token")
        else
            warn "Unknown module: $token"
        fi
    done
fi

if [[ ${#selected[@]} -eq 0 ]]; then
    echo -e "  ${D}Nothing selected${R}"
    exit 0
fi

echo ""
echo -e "  ${D}Installing: ${selected[*]}${R}"

for mod in "${selected[@]}"; do
    bash "$ROOT_DIR/$mod/install.sh"
done

echo ""
echo -e "  ${GRN}${B}Done!${R}"
echo ""
