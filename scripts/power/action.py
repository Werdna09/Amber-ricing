#!/usr/bin/env python3
"""Run an explicitly confirmed Amber power action. No shell interpolated input."""
from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys

VALID = ('lock', 'suspend', 'logout', 'reboot', 'shutdown')


def kde_bus() -> str | None:
    return shutil.which('qdbus6') or shutil.which('qdbus')


def commands(action: str) -> list[list[str]]:
    bus = kde_bus()
    kde = {
        'lock': ['org.kde.screensaver', '/ScreenSaver', 'Lock'],
        'logout': ['org.kde.Shutdown', '/Shutdown', 'org.kde.Shutdown.logout'],
        'reboot': ['org.kde.Shutdown', '/Shutdown', 'org.kde.Shutdown.logoutAndReboot'],
        'shutdown': ['org.kde.Shutdown', '/Shutdown', 'org.kde.Shutdown.logoutAndShutdown'],
    }
    if action == 'lock':
        out = [[bus, *kde['lock']]] if bus else []
        return out + [['loginctl', 'lock-session']]
    if action == 'suspend':
        # KDE/PowerDevil's Sleep shortcut integrates screen-lock policy.
        out = [[bus, 'org.kde.kglobalaccel', '/component/org_kde_powerdevil',
                'invokeShortcut', 'Sleep']] if bus else []
        return out + [['systemctl', 'suspend']]
    if action == 'logout':
        if bus:
            return [[bus, *kde['logout']]]
        session = os.environ.get('XDG_SESSION_ID', '')
        return [['loginctl', 'terminate-session', session]] if session else []
    if action in ('reboot', 'shutdown'):
        out = [[bus, *kde[action]]] if bus else []
        return out + [['systemctl', 'reboot' if action == 'reboot' else 'poweroff']]
    raise ValueError(f'Unknown action: {action}')


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--action', choices=VALID, required=True)
    parser.add_argument('--check', action='store_true', help='Show candidate commands; do not run anything')
    args = parser.parse_args()
    candidates = commands(args.action)
    if args.check:
        print(f'Action: {args.action}')
        for row in candidates:
            print('  ' + ' '.join(row))
        return 0 if candidates else 1
    if not candidates:
        print(f'Amber Power: no safe command available for {args.action}', file=sys.stderr)
        return 2
    for cmd in candidates:
        if not shutil.which(cmd[0]):
            continue
        try:
            p = subprocess.run(cmd, capture_output=True, text=True, timeout=12, check=False)
        except (OSError, subprocess.TimeoutExpired) as exc:
            print(f'Amber Power: {exc}', file=sys.stderr)
            continue
        if p.returncode == 0:
            return 0
        print(f'Amber Power: {cmd[0]} returned {p.returncode}: {p.stderr.strip()}', file=sys.stderr)
    return 1


if __name__ == '__main__':
    raise SystemExit(main())
