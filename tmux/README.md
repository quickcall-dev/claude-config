# Tmux + Neovim Setup

Minimal, vim-style tmux and neovim config. Catppuccin latte theme across both. Seamless `Ctrl-h/j/k/l` navigation between tmux panes and nvim splits.

## Prerequisites

- macOS
- [Homebrew](https://brew.sh)

## Install

### 1. Install dependencies

```bash
brew install tmux neovim fzf
npm install -g tree-sitter-cli
```

### 2. Install TPM (tmux plugin manager)

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### 3. Set up tmux config

```bash
git clone https://github.com/quickcall-dev/claude-config.git
cd claude-config

# Symlink tmux config
ln -sf "$(pwd)/tmux/.tmux.conf" ~/.tmux.conf
```

### 4. Set up neovim config

```bash
# Copy nvim config (or symlink it)
mkdir -p ~/.config/nvim
cp nvim/init.lua ~/.config/nvim/init.lua
```

### 5. Install plugins

```bash
# Tmux — start tmux, then press:
# Ctrl+b I  (capital I — installs all plugins)
tmux source ~/.tmux.conf

# Neovim — just open it, lazy.nvim auto-installs everything
nvim
```

## What's included

### Tmux plugins

| Plugin | What it does |
|--------|-------------|
| [tpm](https://github.com/tmux-plugins/tpm) | Plugin manager |
| [tmux-yank](https://github.com/tmux-plugins/tmux-yank) | System clipboard integration |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) | Save/restore sessions |
| [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) | Auto-save sessions every 15min |
| [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | Seamless Ctrl-h/j/k/l between tmux and nvim |
| [tmux-fzf](https://github.com/sainnhe/tmux-fzf) | Fuzzy finder for sessions/windows/panes |
| [catppuccin/tmux](https://github.com/catppuccin/tmux) | Catppuccin latte theme |

### Neovim plugins

| Plugin | What it does |
|--------|-------------|
| [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | Seamless Ctrl-h/j/k/l between nvim and tmux |
| [catppuccin/nvim](https://github.com/catppuccin/nvim) | Catppuccin latte theme |
| [lualine](https://github.com/nvim-lualine/lualine.nvim) | Statusline |
| [telescope](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting |
| [nvim-tree](https://github.com/nvim-tree/nvim-tree.lua) | File explorer sidebar |
| [gitsigns](https://github.com/lewis6991/gitsigns.nvim) | Git diff in gutter |
| [Comment.nvim](https://github.com/numToStr/Comment.nvim) | Toggle comments |
| [nvim-autopairs](https://github.com/windwp/nvim-autopairs) | Auto close brackets |

## Tmux cheat sheet

The **prefix** is `Ctrl+b` (configurable in `.tmux.conf`). You press the prefix first, release, then press the next key. It's like a namespace so tmux keys don't collide with your normal typing. For example, `prefix |` means: hold Ctrl, press Space, release both, then press `|`.

In the tables below, `prefix` = whatever you set in `.tmux.conf` (default: `Ctrl+b`).

### Splits & windows

| Key | Action |
|-----|--------|
| `prefix \|` | Split side by side |
| `prefix -` | Split top/bottom |
| `prefix c` | New window (same directory) |
| `prefix n` | Next window |
| `prefix p` | Previous window |
| `prefix Tab` | Last window |
| `prefix 1-9` | Jump to window by number |

### Navigation

| Key | Action |
|-----|--------|
| `Ctrl-h/j/k/l` | Move between tmux panes AND nvim splits (no prefix needed) |
| `prefix h/j/k/l` | Move to pane (left/down/up/right) |
| `prefix H/J/K/L` | Resize pane (5 cells at a time, repeatable) |
| `prefix Ctrl-j/k` | Swap pane down/up |

### Copy mode

| Key | Action |
|-----|--------|
| `prefix Escape` | Enter copy mode |
| `v` | Start selection |
| `V` | Select line |
| `Ctrl+v` | Rectangle/block select |
| `y` | Yank (copy to clipboard) |
| `Ctrl+u` | Half page up |
| `Ctrl+d` | Half page down |
| `10 Enter k` | Move up 10 lines (number, Enter, then motion) |
| `/` | Search forward |
| `?` | Search backward |

### Sessions & misc

| Key | Action |
|-----|--------|
| `prefix S` | New session |
| `prefix s` | List sessions |
| `prefix F` | Fuzzy finder (sessions/windows/panes) |
| `prefix q` | Kill pane (confirms) |
| `prefix Q` | Kill window (confirms) |
| `prefix r` | Reload config |
| `prefix Ctrl+s` | Save session (resurrect) |
| `prefix Ctrl+r` | Restore session (resurrect) |

## Neovim cheat sheet

Leader key is `Space` — same idea as tmux's prefix but for nvim. Press `Space`, release, then press the next key. For example, `Space ff` means: press Space, then press `f` twice.

### Navigation

| Key | Action |
|-----|--------|
| `Ctrl-h/j/k/l` | Move between nvim splits AND tmux panes |
| `Ctrl+d` | Half page down (centered) |
| `Ctrl+u` | Half page up (centered) |

### Files & search

| Key | Action |
|-----|--------|
| `Space ff` | Find files (telescope) |
| `Space fg` | Live grep (telescope) |
| `Space fb` | Switch buffer (telescope) |
| `Space e` | Toggle file explorer |

### Editing

| Key | Action |
|-----|--------|
| `jk` | Escape to normal mode |
| `gcc` | Toggle comment (line) |
| `gc` | Toggle comment (visual selection) |
| `J/K` | Move selected lines down/up (visual mode) |
| `Space sv` | Vertical split |
| `Space sh` | Horizontal split |

### Basics (if you're new to vim)

| Key | Mode | Action |
|-----|------|--------|
| `i` | Normal | Enter insert mode (start typing) |
| `Esc` or `jk` | Insert | Back to normal mode |
| `h/j/k/l` | Normal | Move left/down/up/right |
| `w/b` | Normal | Next/previous word |
| `dd` | Normal | Delete line |
| `yy` | Normal | Copy line |
| `p` | Normal | Paste |
| `u` | Normal | Undo |
| `Ctrl+r` | Normal | Redo |
| `:w` | Command | Save |
| `:q` | Command | Quit |
| `:wq` | Command | Save and quit |

## Switching theme

Both tmux and nvim use catppuccin latte (light). To switch to dark:

**tmux** — in `.tmux.conf`, change `latte` to `mocha`:
```
set -g @catppuccin_flavor 'mocha'
```

**nvim** — in `init.lua`, change `latte` to `mocha`:
```lua
require("catppuccin").setup({ flavour = "mocha" })
```

Available flavours: `latte` (light), `frappe`, `macchiato`, `mocha` (darkest).

## Tmux in VS Code / Cursor

If tmux renders with broken/garbled text in VS Code or Cursor's integrated terminal, add these to your editor's `settings.json` (`Cmd+Shift+P` → "Open User Settings JSON"):

```json
{
  "terminal.integrated.gpuAcceleration": "off",
  "terminal.integrated.profiles.osx": {
    "tmux": {
      "path": "tmux",
      "args": ["new-session", "-A", "-s", "main"],
      "icon": "terminal-tmux"
    }
  },
  "terminal.integrated.defaultProfile.osx": "tmux"
}
```

This disables GPU rendering (the #1 cause of corruption) and auto-launches tmux when you open a terminal.
