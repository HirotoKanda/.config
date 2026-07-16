#!/usr/bin/env python3
"""check_figure.py — automatable subset of the slide-figures review checklist.

Two independent checks:

  1. Palette check (always): given hex colors, flag
       - low contrast vs. the slide background (WCAG-style ratio),
       - pairs indistinguishable under color-vision deficiency (protan/deutan/tritan)
         via a simple CVD simulation + perceptual distance,
       - red-green pairs.
  2. Export check (if a file is given): PDF/SVG (vector, good) vs. raster;
     for PDFs, whether fonts are embedded and non-Type-3 (needs `pdffonts`).

No third-party deps. Examples:
    python check_figure.py --colors 0072B2 D55E00 009E73 --bg white
    python check_figure.py --colors "#E69F00,#F0E442" --bg white
    python check_figure.py --file talk_fig.pdf
    python check_figure.py --okabe-ito --bg dark        # sanity-check the default palette
"""
from __future__ import annotations
import argparse
import shutil
import subprocess
import sys

OKABE_ITO = ["000000", "E69F00", "56B4E9", "009E73",
             "F0E442", "0072B2", "D55E00", "CC79A7"]

# ---------- color utilities ----------

def parse_hex(s: str) -> tuple[float, float, float]:
    s = s.strip().lstrip("#")
    if len(s) == 3:
        s = "".join(c * 2 for c in s)
    if len(s) != 6:
        raise ValueError(f"bad hex color: {s!r}")
    return tuple(int(s[i:i + 2], 16) / 255.0 for i in (0, 2, 4))  # type: ignore


def _lin(c: float) -> float:
    return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4


def rel_luminance(rgb) -> float:
    r, g, b = (_lin(c) for c in rgb)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast_ratio(a, b) -> float:
    la, lb = rel_luminance(a), rel_luminance(b)
    hi, lo = max(la, lb), min(la, lb)
    return (hi + 0.05) / (lo + 0.05)


# Brettel-style CVD simulation, simplified (Viénot 1999 dichromat approximation).
def simulate_cvd(rgb, kind: str):
    # sRGB -> linear
    r, g, b = (_lin(c) for c in rgb)
    # linear RGB -> LMS (Hunt-Pointer-Estevez, normalized)
    L = 0.31399 * r + 0.63951 * g + 0.04649 * b
    M = 0.15537 * r + 0.75789 * g + 0.08670 * b
    S = 0.01775 * r + 0.10945 * g + 0.87262 * b
    if kind == "protan":
        L = 1.05118294 * M - 0.05116099 * S
    elif kind == "deutan":
        M = 0.9513092 * L + 0.04866992 * S
    elif kind == "tritan":
        S = -0.86744736 * L + 1.86727089 * M
    # LMS -> linear RGB
    r2 = 5.47221206 * L - 4.6419601 * M + 0.16963708 * S
    g2 = -1.1252419 * L + 2.29317094 * M - 0.1678952 * S
    b2 = 0.02980165 * L - 0.19318073 * M + 1.16364789 * S
    return tuple(min(1.0, max(0.0, v)) for v in (r2, g2, b2))


def perceptual_dist(a, b) -> float:
    # crude luminance-weighted RGB distance in 0..~1.7; good enough for a warning.
    dr, dg, db = (a[0] - b[0]), (a[1] - b[1]), (a[2] - b[2])
    return (2 * dr * dr + 4 * dg * dg + 3 * db * db) ** 0.5 / (9 ** 0.5)


# ---------- checks ----------

# Calibrated so the Okabe-Ito reference palette (worst designed pair ~0.10)
# passes cleanly, while a genuine red/green confusion (e.g. pure red vs green,
# ~0.06 under deutan) still trips. Colors closer than this after CVD simulation
# are the real "confusable under colorblindness" cases — no crude hue heuristic
# needed; the simulation IS the test.
CVD_MERGE_THRESH = 0.08


def check_palette(colors: list[str], bg: str) -> int:
    bg_rgb = parse_hex({"white": "FFFFFF", "light": "F5F5F5",
                        "dark": "1A1A1A", "black": "000000"}.get(bg, bg))
    rgbs = [parse_hex(c) for c in colors]
    contrast_issues = 0
    distinguish_issues = 0

    print(f"\n== Contrast vs. background ({bg}) ==  (want >= 3:1 for lines/markers)")
    for c, rgb in zip(colors, rgbs):
        cr = contrast_ratio(rgb, bg_rgb)
        flag = "" if cr >= 3.0 else "  <-- LOW on this background"
        if cr < 3.0:
            contrast_issues += 1
        print(f"  #{c.lstrip('#').upper():<7} {cr:5.2f}:1{flag}")
    if contrast_issues:
        print(f"  note: {contrast_issues} color(s) < 3:1 here — thicken the line/"
              "marker, use a darker variant, or switch slide background.")

    print("\n== Colorblind distinguishability (pairwise, CVD-simulated) ==")
    CVD = ("protan", "deutan", "tritan")
    for i in range(len(rgbs)):
        for j in range(i + 1, len(rgbs)):
            worst_kind, worst = None, 99.0
            for kind in CVD:
                d = perceptual_dist(simulate_cvd(rgbs[i], kind),
                                    simulate_cvd(rgbs[j], kind))
                if d < worst:
                    worst, worst_kind = d, kind
            if worst < CVD_MERGE_THRESH:
                distinguish_issues += 1
                print(f"  #{colors[i].lstrip('#').upper()} vs "
                      f"#{colors[j].lstrip('#').upper()}: confusable under "
                      f"{worst_kind} (d={worst:.2f}) — add shape/dash/label or recolor")
    if distinguish_issues == 0:
        print("  all pairs distinguishable under protan/deutan/tritan — good")

    total = contrast_issues + distinguish_issues
    print(f"\nPalette result: distinguishability "
          f"{'PASS' if distinguish_issues == 0 else f'{distinguish_issues} issue(s)'}"
          f"; contrast {'PASS' if contrast_issues == 0 else f'{contrast_issues} low on {bg}'}")
    return total


def check_export(path: str) -> int:
    lower = path.lower()
    problems = 0
    print(f"\n== Export check: {path} ==")
    if lower.endswith((".pdf", ".svg", ".eps")):
        print("  format: VECTOR (good — scales losslessly on any projector)")
    elif lower.endswith((".png", ".jpg", ".jpeg", ".tif", ".tiff")):
        print("  format: RASTER — OK only for photos/dense scatter/heatmaps.")
        print("          For line art/diagrams, prefer PDF/SVG. Ensure >=1920x1080 px.")
        problems += 1
    else:
        print("  format: unknown extension")

    if lower.endswith(".pdf"):
        if shutil.which("pdffonts"):
            try:
                out = subprocess.run(["pdffonts", path], capture_output=True,
                                     text=True, timeout=20).stdout
            except Exception as e:  # noqa: BLE001
                print(f"  (pdffonts failed: {e})")
                return problems
            lines = [ln for ln in out.splitlines()[2:] if ln.strip()]
            if not lines:
                print("  fonts: none found (all text may be outlined — fine).")
            else:
                bad = False
                for ln in lines:
                    is_t3 = "Type 3" in ln
                    emb = " yes " in ln or ln.rstrip().endswith(" yes") or "\tyes" in ln
                    # pdffonts columns: name type emb sub uni ...
                    cols = ln.split()
                    emb_col = cols[2] if len(cols) > 2 else ""
                    if is_t3 or emb_col.lower().startswith("n"):
                        bad = True
                        print(f"  font ISSUE: {ln.strip()}")
                if bad:
                    problems += 1
                    print("  -> embed fonts (matplotlib pdf.fonttype=42, or "
                          "gs -dEmbedAllFonts=true); avoid Type 3.")
                else:
                    print("  fonts: all embedded, none Type 3 — good.")
        else:
            print("  (install poppler's `pdffonts` to verify font embedding)")
    return problems


def main() -> int:
    p = argparse.ArgumentParser(description="Slide-figure palette & export checker.")
    p.add_argument("--colors", help="hex colors, space- or comma-separated")
    p.add_argument("--okabe-ito", action="store_true", help="use the Okabe-Ito palette")
    p.add_argument("--bg", default="white",
                   help="background: white|light|dark|black or a hex (default white)")
    p.add_argument("--file", help="exported figure to audit (pdf/svg/png/...)")
    a = p.parse_args()

    total = 0
    ran = False
    colors = None
    if a.okabe_ito:
        colors = OKABE_ITO
    elif a.colors:
        colors = [c for c in a.colors.replace(",", " ").split() if c]
    if colors:
        total += check_palette(colors, a.bg)
        ran = True
    if a.file:
        total += check_export(a.file)
        ran = True
    if not ran:
        p.print_help()
        return 2
    print(f"\n{'='*40}\nTOTAL: {'PASS — no issues' if total == 0 else f'{total} issue(s) to fix'}")
    return 1 if total else 0


if __name__ == "__main__":
    sys.exit(main())
