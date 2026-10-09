import QtQuick
import Quickshell
import "theme"

ShellRoot {
    id: root
    ThemeManager { id: theme }

    // Docasne samostatne testovaci okno; zadny systemovy panel.
    FloatingWindow {
        id: preview
        visible: true
        title: "Amber — Theme Bank Preview"
        implicitWidth: 850
        implicitHeight: 670
        color: theme.colors.background

        Rectangle {
            anchors.fill: parent
            color: theme.colors.background

            Column {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 16

                Text {
                    text: "AMBER  /  THEME BANK"
                    font.pixelSize: 25
                    font.bold: true
                    color: theme.colors.accent
                }
                Text {
                    text: "Active: " + theme.current.name
                    font.pixelSize: 15
                    color: theme.colors.text
                }

                Rectangle {
                    width: parent.width
                    height: 2
                    color: theme.colors.border
                }

                Flickable {
                    width: parent.width
                    height: parent.height - 105
                    contentHeight: choices.implicitHeight
                    clip: true
                    Column {
                        id: choices
                        width: parent.width
                        spacing: 8

                        Repeater {
                            model: theme.palettes
                            delegate: Rectangle {
                                id: entry
                                required property var modelData
                                width: choices.width
                                height: 47
                                radius: 5
                                color: theme.selectedId === modelData.id
                                    ? theme.colors.surface : theme.colors.background
                                border.width: theme.selectedId === modelData.id ? 2 : 1
                                border.color: theme.selectedId === modelData.id
                                    ? theme.colors.accent : theme.colors.border

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 9
                                    spacing: 10
                                    Text {
                                        width: 185
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: entry.modelData.name
                                        color: theme.colors.text
                                        font.pixelSize: 14
                                        elide: Text.ElideRight
                                    }
                                    Repeater {
                                        model: ["background", "surface", "border", "muted", "accent", "text"]
                                        delegate: Rectangle {
                                            required property string modelData
                                            width: 64
                                            height: 27
                                            radius: 3
                                            color: entry.modelData.colors[modelData]
                                            border.width: 1
                                            border.color: "#777777"
                                        }
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: theme.selectPalette(entry.modelData.id)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
