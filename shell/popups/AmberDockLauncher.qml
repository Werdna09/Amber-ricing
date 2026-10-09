import QtQuick
import Quickshell
import Quickshell.Widgets
import "../components/chrome"

// Amber Launcher v2 — application catalogue, quick launch, search and keyboard navigation.
// This component deliberately keeps the existing AmberDockLauncher public API.
PopupWindow {
    id: root
    required property Item anchorItem
    required property var theme

    property string query: ""
    property string category: "Vše"
    readonly property var categories: [
        { label: "Vše", icon: "✦" },
        { label: "Internet", icon: "◉" },
        { label: "Vývoj", icon: "⌘" },
        { label: "Multimédia", icon: "♫" },
        { label: "Grafika", icon: "◇" },
        { label: "Hry", icon: "♜" },
        { label: "Systém", icon: "⚙" },
        { label: "Ostatní", icon: "·" }
    ]
    readonly property var favourites: [
        { label: "Firefox", id: "firefox", icon: "firefox" },
        { label: "Dolphin", id: "org.kde.dolphin", icon: "system-file-manager" },
        { label: "Alacritty", id: "Alacritty", icon: "utilities-terminal" },
        { label: "Steam", id: "steam", icon: "steam" }
    ]

    implicitWidth: 610
    implicitHeight: 586
    visible: false
    color: "transparent"
    grabFocus: true

    anchor.item: root.anchorItem
    anchor.rect.x: Math.round((root.anchorItem.width - root.implicitWidth) / 2)
    anchor.rect.y: -9
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Top | Edges.Right
    anchor.adjustment: PopupAdjustment.SlideX | PopupAdjustment.FlipY

    function inCategory(entry) {
        if (root.category === "Vše") return true
        const cats = String(entry.categories || "").toLowerCase()
        function containsAny(words) {
            for (let i = 0; i < words.length; ++i)
                if (cats.indexOf(words[i]) !== -1) return true
            return false
        }
        switch (root.category) {
        case "Internet": return containsAny(["network", "webbrowser", "email", "instantmessaging"])
        case "Vývoj": return containsAny(["development", "ide"])
        case "Multimédia": return containsAny(["audiovideo", "audio", "video", "player", "music"])
        case "Grafika": return containsAny(["graphics", "photography", "2dgraphics", "3dgraphics"])
        case "Hry": return containsAny(["game"])
        case "Systém": return containsAny(["system", "settings", "utility", "filemanager"])
        case "Ostatní": return !containsAny([
            "network", "webbrowser", "email", "instantmessaging", "development", "ide",
            "audiovideo", "audio", "video", "player", "music", "graphics", "photography",
            "game", "system", "settings", "utility", "filemanager"
        ])
        }
        return true
    }

    function applications() {
        let apps = [...DesktopEntries.applications.values]
        const needle = root.query.trim().toLowerCase()
        apps = apps.filter(entry => {
            if (entry.noDisplay) return false
            if (!root.inCategory(entry)) return false
            if (!needle) return true
            const searchable = [entry.name, entry.genericName, entry.comment,
                                String(entry.keywords || "")].join(" ").toLowerCase()
            return searchable.indexOf(needle) !== -1
        })
        apps.sort((a, b) => String(a.name || "").localeCompare(String(b.name || "")))
        return apps
    }

    function favouriteEntry(id) {
        const candidates = [id, id + ".desktop"]
        for (let i = 0; i < candidates.length; ++i) {
            const found = DesktopEntries.byId(candidates[i])
            if (found !== null && !found.noDisplay) return found
        }
        return DesktopEntries.heuristicLookup(id)
    }

    function startApplication(entry) {
        if (!entry) return
        root.visible = false
        entry.execute()
    }

    function activateSelected() {
        if (applicationList.count < 1) return
        let idx = applicationList.currentIndex
        if (idx < 0 || idx >= applicationList.count) idx = 0
        const choices = root.applications()
        if (choices[idx]) root.startApplication(choices[idx])
    }

    function moveSelection(step) {
        const count = applicationList.count
        if (count < 1) return
        const current = applicationList.currentIndex < 0 ? 0 : applicationList.currentIndex
        applicationList.currentIndex = Math.max(0, Math.min(count - 1, current + step))
        applicationList.positionViewAtIndex(applicationList.currentIndex, ListView.Contain)
    }

    onVisibleChanged: {
        if (visible) {
            root.query = ""
            root.category = "Vše"
            applicationList.currentIndex = 0
            search.forceActiveFocus()
        }
    }

    PixelSurface {
        id: shellSurface
        anchors.fill: parent
        theme: root.theme

        Text {
            id: heading
            anchors { top: parent.top; left: parent.left; topMargin: 18; leftMargin: 22 }
            text: "✦  AMBER / LAUNCHER"
            color: root.theme.colors.accent
            font.family: "JetBrains Mono"
            font.pixelSize: 15
            font.bold: true
            font.letterSpacing: 1
        }

        Text {
            anchors { right: parent.right; rightMargin: 22; verticalCenter: heading.verticalCenter }
            text: "APLIKACE"
            color: root.theme.colors.muted
            font.family: "JetBrains Mono"
            font.pixelSize: 10
        }

        Rectangle {
            id: searchFrame
            anchors { top: heading.bottom; left: parent.left; right: parent.right
                      topMargin: 15; leftMargin: 20; rightMargin: 20 }
            height: 42
            radius: 1
            color: root.theme.colors.surface
            border.width: 1
            border.color: search.activeFocus ? root.theme.colors.accent : root.theme.colors.border

            SoulsHighlight {
                anchors.fill: parent
                theme: root.theme
                selected: search.activeFocus
            }
            Text {
                anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                text: "⌕"
                font.pixelSize: 19
                color: root.theme.colors.accent
            }
            TextInput {
                id: search
                anchors { fill: parent; leftMargin: 38; rightMargin: 12 }
                verticalAlignment: TextInput.AlignVCenter
                color: root.theme.colors.text
                selectionColor: root.theme.colors.accent
                selectedTextColor: root.theme.colors.background
                font.family: "JetBrains Mono"
                font.pixelSize: 13
                clip: true
                text: root.query
                onTextEdited: {
                    root.query = text
                    applicationList.currentIndex = 0
                }
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        root.visible = false
                        event.accepted = true
                    } else if (event.key === Qt.Key_Down) {
                        root.moveSelection(1)
                        event.accepted = true
                    } else if (event.key === Qt.Key_Up) {
                        root.moveSelection(-1)
                        event.accepted = true
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.activateSelected()
                        event.accepted = true
                    }
                }
            }
            Text {
                anchors { left: search.left; verticalCenter: parent.verticalCenter }
                visible: search.text.length === 0
                text: "Hledat aplikaci…"
                color: root.theme.colors.muted
                font.family: "JetBrains Mono"
                font.pixelSize: 12
            }
        }

        Text {
            id: quickTitle
            anchors { left: searchFrame.left; top: searchFrame.bottom; topMargin: 17 }
            text: "RYCHLÝ PŘÍSTUP"
            font.family: "JetBrains Mono"
            font.pixelSize: 10
            font.bold: true
            color: root.theme.colors.muted
        }

        Row {
            id: quickRow
            anchors { left: searchFrame.left; right: searchFrame.right; top: quickTitle.bottom; topMargin: 7 }
            height: 52
            spacing: 8
            Repeater {
                model: root.favourites
                delegate: Rectangle {
                    id: shortcut
                    required property var modelData
                    readonly property var entry: root.favouriteEntry(modelData.id)
                    width: (quickRow.width - 3 * quickRow.spacing) / 4
                    height: quickRow.height
                    color: shortcutMouse.containsMouse ? root.theme.colors.surface : "transparent"
                    radius: 1
                    border.width: 1
                    border.color: shortcutMouse.containsMouse ? root.theme.colors.accent : root.theme.colors.border
                    SoulsHighlight { anchors.fill: parent; theme: root.theme; hovered: shortcutMouse.containsMouse }
                    Row {
                        anchors.centerIn: parent
                        spacing: 8
                        IconImage {
                            anchors.verticalCenter: parent.verticalCenter
                            implicitSize: 23
                            source: Quickshell.iconPath(shortcut.entry && shortcut.entry.icon
                                                       ? shortcut.entry.icon : shortcut.modelData.icon,
                                                       "application-x-executable")
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: shortcut.modelData.label
                            font.family: "JetBrains Mono"
                            font.pixelSize: 11
                            color: root.theme.colors.text
                        }
                    }
                    MouseArea {
                        id: shortcutMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.startApplication(shortcut.entry)
                    }
                }
            }
        }

        Rectangle {
            id: divider
            anchors { left: searchFrame.left; right: searchFrame.right; top: quickRow.bottom; topMargin: 14 }
            height: 1
            color: root.theme.colors.border
        }

        Text {
            id: sectionTitle
            anchors { left: searchFrame.left; top: divider.bottom; topMargin: 11 }
            text: "KATEGORIE"
            color: root.theme.colors.muted
            font.family: "JetBrains Mono"
            font.pixelSize: 10
            font.bold: true
        }

        Text {
            anchors { right: searchFrame.right; verticalCenter: sectionTitle.verticalCenter }
            text: applicationList.count + " výsledků"
            color: root.theme.colors.muted
            font.family: "JetBrains Mono"
            font.pixelSize: 10
        }

        Column {
            id: categoryList
            anchors { left: searchFrame.left; top: sectionTitle.bottom; topMargin: 11 }
            width: 138
            spacing: 3
            Repeater {
                model: root.categories
                delegate: Rectangle {
                    id: categoryRow
                    required property var modelData
                    readonly property bool chosen: root.category === modelData.label
                    width: categoryList.width
                    height: 33
                    radius: 1
                    color: chosen ? root.theme.colors.surface : "transparent"
                    border.width: chosen ? 1 : 0
                    border.color: root.theme.colors.accent
                    SoulsHighlight { anchors.fill: parent; theme: root.theme
                                     hovered: categoryMouse.containsMouse; selected: categoryRow.chosen }
                    Row {
                        anchors { left: parent.left; leftMargin: 11; verticalCenter: parent.verticalCenter }
                        spacing: 10
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 16
                            text: categoryRow.modelData.icon
                            color: categoryRow.chosen ? root.theme.colors.accent : root.theme.colors.muted
                            font.pixelSize: 12
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: categoryRow.modelData.label
                            color: categoryRow.chosen ? root.theme.colors.text : root.theme.colors.muted
                            font.family: "JetBrains Mono"
                            font.pixelSize: 11
                            font.bold: categoryRow.chosen
                        }
                    }
                    MouseArea {
                        id: categoryMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.category = categoryRow.modelData.label
                            applicationList.currentIndex = 0
                            search.forceActiveFocus()
                        }
                    }
                }
            }
        }

        Rectangle {
            id: verticalDivider
            anchors { left: categoryList.right; leftMargin: 12; top: categoryList.top; bottom: footerDivider.top; bottomMargin: 10 }
            width: 1
            color: root.theme.colors.border
        }

        ScriptModel {
            id: launchModel
            values: root.applications()
            objectProp: "id"
        }
        ListView {
            id: applicationList
            anchors { left: verticalDivider.right; leftMargin: 11; right: searchFrame.right;
                      top: categoryList.top; bottom: footerDivider.top; bottomMargin: 9 }
            clip: true
            spacing: 3
            model: launchModel
            currentIndex: 0
            highlightMoveDuration: 90
            delegate: Rectangle {
                id: appRow
                required property var modelData
                required property int index
                readonly property bool highlighted: applicationList.currentIndex === index
                width: ListView.view.width
                height: 46
                radius: 1
                color: highlighted ? root.theme.colors.surface : "transparent"
                border.width: highlighted ? 1 : 0
                border.color: root.theme.colors.accent
                SoulsHighlight {
                    anchors.fill: parent
                    theme: root.theme
                    selected: appRow.highlighted
                    hovered: appMouse.containsMouse
                }
                IconImage {
                    id: appIcon
                    anchors { left: parent.left; leftMargin: 11; verticalCenter: parent.verticalCenter }
                    implicitSize: 29
                    source: Quickshell.iconPath(appRow.modelData.icon, "application-x-executable")
                }
                Column {
                    anchors { left: appIcon.right; leftMargin: 12; right: parent.right;
                              rightMargin: 9; verticalCenter: parent.verticalCenter }
                    spacing: 3
                    Text {
                        width: parent.width
                        text: appRow.modelData.name
                        elide: Text.ElideRight
                        font.family: "JetBrains Mono"
                        font.pixelSize: 12
                        font.bold: appRow.highlighted
                        color: root.theme.colors.text
                    }
                    Text {
                        width: parent.width
                        text: String(appRow.modelData.genericName || appRow.modelData.comment || "Aplikace")
                        elide: Text.ElideRight
                        font.family: "JetBrains Mono"
                        font.pixelSize: 9
                        color: root.theme.colors.muted
                    }
                }
                MouseArea {
                    id: appMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: applicationList.currentIndex = appRow.index
                    onClicked: root.startApplication(appRow.modelData)
                }
            }
        }
        Text {
            anchors.centerIn: applicationList
            visible: applicationList.count === 0
            text: "Žádná odpovídající aplikace"
            color: root.theme.colors.muted
            font.family: "JetBrains Mono"
            font.pixelSize: 11
        }

        Rectangle {
            id: footerDivider
            anchors { left: searchFrame.left; right: searchFrame.right; bottom: parent.bottom; bottomMargin: 39 }
            height: 1
            color: root.theme.colors.border
        }
        Text {
            anchors { left: searchFrame.left; bottom: parent.bottom; bottomMargin: 17 }
            text: "↑ ↓  výběr     ENTER  spustit     ESC  zavřít"
            font.family: "JetBrains Mono"
            font.pixelSize: 10
            color: root.theme.colors.muted
        }
    }
}
