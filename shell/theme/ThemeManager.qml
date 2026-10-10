import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: manager

    // Jediny zdroj barev pro vsechny Amber komponenty.
    property var palettes: []
    property string selectedId: "first-flame"
    // AMBER_ALACRITTY_SYNC_V1
    onSelectedIdChanged: {
        // AMBER_LOTHRIC_STEEL_V1
        Quickshell.execDetached(["python3", Quickshell.shellDir + "/../scripts/kwin/sync_decoration.py", "--palette", selectedId])

        Quickshell.execDetached(["python3", "/home/ondra/Rice/amber/scripts/alacritty/sync_colors.py", "--palette", selectedId])
        manager.applyWallpaper(selectedId)
        manager.applyKdeColors(selectedId)
    }

    readonly property var current: paletteById(selectedId)
    readonly property var colors: current.colors

    function paletteById(id) {
        for (let i = 0; i < palettes.length; i++) {
            if (palettes[i].id === id)
                return palettes[i]
        }
        return {
            id: "first-flame", name: "First Flame", mode: "day",
            colors: {
                background: "#211A17", surface: "#352820",
                border: "#644A35", muted: "#AD7650",
                accent: "#DAA45C", text: "#E8D4B2"
            }
        }
    }

    // AMBER_KDE_COLOR_SYNC_V1: mirrors selected palette to KDE app colors.
    function applyKdeColors(id) {
        Quickshell.execDetached([
            "python3",
            Quickshell.shellDir + "/../scripts/kde/sync_colors.py",
            "--apply", id
        ])
    }

    function selectPalette(id) {
        if (!palettes.some(p => p.id === id))
            return
        selectedId = id
        selection.adapter.selected = id
        selection.writeAdapter()
    }

    // AMBER_WALLPAPER_SYNC_V1
    // Project-relative path: works even when the whole Amber repo is moved.
    function applyWallpaper(id) {
        Quickshell.execDetached([
            "python3",
            Quickshell.shellDir + "/../scripts/wallpapers/apply_wallpaper.py",
            "--palette", id
        ])
    }

    property FileView bank: FileView {
        path: Qt.resolvedUrl("palettes.json")
        blockLoading: true
        onLoaded: {
            try { manager.palettes = JSON.parse(text()) }
            catch (e) { console.error("Amber: invalid palettes.json", e) }
        }
    }

    property FileView selection: FileView {
        path: Qt.resolvedUrl("selection.json")
        blockLoading: true
        adapter: JsonAdapter { property string selected: "first-flame" }
        onLoaded: {
            if (manager.selectedId === adapter.selected) {
                manager.applyWallpaper(adapter.selected)
                manager.applyKdeColors(adapter.selected)
            } else {
                manager.selectedId = adapter.selected
            }
        }
    }
}
