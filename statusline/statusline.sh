#!/usr/bin/env bash

# Read JSON input from stdin
input=$(cat)

# Extract data from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
session_id=$(echo "$input" | jq -r '.session_id // ""')

# Directory - just basename
dir_base=$(basename "$cwd")

# Turn count from counter file
turn=""
if [[ -n "$session_id" ]]; then
    turn_file="/tmp/claude-turns-${session_id}.txt"
    if [[ -f "$turn_file" ]]; then
        turn=$(cat "$turn_file" 2>/dev/null)
    fi
fi
[[ -z "$turn" ]] && turn="0"

# Git status - compact
git_info=""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
    if [[ -z "$branch" ]]; then
        branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
    fi

    status=""
    if ! git -C "$cwd" --no-optional-locks diff-index --quiet HEAD -- 2>/dev/null; then
        status="*"
    fi

    git_info="$(printf '\033[32m')$branch$status$(printf '\033[0m')"
fi

# Context usage with progress bar
used_int=${used_pct%.*}

filled=$(( (used_int + 12) / 13 ))
[[ $filled -gt 8 ]] && filled=8

bar=""
for ((i=0; i<filled; i++)); do bar="${bar}█"; done
for ((i=filled; i<8; i++)); do bar="${bar}░"; done

if [[ $used_int -lt 50 ]]; then
    bar_color='\033[32m'
elif [[ $used_int -lt 75 ]]; then
    bar_color='\033[33m'
else
    bar_color='\033[31m'
fi

ctx_display="$(printf "$bar_color")[${bar}]$(printf '\033[0m') $(printf '\033[90m')${used_int}%$(printf '\033[0m')"

# Turn display with color warnings
if [[ $turn -ge 30 ]]; then
    turn_color='\033[31m'  # Red - danger zone
elif [[ $turn -ge 20 ]]; then
    turn_color='\033[33m'  # Yellow - getting long
else
    turn_color='\033[36m'  # Cyan - normal
fi
turn_display="$(printf "$turn_color")T${turn}$(printf '\033[0m')"

# Separator
sep="$(printf '\033[90m')•$(printf '\033[0m')"

# Build status line
# Format: dir • branch • model • [████░░░░] 50% • T12
if [[ -n "$git_info" ]]; then
    printf "$(printf '\033[34m')%s$(printf '\033[0m') %s %s %s $(printf '\033[35m')%s$(printf '\033[0m') %s %s %s %s" \
        "$dir_base" "$sep" \
        "$git_info" "$sep" \
        "$model" "$sep" \
        "$ctx_display" "$sep" \
        "$turn_display"
else
    printf "$(printf '\033[34m')%s$(printf '\033[0m') %s $(printf '\033[35m')%s$(printf '\033[0m') %s %s %s %s" \
        "$dir_base" "$sep" \
        "$model" "$sep" \
        "$ctx_display" "$sep" \
        "$turn_display"
fi
