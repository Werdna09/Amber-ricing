#!/usr/bin/env python3
"""Amber Theme Bank -> KDE Plasma wallpaper (one image for every palette).

Safety: validates IDs against palettes.json and restricts image names to the
10-image mapping. Does not change any wallpaper in --check or --dry-run mode.
"""
from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PALETTES_PATH = ROOT / 'shell/theme/palettes.json'
SELECTION_PATH = ROOT / 'shell/theme/selection.json'
WALLPAPERS_DIR = ROOT / 'shell/assets/wallpapers'

# The palette ID for Moss & Ember is moss-ember, while the art file is
# intentionally named moss-and-ember.png.
IMAGES = {
    'first-flame': 'first-flame.png',
    'anor-londo': 'anor-londo.png',
    'ashen-pilgrim': 'ashen-pilgrim.png',
    'moss-ember': 'moss-and-ember.png',
    'crimson-covenant': 'crimson-covenant.png',
    'dying-ember': 'dying-ember.png',
    'moonlit-cathedral': 'moonlit-cathedral.png',
    'abyss-watcher': 'abyss-watcher.png',
    'hollow-grove': 'hollow-grove.png',
    'eclipse-of-fire': 'eclipse-of-fire.png',
}


def palette_bank() -> list[dict]:
    data = json.loads(PALETTES_PATH.read_text(encoding='utf-8'))
    if not isinstance(data, list) or not all(isinstance(p, dict) for p in data):
        raise ValueError('palettes.json must contain a list of palette objects')
    ids = [p.get('id') for p in data]
    if len(ids) != 10 or set(ids) != set(IMAGES) or len(set(ids)) != len(ids):
        raise ValueError(f'Palette IDs do not match the 10 expected wallpapers: {ids!r}')
    return data


def current_id() -> str:
    try:
        data = json.loads(SELECTION_PATH.read_text(encoding='utf-8'))
        return str(data.get('selected') or 'first-flame')
    except (FileNotFoundError, ValueError, AttributeError):
        return 'first-flame'


def png_dimensions(path: Path) -> tuple[int, int]:
    with path.open('rb') as f:
        header = f.read(24)
    if (len(header) != 24 or header[:8] != b'\x89PNG\r\n\x1a\n'
            or header[12:16] != b'IHDR'):
        raise ValueError(f'Not a valid PNG header: {path}')
    width = int.from_bytes(header[16:20], 'big')
    height = int.from_bytes(header[20:24], 'big')
    if width < 800 or height < 450:
        raise ValueError(f'Image too small for desktop: {path.name} ({width}x{height})')
    return width, height


def check_all() -> None:
    palettes = palette_bank()
    for pal in palettes:
        ident = pal['id']
        path = WALLPAPERS_DIR / IMAGES[ident]
        if not path.is_file() or path.is_symlink():
            raise ValueError(f'Missing PNG wallpaper: {path}')
        width, height = png_dimensions(path)
        print(f'  OK  {ident:20} -> {path.name:26} {width}x{height}')


def main() -> int:
    parser = argparse.ArgumentParser(description='Synchronize KDE Plasma wallpaper with Amber palette')
    parser.add_argument('--palette', help='Amber palette ID; default reads selection.json')
    parser.add_argument('--check', action='store_true', help='Validate all ten images; change nothing')
    parser.add_argument('--dry-run', action='store_true', help='Show image to be applied; change nothing')
    args = parser.parse_args()

    try:
        if args.check:
            check_all()
            print('All ten wallpaper images verified. No wallpaper was changed.')
            return 0
        palette_bank()
        ident = args.palette or current_id()
        if ident not in IMAGES:
            raise ValueError(f'Unknown Amber palette: {ident!r}')
        wallpaper = WALLPAPERS_DIR / IMAGES[ident]
        if not wallpaper.is_file() or wallpaper.is_symlink():
            raise ValueError(f'Wallpaper missing: {wallpaper}')
        png_dimensions(wallpaper)
        cmd = ['plasma-apply-wallpaperimage', str(wallpaper.resolve())]
        if args.dry_run:
            print(f'Selected palette: {ident}')
            print(f'Would apply: {wallpaper.resolve()}')
            print('No wallpaper was changed.')
            return 0
        if shutil.which(cmd[0]) is None:
            raise ValueError('plasma-apply-wallpaperimage is unavailable; check KDE Plasma installation')
        result = subprocess.run(cmd, capture_output=True, text=True, check=False, timeout=20)
        if result.returncode != 0:
            message = (result.stderr or result.stdout).strip()
            raise RuntimeError(f'KDE wallpaper command exited {result.returncode}: {message}')
        print(f'Applied {ident}: {wallpaper.name}')
        return 0
    except (OSError, ValueError, KeyError, TypeError, RuntimeError, subprocess.TimeoutExpired) as e:
        print(f'Amber wallpaper: {e}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
