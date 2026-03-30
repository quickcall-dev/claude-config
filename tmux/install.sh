#!/usr/bin/env bash
set -e

# Colors
TEAL='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

ok() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; exit 1; }
step() { echo -e "\n${TEAL}→${NC} $1"; }

echo ""
echo "  ship it."
echo -e "  ${TEAL}quick${NC}"
echo ""

# ─── Detect OS ───

OS="$(uname -s)"
case "$OS" in
    Darwin) PLATFORM="mac" ;;
    Linux)  PLATFORM="linux" ;;
    *)      fail "Unsupported OS: $OS" ;;
esac

# ─── Package install helper ───

pkg_install() {
    local pkg="$1"
    if [[ "$PLATFORM" == "mac" ]]; then
        if ! command -v brew &>/dev/null; then
            fail "Homebrew not found. Install it: https://brew.sh"
        fi
        brew install "$pkg"
    else
        if command -v apt-get &>/dev/null; then
            sudo apt-get update -qq && sudo apt-get install -y -qq "$pkg"
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y "$pkg"
        elif command -v pacman &>/dev/null; then
            sudo pacman -S --noconfirm "$pkg"
        else
            fail "No supported package manager found (apt/dnf/pacman)"
        fi
    fi
}

# ─── Check / install dependencies ───

step "Checking dependencies"

for pkg in tmux nvim fzf; do
    if command -v "$pkg" &>/dev/null; then
        ok "$pkg $($pkg --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+[^ ]*' | head -1)"
    else
        warn "$pkg not found — installing"
        case "$pkg" in
            nvim)
                if [[ "$PLATFORM" == "mac" ]]; then
                    pkg_install neovim
                else
                    # apt has outdated nvim — use snap or appimage
                    if command -v snap &>/dev/null; then
                        sudo snap install nvim --classic
                    elif command -v apt-get &>/dev/null; then
                        # Try PPA for newer version
                        sudo apt-get install -y -qq software-properties-common
                        sudo add-apt-repository -y ppa:neovim-ppa/unstable
                        sudo apt-get update -qq
                        sudo apt-get install -y -qq neovim
                    else
                        pkg_install neovim
                    fi
                fi
                ;;
            *)  pkg_install "$pkg" ;;
        esac
        ok "$pkg installed"
    fi
done

if ! command -v tree-sitter &>/dev/null; then
    if command -v npm &>/dev/null; then
        warn "tree-sitter-cli not found — installing"
        npm install -g tree-sitter-cli
        ok "tree-sitter-cli installed"
    else
        warn "tree-sitter-cli not found (npm not available — skipping)"
    fi
else
    ok "tree-sitter-cli"
fi

# ─── Install TPM ───

step "Setting up tmux"

TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ -d "$TPM_DIR" ]]; then
    ok "TPM already installed"
else
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    ok "TPM installed"
fi

# ─── Tmux config ───

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$HOME/.tmux.conf"

if [[ -f "$DEST" ]] && [[ ! -L "$DEST" ]]; then
    BACKUP="$DEST.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$DEST" "$BACKUP"
    ok "backed up existing config → $BACKUP"
elif [[ -L "$DEST" ]]; then
    rm "$DEST"
fi

ln -sf "$SCRIPT_DIR/.tmux.conf" "$DEST"
ok "tmux config → $DEST (symlinked)"

# macOS: fix provenance xattr that blocks TPM
if [[ "$PLATFORM" == "mac" ]]; then
    xattr -r -d com.apple.provenance "$TPM_DIR" 2>/dev/null || true
    xattr -r -d com.apple.quarantine "$TPM_DIR" 2>/dev/null || true
fi

# ─── Neovim config ───

step "Setting up neovim"

NVIM_DIR="$HOME/.config/nvim"
mkdir -p "$NVIM_DIR"

if [[ -f "$NVIM_DIR/init.lua" ]]; then
    BACKUP="$NVIM_DIR/init.lua.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$NVIM_DIR/init.lua" "$BACKUP"
    ok "backed up existing nvim config → $BACKUP"
fi

if [[ -f "$SCRIPT_DIR/../nvim/init.lua" ]]; then
    cp "$SCRIPT_DIR/../nvim/init.lua" "$NVIM_DIR/init.lua"
else
    cp "$SCRIPT_DIR/init.lua" "$NVIM_DIR/init.lua" 2>/dev/null || warn "nvim init.lua not found in repo — skipping"
fi
ok "nvim config → $NVIM_DIR/init.lua"

# ─── Install tmux plugins ───

step "Installing tmux plugins"

if [[ -n "${TMUX:-}" ]]; then
    tmux source-file "$DEST" 2>/dev/null
    "$TPM_DIR/bin/install_plugins" 2>/dev/null && ok "tmux plugins installed" || warn "run prefix I inside tmux to install plugins"
else
    tmux start-server
    tmux new-session -d -s _install
    "$TPM_DIR/bin/install_plugins" 2>/dev/null && ok "tmux plugins installed" || warn "run prefix I inside tmux to install plugins"
    tmux kill-session -t _install 2>/dev/null
fi

# ─── VS Code / Cursor fix ───

step "Checking VS Code / Cursor"

fix_editor_settings() {
    local settings_file="$1"
    local editor_name="$2"
    local profile_key="$3"

    if [[ ! -f "$settings_file" ]]; then
        return
    fi

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

# ─── Done ───

step "Installing nvim plugins (first launch)"
echo "  This may take a moment..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null && ok "nvim plugins installed" || warn "open nvim manually — plugins will auto-install"

echo ""
echo -e "${GREEN}Done!${NC} Open a new terminal and run ${TEAL}tmux${NC}"
echo ""
echo "  Prefix key:  Ctrl+b (default, change in .tmux.conf)"
echo "  Reload:      prefix r"
echo "  Splits:      prefix |  and  prefix -"
echo "  Navigation:  Ctrl-h/j/k/l (works across nvim + tmux)"
echo "  Find files:  Space ff (in nvim)"
echo ""
