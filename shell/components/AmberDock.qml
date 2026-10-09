import QtQuick
import Quickshell
import Quickshell.Widgets
import "chrome"
import "../popups"

// Amber Dock v1: functional KWin task dock, auto-hide, palette-aware pixel chrome.
// It is deliberately independent of AmberTopPanel and the existing popup services.
Scope {
    id: root
    required property var theme
    required property var windowService

    // Initial pinned set follows Crylia. Edit this array to personalize the dock.
    property var pinnedApps: [
        { key: "firefox", keys: ["firefox"], lookup: "firefox", icon: "firefox", command: ["firefox"] },
        { key: "org.kde.dolphin", keys: ["org.kde.dolphin", "dolphin"], lookup: "org.kde.dolphin", icon: "system-file-manager", command: ["dolphin"] },
        { key: "alacritty", keys: ["alacritty"], lookup: "Alacritty", icon: "utilities-terminal", command: ["alacritty"] },
        { key: "steam", keys: ["steam"], lookup: "steam", icon: "steam", command: ["steam"] }
    ]

    function normalize(value) {
        let s = String(value || "").trim().toLowerCase()
        const slash = s.lastIndexOf("/")
        if (slash >= 0) s = s.substring(slash + 1)
        if (s.endsWith(".desktop")) s = s.slice(0, -8)
        return s
    }
    function isPinnedMatch(pin, app) {
        const key = normalize(app.key)
        return pin.keys.some(k => normalize(k) === key)
    }
    function desktopEntryFor(app) {
        const candidates = [app.desktopFile, app.lookup, app.resourceClass, app.key]
        for (let i = 0; i < candidates.length; ++i) {
            const name = String(candidates[i] || "").trim()
            if (!name) continue
            let entry = DesktopEntries.byId(name)
            if (entry !== null) return entry
            if (!name.endsWith(".desktop")) {
                entry = DesktopEntries.byId(name + ".desktop")
                if (entry !== null) return entry
            }
        }
        for (let i = 0; i < candidates.length; ++i) {
            const name = String(candidates[i] || "").trim()
            if (!name) continue
            const entry = DesktopEntries.heuristicLookup(name)
            if (entry !== null) return entry
        }
        return null
    }
    function dockApplications() {
        const running = windowService.applications || []
        const items = []
        const used = {}
        for (let i = 0; i < pinnedApps.length; i++) {
            const pin = pinnedApps[i]
            let match = null
            for (let j = 0; j < running.length; j++) {
                if (isPinnedMatch(pin, running[j])) { match = running[j]; break }
            }
            if (match) used[match.key] = true
            const app = match || {}
            items.push({
                key: pin.key, desktopFile: app.desktopFile || pin.lookup,
                resourceClass: app.resourceClass || "", caption: app.caption || "",
                lookup: pin.lookup, fallbackIcon: pin.icon, command: pin.command,
                pinned: true, running: Boolean(match), active: Boolean(app.active),
                minimized: Boolean(app.minimized), windowCount: app.windowCount || 0,
                activeWindowId: app.activeWindowId || "", representativeId: app.representativeId || "",
                windows: app.windows || [],
                signature: pin.key + "|" + Boolean(match) + "|" + Boolean(app.active) + "|" +
                           (app.windowCount || 0) + "|" + (app.activeWindowId || "") + "|" +
                           (app.windows || []).map(w => w.id + ":" + w.caption + ":" + w.minimized).join(";")
            })
        }
        for (let i = 0; i < running.length; i++) {
            const app = running[i]
            if (used[app.key]) continue
            items.push({
                key: app.key, desktopFile: app.desktopFile, resourceClass: app.resourceClass,
                caption: app.caption, lookup: app.desktopFile, fallbackIcon: "application-x-executable",
                command: [], pinned: false, running: true, active: app.active,
                minimized: app.minimized, windowCount: app.windowCount,
                activeWindowId: app.activeWindowId, representativeId: app.representativeId,
                windows: app.windows || [],
                signature: app.key + "|" + app.active + "|" + app.minimized + "|" +
                           app.windowCount + "|" + app.activeWindowId + "|" + app.representativeId + "|" +
                           (app.windows || []).map(w => w.id + ":" + w.caption + ":" + w.minimized).join(";")
            })
        }
        return items
    }
    function launch(app, entry) {
        if (entry !== null) entry.execute()
        else if (app.command && app.command.length) Quickshell.execDetached(app.command)
        windowService.refreshSoon(600)
    }

    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: dockWindow
            required property var modelData
            screen: modelData
            anchors { left: true; right: true; bottom: true }
            implicitHeight: 78
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            aboveWindows: true
            focusable: false
            property bool shown: false
            property bool launcherOpen: false
            property bool menuOpen: false
            property bool previewOpen: false
            property var activePreview: null

            mask: Region {
                x: dockSurface.x
                y: dockSurface.y
                width: dockSurface.width
                height: dockSurface.height
                Region {
                    x: 0; y: dockWindow.implicitHeight - 4
                    width: dockWindow.width; height: 4
                }
            }

            function reveal() { hideTimer.stop(); shown = true }
            function scheduleHide() { hideTimer.restart() }
            Timer {
                id: hideTimer; interval: 550; repeat: false
                onTriggered: {
                    if (!edgeHover.hovered && !dockHover.hovered &&
                        !dockWindow.launcherOpen && !dockWindow.menuOpen &&
                        !dockWindow.previewOpen) dockWindow.shown = false
                }
            }
            Rectangle {
                id: edgeTrigger
                x: 0; y: parent.height - height
                width: parent.width; height: 4; color: "transparent"
                HoverHandler {
                    id: edgeHover
                    onHoveredChanged: hovered ? dockWindow.reveal() : dockWindow.scheduleHide()
                }
            }
            PixelSurface {
                id: dockSurface
                theme: root.theme
                width: viewport.width + 16
                height: 58
                x: Math.round((dockWindow.width - width) / 2)
                y: dockWindow.shown ? 8 : dockWindow.implicitHeight + 5
                Behavior on y { NumberAnimation { duration: 185; easing.type: Easing.OutCubic } }
                Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                HoverHandler {
                    id: dockHover
                    onHoveredChanged: hovered ? dockWindow.reveal() : dockWindow.scheduleHide()
                }
                ScriptModel {
                    id: dockModel
                    values: root.dockApplications()
                    objectProp: "signature"
                }
                Flickable {
                    id: viewport
                    anchors.centerIn: parent
                    width: Math.min(dockRow.width, dockWindow.width - 42)
                    height: 50
                    contentWidth: dockRow.width
                    contentHeight: dockRow.height
                    boundsBehavior: Flickable.StopAtBounds
                    interactive: contentWidth > width
                    clip: true
                    Row {
                        id: dockRow
                        spacing: 3
                        height: 50
                        Rectangle {
                            id: launcherButton
                            width: 46; height: 48; radius: 1
                            color: launcherMouse.containsMouse || launcherPopup.visible ? root.theme.colors.surface : "transparent"
                            border.width: launcherMouse.containsMouse || launcherPopup.visible ? 1 : 0
                            border.color: root.theme.colors.accent
                            BonfireMark { anchors.centerIn: parent; theme: root.theme }
                            MouseArea {
                                id: launcherMouse
                                anchors.fill: parent; hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: launcherPopup.visible = !launcherPopup.visible
                            }
                            AmberDockLauncher {
                                id: launcherPopup
                                anchorItem: launcherButton
                                theme: root.theme
                                onVisibleChanged: {
                                    dockWindow.launcherOpen = visible
                                    if (visible) dockWindow.reveal()
                                    else dockWindow.scheduleHide()
                                }
                            }
                        }
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 1; height: 31; color: root.theme.colors.border
                        }
                        Repeater {
                            model: dockModel
                            delegate: Rectangle {
                                id: appButton
                                required property var modelData
                                readonly property var entry: root.desktopEntryFor(modelData)
                                readonly property string iconName: entry !== null && entry.icon ? entry.icon : modelData.fallbackIcon
                                readonly property string title: entry !== null && entry.name ? entry.name : (modelData.resourceClass || modelData.key)
                                readonly property string targetId: modelData.active && modelData.activeWindowId
                                    ? modelData.activeWindowId : modelData.representativeId
                                readonly property int indicators: Math.min(4, Number(modelData.windowCount || 0))
                                readonly property bool hasMultipleWindows: Number(modelData.windowCount || 0) > 1
                                width: 46; height: 48; radius: 1
                                color: menu.visible || appMouse.containsMouse ? root.theme.colors.surface : "transparent"
                                border.width: menu.visible || appMouse.containsMouse ? 1 : 0
                                border.color: root.theme.colors.accent
                                SoulsHighlight {
                                    anchors.fill: parent
                                    theme: root.theme
                                    hovered: appMouse.containsMouse
                                    selected: modelData.active || menu.visible
                                }
                                IconImage {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.verticalCenterOffset: -3
                                    implicitSize: 31
                                    source: Quickshell.iconPath(appButton.iconName, "application-x-executable")
                                    opacity: appButton.modelData.minimized ? 0.62 : 1
                                }
                                Row {
                                    visible: appButton.indicators > 0
                                    anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 2 }
                                    spacing: 2
                                    Repeater {
                                        model: appButton.indicators
                                        delegate: Rectangle {
                                            width: appButton.indicators === 1 ? 19 : 7
                                            height: appButton.modelData.active ? 3 : 2
                                            color: appButton.modelData.active ? root.theme.colors.accent : root.theme.colors.muted
                                        }
                                    }
                                }
                                // Hover 260 ms to inspect a multi-window app. Moving into
                                // the popup cancels dismissal, so it stays clickable.
                                Timer {
                                    id: previewDelay
                                    interval: 260; repeat: false
                                    onTriggered: {
                                        if (appMouse.containsMouse && appButton.hasMultipleWindows && !menu.visible) {
                                            if (dockWindow.activePreview && dockWindow.activePreview !== previewPopup)
                                                dockWindow.activePreview.visible = false
                                            previewPopup.visible = true
                                        }
                                    }
                                }
                                Timer {
                                    id: previewDismiss
                                    interval: 480; repeat: false
                                    onTriggered: {
                                        if (!appMouse.containsMouse && !previewPopup.pointerInside)
                                            previewPopup.visible = false
                                    }
                                }
                                MouseArea {
                                    id: appMouse
                                    anchors.fill: parent; hoverEnabled: true
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: {
                                        previewDismiss.stop()
                                        if (appButton.hasMultipleWindows && !menu.visible)
                                            previewDelay.restart()
                                    }
                                    onExited: {
                                        previewDelay.stop()
                                        if (previewPopup.visible) previewDismiss.restart()
                                    }
                                    onClicked: mouse => {
                                        if (mouse.button === Qt.RightButton) {
                                            previewDelay.stop()
                                            previewPopup.visible = false
                                            menu.visible = !menu.visible
                                            return
                                        }
                                        if (!appButton.modelData.running) {
                                            root.launch(appButton.modelData, appButton.entry)
                                        } else if (appButton.hasMultipleWindows) {
                                            previewDelay.stop()
                                            previewPopup.visible = !previewPopup.visible
                                        } else if (appButton.modelData.active) {
                                            root.windowService.minimize(appButton.targetId)
                                        } else {
                                            root.windowService.activate(appButton.targetId)
                                        }
                                    }
                                }
                                AmberWindowPicker {
                                    id: previewPopup
                                    anchorItem: appButton
                                    theme: root.theme
                                    windowService: root.windowService
                                    appName: appButton.title
                                    iconName: appButton.iconName
                                    windows: appButton.modelData.windows || []
                                    onPointerInsideChanged: {
                                        if (pointerInside) {
                                            previewDelay.stop()
                                            previewDismiss.stop()
                                            dockWindow.reveal()
                                        } else if (visible) {
                                            previewDismiss.restart()
                                        }
                                    }
                                    onVisibleChanged: {
                                        if (visible) {
                                            if (dockWindow.activePreview && dockWindow.activePreview !== previewPopup)
                                                dockWindow.activePreview.visible = false
                                            dockWindow.activePreview = previewPopup
                                            dockWindow.previewOpen = true
                                            dockWindow.reveal()
                                        } else {
                                            if (dockWindow.activePreview === previewPopup) {
                                                dockWindow.activePreview = null
                                                dockWindow.previewOpen = false
                                            }
                                            dockWindow.scheduleHide()
                                        }
                                    }
                                }
                                PopupWindow {
                                    id: menu
                                    visible: false
                                    color: "transparent"; grabFocus: true
                                    implicitWidth: 218; implicitHeight: 104
                                    anchor.item: appButton
                                    anchor.rect.x: Math.round((appButton.width - implicitWidth) / 2)
                                    anchor.rect.y: -7
                                    anchor.edges: Edges.Top | Edges.Left
                                    anchor.gravity: Edges.Top | Edges.Right
                                    anchor.adjustment: PopupAdjustment.SlideX | PopupAdjustment.FlipY
                                    onVisibleChanged: {
                                        dockWindow.menuOpen = visible
                                        if (visible) {
                                            previewDelay.stop()
                                            previewPopup.visible = false
                                            dockWindow.reveal()
                                        } else dockWindow.scheduleHide()
                                    }
                                    PixelSurface {
                                        anchors.fill: parent; theme: root.theme
                                        Column {
                                            anchors { fill: parent; margins: 9 }
                                            spacing: 4
                                            Text {
                                                text: appButton.title
                                                width: parent.width; height: 18; elide: Text.ElideRight
                                                font.family: "JetBrains Mono"; font.pixelSize: 11
                                                font.bold: true; color: root.theme.colors.text
                                            }
                                            Rectangle {
                                                width: parent.width; height: 29; radius: 1
                                                color: openMouse.containsMouse ? root.theme.colors.surface : "transparent"
                                                border.width: openMouse.containsMouse ? 1 : 0
                                                border.color: root.theme.colors.accent
                                                Text { anchors.centerIn: parent; text: "Open new window";
                                                       font.family: "JetBrains Mono"; font.pixelSize: 10; color: root.theme.colors.text }
                                                MouseArea {
                                                    id: openMouse; anchors.fill: parent; hoverEnabled: true
                                                    onClicked: { root.launch(appButton.modelData, appButton.entry); menu.visible = false }
                                                }
                                            }
                                            Rectangle {
                                                width: parent.width; height: 29; radius: 1
                                                color: closeMouse.containsMouse ? root.theme.colors.surface : "transparent"
                                                border.width: closeMouse.containsMouse ? 1 : 0
                                                border.color: root.theme.colors.accent
                                                Text { anchors.centerIn: parent; text: "Close window";
                                                       font.family: "JetBrains Mono"; font.pixelSize: 10;
                                                       color: appButton.modelData.running ? root.theme.colors.text : root.theme.colors.muted }
                                                MouseArea {
                                                    id: closeMouse; anchors.fill: parent; hoverEnabled: true
                                                    enabled: appButton.modelData.running
                                                    onClicked: { root.windowService.close(appButton.targetId); menu.visible = false }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
