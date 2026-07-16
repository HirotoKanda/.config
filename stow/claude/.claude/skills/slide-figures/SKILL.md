---
name: slide-figures
description: >-
  Create OR review scientific/data figures for presentation SLIDES and talks
  (Beamer, Keynote, PowerPoint) — as opposed to figures for print papers. Use
  when the user wants to make a figure/plot/chart for a talk or slide, redraw a
  paper figure for a presentation, check whether a figure is legible from the
  back of a room, pick a colorblind-safe palette, fix tiny fonts / thin lines /
  spaghetti plots on a slide, set matplotlib or TikZ/PGFPlots for talk output,
  or asks "is this figure readable on a slide?". Covers matplotlib, TikZ/PGFPlots
  (LaTeX/Beamer), and tool-agnostic rules. Complements `dataviz` (which governs
  chart form/color in general); this skill governs the slide-specific overlay:
  legibility at distance, one-message-per-slide, projection, and export.
---

# Slide Figures — figures that read from the back of the room

A slide figure is not a paper figure shrunk down. A paper figure is read at
30 cm by one person who can re-read it; a slide figure is read at 10+ m by a
room, once, for a few seconds, while you talk over it. The whole discipline
below follows from that one difference.

If the task is general chart form/color choice (which chart type, categorical
vs. sequential palette), that's `dataviz` — read it first. **This** skill is the
slide overlay on top: legibility at distance, ruthless simplification,
projection-safe color, and export.

## Two modes

- **Creating** a new figure → apply the rulebook, then use the toolchain
  starters. Jump to *Creating workflow*.
- **Reviewing** an existing figure → score it against the same rulebook.
  Jump to *Reviewing workflow*. Ask the user for the figure (image, source,
  or plotting code) and the slide aspect ratio if not given.

Both modes share one rulebook — the sections below.

---

## The rulebook

### R1 · Legibility at distance (the non-negotiables)

The room, not the author, sets the minimum size.

| Element | Slide minimum | Notes |
|---|---|---|
| Any figure text (axis labels, ticks, legend) | **18 pt**, ideally 20–24 pt | 18 pt ≈ invisible past ~3rd row is the *floor*, not a target |
| Axis title | 20–24 pt | |
| Data line weight | **3 pt** (`linewidth=3`) | 1 pt paper lines vanish |
| Marker size | ~10 pt (`markersize=10`) | |
| Emphasis / callout | ≥ 24 pt | |

Anchor numbers come from matplotlib's `talk` context (`axes.titlesize:24`,
`axes.labelsize:20`, `lines.linewidth:3`, `lines.markersize:10`,
`xtick.labelsize:16`). See `assets/talk.mplstyle`.

- **Sans-serif only.** Thin serifs wash out under projector glare. Never serif
  below 18 pt.
- **8H rule of thumb:** text height ≥ 1/50 of screen height, i.e. legible for a
  viewer up to 8× the screen height away. If in doubt, bigger.
- **Regenerate, never screenshot** a paper figure onto a slide — the fonts were
  tuned for a much smaller final size. Rebuild from source with a slide `figsize`
  and 18 pt+ fonts. (See R6.)

### R2 · One message per slide

- Each figure carries **exactly one message** (Doumont, *Trees, Maps, and
  Theorems*). State it as a full sentence in the slide title ("Rate rises with
  temperature", not "Results"). If the figure supports two claims, split it
  across two slides / two builds.
- **Redraw, don't reuse.** A dense multi-panel paper figure (a,b,c,d) → split
  into separate simpler plots, one per slide or per build. Drop panel letters;
  they only mean something next to a caption nobody reads.
- Decide the single fact the figure must convey, then delete everything that
  doesn't serve it.

### R3 · Declutter (maximize data-ink)

Erase, in this order (Knaflic / Tufte):
1. Chart border/box.
2. Gridlines — remove, or lighten to faint gray if values must be read off.
3. Redundant tick marks and axis lines.
4. Background fills, drop shadows, 3-D effects, moiré, ornament.
5. Legend, if direct labels will do (see R4).

Complexity caps for a live room: **≤ 5 lines** per line chart before it's
spaghetti; **≤ 6 wedges** per pie (prefer a bar chart). Over these, split or
aggregate.

### R4 · Labels beat legends

A legend forces the audience to look away → decode the key → look back, every
time. That taxes working memory during a talk.

- **Direct-label** each line/bar/series next to itself, in its own color.
- If exact values matter: label the data points and drop the y-axis. If only the
  trend matters: keep the axis, skip point labels.
- Always include **units** in axis titles. Never make the room infer them.

### R5 · Projection-safe color & accessibility

- **Default palette: Okabe–Ito** (colorblind-safe; Wong, *Nat. Methods* 2011).
  Full hex list in `references/palette.md`.
- **Never encode by color alone.** If a grayscale print of the figure loses
  information, it fails. Add redundant coding: shape, dash pattern, hatch, or
  direct label.
- **No red–green pairs** (≈8% of men can't separate them; also "vibrates" under
  projection).
- **Sequential/continuous data:** `viridis` (perceptually uniform), or `cividis`
  for maximum color-vision-deficiency safety. **Never `jet`/rainbow** — false
  edges, not uniform.
- **Contrast:** aim WCAG-style ≥ 3:1 for lines/markers vs. background, ≥ 4.5:1
  for text. The validator checks this.
- **Projectors shift hue** (pale green → chartreuse, yellow → muddy). Prefer
  saturated, high-contrast combos and, when it matters, test on the real
  projector. Match the figure background to the slide theme (light or dark).
- Beyond ~8 categories: Krzywinski extended colorblind-safe sets (see palette
  reference) — but first ask whether that many series belongs on one slide (R3).

### R6 · Export & technical

- **Vector by default** (PDF/SVG) for line plots and diagrams — the projector
  resolution is unknown and vector scales losslessly. Raster (PNG) only for
  photos, dense scatter, or heatmaps.
- **Raster target:** ≥ 1920×1080 px for 16:9. What matters is pixel count, not
  the DPI tag; `dpi=150` is plenty for slides (vs. 300+ for print).
- **Aspect ratio:** 16:9 is the modern default (PowerPoint widescreen =
  13.33 × 7.5 in). Don't present a 4:3 figure/deck on a 16:9 projector — you
  waste ~25% of the screen and shrink the figure for everyone.
- **Embed fonts.** Type-3/bitmap fonts (common from gnuplot/xfig) blur when
  scaled. Verify with `pdffonts file.pdf`; in matplotlib set
  `pdf.fonttype: 42` (see the style file). Use `bbox_inches='tight'` so labels
  aren't clipped.
- Full numeric specs: `references/specs.md`.

### R7 · Builds & annotation (use sparingly)

- Progressive reveal is for a **genuine punchline or to reduce momentary
  complexity** — not by default. Simon Peyton Jones: one-by-one reveals are "very
  annoying" used reflexively. Duarte: reveal a complex diagram one layer at a
  time only when each layer needs its own explanation.
- **Highlight to direct attention:** gray everything out, color/enlarge the one
  focal element. Keep emphasis to ≲ 10% of the figure or it stops being emphasis.
- Technical build pattern: fix the axes/limits once, then a sequence of functions
  each adding one layer → N functions give N+1 slide states.

### Caveat (Tufte)

Tufte's honest position: projected slides are a low-resolution medium and a
genuinely dense figure belongs on a **paper handout**, with the slide showing
only the headline. If a figure can't survive R1–R3, the right move may be to
split it *and* hand out the detailed version — not to cram it.

---

## Creating workflow

1. **State the one message** (R2) — get it as a sentence; it becomes the title.
2. **Pick the form** — defer to `dataviz` for chart-type/palette-family choice.
3. **Set the toolchain to talk defaults** — matplotlib: `plt.style.use(<path>/assets/talk.mplstyle)`; TikZ/PGFPlots: see *Toolchain starters*.
4. **Apply R3–R5** — declutter, direct-label with units, Okabe–Ito / viridis.
5. **Export per R6** — vector, right aspect ratio, embedded fonts.
6. **Validate** — run `scripts/check_figure.py` on the palette/export and
   self-check against the *Review checklist*.

## Reviewing workflow

Ask for the figure (image + ideally source/aspect ratio). Score against the
checklist; report **pass / fail per item** with the specific fix, ordered
worst-first. Don't just say "text is small" — say "ticks ≈ 11 pt, need ≥ 18 pt;
bump `xtick.labelsize` to 18."

### Review checklist

- [ ] **R1** All text ≥ 18 pt at final slide size; lines ≥ 3 pt; sans-serif.
- [ ] **R2** One message, stated as the title; not a shrunk multi-panel paper fig.
- [ ] **R3** No box/heavy grid/3-D/chartjunk; ≤ 5 lines or ≤ 6 wedges.
- [ ] **R4** Direct labels over legend where possible; units on every axis.
- [ ] **R5** Okabe–Ito / viridis; not color-alone; no red–green; contrast ≥ 3:1;
      background matches slide theme.
- [ ] **R6** Vector (or ≥1920×1080 raster); correct aspect ratio; fonts embedded.
- [ ] **R7** Any build/animation earns its place; emphasis ≲ 10%.

Run `scripts/check_figure.py --help` for the automatable subset (palette
colorblind-safety, pairwise contrast, and — for an exported file — vector/raster
and font-embedding checks).

---

## Toolchain starters

### matplotlib
```python
import matplotlib.pyplot as plt
plt.style.use("<skill>/assets/talk.mplstyle")   # 18pt+ fonts, 3pt lines, Okabe–Ito cycle
fig, ax = plt.subplots(figsize=(10, 5.6))        # 16:9-ish; big physical size
# ... plot; direct-label instead of ax.legend() where possible ...
ax.set_ylabel("Cross section (mb)")              # units in the title
fig.savefig("fig.pdf", bbox_inches="tight")      # vector; talk.mplstyle sets pdf.fonttype:42
```

### TikZ / PGFPlots (Beamer)
```latex
% Vector-native; text auto-matches Beamer font & size. Keep it big and clean.
\begin{tikzpicture}
  \begin{axis}[
      width=0.9\textwidth, height=6cm,
      tick label style={font=\large}, label style={font=\large},
      line width=1.2pt, tick align=outside,
      axis lines=left,            % no box (R3)
      xlabel={Energy (MeV)}, ylabel={Rate (s$^{-1}$)},
      cycle list name=okabeito,   % define via \pgfplotsset (see references/palette.md)
      nodes near coords style={font=\large},
    ]
    \addplot ...; \node[right] at (axis cs:...) {baseline};  % direct label (R4)
  \end{axis}
\end{tikzpicture}
```
Define the Okabe–Ito `cycle list` once in the preamble — snippet in
`references/palette.md`.

### Tool-agnostic (Keynote / PowerPoint / plotly / etc.)
The rulebook is the spec: 18 pt+ text at final size, one message = title,
declutter to data-ink, direct labels + units, Okabe–Ito/viridis + redundant
coding, vector export at the deck's aspect ratio, fonts embedded.

## Reference files
- `references/palette.md` — Okabe–Ito & viridis/cividis hex, red–green don'ts,
  extended (>8) palettes, matplotlib cycle + PGFPlots `cycle list` snippets.
- `references/specs.md` — font-pt / line-weight / marker tables, slide pixel
  dimensions, DPI, aspect-ratio math, the 8H rule, font-embedding fixes.
- `scripts/check_figure.py` — palette colorblind-safety + pairwise contrast
  checker; optional export audit (vector vs raster, embedded fonts) for a file.
- `assets/talk.mplstyle` — importable matplotlib talk style.
