# all-configs Textual TUI Installer — Design Spec

## Goal

Replace the current bash-number picker in `claude-config` with a clean, keyboard-driven Textual TUI. Rename the repo to `all-configs`. Keep existing per-module `install.sh` scripts unchanged.

## Architecture

- **Bootstrapper (`install.sh`)**: detects `uvx`, `uv`, or `python3 + venv`; creates a temporary venv; installs Textual; runs the TUI.
- **TUI app (`all_configs/tui.py`)**: discovers modules, renders a checkbox list with one-line descriptions, shows an install log, and shells out to each selected module's `install.sh`.
- **Module manifest (`module.toml`)**: each module directory contains a small manifest with name, description, and supported platforms.
- **Repo metadata**: README and git remote updated from `claude-config` to `all-configs`.

## Modules (existing)

| Module | Description | Platforms |
|--------|-------------|-----------|
| `caveman` | caveman Claude Code plugin — ~75% fewer output tokens | mac, linux |
| `claude` | Claude Code CLI via claude.ai/install.sh | mac, linux |
| `ghostty` | Ghostty terminal config + themes | mac, linux |
| `karabiner` | Karabiner-Elements key remaps | mac |
| `node` | Node.js, npm, npx via system package manager | mac, linux |
| `nvim` | Neovim config with Lazy, treesitter, fzf | mac, linux |
| `skills` | QuickCall Claude Code skills | mac, linux |
| `statusline` | Status bar + turn counter for Claude Code | mac, linux |
| `tmux` | tmux config, TPM, vim nav, clipboard | mac, linux |

## Module manifest format

```toml
name = "tmux"
description = "tmux config, TPM, vim nav, clipboard"
platforms = ["mac", "linux"]
```

## Bootstrapper behavior

1. Check for `uvx`. If found, run `uvx --python python3.11 --from textual python -m all_configs.tui`.
2. Else check for `uv`. If found, create temp venv with `uv venv` and install Textual.
3. Else check for `python3`. Create `.tmp-install-venv` with `python3 -m venv` and `pip install textual`.
4. Launch TUI.
5. On exit, remove temp venv (optional; can be left for caching).

## TUI behavior

- Header shows "all-configs installer".
- Scrollable list of modules for the current platform.
- Each row: checkbox + module name + description.
- Footer help: `Space` toggle, `a` select all, `n` none, `Enter` install, `q` quit.
- Install runs sequentially in a background thread; output appears in a log pane.
- On error, mark module failed and continue (or stop, configurable).

## Out of scope

- Rewriting module `install.sh` scripts.
- Adding `.pi` configs.
- Real-time install progress bars per module.
- Dependency ordering between modules.

## Repository changes

- Rename repo from `claude-config` to `all-configs`.
- Update `README.md` title, clone URL, and references.
- Add `all_configs/` Python package.
- Add `module.toml` to each module directory.
- Update root `install.sh` to bootstrap Textual TUI.
