#!/usr/bin/env python3
"""Read Amber Theme Bank for fish prompt. Outputs fish set_color-compatible RRGGBB."""
from __future__ import annotations
import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
THEMES = ROOT / 'shell/theme'
FALLBACK = 'first-flame'
HEX = re.compile(r'#[0-9a-fA-F]{6}\Z')
KEYS = ('background', 'surface', 'border', 'muted', 'accent', 'text')


def get_theme():
    bank = json.loads((THEMES / 'palettes.json').read_text(encoding='utf8'))
    if not isinstance(bank, list) or not bank:
        raise ValueError('Theme Bank is empty')
    try:
        state = json.loads((THEMES / 'selection.json').read_text(encoding='utf8'))
        selected = state.get('selected', FALLBACK)
    except (OSError, ValueError, AttributeError):
        selected = FALLBACK
    theme = next((v for v in bank if v.get('id') == selected), None)
    theme = theme or next((v for v in bank if v.get('id') == FALLBACK), bank[0])
    for key in KEYS:
        if not HEX.fullmatch(theme['colors'][key]):
            raise ValueError(f'Invalid {key} color')
    return theme


def blend(fg, bg, f):
    a = [int(fg[i:i+2], 16) for i in (1,3,5)]
    b = [int(bg[i:i+2], 16) for i in (1,3,5)]
    return ''.join(f'{round(x*f+y*(1-f)):02X}' for x,y in zip(a,b))


def palette_lines(theme):
    c = theme['colors']
    # Gray-ish ink on dark surface for the special Git segment.
    git_ink = blend(c['text'], c['background'], .67)
    git_frame = blend(c['border'], c['text'], .42)
    return [c[k][1:].upper() for k in KEYS] + [git_ink, git_frame]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    theme = get_theme()
    if args.check:
        print(f"Palette: {theme['name']} ({theme['id']})")
        print('Colors:', ', '.join(f'{k}={v}' for k,v in zip(KEYS, palette_lines(theme)[:6])))
    else:
        print('\n'.join(palette_lines(theme)))

if __name__ == '__main__':
    main()
