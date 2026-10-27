#!/usr/bin/env python3
"""Generate Travel Pal launcher and splash PNGs (warm scrapbook palette)."""
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1] / "assets" / "brand"
PAPER = (247, 243, 236)
TERRACOTTA = (201, 111, 74)
INK = (37, 35, 31)
OLIVE = (111, 118, 87)
BORDER = (221, 214, 201)


def draw_mark(draw: ImageDraw.ImageDraw, cx: int, cy: int, scale: float) -> None:
    s = scale
    # Scrapbook frame
    left, top = cx - int(140 * s), cy - int(110 * s)
    right, bottom = cx + int(140 * s), cy + int(110 * s)
    draw.rounded_rectangle(
        [left, top, right, bottom],
        radius=int(28 * s),
        outline=TERRACOTTA,
        width=max(2, int(8 * s)),
        fill=PAPER,
    )
    # Photo tile
    px1, py1 = cx - int(95 * s), cy - int(70 * s)
    px2, py2 = cx + int(45 * s), cy + int(40 * s)
    draw.rounded_rectangle(
        [px1, py1, px2, py2],
        radius=int(12 * s),
        fill=OLIVE,
    )
    # Sun / horizon accent
    draw.ellipse(
        [
            cx + int(35 * s),
            cy - int(55 * s),
            cx + int(85 * s),
            cy - int(5 * s),
        ],
        fill=TERRACOTTA,
    )
    # Journal lines
    for i, yoff in enumerate((55, 75, 95)):
        y = cy + int(yoff * s)
        draw.line(
            (cx - int(30 * s), y, cx + int(120 * s), y),
            fill=BORDER if i < 2 else INK,
            width=max(1, int(3 * s)),
        )


def make_icon(size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size), PAPER + (255,))
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle(
        [0, 0, size - 1, size - 1],
        radius=int(size * 0.18),
        fill=PAPER,
    )
    draw_mark(draw, size // 2, size // 2, size / 512)
    return img


def main() -> None:
    ROOT.mkdir(parents=True, exist_ok=True)
    icon = make_icon(1024)
    icon.save(ROOT / "app_icon.png")
    splash = make_icon(512)
    splash.save(ROOT / "splash_logo.png")
    print("Wrote", ROOT / "app_icon.png", ROOT / "splash_logo.png")


if __name__ == "__main__":
    main()
