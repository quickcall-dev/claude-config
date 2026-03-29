# claude-config

Status line and hooks for Claude Code.

<img src="demo.gif" width="600" />

## Install

```bash
git clone https://github.com/quickcall-dev/claude-config.git
cd claude-config
./install.sh
```

## What you get

```
my-project • main* • Opus 4.6 • [█░░░░░░░] 5% • T12
```

Directory, git branch, model, context usage, and turn count. Turns change color as sessions get longer: cyan (T1-19), yellow (T20-29), red (T30+).

## Requirements

macOS or Linux, [jq](https://jqlang.github.io/jq/), [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
