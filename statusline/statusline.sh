#!/usr/bin/env bash

input=$(cat)

eval "$(echo "$input" | jq -r '
  @sh "cwd=\(.workspace.current_dir // .cwd)",
  @sh "model=\(.model.display_name // "Claude")",
  @sh "used_pct=\(.context_window.used_percentage // 0)",
  @sh "total_input=\(.context_window.total_input_tokens // 0)",
  @sh "total_output=\(.context_window.total_output_tokens // 0)",
  @sh "ctx_window_size=\(.context_window.context_window_size // 0)",
  @sh "session_id=\(.session_id // "")",
  @sh "session_name=\(.session_name // "")",
  @sh "five_h_pct=\(.rate_limits.five_hour.used_percentage // "")",
  @sh "five_h_reset=\(.rate_limits.five_hour.resets_at // "")",
  @sh "seven_d_pct=\(.rate_limits.seven_day.used_percentage // "")",
  @sh "seven_d_reset=\(.rate_limits.seven_day.resets_at // "")"
')"

R='\033[0m'; B='\033[1m'; D='\033[2m'
BLUE='\033[38;5;75m'
GREEN='\033[38;5;114m'
YELLOW='\033[38;5;222m'
RED='\033[38;5;203m'
CYAN='\033[38;5;117m'
MAGENTA='\033[38;5;183m'
GRAY='\033[38;5;242m'

# ── Git ───────────────────────────────────────────────────────────────────────
git_root="" git_branch=""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    git_root=$(basename "$(git -C "$cwd" --no-optional-locks rev-parse --show-toplevel 2>/dev/null)")
    git_branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
    [[ -z "$git_branch" ]] && git_branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
    if ! git -C "$cwd" --no-optional-locks diff-index --quiet HEAD -- 2>/dev/null; then
        git_branch="${git_branch}*"
    fi
fi
dir="${git_root:-$(basename "$cwd")}"

# ── Model short ──────────────────────────────────────────────────────────────
short_model=$(echo "$model" | sed -E 's/Claude //; s/ \(.*//; s/^(.)/\L\1/')
if [[ $ctx_window_size -ge 1000000 ]]; then
    short_model+="[$(( ctx_window_size / 1000000 ))M]"
elif [[ $ctx_window_size -ge 1000 ]]; then
    short_model+="[$(( ctx_window_size / 1000 ))K]"
fi

# ── Context % ────────────────────────────────────────────────────────────────
used_int=${used_pct%.*}; used_int=${used_int:-0}
if   [[ $used_int -lt 50 ]]; then cc="$GREEN"
elif [[ $used_int -lt 75 ]]; then cc="$YELLOW"
else cc="$RED"; fi

# ── Turn ─────────────────────────────────────────────────────────────────────
turn="0"
if [[ -n "$session_id" ]]; then
    tf="/tmp/claude-turns-${session_id}.txt"
    [[ -f "$tf" ]] && turn=$(cat "$tf" 2>/dev/null)
fi
[[ -z "$turn" ]] && turn="0"

# ── Countdown ────────────────────────────────────────────────────────────────
fmt_cd() {
    local diff=$(( $1 - $(date +%s) ))
    if [[ $diff -le 0 ]]; then echo "now"
    elif [[ $diff -ge 86400 ]]; then printf "%dd %dh" $(( diff/86400 )) $(( (diff%86400)/3600 ))
    elif [[ $diff -ge 3600 ]]; then printf "%dh %dm" $(( diff/3600 )) $(( (diff%3600)/60 ))
    else printf "%dm" $(( diff/60 )); fi
}

lc() {
    if   [[ $1 -lt 50 ]]; then echo "$GREEN"
    elif [[ $1 -lt 80 ]]; then echo "$YELLOW"
    else echo "$RED"; fi
}

# ── Rate limits ──────────────────────────────────────────────────────────────
session_bit=""
if [[ -n "$five_h_pct" ]]; then
    sv=$(printf "%.0f" "$five_h_pct"); sc=$(lc "$sv")
    sr=""; [[ -n "$five_h_reset" ]] && sr=" $(fmt_cd "$five_h_reset")"
    session_bit="${sc}5h: ${sv}%${sr}${R}"
fi

weekly_bit=""
if [[ -n "$seven_d_pct" ]]; then
    wv=$(printf "%.0f" "$seven_d_pct"); wc=$(lc "$wv")
    wr=""; [[ -n "$seven_d_reset" ]] && wr=" $(fmt_cd "$seven_d_reset")"
    weekly_bit="${wc}7d: ${wv}%${wr}${R}"
fi

# ── Right side ───────────────────────────────────────────────────────────────
right=""
[[ -n "$session_name" ]] && right="${GRAY}[s] ${session_name}${R}"

# ── Effort level (read from settings) ────────────────────────────────────────
effort=$(jq -r '.effortLevel // "medium"' ~/.claude/settings.json 2>/dev/null)
case "$effort" in
    low)  effort_display="${GREEN}o low${R}" ;;
    high) effort_display="${RED}* high${R}" ;;
    *)    effort_display="${YELLOW}~ med${R}" ;;
esac

# ── Line 1: identity + turn + effort ────────────────────────────────────────
line1="${BLUE}${B}${dir}${R}${GRAY}/${R}${GREEN}${git_branch}${R}"
line1+="  ${MAGENTA}${short_model}${R}"
line1+="  ${GRAY}ctx${R} ${cc}${B}${used_int}%${R}"
line1+="  ${GRAY}T#${R}${CYAN}${B}${turn}${R}"
line1+="  ${effort_display}"

# ── Line 2: session left, weekly right ──────────────────────────────────────
line2_left=""
[[ -n "$session_bit" ]] && line2_left="${GRAY}session${R} ${session_bit}"

line2_right=""
[[ -n "$weekly_bit" ]] && line2_right="${GRAY}weekly${R} ${weekly_bit}"

# ── Output ───────────────────────────────────────────────────────────────────
if [[ -n "$right" ]]; then
    printf "%b\t%b\n%b\t%b" "$line1" "$right" "$line2_left" "$line2_right"
else
    printf "%b\n%b\t%b" "$line1" "$line2_left" "$line2_right"
fi
