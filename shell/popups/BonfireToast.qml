import QtQuick
import Quickshell
import "../components/chrome"

// Latest incoming desktop notification, shown for 5 seconds.
PopupWindow {
    id: root
    required property Item anchorItem
    required property var theme
    required property var notifications

    implicitWidth: 362
    implicitHeight: 120
    visible: false
    grabFocus: false
    color: "transparent"
    anchor.item: anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.margins.top: 8
    anchor.adjustment: PopupAdjustment.SlideX

    Connections {
        target: root.notifications
        function onToastSerialChanged() {
            if (root.notifications.doNotDisturb) return
            root.visible = true
            hideTimer.restart()
        }
        function onDoNotDisturbChanged() {
            if (root.notifications.doNotDisturb) {
                hideTimer.stop()
                root.visible = false
            }
        }
    }
    Timer {
        id: hideTimer
        interval: 5500
        repeat: false
        onTriggered: root.visible = false
    }

    Rectangle {
        anchors.fill: parent
        color: root.theme.colors.background
        radius: 1
        border.width: 1
        border.color: root.theme.colors.accent
        Image {
            anchors.fill: parent
            source: "../assets/stone-grain.png"
            fillMode: Image.Tile
            opacity: 0.12
            smooth: false
        }
        Column {
            anchors.fill: parent
            anchors.margins: 13
            spacing: 6
            Text {
                text: "✦  BONFIRE MESSAGE"
                color: root.theme.colors.accent
                font.family: "JetBrains Mono"; font.pixelSize: 11; font.bold: true
            }
            Text {
                width: parent.width
                text: root.notifications.latestToast ? root.notifications.latestToast.app + " · " + root.notifications.latestToast.title : ""
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: root.theme.colors.text
                font.family: "JetBrains Mono"; font.pixelSize: 12; font.bold: true
            }
            Text {
                width: parent.width
                text: root.notifications.latestToast ? root.notifications.latestToast.body : ""
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                maximumLineCount: 2
                color: root.theme.colors.muted
                font.family: "JetBrains Mono"; font.pixelSize: 11
            }
        }
        PixelBorder {
            anchors.fill: parent
            z: 50
            accent: root.theme.colors.accent
            secondary: root.theme.colors.border
        }
        MouseArea {
            anchors.fill: parent
            onClicked: { root.visible = false; hideTimer.stop() }
        }
    }
}
