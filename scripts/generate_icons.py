#!/usr/bin/env python3
"""Generate PWA icon set from a single design defined here.

Outputs (in frontend/):
  - icon-192.png
  - icon-512.png
  - icon-maskable-512.png   (with safe-area padding)
  - apple-touch-icon.png    (180x180)
  - favicon.ico             (multi-size)
  - favicon-32.png
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

BG = (45, 111, 101, 255)     # forest green
LEAF = (246, 241, 234, 255)  # cream
DOT = (215, 106, 77, 255)    # terracotta
STEM = (45, 111, 101, 255)   # green (same as bg, used for veins on cream leaf)

FRONTEND = Path(__file__).resolve().parent.parent / "frontend"


def draw_icon(size: int, *, maskable: bool = False) -> Image.Image:
    """Render the icon at the given pixel size.

    When maskable=True, the foreground is shrunk to fit inside the 80% safe
    area so Android can mask the icon to any shape without clipping the leaf.
    """
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    radius = int(size * 0.22)
    if maskable:
        draw.rectangle((0, 0, size, size), fill=BG)
    else:
        draw.rounded_rectangle((0, 0, size - 1, size - 1), radius=radius, fill=BG)

    # Foreground bounds: full canvas normally, 80% centered for maskable
    if maskable:
        inset = int(size * 0.10)
        fx0, fy0 = inset, inset
        fw = size - 2 * inset
    else:
        fx0, fy0 = 0, 0
        fw = size

    cx = fx0 + fw // 2
    cy = fy0 + fw // 2
    leaf_w = int(fw * 0.46)
    leaf_h = int(fw * 0.62)

    # Cream leaf body (vertical ellipse)
    draw.ellipse(
        (cx - leaf_w // 2, cy - int(leaf_h * 0.55),
         cx + leaf_w // 2, cy + int(leaf_h * 0.45)),
        fill=LEAF,
    )

    # Terracotta accent dot (sun / fruit)
    dot_r = max(2, int(fw * 0.07))
    draw.ellipse(
        (cx - dot_r, cy - int(leaf_h * 0.28) - dot_r,
         cx + dot_r, cy - int(leaf_h * 0.28) + dot_r),
        fill=DOT,
    )

    # Green vein down the leaf
    vein_w = max(2, int(fw * 0.018))
    draw.line(
        ((cx, cy - int(leaf_h * 0.18)), (cx, cy + int(leaf_h * 0.4))),
        fill=STEM,
        width=vein_w,
    )

    # Two side leaflets (quarter ellipses approximated as small ovals)
    side_w = int(fw * 0.18)
    side_h = int(fw * 0.10)
    # left leaflet
    draw.ellipse(
        (cx - side_w, cy + int(leaf_h * 0.04),
         cx,           cy + int(leaf_h * 0.04) + side_h),
        fill=STEM,
    )
    # right leaflet
    draw.ellipse(
        (cx,          cy + int(leaf_h * 0.20),
         cx + side_w, cy + int(leaf_h * 0.20) + side_h),
        fill=STEM,
    )

    return img


def main() -> None:
    targets = [
        ("icon-192.png", 192, False),
        ("icon-512.png", 512, False),
        ("icon-maskable-512.png", 512, True),
        ("apple-touch-icon.png", 180, False),
        ("favicon-32.png", 32, False),
    ]
    for name, size, maskable in targets:
        out = FRONTEND / name
        draw_icon(size, maskable=maskable).save(out, format="PNG", optimize=True)
        print(f"wrote {out.relative_to(FRONTEND.parent)} ({size}x{size})")

    # Multi-size favicon.ico
    ico_sizes = [(16, 16), (32, 32), (48, 48)]
    base = draw_icon(48, maskable=False)
    ico_path = FRONTEND / "favicon.ico"
    base.save(ico_path, format="ICO", sizes=ico_sizes)
    print(f"wrote {ico_path.relative_to(FRONTEND.parent)} (16,32,48)")


if __name__ == "__main__":
    main()
