# Numeric specs for slide figures

## Type & element sizes (at final slide size)

| Element | Minimum | Comfortable |
|---|---|---|
| Figure body text (ticks, legend) | 18 pt | 20–24 pt |
| Axis title | 20 pt | 24 pt |
| In-figure emphasis / callout | 24 pt | 28–32 pt |
| Data line weight | 3 pt | 3–4 pt |
| Marker size | 8 pt | 10–12 pt |

matplotlib `talk` anchors: `axes.titlesize:24`, `axes.labelsize:20`,
`lines.linewidth:3`, `lines.markersize:10`, `xtick.labelsize:16`,
`ytick.labelsize:16`, `legend.fontsize:16`. (`talk.mplstyle` bumps ticks to 18.)

## Slide dimensions

| Deck | Inches | Pixels @ full HD |
|---|---|---|
| 16:9 widescreen (default) | 13.33 × 7.5 | 1920 × 1080 |
| 4:3 legacy | 10 × 7.5 | 1024 × 768 |

- A figure filling ~½ the slide width at 16:9 ≈ 6.5 in wide → use
  `figsize=(6.5, 4)` to `(10, 5.6)` and let font pt sizes do the work.
- Presenting 4:3 content on a 16:9 projector wastes ~25% of the screen.

## Resolution / export

- Raster target: **≥ 1920×1080 px** for 16:9 (pixel count matters, not the DPI
  tag). `dpi=150` is enough for slides; 300+ is for print.
- **Vector (PDF/SVG) by default** for line art/diagrams; raster (PNG) for photos,
  dense scatter, heatmaps.
- matplotlib: `fig.savefig("f.pdf", bbox_inches="tight")` — `talk.mplstyle` sets
  `pdf.fonttype:42` / `ps.fonttype:42` so fonts embed as TrueType, not Type-3.

## Font embedding

- Check: `pdffonts file.pdf` — every font should show `emb=yes` and **not**
  `Type 3`.
- Fix (matplotlib): `rcParams["pdf.fonttype"] = 42`.
- Fix (any PDF): `gs -o out.pdf -dEmbedAllFonts=true -dSubsetFonts=true \
  -sDEVICE=pdfwrite in.pdf`.

## The 8H rule (legibility vs. distance)

- Farthest viewer ≤ **8 × screen height** away.
- Minimum text height ≈ screen height ÷ 50.
- Quick check: back-row distance (inches) ÷ 400 = minimum text height (inches).
  E.g. 40 ft back = 480 in → ≥ 1.2 in tall text on screen.

## Complexity caps (back-of-room)

- Line chart: ≤ 5 lines before spaghetti.
- Pie: ≤ 6 wedges (prefer a bar chart).
- Emphasis: ≲ 10% of the figure's ink, or it stops reading as emphasis.
