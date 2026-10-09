import QtQuick
import Quickshell
import "../components/chrome"

PopupWindow {
    id: root
    required property Item anchorItem
    required property var theme
    implicitWidth: 436
    implicitHeight: 575
    color: "transparent"
    grabFocus: true
    anchor.item: anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.margins.top: 7
    anchor.adjustment: PopupAdjustment.SlideX | PopupAdjustment.FlipX

    Rectangle {
        anchors.fill: parent
        // Seamless understated pixel grain (passive; behind interactive content).
        Image {
            anchors.fill: parent
            source: "../assets/stone-grain.png"
            fillMode: Image.Tile
            opacity: 0.12
            smooth: false
        }
        color: root.theme.colors.background
        radius: 1
        border.width: 1
        border.color: root.theme.colors.border

        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 9
            Text {
                text: "THEME BANK"
                color: root.theme.colors.accent
                font.family: "JetBrains Mono"
                font.pixelSize: 16
                font.bold: true
            }
            Repeater {
                model: ["day", "night"]
                delegate: Column {
                    id: group
                    required property string modelData
                    width: parent.width
                    spacing: 5
                    Text {
                        text: group.modelData === "day" ? "☀ BONFIRE DUSK" : "☾ EMBER MOON"
                        color: root.theme.colors.muted
                        font.family: "JetBrains Mono"
                        font.pixelSize: 12
                    }
                    Repeater {
                        model: root.theme.palettes.filter(p => p.mode === group.modelData)
                        delegate: Rectangle {
                            id: paletteEntry
                            required property var modelData
                            width: group.width
                            height: 42
                            radius: 3
                            color: root.theme.selectedId === modelData.id ? root.theme.colors.surface : root.theme.colors.background
                            border.width: root.theme.selectedId === modelData.id ? 2 : 1
                            border.color: root.theme.selectedId === modelData.id ? root.theme.colors.accent : root.theme.colors.border
                            Row {
                                anchors.fill: parent
                                anchors.margins: 7
                                spacing: 5
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 176
                                    text: paletteEntry.modelData.name
                                    elide: Text.ElideRight
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 12
                                    color: root.theme.colors.text
                                }
                                Repeater {
                                    model: ["background", "surface", "border", "muted", "accent", "text"]
                                    delegate: Rectangle {
                                        required property string modelData
                                        width: 28; height: 24; radius: 1
                                        color: paletteEntry.modelData.colors[modelData]
                                        border.width: 1
                                        border.color: root.theme.colors.border
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.theme.selectPalette(paletteEntry.modelData.id)
                                    root.visible = false
                                }
                            }
                        }
                    }
                }
            }
        }
        // Decorative only: never intercepts clicks on controls or network rows.
        PixelBorder {
            anchors.fill: parent
            z: 50
            accent: root.theme.colors.accent
            secondary: root.theme.colors.border
        }

    }
}
