import QtQuick
import Quickshell
import Quickshell.Widgets
import "../components/chrome"

// Temporary functional launcher. A fully themed launcher will follow as a separate milestone.
PopupWindow {
    id: root
    required property Item anchorItem
    required property var theme
    property string query: ""

    implicitWidth: 430
    implicitHeight: 460
    color: "transparent"
    grabFocus: true
    visible: false

    anchor.item: root.anchorItem
    anchor.rect.x: Math.round((root.anchorItem.width - root.implicitWidth) / 2)
    anchor.rect.y: -8
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Top | Edges.Right
    anchor.adjustment: PopupAdjustment.SlideX | PopupAdjustment.FlipY

    function applications() {
        let apps = [...DesktopEntries.applications.values]
        const needle = root.query.trim().toLowerCase()
        if (needle) apps = apps.filter(a =>
            String(a.name || "").toLowerCase().includes(needle) ||
            String(a.genericName || "").toLowerCase().includes(needle))
        apps.sort((a, b) => String(a.name).localeCompare(String(b.name)))
        return apps
    }

    onVisibleChanged: {
        if (visible) {
            query = ""
            search.forceActiveFocus()
        }
    }

    PixelSurface {
        anchors.fill: parent
        theme: root.theme

        Text {
            id: heading
            anchors { top: parent.top; left: parent.left; topMargin: 18; leftMargin: 20 }
            text: "AMBER · APPLICATIONS"
            font.family: "JetBrains Mono"; font.pixelSize: 14; font.bold: true
            color: root.theme.colors.accent
        }
        Rectangle {
            id: searchBox
            anchors { left: parent.left; right: parent.right; top: heading.bottom
                      leftMargin: 20; rightMargin: 20; topMargin: 14 }
            height: 36; radius: 1
            color: root.theme.colors.surface
            border.width: 1; border.color: search.activeFocus ? root.theme.colors.accent : root.theme.colors.border
            TextInput {
                id: search
                anchors { fill: parent; leftMargin: 12; rightMargin: 10 }
                verticalAlignment: TextInput.AlignVCenter
                clip: true
                color: root.theme.colors.text
                selectionColor: root.theme.colors.accent
                font.family: "JetBrains Mono"; font.pixelSize: 12
                text: root.query
                onTextEdited: root.query = text
                Keys.onEscapePressed: root.visible = false
                Keys.onReturnPressed: {
                    if (applicationList.count > 0) {
                        const first = root.applications()[0]
                        if (first) { first.execute(); root.visible = false }
                    }
                }
            }
        }
        Text {
            anchors.centerIn: searchBox
            anchors.horizontalCenterOffset: 0
            visible: root.query.length === 0
            text: "Type to search apps…"
            color: root.theme.colors.muted
            font.family: "JetBrains Mono"; font.pixelSize: 12
            z: 0
        }
        Rectangle {
            anchors { top: searchBox.bottom; left: searchBox.left; right: searchBox.right; topMargin: 10 }
            height: 1; color: root.theme.colors.border
        }
        ScriptModel {
            id: launchModel
            values: root.applications()
            objectProp: "id"
        }
        ListView {
            id: applicationList
            anchors { top: searchBox.bottom; left: parent.left; right: parent.right; bottom: parent.bottom
                      topMargin: 17; leftMargin: 18; rightMargin: 18; bottomMargin: 14 }
            clip: true
            spacing: 2
            model: launchModel
            delegate: Rectangle {
                id: appRow
                required property var modelData
                width: ListView.view.width
                height: 42
                radius: 1
                color: appMouse.containsMouse ? root.theme.colors.surface : "transparent"
                border.width: appMouse.containsMouse ? 1 : 0
                border.color: root.theme.colors.accent
                Row {
                    anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
                    spacing: 10
                    IconImage {
                        anchors.verticalCenter: parent.verticalCenter
                        implicitSize: 26
                        source: Quickshell.iconPath(appRow.modelData.icon, "application-x-executable")
                    }
                    Text {
                        width: appRow.width - 60
                        anchors.verticalCenter: parent.verticalCenter
                        text: appRow.modelData.name
                        elide: Text.ElideRight
                        color: root.theme.colors.text
                        font.family: "JetBrains Mono"; font.pixelSize: 12
                    }
                }
                MouseArea {
                    id: appMouse
                    anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { appRow.modelData.execute(); root.visible = false }
                }
            }
        }
    }
}
