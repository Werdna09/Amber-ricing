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
            implicitHeight: 56
            exclusiveZone: 56
            color: "transparent"

            function closePopups() {
                themePopup.visible = false
                clockPopup.visible = false
                cpuPopup.visible = false
                audioPopup.visible = false
                wifiPopup.visible = false
                bluetoothPopup.visible = false
                batteryPopup.visible = false
                updatesPopup.visible = false
                mediaPopup.visible = false
            }
            function togglePopup(p) {
                const shouldOpen = !p.visible
                closePopups()
                p.visible = shouldOpen
            }

            SystemClock { id: clock; precision: SystemClock.Minutes }

            Rectangle {
                id: frame
                anchors { fill: parent; margins: 3 }
                radius: 0
                color: "#121111"
                border.width: 1
                border.color: root.theme.colors.accent

                // A discreet second border, avoiding heavy fantasy ornaments.
                Rectangle {
                    anchors { fill: parent; margins: 2 }
                    color: "transparent"
                    border.width: 1
                    border.color: root.theme.colors.border
                    opacity: 0.7
                }

                // Four precise, axis-aligned pixel corners. No rotations/overlap.
                Repeater {
                    model: 4
                    delegate: Item {
                        required property int index
                        width: 12; height: 12
                        x: index % 2 === 0 ? 0 : frame.width - width
                        y: index < 2 ? 0 : frame.height - height
                        Rectangle {
                            width: 11; height: 2
                            x: parent.index % 2 === 0 ? 0 : parent.width - width
                            y: parent.index < 2 ? 0 : parent.height - height
                            color: root.theme.colors.accent
                        }
                        Rectangle {
                            width: 2; height: 11
                            x: parent.index % 2 === 0 ? 0 : parent.width - width
                            y: parent.index < 2 ? 0 : parent.height - height
                            color: root.theme.colors.accent
                        }
                    }
                }

                Row {
                    id: leftRow
                    anchors { left: parent.left; leftMargin: 22; verticalCenter: parent.verticalCenter }
                    spacing: 9
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "♨"
                        color: root.theme.colors.accent
                        font.family: "DejaVu Sans"
                        font.pixelSize: 23
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "AMBER"
                        color: root.theme.colors.accent
                        font.family: "JetBrains Mono"
                        font.pixelSize: 14
                        font.bold: true
                    }
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 1; height: 24; color: root.theme.colors.border
                    }
                    Repeater {
                        model: 4
                        delegate: Rectangle {
                            id: desktopItem
                            required property int index
                            readonly property int desktop: index + 1
                            readonly property bool active: root.workspaces.current === desktop
                            width: 34; height: 34; radius: 3
                            color: active ? root.theme.colors.surface : "#171616"
                            border.color: active ? root.theme.colors.accent : root.theme.colors.border
                            border.width: active ? 2 : 1
                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                radius: parent.radius
                                border.width: desktopItem.active ? 1 : 0
                                border.color: root.theme.colors.accent
                                opacity: 0.25
                            }
                            Text {
                                anchors.centerIn: parent
                                text: desktopItem.desktop
                                color: desktopItem.active ? root.theme.colors.accent : root.theme.colors.text
                                font.family: "JetBrains Mono"
                                font.pixelSize: 14
                                font.bold: desktopItem.active
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.workspaces.switchTo(desktopItem.desktop)
                            }
                        }
                    }
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 1; height: 24; color: root.theme.colors.border
                    }
                    Rectangle {
                        id: mediaButton
                        width: 155; height: 32; radius: 2
                        color: mediaMouse.containsMouse ? root.theme.colors.surface : "#161515"
                        border.width: 1
                        border.color: mediaMouse.containsMouse ? root.theme.colors.accent : root.theme.colors.border
                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 8; anchors.rightMargin: 8
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            wrapMode: Text.NoWrap
                            text: root.media.available
                                ? (root.media.playing ? "♫ " : "Ⅱ ") + root.media.displayText
                                : "♫ No media"
                            color: root.theme.colors.text
                            font.family: "JetBrains Mono"
                            font.pixelSize: 11
                        }
                        MouseArea {
                            id: mediaMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: window.togglePopup(mediaPopup)
                        }
                    }
                }

                // Truly screen-centered: not centered between the left and right groups.
                Item {
                    id: clockButton
                    anchors.centerIn: parent
                    width: 230; height: 46
                    Rectangle {
                        anchors.fill: parent
                        radius: 2
                        color: clockMouse.containsMouse ? root.theme.colors.surface : "transparent"
                        border.width: clockPopup.visible ? 1 : 0
                        border.color: root.theme.colors.accent
                    }
                    MouseArea {
                        id: clockMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: window.togglePopup(clockPopup)
                    }
                    Column {
                        anchors.centerIn: parent
                        spacing: 0
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatTime(clock.date, "HH:mm")
                        color: root.theme.colors.text
                        font.family: "JetBrains Mono"
                        font.pixelSize: 17
                        font.bold: true
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatDate(clock.date, "ddd, d. MMM yyyy")
                        color: root.theme.colors.muted
                        font.family: "JetBrains Mono"
                        font.pixelSize: 10
                    }
                }
                }

                Row {
                    id: rightRow
                    anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
                    spacing: 5
                    WidgetButton {
                        id: cpuButton
                        theme: root.theme
                        label: "CPU " + root.stats.cpuUsage + "%  " +
                            (root.stats.cpuTemp > 0 ? root.stats.cpuTemp + "°" : "—")
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
                        label: root.battery.available ? (root.battery.charging ? "⚡ " : "▣ ") + root.battery.percentage + "%" : "▣ —"
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
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 1; height: 24; color: root.theme.colors.border
                    }
                    WidgetButton {
                        id: themeButton
                        theme: root.theme
                        selected: themePopup.visible
                        label: "◈ " + root.theme.current.name + " ▾"
                        onActivated: window.togglePopup(themePopup)
                    }
                }

                CalendarPopup {
                    id: clockPopup
                    anchorItem: clockButton
                    theme: root.theme
                    clockService: clock
                    visible: false
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
                        radius: 3
                        color: root.theme.colors.surface
                        border.width: 1; border.color: root.theme.colors.accent
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
