#!/usr/bin/env python3
"""Amber Lothric Steel: generate one Aurorae design in ten Theme Bank colors.

This is an offline, dependency-free generator. --sync switches ONLY KWin window
DECORATIONS (never the Plasma color scheme or icon theme).
"""
from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BANK = ROOT / 'shell/theme/palettes.json'
SELECTION = ROOT / 'shell/theme/selection.json'
PROJECT_OUT = ROOT / 'kwin-decoration'
USER_OUT = Path.home() / '.local/share/aurorae/themes'
PREFIX = 'AmberLothricSteel-'
REQUIRED = ('background', 'surface', 'border', 'muted', 'accent', 'text')
HEX = re.compile(r'#[0-9a-fA-F]{6}\Z')
IDS = ('first-flame','anor-londo','ashen-pilgrim','moss-ember','crimson-covenant',
       'dying-ember','moonlit-cathedral','abyss-watcher','hollow-grove','eclipse-of-fire')


def bank() -> list[dict]:
    arr = json.loads(BANK.read_text(encoding='utf-8'))
    if not isinstance(arr, list) or len(arr) != 10 or {p.get('id') for p in arr} != set(IDS):
        raise ValueError('Expected exactly ten known unique Amber palette IDs')
    for p in arr:
        if not isinstance(p.get('name'), str) or not p['name']:
            raise ValueError('Palette missing a name')
        if not isinstance(p.get('colors'), dict) or any(not HEX.fullmatch(p['colors'].get(k, '')) for k in REQUIRED):
            raise ValueError('Bad colors for ' + str(p.get('id')))
    return arr


def chosen() -> str:
    try:
        return json.loads(SELECTION.read_text(encoding='utf-8')).get('selected', 'first-flame')
    except (OSError, ValueError, AttributeError):
        return 'first-flame'


def mix(a: str, b: str, amount: float) -> str:
    aa = [int(a[i:i + 2], 16) for i in (1, 3, 5)]
    bb = [int(b[i:i + 2], 16) for i in (1, 3, 5)]
    return '#' + ''.join(f'{round(x * (1 - amount) + y * amount):02X}' for x, y in zip(aa, bb))


def rgb(a: str) -> str:
    return ','.join(str(int(a[i:i+2], 16)) for i in (1,3,5))


def rect(x: int, y: int, w: int, h: int, fill: str, extra: str = '') -> str:
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{fill}"{extra}/>'


def svg_open(w: int, h: int) -> str:
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}" shape-rendering="crispEdges">'


def frame_svg(c: dict) -> str:
    """FrameSvg nine-patch: per-state tile geometry and literal pixel borders."""
    tw, mw, edge = 18, 46, 18
    top, mid, bot = 36, 30, 12
    one = tw + mw + edge
    chunk = []
    for mode, offset in [('decoration', 0), ('decoration-inactive', one + 12)]:
        active = mode == 'decoration'
        face = c['background'] if active else mix(c['background'], c['surface'], .35)
        steel = c['border'] if active else mix(c['border'], face, .68)
        metal = mix(c['surface'], c['border'], .35 if active else .16)
        ember = c['accent'] if active else mix(c['accent'], face, .75)
        inner = mix(c['surface'], c['background'], .45)
        def tile(part: str, x: int, y: int, w: int, h: int, shapes: list[str]) -> None:
            chunk.append(f'<g id="{mode}-{part}" transform="translate({offset + x},{y})">'
                         + rect(0, 0, w, h, face if y == 0 else '#000000',
                                '' if y == 0 else ' fill-opacity="0.001"')
                         + ''.join(shapes) + '</g>')
        tile('topleft',0,0,tw,top,[
            rect(0,0,tw,top,face), rect(0,0,tw,2,steel),rect(0,0,2,top,steel),
            rect(2,2,tw-2,2,metal),rect(2,4,2,top-4,metal),
            rect(5,4,7,2,ember),rect(5,6,2,6,steel),
            rect(0,top-3,tw,1,ember),rect(2,top-2,tw-2,2,inner)])
        tile('top',tw,0,mw,top,[
            rect(0,0,mw,top,face),rect(0,0,mw,2,steel),rect(0,2,mw,2,metal),
            rect(0,top-3,mw,1,ember),rect(0,top-2,mw,2,inner)])
        tile('topright',tw+mw,0,edge,top,[
            rect(0,0,edge,top,face),rect(0,0,edge,2,steel),rect(edge-2,0,2,top,steel),
            rect(0,2,edge-2,2,metal),rect(edge-4,4,2,top-4,metal),
            rect(edge-12,4,7,2,ember),rect(edge-7,6,2,6,steel),
            rect(0,top-3,edge,1,ember),rect(0,top-2,edge-2,2,inner)])
        tile('left',0,top,tw,mid,[rect(0,0,2,mid,steel),rect(2,0,2,mid,metal),
                                rect(4,0,1,mid,inner)])
        tile('center',tw,top,mw,mid,[])  # transparent, window content remains untouched
        tile('right',tw+mw,top,edge,mid,[rect(edge-2,0,2,mid,steel),
                        rect(edge-4,0,2,mid,metal),rect(edge-5,0,1,mid,inner)])
        tile('bottomleft',0,top+mid,tw,bot,[rect(0,0,2,bot,steel),
                    rect(2,0,2,bot,metal),rect(0,bot-2,tw,2,steel),
                    rect(2,bot-4,tw-2,2,metal),rect(5,bot-8,7,2,ember)])
        tile('bottom',tw,top+mid,mw,bot,[rect(0,bot-2,mw,2,steel),
                    rect(0,bot-4,mw,2,metal)])
        tile('bottomright',tw+mw,top+mid,edge,bot,[
                    rect(edge-2,0,2,bot,steel),rect(edge-4,0,2,bot,metal),
                    rect(0,bot-2,edge,2,steel),rect(0,bot-4,edge-2,2,metal),
                    rect(edge-12,bot-8,7,2,ember)])
    # AMBER_MAXIMIZED_OPAQUE_CENTER_V1
    # Aurorae uses the center tile as the maximized titlebar background.
    # Keep the normal center transparent for unmaximized window content.
    for maximized_id, offset, face in (
        ("decoration-maximized-center", 0, c['background']),
        ("decoration-maximized-inactive-center", one + 12,
         mix(c['background'], c['surface'], .35)),
    ):
        chunk.append(
            f'<g id="{maximized_id}" transform="translate({offset + tw},{top})">'
            + rect(0, 0, mw, mid, face) + '</g>'
        )
    return svg_open(2*one+12,top+mid+bot)+'\n'+ '\n'.join(chunk) + '\n</svg>\n'


def glyph(name: str, color: str) -> str:
    """All symbols are orthogonal-pixel geometry; no font glyphs/antialiasing."""
    g=[]
    if name == 'close':
        for x in range(5):
            g += [rect(8+2*x,8+2*x,2,2,color),rect(16-2*x,8+2*x,2,2,color)]
    elif name == 'minimize': g=[rect(7,16,14,2,color),rect(9,14,10,2,color)]
    elif name == 'maximize': g=[rect(7,7,14,2,color),rect(7,9,2,12,color),rect(19,9,2,12,color),rect(9,19,10,2,color)]
    elif name == 'restore':
        g=[rect(10,6,12,2,color),rect(20,8,2,10,color),rect(7,10,12,2,color),
           rect(7,12,2,10,color),rect(17,12,2,10,color),rect(9,20,8,2,color)]
    elif name == 'alldesktops': g=[rect(7,7,14,14,color), rect(9,9,10,10,'#121214'),rect(12,12,4,4,color)]
    elif name == 'keepabove': g=[rect(13,7,2,13,color),rect(9,11,4,2,color),rect(15,11,4,2,color),rect(10,9,2,2,color),rect(16,9,2,2,color)]
    elif name == 'keepbelow': g=[rect(13,8,2,13,color),rect(9,15,4,2,color),rect(15,15,4,2,color),rect(10,17,2,2,color),rect(16,17,2,2,color)]
    elif name == 'shade': g=[rect(7,9,14,2,color),rect(10,14,8,2,color),rect(12,16,4,2,color)]
    elif name == 'help':
        g=[rect(9,8,10,2,color),rect(17,10,2,5,color),rect(13,14,5,2,color),
           rect(13,16,2,2,color),rect(13,20,2,2,color)]
    elif name == 'appmenu': g=[rect(7,8,14,2,color),rect(7,13,14,2,color),rect(7,18,14,2,color)]
    return ''.join(g)


def button_svg(name: str, c: dict) -> str:
    states=['active','inactive','hover','hover-inactive','pressed','pressed-inactive','deactivated']
    groups=[]
    for i, state in enumerate(states):
        is_hover='hover' in state
        is_press='pressed' in state
        inactive='inactive' in state
        base=mix(c['background'],c['surface'],.5)
        if is_hover: base=mix(c['surface'],c['accent'], .33)
        if is_press: base=mix(c['accent'],c['background'], .60)
        foreground= c['text'] if not inactive else mix(c['muted'],c['background'],.3)
        if is_hover: foreground = c['accent']
        if name == 'close' and is_hover: foreground=mix('#B45B4C',c['accent'],.3)
        if 'deactivated' in state: foreground=c['muted']
        edge=c['border'] if not is_hover else c['accent']
        shapes=[rect(0,0,28,28,'#000000',' fill-opacity="0.001"'),
                rect(3,4,22,21,base),rect(3,4,22,1,edge),rect(3,4,1,21,edge),
                rect(24,4,1,21,edge),rect(3,24,22,1,edge),
                rect(6,7,2,2,mix(edge,base,.35)),rect(20,20,2,2,mix(edge,base,.35)),
                glyph(name,foreground)]
        groups.append(f'<g id="{state}-center" transform="translate({i*32},0)">'+''.join(shapes)+'</g>')
    return svg_open(32*len(states),28)+'\n'+'\n'.join(groups)+'\n</svg>\n'


def config_rc(c: dict) -> str:
    return f'''[General]
TitleAlignment=Left
TitleVerticalAlignment=Center
Animation=0
ActiveTextColor={rgb(c['text'])}
InactiveTextColor={rgb(mix(c['muted'],c['background'],.20))}
UseTextShadow=false
HaloActive=false
HaloInactive=false
Shadow=false
LeftButtons=M
RightButtons=IAX

[Layout]
BorderLeft=4
BorderRight=4
BorderBottom=4
BorderTop=0
TitleHeight=27
TitleEdgeTop=3
TitleEdgeBottom=3
TitleEdgeLeft=8
TitleEdgeRight=8
TitleEdgeTopMaximized=0
TitleEdgeBottomMaximized=1
TitleEdgeLeftMaximized=0
TitleEdgeRightMaximized=0
TitleBorderLeft=9
TitleBorderRight=7
ButtonWidth=28
ButtonHeight=28
ButtonSpacing=3
ButtonMarginTop=1
ExplicitButtonSpacer=8
PaddingTop=0
PaddingBottom=0
PaddingLeft=0
PaddingRight=0
'''


def build_one(p: dict, folder: Path) -> None:
    ident=PREFIX+p['id']
    folder.mkdir(parents=True,exist_ok=True)
    meta=f'''[Desktop Entry]
Name=Amber Lothric Steel — {p['name']}
Comment=Amber Dark Souls inspired pixel-forged window borders, generated from Theme Bank
X-KDE-PluginInfo-Name={ident}
X-KDE-PluginInfo-Version=1.0
X-KDE-PluginInfo-Author=Amber Project
X-KDE-PluginInfo-Website=https://github.com/Werdna09/Amber-ricing
X-KDE-PluginInfo-License=CC0-1.0
Type=Application
X-KDE-PluginInfo-EnabledByDefault=true
'''
    files={'metadata.desktop':meta,ident+'rc':config_rc(p['colors']),
           'decoration.svg':frame_svg(p['colors'])}
    for btn in ('close','minimize','maximize','restore','alldesktops','keepabove','keepbelow','shade','help','appmenu'):
        files[btn+'.svg']=button_svg(btn,p['colors'])
    for name,contents in files.items():
        if name.endswith('.svg'): ET.fromstring(contents)
        (folder/name).write_text(contents,encoding='utf-8')


def generate(install: bool) -> None:
    for pal in bank():
        p=PROJECT_OUT/(PREFIX+pal['id'])
        build_one(pal,p)
        if install:
            target=USER_OUT/p.name
            if target.is_symlink(): raise ValueError('Refusing to overwrite symlink '+str(target))
            if target.exists(): shutil.rmtree(target)
            shutil.copytree(p,target)
    print('Generated 10 Aurorae themes at',PROJECT_OUT)
    if install: print('Installed themes at',USER_OUT)


def run(cmd:list[str], *, required:bool = True) -> bool:
    try:
        result=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,timeout=12,check=False)
    except (OSError,subprocess.TimeoutExpired) as exc:
        if required: raise RuntimeError(str(exc)) from exc
        print('WARNING:',exc,file=sys.stderr)
        return False
    if result.returncode:
        if required: raise RuntimeError(f'{cmd[0]} failed: {(result.stderr or result.stdout).strip()}')
        print('WARNING:',(result.stderr or result.stdout).strip(),file=sys.stderr)
        return False
    return True


def refresh_kwin() -> None:
    for utility,cmd in [('qdbus6',['qdbus6','org.kde.KWin','/KWin','reconfigure']),
                       ('dbus-send',['dbus-send','--session','--dest=org.kde.KWin','--type=method_call','/KWin','org.kde.KWin.reconfigure'])]:
        if shutil.which(utility) and run(cmd,required=False): return
    print('WARNING: KWin D-Bus reconfigure unavailable; use System Settings > Window Decorations or log out/in.',file=sys.stderr)


def switch(ident:str) -> None:
    if ident not in IDS: raise ValueError('Unknown palette ID: '+ident)
    name=PREFIX+ident
    if not (USER_OUT/name/'metadata.desktop').is_file():
        raise ValueError('Aurorae theme not installed, use --install first: '+name)
    if not shutil.which('kwriteconfig6'):
        raise RuntimeError('Missing kwriteconfig6 (KDE Plasma 6 needed)')
    args=['kwriteconfig6','--file','kwinrc','--group','org.kde.kdecoration2']
    run(args+['--key','library','org.kde.kwin.aurorae'])
    run(args+['--key','theme','__aurorae__svg__'+name])
    refresh_kwin()
    print(f'KWin decoration selected: {name}')


def main() -> int:
    a=argparse.ArgumentParser(description='Amber Lothric Steel dynamic Aurorae window decoration')
    group=a.add_mutually_exclusive_group(required=True)
    group.add_argument('--check',action='store_true')
    group.add_argument('--build',action='store_true')
    group.add_argument('--install',action='store_true')
    group.add_argument('--sync',action='store_true')
    a.add_argument('--palette',choices=IDS)
    args=a.parse_args()
    try:
        pals=bank()
        if args.check:
            print('Status: ready; valid palettes:',len(pals))
            print('Project:',ROOT)
            print('Active:',args.palette or chosen())
            print('Generate to:',PROJECT_OUT)
            print('Install to:',USER_OUT)
        elif args.build: generate(False)
        elif args.install: generate(True)
        elif args.sync: switch(args.palette or chosen())
        return 0
    except (OSError,ValueError,KeyError,TypeError,RuntimeError,ET.ParseError) as exc:
        print('Lothric Steel:',exc,file=sys.stderr)
        return 1


if __name__=='__main__':
    raise SystemExit(main())
