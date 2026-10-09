import QtQuick
import Quickshell
import Quickshell.Widgets
import "../components/chrome"

// Window selection cards for one running application.
// KDE Wayland: intentionally uses window titles/icons, not fabricated screen captures.
PopupWindow {
    id: root
    required property Item anchorItem
    required property var theme
    required property var windowService
    property string appName: "Application"
    property string iconName: "application-x-executable"
    property var windows: []
    readonly property bool pointerInside: pointer.hovered
    onWindowsChanged: { if (visible && windows.length < 2) visible = false }

    implicitWidth: 330
    implicitHeight: Math.min(374, 63 + Math.max(1, windows.length) * 65)
    visible: false
    color: "transparent"
    grabFocus: false

    anchor.item: root.anchorItem
    anchor.rect.x: Math.round((root.anchorItem.width - root.implicitWidth) / 2)
    anchor.rect.y: -6
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Top | Edges.Right
    anchor.adjustment: PopupAdjustment.SlideX | PopupAdjustment.FlipY

    PixelSurface {
        anchors.fill: parent
        theme: root.theme

        HoverHandler { id: pointer }

        Row {
            id: header
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
            spacing: 8
            height: 32
            IconImage {
                implicitSize: 24
                anchors.verticalCenter: parent.verticalCenter
                source: Quickshell.iconPath(root.iconName, "application-x-executable")
            }
            Column {
                width: parent.width - 72
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                Text {
                    width: parent.width
                    text: root.appName
                    elide: Text.ElideRight
                    color: root.theme.colors.text
                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    font.bold: true
                }
                Text {
                    text: root.windows.length + (root.windows.length === 1 ? " OKNO" :
                        root.windows.length < 5 ? " OKNA" : " OKEN")
                    color: root.theme.colors.muted
                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                }
            }
        }
        Rectangle {
            id: divider
            anchors { left: parent.left; right: parent.right; top: header.bottom; margins: 11 }
            height: 1
            color: root.theme.colors.border
        }
        ListView {
            id: windowList
            anchors {
                top: divider.bottom; left: parent.left; right: parent.right; bottom: parent.bottom
                margins: 9; topMargin: 7
            }
            spacing: 3
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: root.windows

            delegate: Rectangle {
                id: windowRow
                required property var modelData
                width: ListView.view.width
                height: 60
                radius: 1
                color: "transparent"
                border.width: mainMouse.containsMouse || closeMouse.containsMouse || modelData.active ? 1 : 0
                border.color: root.theme.colors.accent

                SoulsHighlight {
                    anchors.fill: parent
                    theme: root.theme
                    hovered: mainMouse.containsMouse || closeMouse.containsMouse
                    selected: windowRow.modelData.active
                }
                IconImage {
                    anchors { left: parent.left; leftMargin: 9; verticalCenter: parent.verticalCenter }
                    implicitSize: 32
                    opacity: windowRow.modelData.minimized ? 0.55 : 1
                    source: Quickshell.iconPath(root.iconName, "application-x-executable")
                }
                Column {
                    anchors { left: parent.left; leftMargin: 50; right: closeButton.left; rightMargin: 6;
                              verticalCenter: parent.verticalCenter }
                    spacing: 5
                    Text {
                        width: parent.width
                        text: String(windowRow.modelData.caption || root.appName)
                        elide: Text.ElideRight
                        color: root.theme.colors.text
                        font.family: "JetBrains Mono"
                        font.pixelSize: 11
                        font.bold: windowRow.modelData.active
                    }
                    Text {
                        text: windowRow.modelData.active ? "AKTIVNÍ" :
                            windowRow.modelData.minimized ? "MINIMALIZOVANÉ" : "OTEVŘENÉ"
                        color: windowRow.modelData.active ? root.theme.colors.accent : root.theme.colors.muted
                        font.family: "JetBrains Mono"
                        font.pixelSize: 9
                    }
                }
                MouseArea {
                    id: mainMouse
                    anchors { left: parent.left; right: closeButton.left; top: parent.top; bottom: parent.bottom }
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.windowService.activate(String(windowRow.modelData.id))
                        root.visible = false
                    }
                }
                Rectangle {
                    id: closeButton
                    anchors { right: parent.right; rightMargin: 7; verticalCenter: parent.verticalCenter }
                    width: 28; height: 28; radius: 1
                    color: closeMouse.containsMouse ? root.theme.colors.surface : "transparent"
                    border.width: closeMouse.containsMouse ? 1 : 0
                    border.color: root.theme.colors.accent
                    Text {
                        anchors.centerIn: parent
                        text: "×"
                        color: closeMouse.containsMouse ? root.theme.colors.accent : root.theme.colors.muted
                        font.family: "JetBrains Mono"
                        font.pixelSize: 20
                    }
                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.windowService.close(String(windowRow.modelData.id))
                            root.visible = false
                        }
                    }
                }
            }
        }
    }
}
