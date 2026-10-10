import QtQuick
import Quickshell
import "../components/chrome"

PopupWindow {
    id: root
    required property Item anchorItem
    required property var theme
    required property var notifications

    implicitWidth: 390
    implicitHeight: 480
    color: "transparent"
    grabFocus: true
    anchor.item: anchorItem
    anchor.edges: Edges.Bottom | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right
    anchor.margins.top: 7
    anchor.adjustment: PopupAdjustment.SlideX

    onVisibleChanged: {
        if (visible) notifications.markRead()
    }

    Rectangle {
        anchors.fill: parent
        color: root.theme.colors.background
        border.width: 1
        border.color: root.theme.colors.accent
        radius: 1
        clip: true

        Image {
            anchors.fill: parent
            source: "../assets/stone-grain.png"
            fillMode: Image.Tile
            opacity: 0.10
            smooth: false
        }

        Column {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            Row {
                width: parent.width
                height: 30
                spacing: 8
                Text {
                    text: "BONFIRE / MESSAGES"
                    color: root.theme.colors.accent
                    font.family: "JetBrains Mono"
                    font.pixelSize: 14
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
                Item { width: 1; height: 1 }
            }

            Row {
                width: parent.width
                height: 34
                spacing: 9
                Rectangle {
                    id: dndToggle
                    width: 186; height: 30; radius: 1
                    color: root.notifications.doNotDisturb ? root.theme.colors.surface : root.theme.colors.background
                    border.width: 1
                    border.color: root.notifications.doNotDisturb ? root.theme.colors.accent : root.theme.colors.border
                    Text {
                        anchors.centerIn: parent
                        text: root.notifications.doNotDisturb ? "☾ DND ENABLED" : "☾ DO NOT DISTURB"
                        color: root.notifications.doNotDisturb ? root.theme.colors.accent : root.theme.colors.text
                        font.family: "JetBrains Mono"; font.pixelSize: 10
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.notifications.doNotDisturb = !root.notifications.doNotDisturb
                    }
                }
                Rectangle {
                    width: 1; height: 1
                    visible: false
                }
                Rectangle {
                    width: 130; height: 30; radius: 1
                    color: root.theme.colors.surface
                    border.width: 1
                    border.color: root.theme.colors.border
                    Text {
                        anchors.centerIn: parent
                        text: "CLEAR ALL"
                        color: root.theme.colors.text
                        font.family: "JetBrains Mono"; font.pixelSize: 10
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.notifications.clearAll()
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: root.theme.colors.border }
            Text {
                text: root.notifications.entries.length + " messages / current session"
                color: root.theme.colors.muted
                font.family: "JetBrains Mono"; font.pixelSize: 10
            }

            Item {
                width: parent.width
                height: 336
                Text {
                    anchors.centerIn: parent
                    visible: root.notifications.entries.length === 0
                    text: "NO ASHES TO READ\n\nYour bonfire is quiet."
                    horizontalAlignment: Text.AlignHCenter
                    color: root.theme.colors.muted
                    font.family: "JetBrains Mono"; font.pixelSize: 12
                }

                Flickable {
                    anchors.fill: parent
                    visible: root.notifications.entries.length > 0
                    clip: true
                    contentWidth: width
                    contentHeight: messageColumn.implicitHeight
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: messageColumn
                        width: parent.width
                        spacing: 7

                        Repeater {
                            model: root.notifications.entries
                            delegate: Rectangle {
                                id: messageCard
                                required property var modelData
                                width: messageColumn.width
                                height: details.implicitHeight + 24
                                radius: 1
                                color: root.theme.colors.surface
                                border.width: 1
                                border.color: modelData.unread ? root.theme.colors.accent : root.theme.colors.border

                                Column {
                                    id: details
                                    x: 11; y: 10
                                    width: parent.width - 50
                                    spacing: 5
                                    Text {
                                        width: parent.width
                                        text: messageCard.modelData.app + "  ·  " + messageCard.modelData.time
                                        textFormat: Text.PlainText
                                        elide: Text.ElideRight
                                        color: root.theme.colors.muted
                                        font.family: "JetBrains Mono"; font.pixelSize: 10
                                    }
                                    Text {
                                        width: parent.width
                                        text: messageCard.modelData.title
                                        textFormat: Text.PlainText
                                        elide: Text.ElideRight
                                        font.bold: true
                                        color: root.theme.colors.text
                                        font.family: "JetBrains Mono"; font.pixelSize: 12
                                    }
                                    Text {
                                        width: parent.width
                                        visible: text.length > 0
                                        text: messageCard.modelData.body
                                        textFormat: Text.PlainText
                                        wrapMode: Text.Wrap
                                        maximumLineCount: 4
                                        elide: Text.ElideRight
                                        color: root.theme.colors.text
                                        font.family: "JetBrains Mono"; font.pixelSize: 11
                                    }
                                    Row {
                                        spacing: 5
                                        visible: messageCard.modelData.actions.length > 0
                                        Repeater {
                                            model: messageCard.modelData.actions
                                            delegate: Rectangle {
                                                required property var modelData
                                                width: Math.min(108, actionLabel.implicitWidth + 14)
                                                height: 24; radius: 1
                                                color: root.theme.colors.background
                                                border.width: 1
                                                border.color: root.theme.colors.accent
                                                Text {
                                                    id: actionLabel
                                                    anchors.centerIn: parent
                                                    text: modelData.label
                                                    textFormat: Text.PlainText
                                                    color: root.theme.colors.accent
                                                    font.family: "JetBrains Mono"; font.pixelSize: 10
                                                }
                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: root.notifications.invokeAction(messageCard.modelData.uid, modelData.index)
                                                }
                                            }
                                        }
                                    }
                                }
                                Text {
                                    anchors { top: parent.top; right: parent.right; topMargin: 10; rightMargin: 11 }
                                    text: "×"
                                    color: root.theme.colors.accent
                                    font.family: "JetBrains Mono"; font.pixelSize: 19
                                    MouseArea {
                                        anchors.fill: parent
                                        anchors.margins: -7
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.notifications.dismiss(messageCard.modelData.uid)
                                    }
                                }
                            }
                        }
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
