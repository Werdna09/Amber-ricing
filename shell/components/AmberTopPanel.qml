import QtQuick
import Quickshell
import "../popups"

Scope {
    id: root
    required property var theme
    required property var workspaces
    required property var stats
    required property var network
    required property var bluetooth
    required property var audio
    required property var battery
    required property var updates
    required property var media
    required property var keyboard

    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: window
            required property var modelData
            screen: modelData
            anchors { top: true; left: true; right: true }
            implicitHeight: 50
            exclusiveZone: 50
            color: "transparent"

            function closePopups() {
                themePopup.visible = false
                cpuPopup.visible = false
                audioPopup.visible = false
                wifiPopup.visible = false
                bluetoothPopup.visible = false
                batteryPopup.visible = false
                updatesPopup.visible = false
                mediaPopup.visible = false
            }
            function togglePopup(p) {
                let open = !p.visible
                closePopups()
                p.visible = open
            }

            SystemClock { id: clock; precision: SystemClock.Minutes }

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
                    id: leftRow
                    anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                    spacing: 7
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "✦ AMBER"
                        color: root.theme.colors.accent
                        font.family: "JetBrains Mono"
                        font.pixelSize: 13
                        font.bold: true
                    }
                    Repeater {
                        model: 4
                        delegate: Rectangle {
                            id: desktopItem
                            required property int index
                            readonly property int desktop: index + 1
                            readonly property bool active: root.workspaces.current === desktop
                            width: 28; height: 28; radius: 3
                            color: active ? root.theme.colors.accent : root.theme.colors.surface
                            border.color: active ? root.theme.colors.accent : root.theme.colors.border
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: desktopItem.desktop
                                color: desktopItem.active ? root.theme.colors.background : root.theme.colors.text
                                font.family: "JetBrains Mono"; font.pixelSize: 12
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.workspaces.switchTo(desktopItem.desktop)
                            }
                        }
                    }
                    Rectangle { width: 1; height: 22; color: root.theme.colors.border; anchors.verticalCenter: parent.verticalCenter }
                    Rectangle {
                        id: mediaButton
                        width: 155; height: 30; radius: 3
                        color: root.theme.colors.surface
                        border.width: 1; border.color: root.theme.colors.border
                        Text {
                            anchors.centerIn: parent
                            width: parent.width - 12
                            elide: Text.ElideRight
                            text: root.media.available ? (root.media.playing ? "♫ " : "Ⅱ ") + root.media.displayText : "♫ No media"
                            color: root.theme.colors.text
                            font.family: "JetBrains Mono"; font.pixelSize: 11
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: window.togglePopup(mediaPopup) }
                    }
                }
                Column {
                    anchors.centerIn: parent
                    spacing: 0
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatTime(clock.date, "HH:mm")
                        color: root.theme.colors.accent
                        font.family: "JetBrains Mono"; font.pixelSize: 16; font.bold: true
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatDate(clock.date, "ddd d. MMM")
                        color: root.theme.colors.text
                        font.family: "JetBrains Mono"; font.pixelSize: 10
                    }
                }
                Row {
                    id: rightRow
                    anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                    spacing: 5
                    WidgetButton {
                        id: cpuButton
                        theme: root.theme
                        label: "CPU " + root.stats.cpuUsage + "%"
                        onActivated: window.togglePopup(cpuPopup)
                    }
                    WidgetButton {
                        id: wifiButton
                        theme: root.theme
                        label: root.network.wifiConnected ? "◉ Wi-Fi" : "○ Wi-Fi"
                        onActivated: window.togglePopup(wifiPopup)
                    }
                    WidgetButton {
                        id: bluetoothButton
                        theme: root.theme
                        label: root.bluetooth.enabled ? "ᛒ " + root.bluetooth.connectedCount : "ᛒ —"
                        onActivated: window.togglePopup(bluetoothPopup)
                    }
                    WidgetButton {
                        id: audioButton
                        theme: root.theme
                        label: root.audio.muted ? "♫ MUTE" : "♫ " + (root.audio.available ? root.audio.volume + "%" : "—")
                        onActivated: window.togglePopup(audioPopup)
                    }
                    WidgetButton {
                        id: batteryButton
                        theme: root.theme
                        label: root.battery.available ? (root.battery.charging ? "⚡" : "▣ ") + root.battery.percentage + "%" : "▣ —"
                        onActivated: window.togglePopup(batteryPopup)
                    }
                    WidgetButton {
                        id: updatesButton
                        theme: root.theme
                        label: "↑ " + root.updates.totalCount
                        onActivated: window.togglePopup(updatesPopup)
                    }
                    WidgetButton {
                        id: keyboardButton
                        theme: root.theme
                        label: root.keyboard.displayLabel
                        onActivated: root.keyboard.nextLayout()
                    }
                    WidgetButton {
                        id: themeButton
                        theme: root.theme
                        label: "✦ " + root.theme.current.name + " ▾"
                        onActivated: window.togglePopup(themePopup)
                    }
                }

                ThemeBankPopup { id: themePopup; anchorItem: themeButton; theme: root.theme; visible: false }
                AudioPopup { theme: root.theme; id: audioPopup; anchorItem: audioButton; audioService: root.audio; visible: false }
                WifiPopup { theme: root.theme; id: wifiPopup; anchorItem: wifiButton; networkService: root.network; visible: false }
                BluetoothPopup { theme: root.theme; id: bluetoothPopup; anchorItem: bluetoothButton; bluetoothService: root.bluetooth; visible: false }
                BatteryPopup { theme: root.theme; id: batteryPopup; anchorItem: batteryButton; batteryService: root.battery; visible: false }
                UpdatesPopup { theme: root.theme; id: updatesPopup; anchorItem: updatesButton; updateService: root.updates; visible: false }
                MediaPopup { theme: root.theme; id: mediaPopup; anchorItem: mediaButton; mediaService: root.media; visible: false }
                PopupWindow {
                    id: cpuPopup
                    visible: false
                    implicitWidth: 250; implicitHeight: 110
                    color: "transparent"
                    grabFocus: true
                    anchor.item: cpuButton
                    anchor.edges: Edges.Bottom | Edges.Right
                    anchor.gravity: Edges.Bottom | Edges.Left
                    anchor.margins.top: 7
                    Rectangle {
                        anchors.fill: parent
                        radius: 4
                        color: root.theme.colors.surface
                        border.width: 1; border.color: root.theme.colors.border
                        Column {
                            anchors.centerIn: parent
                            spacing: 8
                            Text { text: "SYSTEM / CPU"; color: root.theme.colors.accent; font.pixelSize: 14; font.family: "JetBrains Mono" }
                            Text { text: "Usage: " + root.stats.cpuUsage + "%"; color: root.theme.colors.text; font.pixelSize: 12; font.family: "JetBrains Mono" }
                            Text { text: "Temp: " + (root.stats.cpuTemp > 0 ? root.stats.cpuTemp + " °C" : "N/A"); color: root.theme.colors.text; font.pixelSize: 12; font.family: "JetBrains Mono" }
                        }
                    }
                }
            }
        }
    }
}
