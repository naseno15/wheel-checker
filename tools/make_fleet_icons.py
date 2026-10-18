"""Crop loco photos into circular fleet icons for the picker UI."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageEnhance, ImageFilter, ImageOps
from pillow_heif import register_heif_opener

register_heif_opener()

OUT_DIR = Path(__file__).resolve().parents[1] / "assets" / "fleet"
SIZE = 256

SOURCES = {
    "GEK": (Path(r"C:\Users\Naito\Downloads\IMG_1175.HEIC"), 0.40),
    "ALS": (Path(r"C:\Users\Naito\Downloads\IMG_4211.HEIC"), 0.40),
    "HID": (Path(r"C:\Users\Naito\Downloads\IMG_4703.HEIC"), 0.40),
    "QSY": (Path(r"C:\Users\Naito\Downloads\IMG_9310.HEIC"), 0.40),
    "CSR": (Path(r"C:\Users\Naito\Downloads\20220503_085818.jpg"), 0.48),
    "GEA": (Path(r"C:\Users\Naito\Downloads\20220328_062554.jpg"), 0.48),
}


def square_crop(im: Image.Image, y_bias: float) -> Image.Image:
    w, h = im.size
    side = min(w, h)
    left = (w - side) // 2
    cy = int(h * y_bias)
    top = max(0, min(h - side, cy - side // 2))
    return im.crop((left, top, left + side, top + side))


def circular_icon(im: Image.Image, size: int = SIZE) -> Image.Image:
    im = im.convert("RGB")
    im = ImageEnhance.Color(im).enhance(1.08)
    im = ImageEnhance.Contrast(im).enhance(1.06)
    im = im.resize((size, size), Image.Resampling.LANCZOS)

    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    inset = 2
    draw.ellipse((inset, inset, size - 1 - inset, size - 1 - inset), fill=255)
    mask = mask.filter(ImageFilter.GaussianBlur(0.6))

    rgba = im.convert("RGBA")
    rgba.putalpha(mask)

    ring = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    rd = ImageDraw.Draw(ring)
    rd.ellipse((1, 1, size - 2, size - 2), outline=(255, 255, 255, 220), width=5)
    rd.ellipse((4, 4, size - 5, size - 5), outline=(20, 40, 60, 100), width=2)
    return Image.alpha_composite(rgba, ring)


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for code, (path, bias) in SOURCES.items():
        if not path.exists():
            raise SystemExit(f"missing source: {path}")
        src = ImageOps.exif_transpose(Image.open(path))
        icon = circular_icon(square_crop(src, bias))
        dest = OUT_DIR / f"{code.lower()}.png"
        icon.save(dest, "PNG", optimize=True)
        print(f"{code} -> {dest} ({dest.stat().st_size} bytes)")
    print("check_fleet_icons: ok")


if __name__ == "__main__":
    main()
