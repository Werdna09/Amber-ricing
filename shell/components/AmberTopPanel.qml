import QtQuick
import Quickshell
import "../popups"

Scope {
    id: root
    required property var theme
    required property var workspaces

    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: panelWindow
            required property var modelData
            screen: modelData
            anchors { top: true; left: true; right: true }
            implicitHeight: 50
            exclusiveZone: 50
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: root.theme.colors.background
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: root.theme.colors.border
                }
                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 12
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "✦ AMBER"
                        color: root.theme.colors.accent
                        font.family: "JetBrains Mono"
                        font.bold: true
                        font.pixelSize: 13
                    }
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4
                        Repeater {
                            model: 4
                            delegate: Rectangle {
                                id: workspaceButton
                                required property int index
                                property int desktopNumber: index + 1
                                property bool active: root.workspaces.current === desktopNumber
                                width: 30; height: 30; radius: 3
                                color: active ? root.theme.colors.accent : root.theme.colors.surface
                                border.width: 1
                                border.color: active ? root.theme.colors.accent : root.theme.colors.border
                                Text {
                                    anchors.centerIn: parent
                                    text: workspaceButton.desktopNumber
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 12
                                    color: workspaceButton.active ? root.theme.colors.background : root.theme.colors.text
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.workspaces.switchTo(workspaceButton.desktopNumber)
                                }
                            }
                        }
                    }
                }
                Column {
                    anchors.centerIn: parent
                    spacing: 0
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatTime(clock.date, "HH:mm")
                        font.family: "JetBrains Mono"
                        font.bold: true
                        font.pixelSize: 16
                        color: root.theme.colors.accent
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatDate(clock.date, "ddd d. MMM")
                        font.family: "JetBrains Mono"
                        font.pixelSize: 10
                        color: root.theme.colors.text
                    }
                }
                Rectangle {
                    id: paletteButton
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    width: paletteLabel.implicitWidth + 24
                    height: 32
                    radius: 3
                    color: root.theme.colors.surface
                    border.width: 1
                    border.color: bankPopup.visible ? root.theme.colors.accent : root.theme.colors.border
                    Text {
                        id: paletteLabel
                        anchors.centerIn: parent
                        text: "✦ " + root.theme.current.name + "  ▾"
                        color: root.theme.colors.text
                        font.family: "JetBrains Mono"
                        font.pixelSize: 12
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: bankPopup.visible = !bankPopup.visible
                    }
                }
                ThemeBankPopup {
                    id: bankPopup
                    anchorItem: paletteButton
                    theme: root.theme
                    visible: false
                }
            }
            SystemClock { id: clock; precision: SystemClock.Minutes }
        }
    }
}
