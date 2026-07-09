#!/bin/bash
# Claude Code statusline: model · git branch · context usage · effort · 5h/weekly usage
input=$(cat)

# Single jq pass; absent fields become "-"
IFS=$'\t' read -r model dir ctx effort five_h week <<EOF
$(printf '%s' "$input" | jq -r '
  [ (.model.display_name // .model.id // "?"),
    (.workspace.current_dir // .cwd // "."),
    (.context_window.used_percentage // "-" | tostring),
    (.effort.level // "-"),
    (.rate_limits.five_hour.used_percentage // "-" | tostring),
    (.rate_limits.seven_day.used_percentage // "-" | tostring)
  ] | @tsv')
EOF

branch=$(git -C "$dir" branch --show-current 2>/dev/null)
[ -z "$branch" ] && branch="no-git"

# ANSI colors (bright variants for dark themes)
R=$'\033[0m'      # reset
DIM=$'\033[2m'
MAGENTA=$'\033[95m'
GREEN=$'\033[92m'
YELLOW=$'\033[93m'
RED=$'\033[91m'
CYAN=$'\033[96m'

# Percentage colored by threshold: <50 green, 50-79 yellow, >=80 red
pct() {
  case "$1" in
    -) printf '%s-%s' "$DIM" "$R" ;;
    *) local n=${1%%.*} c=$GREEN
       [ "$n" -ge 50 ] && c=$YELLOW
       [ "$n" -ge 80 ] && c=$RED
       printf '%s%s%%%s' "$c" "$n" "$R" ;;
  esac
}

sep="${DIM} · ${R}"
printf '%s%s%s%s⎇ %s%s%sctx %s%seffort %s%s%s%s5h %s%swk %s' \
  "$MAGENTA" "$model" "$R" "$sep" \
  "$GREEN" "$branch$R" "$sep" \
  "$(pct "$ctx")" "$sep" \
  "$CYAN" "$effort" "$R" "$sep" \
  "$(pct "$five_h")" "$sep" \
  "$(pct "$week")"
