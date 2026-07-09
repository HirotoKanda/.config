#!/usr/bin/env bash
# audit.sh — scan repos for Claude Code context-hygiene signals.
#
# Usage:
#   audit.sh                 # discover git repos under $HOME (skips dependency/cache clones)
#   audit.sh PATH [PATH...]  # audit specific repo paths
#
# Emits one block per repo with the file-auditable signals behind the 7-point
# checklist: CLAUDE.md size (the big one — it loads every turn), AGENTS.md,
# persisted plans, .claude/ skills+agents+settings, and project-level MCP config.
# It does NOT judge behavioral points (multi-task prompts, over-delegating design,
# all-day sessions) — those aren't visible on disk.

set -u

# Heaviness thresholds for CLAUDE.md (bytes). Tunable; these are heuristics, not
# laws — a dense reference file is the smell, regardless of the exact number.
LEAN_MAX=6000        # <= this: lean
HEAVY_MIN=12000      # >= this: heavy / likely bloated (extract reference to on-demand docs)

flag_for_bytes() {
  local b=$1
  if   [ "$b" -ge "$HEAVY_MIN" ]; then echo "HEAVY"
  elif [ "$b" -gt "$LEAN_MAX" ];  then echo "BORDERLINE"
  else echo "LEAN"; fi
}

audit_repo() {
  local r=$1
  printf '=== %s\n' "$r"
  local found_any=0

  # --- #1 CLAUDE.md (root + nested), the per-turn tax ---
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    found_any=1
    local lines bytes kb flag
    lines=$(wc -l < "$f" | tr -d ' ')
    bytes=$(wc -c < "$f" | tr -d ' ')
    kb=$(awk "BEGIN{printf \"%.1f\", $bytes/1024}")
    flag=$(flag_for_bytes "$bytes")
    printf '  [#1] CLAUDE.md %-28s %4s lines  %6s KB  %s\n' "${f#"$r"/}" "$lines" "$kb" "$flag"
  done < <(find "$r" -maxdepth 3 -name CLAUDE.md \
             -not -path '*/node_modules/*' -not -path '*/.worktrees/*' 2>/dev/null | sort)

  # AGENTS.md (Codex/other harness equivalent — also loads every turn)
  if [ -f "$r/AGENTS.md" ]; then
    found_any=1
    local al ab
    al=$(wc -l < "$r/AGENTS.md" | tr -d ' '); ab=$(wc -c < "$r/AGENTS.md" | tr -d ' ')
    printf '  [#1] AGENTS.md  %-28s %4s lines  %6s KB  %s\n' "" "$al" \
      "$(awk "BEGIN{printf \"%.1f\", $ab/1024}")" "$(flag_for_bytes "$ab")"
  fi

  # --- #3 persisted plans (good: state in files, not the chat) ---
  # Real repos persist plans many ways, not just a file literally named PLAN.md.
  # Catch three conventions: a plans/ directory, PLAN.md/plan.md, and
  # *_plan.md / *-plan.md / plan-*.md names (e.g. nucleon_scattering_plan.md).
  # Patterns stay anchored on the word "plan" so we don't match "explanation.md".
  local plan_hits=""
  if [ -d "$r/plans" ]; then
    local pc
    pc=$(find "$r/plans" -maxdepth 1 -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
    plan_hits="plans/ ($pc md)"
  fi
  while IFS= read -r p; do
    [ -z "$p" ] && continue
    plan_hits="${plan_hits:+$plan_hits, }${p#"$r"/}"
  done < <(find "$r" -maxdepth 2 \
             \( -iname 'plan.md' -o -iname '*_plan.md' -o -iname '*-plan.md' \
                -o -iname 'plan_*.md' -o -iname 'plan-*.md' \) \
             -not -path '*/node_modules/*' -not -path '*/plans/*' 2>/dev/null | sort)
  if [ -n "$plan_hits" ]; then
    found_any=1
    printf '  [#3] plans: %s\n' "$plan_hits"
  fi

  # --- #1/#2/#6 .claude/ skills + agents + settings ---
  if [ -d "$r/.claude" ]; then
    found_any=1
    local nsk=0 nag=0 set=no
    [ -d "$r/.claude/skills" ] && nsk=$(find "$r/.claude/skills" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
    [ -d "$r/.claude/agents" ] && nag=$(find "$r/.claude/agents" -maxdepth 1 -mindepth 1 \( -name '*.md' \) 2>/dev/null | wc -l | tr -d ' ')
    { [ -f "$r/.claude/settings.json" ] || [ -f "$r/.claude/settings.local.json" ]; } && set=yes
    printf '  [#2/#6] .claude/: skills=%s  agents=%s  settings=%s\n' "$nsk" "$nag" "$set"
  fi

  # --- #4 project-level MCP servers ---
  if [ -f "$r/.mcp.json" ]; then
    found_any=1
    local names
    names=$(grep -oE '"[a-zA-Z0-9_-]+"[[:space:]]*:[[:space:]]*\{' "$r/.mcp.json" 2>/dev/null \
              | sed -E 's/"([a-zA-Z0-9_-]+)".*/\1/' | grep -v '^mcpServers$' | paste -sd, - 2>/dev/null)
    printf '  [#4] .mcp.json servers: %s\n' "${names:-<unparsed>}"
  fi

  [ "$found_any" -eq 0 ] && printf '  (no Claude Code config)\n'
  printf '\n'
}

# ---- discover repos ----
if [ "$#" -gt 0 ]; then
  for r in "$@"; do audit_repo "$r"; done
else
  # Skip dependency/cache clones — they aren't the user's to audit.
  find "$HOME" -type d -name .git -maxdepth 7 \
    -not -path '*/node_modules/*' \
    -not -path '*/.Trash/*' \
    -not -path '*/.claude/plugins/*' \
    -not -path '*/.codex/*' \
    -not -path '*/.local/share/*' \
    -not -path '*/Library/Caches/*' \
    -not -path '*/.cache/*' \
    -not -path '*/vendor/*' \
    -not -path '*/.venv/*' \
    -not -path '*/site-packages/*' \
    2>/dev/null | sed 's|/\.git$||' | sort | while IFS= read -r r; do
      audit_repo "$r"
    done
fi
