# Tmux Setup

Minimal, vim-style tmux config. Seamless `Ctrl-h/j/k/l` navigation, system clipboard, session persistence.

## Install

```bash
# From the repo root
./install.sh tmux

# Or standalone
./tmux/install.sh
```

This handles everything: installs tmux if needed, sets up TPM, symlinks the config, installs plugins, and patches VS Code/Cursor.

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

See [nvim/](../nvim/) for the neovim config and cheat sheet.

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
