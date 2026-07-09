---
name: claude-code-context-audit
description: >-
  Audit a repo (or every repo on the machine) for Claude Code context hygiene and
  offer to fix what's found. Use this whenever the user wants to check, audit, or
  review their Claude Code setup, asks "is my CLAUDE.md too big / bloated", worries
  about token bloat or context being wasted every turn, wants to know if they're
  "using Claude Code right", asks about MCP / skills / sub-agent hygiene across
  their projects, or references the "7 mistakes / you're using Claude Code wrong"
  article. Trigger it even when the user just gestures at "clean up my Claude setup"
  without naming a specific file — finding what to clean up is this skill's job.
---

# Claude Code context audit

Audit one or more repos against seven context-hygiene practices, report a scorecard,
then offer concrete fixes. The core idea behind all seven: **context is the scarce
resource.** Anything loaded into every turn — an oversized `CLAUDE.md`, a wall of MCP
tool definitions — is a tax paid on every single message, and it crowds out attention
from the actual task. Good setup keeps the per-turn footprint small and pushes
reference material to places that load only when needed (Agent Skills, on-demand docs).

## The seven points

Five are visible on disk (the scan checks them). Three are behavioral — they live in
*how* the user drives the tool, not in any file — so the audit names them but can't
grade them. Be honest about that split; don't pretend a file check proves a habit.

**File-auditable:**
1. **Oversized `CLAUDE.md`.** It reloads every turn. Comprehensive docs (full directory
   maps, naming conventions, history, exhaustive parameter tables, I/O trivia) belong in
   on-demand Agent Skills or `docs/` files, not here. Keep the root file to overview +
   build/run + the load-bearing contracts that actually cause errors when forgotten.
4. **All MCP servers always on.** Every connected server's tool definitions consume
   tokens and attention whether used or not. Connect only what the current work needs.
   (Project-level `.mcp.json` is what the scan sees; the user may also have global servers.)
6. **No review pass.** Faster generation means *more absolute bugs*, not better code. A
   review-specialist sub-agent or review skill is the screen. Most relevant in repos that
   generate a lot of code.
   *(Proxy signals: a review agent in `.claude/agents/`, a review skill, small diffs.)*
3. **`/compact` mid-task wipes decisions** → persist plans in a file (`PLAN.md`,
   `plans/`) so they survive a session boundary. *(Proxy: presence of plan files.)*
2. **Multi-task prompts** ("test + refactor + document + PR" at once) cause
   lost-in-the-middle. *(Proxy: existence of focused single-responsibility sub-agents.)*

**Behavioral — name them, don't grade them:**
- **#2** stuffing many unrelated tasks into one prompt.
- **#5** fully delegating *design/architecture* to the model — it writes plausible code
  that misses ownership, threading, and lifecycle concerns. Architecture stays human-owned.
- **#7** one all-day conversation accumulating context cruft → segment by task, start
  fresh sessions, keep durable state in files.

## Workflow

### 1. Scope it
If the user named a repo, audit that. If they said "my repos" / "this machine" / didn't
specify, scan everything. Run the bundled scanner — it discovers git repos under `$HOME`,
skips dependency/cache clones (node_modules, plugin caches, `.local/share`, etc.), and
prints the disk signals:

```bash
bash scripts/audit.sh                 # all repos under $HOME
bash scripts/audit.sh /path/to/repo   # one or more specific repos
```

The scanner flags each `CLAUDE.md` as `LEAN` / `BORDERLINE` / `HEAVY` by size. Those are
heuristics, not verdicts — a 12 KB file that's all load-bearing contract is fine; a 6 KB
file that's a duplicated directory map is not. So for anything flagged `BORDERLINE`/`HEAVY`,
**read it** before judging, and check whether its bulk is **already duplicated** in
`docs/`, `_documentation/`, or per-module docs (a very common finding — the root file
re-states what already lives elsewhere). Duplicated reference is the easiest win: it can
just be deleted in favor of a pointer.

### 2. Report
Lead with a scorecard table, then the specifics. Keep it scannable — the user wants to
know *which file is the problem*, not a lecture on all seven points. Use this shape:

```
| Repo | #1 CLAUDE.md | #4 MCP | skills/agents | Verdict |
|------|--------------|--------|---------------|---------|
| foo  | 🔴 130 ln / 18 KB, dense | none | none | main offender |
| bar  | 🟢 9 ln       | ✅ 1 (arxiv) | ✅ 2 skills, 2 agents | exemplary |
```

Then: a short paragraph per *real* finding (skip points that are fine), and an explicit
note of the behavioral points you **cannot** see from disk, so the user isn't misled into
thinking a clean scorecard means clean habits. Call out the single highest-leverage fix
rather than burying it in a list.

### 3. Offer fixes
Don't auto-edit. Propose the concrete change and let the user pick. The highest-value fix
is almost always slimming a `HEAVY` `CLAUDE.md` — see the playbook below.

## Fix playbook: slimming a `CLAUDE.md`

The move is **extract, don't delete** — relocate reference weight to a doc that loads on
demand, leaving the root file lean and a pointer behind. Nothing is lost; it just stops
being taxed every turn.

1. **Classify each section** by how often a session actually needs it:
   - *Every turn* → keep in `CLAUDE.md`: one-line project overview, build/run commands,
     and the **load-bearing contracts** — the things that cause real errors when forgotten
     (single-source-of-truth files, cross-repo coupling, known footguns).
   - *Occasionally* → extract: directory maps, module-by-module breakdowns, full parameter
     tables, output-file inventories, tool flag dumps, I/O trivia, persona catalogs.
2. **Check for existing duplication first.** If the extracted content already lives in
   `docs/`, `_documentation/`, or per-module docs, don't copy it — just point to it.
3. **Place extracted docs to match repo convention.** Reuse an existing docs directory if
   there is one (`_documentation/`, `docs/`, `projects/`) rather than inventing a new
   layout. Name it discoverably (e.g. `codebase_map.md`, `architecture.md`).
4. **Leave a pointer block** in `CLAUDE.md` — a short "load on demand" list naming each
   doc and what it holds, so the model knows where to look without carrying the content.
5. **Preserve technical detail verbatim** when moving it. Hard-won specifics (exact
   thresholds, unit numbers, coupling caveats) are the whole value — reword prose freely,
   but don't paraphrase a number or drop a caveat.
6. **Show the before/after size** (lines + KB) and confirm nothing was lost. Don't commit
   unless asked.

A worked target: a 130-line / 18 KB dense `CLAUDE.md` → ~50 lines / ~4 KB (overview +
build + contract + pointers), with the architecture/parameters/I-O detail moved to
`_documentation/codebase_map.md`. ~80% lighter per turn, zero information lost.

For persona / "model of me" `CLAUDE.md` files, go lighter: the persona and behavior rules
genuinely are useful most sessions. Extract only the clear reference catalogs (e.g. a long
textbook/library list, operational internals of a background job) and keep the rest.

## Related fixes (when the user wants them)
- **#4 MCP:** recommend disconnecting servers not needed for current work; project
  `.mcp.json` should list only task-relevant servers.
- **#6 review:** offer to add a scoped review sub-agent (`.claude/agents/`) to repos that
  generate a lot of code and have none.
- **#1 push to skills:** genuinely reusable knowledge (a workflow, a domain reference) is
  better as an Agent Skill than as `CLAUDE.md` prose — it loads only when its description
  matches.
