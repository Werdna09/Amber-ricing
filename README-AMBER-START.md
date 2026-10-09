# Amber Theme Bank — first test

Run inside `~/Rice/amber`:

```fish
cp shell/theme/selection.example.json shell/theme/selection.json
qs -p ~/Rice/amber/shell
```

This is a standalone test window and does not replace Crylia. Do not launch via autostart yet. Later, you may link `~/Rice/amber/shell` as `~/.config/quickshell/amber` and use `qs -c amber`.

The central palette bank lives in `shell/theme/palettes.json`. Individual JSON palettes are also provided under `shell/theme/palettes/` for later migration to separate loaders. For now, the aggregate bank is the runtime source of truth.

The selected palette is persisted in `shell/theme/selection.json`, intentionally ignored by Git.
