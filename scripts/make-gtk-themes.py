#!/usr/bin/env python3
"""Generate the Thinkpadism GTK themes from the Platinum source.

The upstream ClassicPlatinumStreamlined theme is a light Mac OS 9 pastiche
with a violet (#9999FF) selection colour. This script derives two themes
from it, so there is exactly one source of truth for the widget geometry
and only the palette differs:

    ThinkpadismPlatinum       light, violet selection recoloured red
    ThinkpadismPlatinumDark   dark, ditto, with the greys inverted

Both the stylesheets and the bitmap assets go through the same colour
transform, which is the point: recolouring only the CSS would leave black
arrows and white checkboxes sitting on a dark background.

The transform works in HLS:

  * Near-greyscale colours are the theme's structure -- backgrounds,
    bevels, text. For the dark variant their lightness is inverted, which
    also swaps highlights and shadows, and that is exactly right for a
    bevelled theme: a ridge lit from the top left stays lit from the top
    left.
  * Violet-to-blue colours are the selection accent. They are rotated to
    the ThinkPad red at every lightness they appear in, so gradients and
    pressed states keep their shape.
  * Everything else -- the #CC0000 error red, the amber warnings -- is
    semantic and left alone.

Run with --check to print what would change without writing anything.
"""

from __future__ import annotations

import argparse
import colorsys
import re
import shutil
import sys
from pathlib import Path

from PIL import Image

# --- The accent ---------------------------------------------------------

# #b3121d, the red off a ThinkPad lid badge, and #e0303c, the brighter
# version that survives a dark background. Both sit on the same hue.
ACCENT_HUE = 355.9 / 360.0

# The source theme's selection colour is #9999FF: hue 240, lightness 0.80,
# fully saturated. Everything in that hue family -- gradient stops, pressed
# states, the focus ring -- is a lighter or darker version of it.
#
# Rotating the hue alone would land the selection on a pale pink, because
# lightness 0.80 is pale whatever the hue. So the family is rescaled as
# well: the factors below map #9999FF exactly onto the target red, and
# every other member of the family moves with it, which keeps gradients
# pointing the same way.
SOURCE_ACCENT_LIGHTNESS = 0.800
SOURCE_ACCENT_SATURATION = 1.000

# Target: #b3121d on light, #e0303c on dark.
ACCENT_TARGET = {
    False: (0.386, 0.817),
    True: (0.533, 0.739),
}

# Anything less saturated than this is treated as structural grey.
GREY_SAT = 0.12

# Hue window, in degrees, that counts as "the selection violet".
ACCENT_SOURCE_HUE = (200.0, 280.0)


def transform(rgb: tuple[int, int, int], dark: bool) -> tuple[int, int, int]:
    """Map one colour through the palette transform."""
    r, g, b = (c / 255.0 for c in rgb)
    h, l, s = colorsys.rgb_to_hls(r, g, b)

    hue_deg = h * 360.0

    if s < GREY_SAT:
        # Structural grey. Inverting its lightness for the dark variant
        # also swaps highlights and shadows, which is what keeps a
        # bevelled widget looking lit from the same corner.
        if dark:
            l = 1.0 - l
    elif ACCENT_SOURCE_HUE[0] <= hue_deg <= ACCENT_SOURCE_HUE[1]:
        target_l, target_s = ACCENT_TARGET[dark]
        h = ACCENT_HUE
        l = min(1.0, l * (target_l / SOURCE_ACCENT_LIGHTNESS))
        s = min(1.0, s * (target_s / SOURCE_ACCENT_SATURATION))
    else:
        # Semantic colour: the #CC0000 error red, amber warnings. Keep the
        # hue, and on dark lift it just enough to stay legible.
        if dark and l < 0.45:
            l = min(1.0, l + 0.18)

    r, g, b = colorsys.hls_to_rgb(h, l, s)
    return tuple(max(0, min(255, round(c * 255))) for c in (r, g, b))


# --- CSS ----------------------------------------------------------------

HEX_RE = re.compile(r"#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{3})\b")
FUNC_RE = re.compile(
    r"\brgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*(?:,\s*([0-9.]+)\s*)?\)"
)


def _expand_short_hex(value: str) -> str:
    if len(value) == 3:
        return "".join(c * 2 for c in value)
    return value


def rewrite_css(text: str, dark: bool) -> str:
    def hex_sub(m: re.Match[str]) -> str:
        raw = _expand_short_hex(m.group(1))
        rgb = tuple(int(raw[i : i + 2], 16) for i in (0, 2, 4))
        return "#%02X%02X%02X" % transform(rgb, dark)

    def func_sub(m: re.Match[str]) -> str:
        rgb = tuple(int(m.group(i)) for i in (1, 2, 3))
        out = transform(rgb, dark)
        alpha = m.group(4)
        if alpha is None:
            return "rgb(%d,%d,%d)" % out
        return "rgba(%d,%d,%d,%s)" % (*out, alpha)

    return FUNC_RE.sub(func_sub, HEX_RE.sub(hex_sub, text))


# --- Assets -------------------------------------------------------------


def rewrite_png(src: Path, dst: Path, dark: bool) -> None:
    """Recolour a bitmap, preserving its alpha channel exactly."""
    image = Image.open(src).convert("RGBA")
    pixels = list(image.getdata())

    # These assets are tiny and use very few distinct colours, so caching
    # the transform per colour makes this effectively free.
    cache: dict[tuple[int, int, int], tuple[int, int, int]] = {}
    out = []
    for r, g, b, a in pixels:
        if a == 0:
            # Fully transparent pixels still carry RGB; leave them, since
            # changing them can only introduce fringing.
            out.append((r, g, b, a))
            continue
        key = (r, g, b)
        if key not in cache:
            cache[key] = transform(key, dark)
        out.append((*cache[key], a))

    image.putdata(out)
    dst.parent.mkdir(parents=True, exist_ok=True)
    image.save(dst, "PNG", optimize=True)


# --- Theme assembly -----------------------------------------------------

INDEX_THEME = """[Desktop Entry]
Type=X-GNOME-Metatheme
Name={name}
Comment={comment}
Encoding=UTF-8

[X-GNOME-Metatheme]
GtkTheme={name}
MetacityTheme={name}
IconTheme=ThinkpadismIcons
CursorTheme=
ButtonLayout=close,minimize,maximize:
"""

VARIANTS = {
    "ThinkpadismPlatinum": {
        "dark": False,
        "comment": "Platinum widgets in ThinkPad red. Light.",
    },
    "ThinkpadismPlatinumDark": {
        "dark": True,
        "comment": "Platinum widgets in ThinkPad red. Dark.",
    },
}


def build(src_root: Path, out_root: Path, check: bool) -> int:
    if not (src_root / "gtk-3.0" / "gtk.css").is_file():
        print(f"error: {src_root} does not look like a GTK theme", file=sys.stderr)
        return 1

    for name, spec in VARIANTS.items():
        dark = spec["dark"]
        dest = out_root / name

        css_count = 0
        png_count = 0

        for version in ("gtk-3.0", "gtk-4.0"):
            src_dir = src_root / version
            if not src_dir.is_dir():
                continue

            for path in sorted(src_dir.rglob("*")):
                if path.is_dir():
                    continue
                rel = path.relative_to(src_root)
                target = dest / rel

                if path.suffix == ".css":
                    css_count += 1
                    if not check:
                        target.parent.mkdir(parents=True, exist_ok=True)
                        target.write_text(
                            rewrite_css(path.read_text(encoding="utf-8"), dark),
                            encoding="utf-8",
                        )
                elif path.suffix == ".png":
                    png_count += 1
                    if not check:
                        rewrite_png(path, target, dark)
                elif not check:
                    target.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(path, target)

        if not check:
            dest.mkdir(parents=True, exist_ok=True)
            (dest / "index.theme").write_text(
                INDEX_THEME.format(name=name, comment=spec["comment"]),
                encoding="utf-8",
            )

        verb = "would write" if check else "wrote"
        print(f"{verb} {name}: {css_count} stylesheets, {png_count} assets")

    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--source",
        type=Path,
        default=Path(__file__).resolve().parent.parent
        / "gtk_theme"
        / "ClassicPlatinumStreamlined",
        help="the upstream theme to derive from",
    )
    parser.add_argument(
        "--out",
        type=Path,
        default=Path("."),
        help="directory the generated themes are written into",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="report what would be generated without writing it",
    )
    args = parser.parse_args()

    return build(args.source, args.out, args.check)


if __name__ == "__main__":
    raise SystemExit(main())
