# 🔥 Amber

**A Dark Souls–inspired, pixel-art desktop for KDE Plasma 6 and Wayland.**

Amber is a personal desktop customization project built on **CachyOS, KWin, and Quickshell**. It combines a compact fantasy-inspired interface with a practical everyday desktop: a custom top panel, dock, launcher, status popups, icon theme, window decorations, and ten coordinated color palettes.

> **Project status:** Running as the author's daily desktop. The repository contains the working configuration and assets, **not a universal one-command installer**. A fresh clone requires the manual setup described below.

## Features

| Component | What is included |
| --- | --- |
| **Quickshell UI** | Top panel with workspaces, clock/date, media, system status and interactive popups; bottom dock, launcher and window picker |
| **Theme Bank** | 10 selectable palettes in two atmospheric groups, all dark |
| **Palette synchronization** | Coordinated Quickshell colors, Plasma application colors, wallpapers, Lothric Steel decorations and Alacritty colors |
| **Lothric Steel** | Custom pixel-forged Aurorae/KWin window borders and titlebar buttons, with a variant for each palette |
| **Amber Icons** | 73 original source icons, with KDE application, folder, device and file-type mappings in 7 sizes (16–128 px) |
| **Terminal and launcher** | Alacritty configuration, palette-aware Fish prompt and Rofi theme/launcher |
| **Editor configuration** | Neovim configuration under `config/nvim/` |

The Quickshell interface also includes Wi-Fi, Bluetooth, audio, updates, battery, calendar and media controls. Some application windows draw their own titlebars; those **client-side decorations are not controlled by KWin's Aurorae theme**. Fullscreen games are unaffected by the window-frame design.

## Theme Bank

Pick a palette from the Theme Bank popup in the top panel. The same source colors are used throughout the project.

| Bonfire Dusk | Ember Moon |
| --- | --- |
| First Flame | Dying Ember |
| Anor Londo | Moonlit Cathedral |
| Ashen Pilgrim | Abyss Watcher |
| Moss & Ember | Hollow Grove |
| Crimson Covenant | Eclipse of Fire |

Both groups use dark backgrounds; the names describe their mood rather than a light/dark system switch.

The source of truth is **[`shell/theme/palettes.json`](shell/theme/palettes.json)**. The currently selected palette is stored locally in `shell/theme/selection.json` (intentionally ignored by Git). The runtime manager is [`shell/theme/ThemeManager.qml`](shell/theme/ThemeManager.qml).

Changing the palette updates the wallpaper, Plasma color scheme, Aurorae window decoration and Alacritty colors. The Fish prompt and Rofi read the current selection when they are invoked.

## Requirements

**Main environment**

- Linux with **KDE Plasma 6**, **KWin** and a **Wayland** session; developed on CachyOS/Arch-based Linux.
- **Quickshell** (`qs`) for the panel, dock and popups.
- **Python 3** for the palette bridges and helper scripts.
- KDE utilities such as `plasma-apply-colorscheme`, `plasma-apply-wallpaperimage`, `kwriteconfig6` and `kreadconfig6`.
- `qdbus6` or an equivalent D-Bus utility for refreshing KWin decorations.

**For optional integrations**

- **Alacritty** and **Fish** for the terminal setup.
- **Rofi** for the themed app/command launcher; **kdotool** for its KWin window picker.
- **JetBrains Mono / JetBrainsMono Nerd Font** for the intended text and symbol rendering.
- Other utilities used by individual panel widgets may need to be installed separately.

Package names and availability vary by distribution. This project does not currently provide a dependency installer.

## Getting started

### 1. Clone the repository

The current configuration assumes the project lives at **`~/Rice/amber`**:

```bash
mkdir -p ~/Rice
cd ~/Rice
git clone https://github.com/Werdna09/Amber-ricing.git amber
cd amber
```

Create your own selection file (Git will not track it):

```bash
cp -n shell/theme/selection.example.json shell/theme/selection.json
```

**Portability note:** The current `ThemeManager.qml` still contains an absolute path to the author's Alacritty synchronization script (`/home/ondra/Rice/amber/scripts/alacritty/sync_colors.py`). **Before running Amber on another user account**, replace that path with your own, or change the script argument to the project-relative expression:

```qml
Quickshell.shellDir + "/../scripts/alacritty/sync_colors.py"
```

The example Alacritty config and Fish prompt also assume `~/Rice/amber`. Check their paths if you clone elsewhere.

### 2. Test Quickshell

From the repository root:

```bash
qs -p ~/Rice/amber/shell
```

This starts Amber without modifying Plasma's autostart configuration. Confirm that the top panel, dock and Theme Bank work before enabling automatic startup. Stop any other Quickshell desktop shell first to avoid duplicate panels.

### 3. Install the KDE icon theme

The ready-to-use icon theme is in [`icon-theme/Amber/`](icon-theme/Amber/); editable original artwork is in [`icon-src/`](icon-src/).

```bash
mkdir -p ~/.local/share/icons
cp -a icon-theme/Amber ~/.local/share/icons/
kwriteconfig6 --file kdeglobals --group Icons --key Theme Amber
kbuildsycoca6
```

Back up an existing `~/.local/share/icons/Amber` directory before replacing it.

### 4. Apply the ten Plasma color schemes

```bash
python3 scripts/kde/sync_colors.py --check
python3 scripts/kde/sync_colors.py --apply
```

This generates the `Amber*.colors` files under `~/.local/share/color-schemes/` and applies the locally selected palette.

### 5. Install and select Lothric Steel window decorations

```bash
python3 scripts/kwin/sync_decoration.py --check
python3 scripts/kwin/sync_decoration.py --install
python3 scripts/kwin/sync_decoration.py --sync
```

This generates and installs ten matching Aurorae themes under `~/.local/share/aurorae/themes/` and activates the selected one. **Back up existing AmberLothricSteel themes before reinstalling:** `--install` replaces those generated theme directories.

The repository already contains the Theme Bank hook. Do **not** run `scripts/kwin/install_lothric.py --apply` on a fresh clone as though it were a generic bootstrap installer; that installer expects an unpatched ThemeManager and maintains its own local restoration state.

### 6. Optional: Alacritty, Fish and Rofi

Generate Alacritty's palette file:

```bash
python3 scripts/alacritty/sync_colors.py --no-ipc
```

An Alacritty configuration is supplied at [`config/alacritty/alacritty.toml`](config/alacritty/alacritty.toml). **Back up your existing Alacritty configuration** before deciding to replace it; its import path assumes `~/Rice/amber`.

To use the palette-aware Fish prompt, load [`scripts/fish/amber_prompt.fish`](scripts/fish/amber_prompt.fish) **after** your existing Fish configuration. For example, add this to `~/.config/fish/config.fish`:

```fish
source ~/Rice/amber/scripts/fish/amber_prompt.fish
```

For the themed Rofi launcher:

```bash
python3 scripts/rofi/amber_rofi.py check
./scripts/rofi/amber-rofi apps
```

### 7. Enable Amber at login (optional)

After you have tested the shell, create `~/.config/autostart/amber-quickshell.desktop`:

```ini
[Desktop Entry]
Type=Application
Name=Amber Quickshell
Comment=Amber desktop shell
Exec=sh -c "sleep 3; exec qs -p ~/Rice/amber/shell"
TryExec=qs
Terminal=false
```

Disable the autostart entry for any previous Quickshell-based rice so only one desktop shell starts. Keep **KDE Plasma and KWin** running; Amber replaces the custom panel/dock layer, not your Wayland session or window manager.

## Updating an existing checkout

```bash
cd ~/Rice/amber
git switch main
git pull --ff-only
```

`git pull` updates the **repository**, but does not automatically recopy already-installed icon files or Aurorae themes. If those assets changed, repeat the relevant installation commands above. Back up local changes before pulling; local selection and generated Alacritty colors are ignored by Git.

To inspect the active Plasma scheme and KWin decoration:

```bash
kreadconfig6 --file kdeglobals --group General --key ColorScheme
kreadconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme
```

## Repository layout

```text
Amber-ricing/
├── shell/
│   ├── shell.qml                  # Quickshell entry point
│   ├── components/                # Top panel, dock and shared UI
│   ├── popups/                    # Theme Bank, controls and menus
│   ├── services/                  # System and window information
│   ├── theme/                     # ThemeManager and palette definitions
│   └── assets/                    # Pixel art and wallpapers
├── config/
│   ├── alacritty/                 # Terminal configuration
│   ├── nvim/                      # Neovim configuration
│   └── rofi/                      # Rofi style template
├── scripts/
│   ├── alacritty/                 # Terminal color synchronization
│   ├── fish/                      # Palette-aware prompt
│   ├── kde/                       # Plasma color-scheme bridge
│   ├── kwin/                      # Aurorae generation and switching
│   ├── power/                     # Session/power actions
│   ├── rofi/                      # Themed launcher and window picker
│   └── wallpapers/                # Wallpaper switching
├── icon-src/                      # 73 original PNG icon sources
├── icon-theme/Amber/              # KDE-compatible icon theme
├── kwin-decoration/               # Ten Lothric Steel Aurorae themes
├── studies/                       # Design studies / mockups
└── README.md
```

## Customization and limitations

- Change palette definitions in `shell/theme/palettes.json`; then regenerate installed KDE color schemes and Aurorae assets if necessary.
- The Theme Bank currently has ten fixed palette IDs, and related scripts expect those IDs.
- Some paths and command assumptions reflect the original CachyOS machine; review them before using another distribution, home directory or repository location.
- KWin decorations apply to windows that use server-side decorations, not necessarily to applications drawing their own titlebars.
- This is a personal work-in-progress with a **documented manual setup**, not yet a general-purpose install/uninstall system.

## Credits and disclaimer

Created and maintained by **[Werdna09](https://github.com/Werdna09)**.

Inspired by *Dark Souls* and classic pixel-art/fantasy interfaces. Amber is an independent, unofficial fan-inspired desktop project and is **not affiliated with or endorsed by FromSoftware**.

*Praise the Sun! \[T]/*

