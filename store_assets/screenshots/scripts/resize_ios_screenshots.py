#!/usr/bin/env python3
"""Resize 6.5inch iOS screenshots for 6.1inch and iPad 13-inch store folders."""

from __future__ import annotations

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC_DIR = ROOT / "ios" / "6.5inch"
IPHONE_DIR = ROOT / "ios" / "6.1inch"
IPAD_DIR = ROOT / "ios" / "ipad-13inch"

IPHONE_SIZE = (1170, 2532)
IPAD_SIZE = (2048, 2732)
# Dark background from HomePalette-style screenshots
IPAD_BG = (15, 15, 20)

# 6.5inch capture names -> 6.1inch README names (App Store / existing layout)
DEST_NAMES = {
    "01_mode_selection.png": "01_mode_selection.png",
    "02_dice.png": "02_dice.png",
    "03_session_setting.png": "04_session_setup.png",
    "04_value_card.png": "05_value_card.png",
    "05_group_discussion.png": "05_group_discussion.png",
    "06_play_history.png": "06_play_history.png",
}

# Legacy files in 6.1inch replaced by the mapping above
LEGACY_61_FILES = {
    "03_theme_settings.png",
    "04_session_setup.png",
    "05_value_card.png",
}


def resize_iphone(img: Image.Image) -> Image.Image:
    if img.size == IPHONE_SIZE:
        return img.copy()
    return img.resize(IPHONE_SIZE, Image.Resampling.LANCZOS)


def resize_ipad(img: Image.Image) -> Image.Image:
    target_w, target_h = IPAD_SIZE
    src_w, src_h = img.size
    scale = min(target_w / src_w, target_h / src_h)
    new_w = round(src_w * scale)
    new_h = round(src_h * scale)
    resized = img.resize((new_w, new_h), Image.Resampling.LANCZOS)
    canvas = Image.new("RGB", IPAD_SIZE, IPAD_BG)
    x = (target_w - new_w) // 2
    y = (target_h - new_h) // 2
    canvas.paste(resized, (x, y))
    return canvas


def process_lang(lang: str) -> None:
    src_lang = SRC_DIR / lang
    for src_name, dest_name in DEST_NAMES.items():
        src_path = src_lang / src_name
        if not src_path.exists():
            raise FileNotFoundError(src_path)

        img = Image.open(src_path).convert("RGB")

        phone_out = IPHONE_DIR / lang / dest_name
        phone_out.parent.mkdir(parents=True, exist_ok=True)
        resize_iphone(img).save(phone_out, format="PNG", optimize=True)

        ipad_out = IPAD_DIR / lang / dest_name
        ipad_out.parent.mkdir(parents=True, exist_ok=True)
        resize_ipad(img).save(ipad_out, format="PNG", optimize=True)

        print(f"{lang}: {src_name} -> {dest_name} ({img.size[0]}x{img.size[1]})")

    # Remove obsolete 6.1inch files after rename mapping
    for legacy in LEGACY_61_FILES:
        path = IPHONE_DIR / lang / legacy
        if path.exists() and legacy not in DEST_NAMES.values():
            path.unlink()
            print(f"{lang}: removed legacy {legacy}")


def main() -> None:
    for lang in ("en", "ja"):
        process_lang(lang)
    print("Done.")


if __name__ == "__main__":
    main()
