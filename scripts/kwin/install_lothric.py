#!/usr/bin/env python3
"""Safely install, activate or restore the Amber Lothric Steel KDE decoration.

--check  : no changes
--apply  : snapshot KWin keys and QML, install script and Aurorae variants,
           wire up Theme Bank, activate currently chosen palette
--restore: restore previous KWin decoration and remove ONLY our QML hook;
           leave project-generated files in Git working tree for inspection.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

PACKAGE = Path(__file__).resolve().parent
DEFAULT_ROOT = (Path(__file__).resolve().parents[2] if
                PACKAGE.name == 'kwin' and PACKAGE.parent.name == 'scripts' else
                Path.home() / 'Rice/amber')
HOME = Path.home()
STATE = HOME / '.local/state/amber-lothric-steel-v1'
STATE_FILE = STATE / 'install-state.json'
QML_REL = 'shell/theme/ThemeManager.qml'
SYNC_REL = 'scripts/kwin/sync_decoration.py'
INSTALL_REL = 'scripts/kwin/install_lothric.py'
HOOK_BEGIN = '        // AMBER_LOTHRIC_STEEL_V1\n'
HOOK_CMD = ('        Quickshell.execDetached(["python3", Quickshell.shellDir + '
            '"/../scripts/kwin/sync_decoration.py", "--palette", selectedId])\n')
HOOK = HOOK_BEGIN + HOOK_CMD
WIN_GROUP = ['--file','kwinrc','--group','org.kde.kdecoration2']


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def command(cmd: list[str], *, require: bool = True) -> str:
    try:
        p=subprocess.run(cmd,text=True,capture_output=True,timeout=20)
    except (OSError,subprocess.TimeoutExpired) as exc:
        if require: raise RuntimeError(str(exc)) from exc
        return ''
    if p.returncode:
        if require: raise RuntimeError(f'{cmd[0]}: {(p.stderr or p.stdout).strip()}')
        return ''
    return p.stdout.strip()


def kread(key: str) -> str | None:
    if not shutil.which('kreadconfig6'): raise RuntimeError('Missing kreadconfig6')
    value=command(['kreadconfig6',*WIN_GROUP,'--key',key],require=False)
    return value or None


def kwrite(key: str, value: str | None) -> None:
    if not shutil.which('kwriteconfig6'): raise RuntimeError('Missing kwriteconfig6')
    args=['kwriteconfig6',*WIN_GROUP,'--key',key]
    command(args+['--delete'] if value is None else args+[value])


def refresh() -> None:
    if shutil.which('qdbus6'):
        if command(['qdbus6','org.kde.KWin','/KWin','reconfigure'],require=False) == '':
            # qdbus often prints no stdout even on success; don't make it an error
            pass
        return
    if shutil.which('dbus-send'):
        command(['dbus-send','--session','--dest=org.kde.KWin','--type=method_call',
                 '/KWin','org.kde.KWin.reconfigure'],require=False)
        return
    print('WARNING: KWin will need Window Decorations settings or a new login to reload.',file=sys.stderr)


def check(root: Path) -> None:
    qml=root/QML_REL
    pal=root/'shell/theme/palettes.json'
    if not qml.is_file() or not pal.is_file():
        raise ValueError(f'Amber project incomplete: {root}')
    contents=qml.read_text('utf-8')
    if contents.count('onSelectedIdChanged: {') != 1:
        raise ValueError('ThemeManager.qml changed; onSelectedIdChanged anchor not unique')
    from_palette=json.loads(pal.read_text('utf-8'))
    if len(from_palette) != 10:
        raise ValueError('Expected 10 Amber palettes')
    if HOOK_BEGIN.strip() in contents and not STATE_FILE.exists():
        raise ValueError('QML already has hook but no restore state; refusing duplicate')
    script_source=PACKAGE/'sync_decoration.py'
    if not script_source.is_file():
        script_source=root/SYNC_REL
    if not script_source.is_file(): raise ValueError('Missing sync_decoration.py')
    # Verify actual generator and palette schema in a nonmutating invocation.
    # When the script is still in Downloads, it can't derive the project path;
    # check the bank locally here and validate the script using --check only
    # after it's in its final repository location.
    for palette in from_palette:
        for k in ('background','surface','border','muted','accent','text'):
            if not re.fullmatch('#[0-9a-fA-F]{6}',palette.get('colors',{}).get(k,'')):
                raise ValueError('Bad palette color '+str(palette.get('id'))+'/'+k)
    print('Status:', 'already installed' if STATE_FILE.is_file() else 'ready')
    print('Project:',root)
    print('Palettes:',len(from_palette))
    print('Aurorae output:',root/'kwin-decoration')
    print('Installed variants:',HOME/'.local/share/aurorae/themes')
    print('Current decoration:',kread('library'),kread('theme'))
    print('ThemeManager hook:', 'present' if HOOK_BEGIN.strip() in contents else 'not yet installed')
    print('Backup state:',STATE)


def apply(root: Path) -> None:
    if STATE_FILE.exists(): raise ValueError('Already applied. Use --restore before reinstalling.')
    check(root)
    for name in ('kreadconfig6','kwriteconfig6'):
        if not shutil.which(name):raise ValueError('Missing '+name+'; cannot activate KDE decoration')
    source = PACKAGE / 'sync_decoration.py'
    if not source.is_file():
        source = root / SYNC_REL
    if not source.is_file(): raise ValueError('Missing generator script')
    qml=root/QML_REL
    before=qml.read_bytes()
    if HOOK_BEGIN.encode() in before:raise ValueError('Hook already present')
    sync_dest=root/SYNC_REL
    install_dest=root/INSTALL_REL
    if sync_dest.exists() and sync_dest.read_bytes()!=source.read_bytes():
        raise ValueError('Existing different scripts/kwin/sync_decoration.py; refusing overwrite')
    if install_dest.exists() and install_dest.read_bytes()!=Path(__file__).read_bytes():
        raise ValueError('Existing different scripts/kwin/install_lothric.py; refusing overwrite')
    restoredirs=HOME/'.local/share/aurorae/themes'
    if restoredirs.is_symlink(): raise ValueError('Aurorae themes folder is a symlink')
    ids=[p['id'] for p in json.loads((root/'shell/theme/palettes.json').read_text('utf-8'))]
    for ident in ids:
        dest=restoredirs/('AmberLothricSteel-'+ident)
        if dest.exists() or dest.is_symlink():
            raise ValueError('Already present: '+str(dest)+'; refusing overwrite without backup')
    snapshot={
        'project':str(root.resolve()),
        'previous':{'library':kread('library'),'theme':kread('theme')},
        'qml_sha_before':digest(before),
        'script_existed':sync_dest.exists(),
        'installer_existed':install_dest.exists(),
        'ids':ids,
    }
    STATE.mkdir(parents=True,exist_ok=False)
    (STATE/'ThemeManager.qml.before').write_bytes(before)
    try:
        sync_dest.parent.mkdir(parents=True,exist_ok=True)
        if not sync_dest.exists(): shutil.copyfile(source,sync_dest)
        if not install_dest.exists(): shutil.copyfile(Path(__file__),install_dest)
        # All SVGs & button states generated and parsed before attempting KWin switch.
        command([sys.executable,str(sync_dest),'--check'])
        command([sys.executable,str(sync_dest),'--install'])
        raw=before.decode('utf-8')
        patched=raw.replace('onSelectedIdChanged: {','onSelectedIdChanged: {\n'+HOOK,1)
        qml.write_text(patched,encoding='utf-8')
        snapshot['qml_sha_after']=digest(qml.read_bytes())
        (STATE_FILE).write_text(json.dumps(snapshot,indent=2),encoding='utf-8')
        command([sys.executable,str(sync_dest),'--sync'])
        print('Status: installed')
        print('KWin theme installed with all ten Amber palettes.')
        print('Restart Quickshell once to load the new Theme Bank hook.')
        print('Restore: python3 '+str(install_dest)+' --restore')
    except Exception:
        qml.write_bytes(before)
        for k,v in snapshot['previous'].items():
            try: kwrite(k,v)
            except Exception: pass
        if not snapshot['script_existed']:sync_dest.unlink(missing_ok=True)
        if not snapshot['installer_existed']:install_dest.unlink(missing_ok=True)
        if STATE_FILE.is_file():STATE_FILE.unlink()
        shutil.rmtree(STATE,ignore_errors=True)
        raise


def restore(root: Path) -> None:
    if not STATE_FILE.is_file():raise ValueError('No Lothric Steel install state to restore')
    state=json.loads(STATE_FILE.read_text('utf-8'))
    if Path(state['project']).resolve()!=root.resolve():
        raise ValueError('Restore belongs to a different Amber project: '+state['project'])
    qml=root/QML_REL
    live=qml.read_bytes()
    if digest(live)==state['qml_sha_after']:
        qml.write_bytes((STATE/'ThemeManager.qml.before').read_bytes())
    else:
        text=live.decode('utf-8')
        if HOOK not in text:
            raise ValueError('QML hook changed; cannot safely remove it automatically')
        qml.write_text(text.replace(HOOK,'',1),encoding='utf-8')
        print('ThemeManager has newer changes: only our hook was removed.')
    for key,value in state['previous'].items(): kwrite(key,value)
    refresh()
    STATE_FILE.unlink()
    print('Status: original KWin decoration restored; Theme Bank hook removed.')
    print('Generated decorations remain in project for Git review. No other KDE settings touched.')


def main() -> int:
    parser=argparse.ArgumentParser()
    actions=parser.add_mutually_exclusive_group(required=True)
    actions.add_argument('--check',action='store_true')
    actions.add_argument('--apply',action='store_true')
    actions.add_argument('--restore',action='store_true')
    parser.add_argument('--project',type=Path,default=DEFAULT_ROOT)
    args=parser.parse_args()
    try:
        if args.restore:restore(args.project)
        elif args.apply:apply(args.project)
        else:check(args.project)
        return 0
    except (OSError,ValueError,KeyError,RuntimeError,TypeError,UnicodeError,json.JSONDecodeError) as exc:
        print('Lothric Steel install:',str(exc),file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
