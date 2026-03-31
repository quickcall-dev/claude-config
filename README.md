# claude-config

Modular configs for Claude Code, tmux, neovim, and more.

<img src="demo.gif" width="600" />

## Install

```bash
git clone https://github.com/quickcall-dev/claude-config.git
cd claude-config

# Interactive — pick what you want
./install.sh

# Or install specific modules
./install.sh statusline tmux nvim
```

Each module can also be installed standalone:

```bash
./statusline/install.sh
./tmux/install.sh
./nvim/install.sh
```

## Modules

| Module | What it does |
|--------|-------------|
| **statusline** | Two-line status bar with rate limits, effort, and turn counter |
| **tmux** | Tmux config, TPM, vim nav, system clipboard, editor integration |
| **nvim** | Neovim config with Lazy, treesitter, telescope, file explorer |

## Statusline preview

```
my-project/main  opus[1M]  ctx 5%  T#3  ○ low
session ⏱ 2% 4h 50m                                          weekly ⏳ 60% 2d 15h
```

Two-line layout:
- **Line 1**: repo/branch, model, context %, turn count, effort level
- **Line 2**: session rate limit (5h) with reset countdown, weekly limit (7d) on the right

Colors shift green → yellow → red as limits approach. Effort reads from your settings (`/effort` to change).

## Requirements

macOS or Linux, [jq](https://jqlang.github.io/jq/) (for statusline), [Claude Code](https://docs.anthropic.com/en/docs/claude-code)

## Adding a new module

Create a directory with an `install.sh` inside it. The root installer auto-discovers it.
