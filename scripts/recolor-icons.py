#!/usr/bin/env python3
"""Shift the blue accents in the icon theme over to red.

The upstream Retroism icon set draws folders and other accented artwork in a
blue/indigo hue. Thinkpadism is a red rice, so every pixel whose hue falls in
the blue band is rotated onto red while keeping its saturation and value --
that preserves the hand-placed pixel shading instead of flattening it.

Greys, blacks, whites and already-warm colours are left untouched, which is
what keeps document pages white and outlines black.

Symlinks are skipped. The theme aliases most of its names (folder-open.png ->
folder.png and so on); following one would rewrite the same image repeatedly
and, worse, replace the link with a regular file.

Usage:
    python3 scripts/recolor-icons.py [--check] [THEME_DIR]

    --check   report what would change without writing anything
"""

from __future__ import annotations

import argparse
import colorsys
import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:  # pragma: no cover - dependency hint only
    sys.exit("This script needs Pillow: pip install pillow (or nix-shell -p python3Packages.pillow)")

DEFAULT_THEME = Path("icon_theme/ThinkpadismIcons")

# Hue band treated as "blue", in degrees. The source art sits around 240.
BLUE_LO, BLUE_HI = 195.0, 280.0

# Where those hues land. Slightly off pure red so the result reads as the
# ThinkPad accent rather than a fire alarm.
RED_CENTER = 356.0
# How much of the original hue spread to keep. 0 flattens every blue to one
# red; 1 would preserve the full 85-degree spread and run into magenta.
SPREAD = 0.14

# Pixels flatter than this are neutral grey and must stay neutral.
MIN_SATURATION = 0.12

# At equal HLS saturation red reads duller than blue, so push it up or the
# folders come out brown. Capped at 1.0 per pixel.
SATURATION_BOOST = 1.45


def shift_pixel(r: int, g: int, b: int) -> tuple[int, int, int]:
    """Rotate one RGB triple from the blue band onto red."""
    h, l, s = colorsys.rgb_to_hls(r / 255.0, g / 255.0, b / 255.0)
    hue = h * 360.0

    if s < MIN_SATURATION or not (BLUE_LO <= hue <= BLUE_HI):
        return r, g, b

    # Position within the blue band, -0.5 .. 0.5, mapped onto the red band.
    band_mid = (BLUE_LO + BLUE_HI) / 2.0
    band_width = BLUE_HI - BLUE_LO
    offset = (hue - band_mid) / band_width

    new_hue = (RED_CENTER + offset * band_width * SPREAD) % 360.0

    # Red reads darker than blue at the same lightness, so lift it a little to
    # keep the icons from muddying at 16px.
    new_l = min(1.0, l * 1.04)
    new_s = min(1.0, s * SATURATION_BOOST)

    nr, ng, nb = colorsys.hls_to_rgb(new_hue / 360.0, new_l, new_s)
    return round(nr * 255), round(ng * 255), round(nb * 255)


def recolor(path: Path, check: bool) -> bool:
    """Recolor one PNG in place. Returns True if any pixel changed.

    Callers must filter out symlinks first; this writes through to `path`.
    """
    with Image.open(path) as img:
        rgba = img.convert("RGBA")

    pixels = list(rgba.getdata())
    cache: dict[tuple[int, int, int], tuple[int, int, int]] = {}
    out = []
    changed = False

    for r, g, b, a in pixels:
        if a == 0:
            out.append((r, g, b, a))
            continue
        key = (r, g, b)
        if key not in cache:
            cache[key] = shift_pixel(r, g, b)
        nr, ng, nb = cache[key]
        if (nr, ng, nb) != key:
            changed = True
        out.append((nr, ng, nb, a))

    if changed and not check:
        rgba.putdata(out)
        rgba.save(path, "PNG", optimize=True)

    return changed


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("theme", nargs="?", default=DEFAULT_THEME, type=Path)
    parser.add_argument("--check", action="store_true", help="report only, write nothing")
    args = parser.parse_args()

    if not args.theme.is_dir():
        sys.exit(f"No such theme directory: {args.theme}")

    everything = sorted(args.theme.rglob("*.png"))
    icons = [p for p in everything if not p.is_symlink()]
    aliases = len(everything) - len(icons)
    if not icons:
        sys.exit(f"No PNGs under {args.theme}")

    touched = 0
    for icon in icons:
        if recolor(icon, args.check):
            touched += 1

    verb = "would change" if args.check else "recolored"
    print(f"{verb} {touched} of {len(icons)} icons under {args.theme} ({aliases} symlink aliases skipped)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
