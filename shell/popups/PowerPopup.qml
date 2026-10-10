import QtQuick
import Quickshell
import "../components/chrome"

// AMBER_THEME_POWER_V1
// Dark-fantasy power menu. Every action requires a second explicit click.
PopupWindow {
    id: root
    required property Item anchorItem
    required property var theme
    property string pendingAction: ""
    property string pendingLabel: ""

    implicitWidth: 322
    implicitHeight: 420
    color: "transparent"
    grabFocus: true
    anchor.item: root.anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.margins.top: 7
    anchor.adjustment: PopupAdjustment.SlideX | PopupAdjustment.FlipX

    readonly property var commands: [
        { key: "lock", label: "UZAMKNOUT", detail: "Zamknout obrazovku" },
        { key: "suspend", label: "USPAT", detail: "Pozastavit počítač" },
        { key: "logout", label: "ODHLASIT", detail: "Ukončit relaci KDE" },
        { key: "reboot", label: "RESTART", detail: "Restartovat počítač" },
        { key: "shutdown", label: "VYPNOUT", detail: "Vypnout počítač" }
    ]

    onVisibleChanged: {
        if (!visible) {
            pendingAction = ""
            pendingLabel = ""
        }
    }

    function executePending() {
        if (pendingAction === "")
            return
        const selected = pendingAction
        root.visible = false
        Quickshell.execDetached([
            "python3",
            Quickshell.shellDir + "/../scripts/power/action.py",
            "--action", selected
        ])
    }

    Rectangle {
        anchors.fill: parent
        color: root.theme.colors.background
        border.width: 1
        border.color: root.theme.colors.border
        radius: 1

        Image {
            anchors.fill: parent
            source: "../assets/stone-grain.png"
            fillMode: Image.Tile
            opacity: 0.12
            smooth: false
        }

        Column {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            Text {
                text: "BONFIRE / SYSTEM"
                color: root.theme.colors.accent
                font.family: "JetBrains Mono"
                font.pixelSize: 15
                font.bold: true
            }
            Text {
                text: "Vyber akci a potvrď ji."
                color: root.theme.colors.muted
                font.family: "JetBrains Mono"
                font.pixelSize: 10
            }

            Repeater {
                model: root.commands
                delegate: Rectangle {
                    id: choice
                    required property var modelData
                    width: parent.width
                    height: 45
                    radius: 1
                    color: root.pendingAction === modelData.key
                           ? root.theme.colors.surface : root.theme.colors.background
                    border.width: root.pendingAction === modelData.key ? 2 : 1
                    border.color: root.pendingAction === modelData.key || hit.containsMouse
                                  ? root.theme.colors.accent : root.theme.colors.border

                    SoulsHighlight {
                        anchors.fill: parent
                        theme: root.theme
                        hovered: hit.containsMouse
                        selected: root.pendingAction === choice.modelData.key
                    }
                    Image {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        width: 30
                        height: 30
                        source: Qt.resolvedUrl("../assets/icons/power-actions/" + choice.modelData.key + ".png")
                        fillMode: Image.PreserveAspectFit
                        smooth: false
                        mipmap: false
                    }
                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: 50
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        Text {
                            text: choice.modelData.label
                            color: root.theme.colors.text
                            font.family: "JetBrains Mono"
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: choice.modelData.detail
                            color: root.theme.colors.muted
                            font.family: "JetBrains Mono"
                            font.pixelSize: 9
                        }
                    }
                    MouseArea {
                        id: hit
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.pendingAction = choice.modelData.key
                            root.pendingLabel = choice.modelData.label
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: root.theme.colors.border
                opacity: 0.8
            }
            Text {
                width: parent.width
                height: 18
                text: root.pendingAction === "" ? "Nejprve vyber akci." : "Potvrdit: " + root.pendingLabel + "?"
                color: root.pendingAction === "" ? root.theme.colors.muted : root.theme.colors.accent
                font.family: "JetBrains Mono"
                font.pixelSize: 10
                elide: Text.ElideRight
            }
            Row {
                width: parent.width
                spacing: 8
                Rectangle {
                    id: cancelButton
                    width: (parent.width - 8) / 2
                    height: 30
                    color: root.theme.colors.surface
                    border.width: 1
                    border.color: cancelMouse.containsMouse ? root.theme.colors.accent : root.theme.colors.border
                    Text {
                        anchors.centerIn: parent
                        text: "ZRUŠIT"
                        color: root.theme.colors.text
                        font.family: "JetBrains Mono"
                        font.pixelSize: 11
                    }
                    MouseArea {
                        id: cancelMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.visible = false
                    }
                }
                Rectangle {
                    width: (parent.width - 8) / 2
                    height: 30
                    opacity: root.pendingAction === "" ? 0.45 : 1.0
                    color: root.theme.colors.surface
                    border.width: 1
                    border.color: confirmMouse.containsMouse && root.pendingAction !== ""
                                  ? root.theme.colors.text : root.theme.colors.accent
                    Text {
                        anchors.centerIn: parent
                        text: "POTVRDIT"
                        color: root.theme.colors.accent
                        font.family: "JetBrains Mono"
                        font.pixelSize: 11
                        font.bold: true
                    }
                    MouseArea {
                        id: confirmMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: root.pendingAction !== ""
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.executePending()
                    }
                }
            }
        }
        PixelBorder {
            anchors.fill: parent
            z: 50
            accent: root.theme.colors.accent
            secondary: root.theme.colors.border
        }
    }
}
