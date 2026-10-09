#!/usr/bin/env python3
"""Amber Rofi: palette-synchronised application, command and KWin window picker.

Requires rofi 2.0, Python 3. No changes to KDE or ~/.config/rofi.
"""
from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
THEME_DIR = ROOT / "shell" / "theme"
TEMPLATE = ROOT / "config" / "rofi" / "amber.rasi.in"
FALLBACK = "first-flame"
HEX = re.compile(r"#[0-9A-Fa-f]{6}\Z")


def palette() -> dict:
    bank = json.loads((THEME_DIR / "palettes.json").read_text(encoding="utf-8"))
    if not isinstance(bank, list) or not bank:
        raise ValueError("palettes.json neobsahuje žádné palety")
    selection_path = THEME_DIR / "selection.json"
    try:
        selection = json.loads(selection_path.read_text(encoding="utf-8"))
        chosen = selection.get("selected", FALLBACK)
    except (FileNotFoundError, OSError, ValueError, AttributeError):
        chosen = FALLBACK
    selected = next((p for p in bank if p.get("id") == chosen), None)
    return selected or next((p for p in bank if p.get("id") == FALLBACK), bank[0])


def theme_path() -> tuple[Path, dict]:
    current = palette()
    colors = current["colors"]
    content = TEMPLATE.read_text(encoding="utf-8")
    for key in ("background", "surface", "border", "muted", "accent", "text"):
        color = colors.get(key)
        if not isinstance(color, str) or not HEX.fullmatch(color):
            raise ValueError(f"Neplatná barva {key}: {color!r}")
        content = content.replace("{{" + key + "}}", color)
    if re.search(r"\{\{[^}]+\}\}", content):
        raise ValueError("Neznámé proměnné ve vzhledu Rofi")
    base = Path(os.environ.get("XDG_RUNTIME_DIR", tempfile.gettempdir())) / f"amber-rofi-{os.getuid()}"
    base.mkdir(mode=0o700, parents=True, exist_ok=True)
    # Keep this private: no accidental substitutions via ~/.config/rofi.
    destination = base / "theme.rasi"
    destination.write_text(content, encoding="utf-8")
    destination.chmod(0o600)
    return destination, current


def rofi_base(theme: Path) -> list[str]:
    # The explicit -theme points to an independently generated Amber theme.
    return ["rofi", "-no-config", "-theme", str(theme)]


def query_kwin_windows() -> list[dict]:
    if not shutil.which("kdotool"):
        raise RuntimeError("kdotool není nainstalován")
    query = (
        "var result=[];"
        "var wins=workspace.stackingOrder;"
        "for(var i=0;i<wins.length;i++){"
        " var w=wins[i];"
        " if(w.deleted||w.skipTaskbar||w.specialWindow||(!w.normalWindow&&!w.dialog))continue;"
        " result.push({id:String(w.internalId), caption:String(w.caption||''),"
        " app:String(w.resourceClass||w.desktopFileName||''),active:Boolean(w.active)});"
        "}"
        "output_result(JSON.stringify(result));"
    )
    result = subprocess.run(["kdotool", "kwinscript", "--inline", query],
                            text=True, capture_output=True, check=True, timeout=12)
    windows = json.loads(result.stdout.strip())
    if not isinstance(windows, list):
        raise ValueError("KWin nevrátil seznam oken")
    return [w for w in windows if isinstance(w, dict) and w.get("id")]


def clean(value: object) -> str:
    return re.sub(r"[\x00-\x1f\x7f]", " ", str(value or "")).strip()


def window_picker(theme: Path) -> int:
    windows = query_kwin_windows()
    if not windows:
        subprocess.run(rofi_base(theme) + ["-e", "Amber: žádná otevřená okna"])
        return 0
    options = []
    for w in windows:
        active = "◆" if w.get("active") else "·"
        app = clean(w.get("app")) or "Aplikace"
        title = clean(w.get("caption")) or "Bez názvu"
        options.append(f"{active} {app}  —  {title}")
    result = subprocess.run(
        rofi_base(theme) + ["-dmenu", "-no-custom", "-format", "i", "-p", "OKNA", "-mesg", "Enter – aktivovat vybrané okno"],
        input="\n".join(options) + "\n", text=True, capture_output=True,
    )
    if result.returncode == 1:
        return 0  # Esc
    if result.returncode != 0:
        print(result.stderr, file=sys.stderr)
        return result.returncode
    try:
        index = int(result.stdout.strip())
        target = windows[index]["id"]
    except (ValueError, IndexError, KeyError):
        return 1
    subprocess.run(["kdotool", "windowactivate", str(target)], check=True)
    return 0


def main() -> int:
    arg = argparse.ArgumentParser(description="Rofi for Amber desktop rice")
    arg.add_argument("mode", choices=("apps", "run", "windows", "check"), nargs="?", default="apps")
    args = arg.parse_args()
    try:
        theme, current = theme_path()
        if args.mode == "check":
            print(f"Amber palette: {current['name']} ({current['id']})")
            print(f"Rofi theme: {theme}")
            print(f"Rofi binary: {shutil.which('rofi') or 'NENALEZENO'}")
            print(f"kdotool binary: {shutil.which('kdotool') or 'NENALEZENO'}")
            if shutil.which("rofi"):
                p = subprocess.run(["rofi", "-rasi-validate", str(theme)], text=True, capture_output=True)
                print(f"Rasi validator: {'OK' if p.returncode == 0 else 'CHYBA'}")
                if p.returncode != 0:
                    print(p.stderr or p.stdout, file=sys.stderr)
                    return p.returncode
            return 0
        if not shutil.which("rofi"):
            raise RuntimeError("Rofi není dostupné v PATH")
        if args.mode == "windows":
            return window_picker(theme)
        mode = "drun" if args.mode == "apps" else "run"
        return subprocess.call(rofi_base(theme) + ["-modes", "drun,run", "-show", mode])
    except (OSError, ValueError, RuntimeError, subprocess.CalledProcessError, subprocess.TimeoutExpired) as exc:
        print(f"Amber Rofi: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
