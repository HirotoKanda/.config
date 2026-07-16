# Palettes for slide figures

Default to **Okabe–Ito** for categorical series and **viridis/cividis** for
continuous data. Both are colorblind-safe. Source: Wong, B. "Points of view:
Color blindness." *Nature Methods* 8, 441 (2011).

## Okabe–Ito (categorical, colorblind-safe)

| Name | Hex | RGB |
|---|---|---|
| Black | `#000000` | 0,0,0 |
| Orange | `#E69F00` | 230,159,0 |
| Sky Blue | `#56B4E9` | 86,180,233 |
| Bluish Green | `#009E73` | 0,158,115 |
| Yellow | `#F0E442` | 240,228,66 |
| Blue | `#0072B2` | 0,114,178 |
| Vermillion | `#D55E00` | 213,94,0 |
| Reddish Purple | `#CC79A7` | 204,121,167 |

Order for max separation on a light background: Blue → Vermillion → Bluish
Green → Reddish Purple → Orange → Sky Blue. Yellow only on dark backgrounds
(low contrast on white — the validator will flag it).

## Continuous / sequential

- **viridis** — perceptually uniform, default in matplotlib since 2015. Use for
  most heatmaps/surfaces.
- **cividis** — optimized for color-vision deficiency; use when CVD safety is
  paramount.
- **Never** `jet`/rainbow/`hsv` — not perceptually uniform, invents false edges.

## Don'ts

- No **red–green** pairs (protan/deutan ≈ 8% of men; also vibrates on projectors).
- No color-alone encoding — pair color with shape/dash/hatch/direct label (R5).

## Extended (> 8 categories)

Prefer to split the figure first (R3). If you truly need more, use Martin
Krzywinski's colorblind-safe extended sets (12/15/24 colors), BC Genome Sciences
Centre: http://mkweb.bcgsc.ca/colorblind/ — but > ~8 series on one slide rarely
survives the back-of-room test.

## matplotlib cycle

```python
from cycler import cycler
okabe_ito = ["#0072B2", "#D55E00", "#009E73", "#CC79A7",
             "#E69F00", "#56B4E9", "#F0E442", "#000000"]
import matplotlib as mpl
mpl.rcParams["axes.prop_cycle"] = cycler(color=okabe_ito)
# (already set in assets/talk.mplstyle)
```

## PGFPlots cycle list (preamble)

```latex
\pgfplotsset{
  cycle list={
    {color={rgb,255:red,0;green,114;blue,178}},    % Blue
    {color={rgb,255:red,213;green,94;blue,0}},      % Vermillion
    {color={rgb,255:red,0;green,158;blue,115}},     % Bluish Green
    {color={rgb,255:red,204;green,121;blue,167}},   % Reddish Purple
    {color={rgb,255:red,230;green,159;blue,0}},     % Orange
    {color={rgb,255:red,86;green,180;blue,233}},    % Sky Blue
  },
}
% name it: \pgfplotsset{cycle list name=okabeito}  after defining as a named list
```
To use `cycle list name=okabeito`, wrap the above in
`\pgfplotscreateplotcyclelist{okabeito}{ ... }` instead of the inline form.
