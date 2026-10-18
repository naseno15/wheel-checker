"""Stitch Alsthom side photos into a long loco diagram for the entry picker."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageEnhance, ImageFilter, ImageOps

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "diagrams" / "als_side.png"
OUT_UI = ROOT / "assets" / "diagrams" / "als_side_ui.png"

# Left → right: front cab, mid (tank), rear cab
SOURCES = [
    Path(r"C:\Users\Naito\Downloads\20220623_165841.jpg"),
    Path(r"C:\Users\Naito\Downloads\20220623_165831.jpg"),
    Path(r"C:\Users\Naito\Downloads\20220623_165810.jpg"),
]


def load(path: Path) -> Image.Image:
    return ImageOps.exif_transpose(Image.open(path)).convert("RGB")


def crop_loco(im: Image.Image, top_frac: float = 0.18, bot_frac: float = 0.08,
              left_frac: float = 0.02, right_frac: float = 0.02) -> Image.Image:
    w, h = im.size
    return im.crop((
        int(w * left_frac),
        int(h * top_frac),
        int(w * (1.0 - right_frac)),
        int(h * (1.0 - bot_frac)),
    ))


def match_height(im: Image.Image, h: int) -> Image.Image:
    w = max(1, int(im.width * (h / im.height)))
    return im.resize((w, h), Image.Resampling.LANCZOS)


def blend_join(left: Image.Image, right: Image.Image, overlap: int = 80) -> Image.Image:
    overlap = min(overlap, left.width // 4, right.width // 4)
    out_w = left.width + right.width - overlap
    out = Image.new("RGB", (out_w, left.height))
    out.paste(left, (0, 0))
    # feather right onto left
    for x in range(overlap):
        a = x / max(1, overlap - 1)
        col_l = left.crop((left.width - overlap + x, 0, left.width - overlap + x + 1, left.height))
        col_r = right.crop((x, 0, x + 1, right.height))
        blended = Image.blend(col_l, col_r, a)
        out.paste(blended, (left.width - overlap + x, 0))
    out.paste(right.crop((overlap, 0, right.width, right.height)), (left.width, 0))
    return out


def diagram_look(im: Image.Image) -> Image.Image:
    """Keep readable loco silhouette — slight polish, not a cartoon."""
    im = ImageEnhance.Color(im).enhance(1.05)
    im = ImageEnhance.Contrast(im).enhance(1.08)
    im = ImageEnhance.Sharpness(im).enhance(1.15)
    # soft vignette so seams / edges fade into UI card
    overlay = Image.new("RGBA", im.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    w, h = im.size
    d.rectangle((0, 0, w, h), outline=(0, 0, 0, 0))
    # top/bottom fade bars
    for i in range(18):
        a = int(90 * (1 - i / 18))
        d.rectangle((0, i, w, i + 1), fill=(12, 24, 36, a))
        d.rectangle((0, h - 1 - i, w, h - i), fill=(12, 24, 36, a))
    rgba = im.convert("RGBA")
    return Image.alpha_composite(rgba, overlay)


def draw_axle_guides(im: Image.Image) -> Image.Image:
    """Paint soft axle hotspots for visual clarity (UI also draws interactive ones)."""
    rgba = im.convert("RGBA")
    layer = Image.new("RGBA", rgba.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    w, h = rgba.size
    # Approximate Co-Co: bogie1 ~15-32%, tank mid, bogie2 ~68-85%
    xs = [0.14, 0.22, 0.30, 0.70, 0.78, 0.86]
    cy = int(h * 0.82)
    r = max(10, int(h * 0.055))
    for i, xf in enumerate(xs):
        cx = int(w * xf)
        d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=(30, 140, 180, 55), outline=(255, 255, 255, 180), width=2)
        # label 1..6
        label = str(i + 1)
        d.text((cx - 4, cy - 6), label, fill=(255, 255, 255, 230))
    # fuel tank hint bar
    d.rounded_rectangle(
        (int(w * 0.38), int(h * 0.62), int(w * 0.62), int(h * 0.78)),
        radius=6,
        outline=(255, 220, 120, 140),
        width=2,
    )
    return Image.alpha_composite(rgba, layer)


def main() -> None:
    parts = []
    # per-frame crop tweaks: front / mid / rear
    crops = [
        dict(top_frac=0.20, bot_frac=0.10, left_frac=0.01, right_frac=0.08),
        dict(top_frac=0.22, bot_frac=0.10, left_frac=0.04, right_frac=0.04),
        dict(top_frac=0.20, bot_frac=0.10, left_frac=0.08, right_frac=0.01),
    ]
    for path, crop in zip(SOURCES, crops):
        if not path.exists():
            raise SystemExit(f"missing {path}")
        parts.append(crop_loco(load(path), **crop))

    target_h = 720
    parts = [match_height(p, target_h) for p in parts]

    stitched = parts[0]
    for p in parts[1:]:
        stitched = blend_join(stitched, p, overlap=100)

    # Trim to long diagram aspect ~ 5.5:1 for phone width
    final_h = 280
    final_w = max(900, int(stitched.width * (final_h / stitched.height)))
    stitched = stitched.resize((final_w, final_h), Image.Resampling.LANCZOS)
    polished = diagram_look(stitched)
    guided = draw_axle_guides(polished)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    polished.save(OUT, "PNG", optimize=True)
    guided.save(OUT_UI, "PNG", optimize=True)
    print(f"als_side -> {OUT} ({OUT.stat().st_size} bytes) {polished.size}")
    print(f"als_side_ui -> {OUT_UI} ({OUT_UI.stat().st_size} bytes) {guided.size}")
    print("check_als_diagram: ok")


if __name__ == "__main__":
    main()
