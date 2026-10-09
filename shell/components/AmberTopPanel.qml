import QtQuick
import Quickshell
import "../popups"
import "chrome"

// Amber v3: faithful pixel-fantasy appearance; all service APIs are unchanged.
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
            implicitHeight: 62
            exclusiveZone: 62
            color: "transparent"

            readonly property bool compact: width < 1600
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
                const shouldOpen = !p.visible;
                closePopups();
                p.visible = shouldOpen;
            }

            SystemClock { id: clock; precision: SystemClock.Minutes }

            PixelSurface {
                id: frame
                anchors { fill: parent; margins: 3 }
                theme: root.theme

                Row {
                    id: leftRow
                    anchors { left: parent.left; leftMargin: 22; verticalCenter: parent.verticalCenter }
                    spacing: 8
                    BonfireMark {
                        anchors.verticalCenter: parent.verticalCenter
                        theme: root.theme
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "AMBER"
                        color: root.theme.colors.accent
                        font.family: "JetBrains Mono"
                        font.pixelSize: 14
                        font.bold: true
                        font.letterSpacing: 1
                    }
                    PixelDivider { anchors.verticalCenter: parent.verticalCenter; theme: root.theme }
                    Repeater {
                        model: 4
                        delegate: Rectangle {
                            id: desktopItem
                            required property int index
                            readonly property int desktop: index + 1
                            readonly property bool active: root.workspaces.current === desktop
                            width: 34; height: 34; radius: 1
                            color: active ? root.theme.colors.surface
                                          : Qt.darker(root.theme.colors.background, 1.35)
                            border.width: active ? 2 : 1
                            border.color: active ? root.theme.colors.accent : root.theme.colors.border
                            Behavior on border.color { ColorAnimation { duration: 140 } }
                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 3
                                color: "transparent"
                                border.width: desktopItem.active ? 1 : 0
                                border.color: root.theme.colors.accent
                                opacity: 0.32
                            }
                            Text {
                                anchors.centerIn: parent
                                text: desktopItem.desktop
                                font.family: "JetBrains Mono"
                                font.pixelSize: 14
                                font.bold: desktopItem.active
                                color: desktopItem.active ? root.theme.colors.accent
                                                          : root.theme.colors.text
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.workspaces.switchTo(desktopItem.desktop)
                            }
                        }
                    }
                    PixelDivider {
                        anchors.verticalCenter: parent.verticalCenter
                        theme: root.theme
                        visible: mediaButton.visible
                    }
                    Rectangle {
                        id: mediaButton
                        visible: !window.compact
                        width: 167; height: 32; radius: 1
                        color: mediaMouse.containsMouse ? root.theme.colors.surface
                              : Qt.darker(root.theme.colors.background, 1.35)
                        border.width: 1
                        border.color: mediaMouse.containsMouse ? root.theme.colors.accent
                                                             : root.theme.colors.border
                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 9; anchors.rightMargin: 9
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.NoWrap
                            elide: Text.ElideRight
                            maximumLineCount: 1
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

                // Clock is fixed at screen center, independent of the two unequal side groups.
                Item {
                    id: clockButton
                    anchors.centerIn: parent
                    width: 200; height: 48
                    Rectangle {
                        anchors.fill: parent
                        color: clockMouse.containsMouse ? root.theme.colors.surface : "transparent"
                        border.width: clockPopup.visible ? 1 : 0
                        border.color: root.theme.colors.accent
                        radius: 1
                    }
                    Rectangle { width: 1; height: 29; anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; color: root.theme.colors.border }
                    Rectangle { width: 1; height: 29; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; color: root.theme.colors.border }
                    Column {
                        anchors.centerIn: parent
                        spacing: 0
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Qt.formatTime(clock.date, "HH:mm")
                            color: root.theme.colors.text
                            font.family: "JetBrains Mono"
                            font.pixelSize: 19
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
                    MouseArea {
                        id: clockMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: window.togglePopup(clockPopup)
                    }
                }

                Row {
                    id: rightRow
                    anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
                    spacing: 5
                    WidgetButton {
                        id: cpuButton
                        theme: root.theme
                        selected: cpuPopup.visible
                        label: "CPU " + root.stats.cpuUsage + "% " +
                               (root.stats.cpuTemp > 0 ? root.stats.cpuTemp + "°" : "—")
                        onActivated: window.togglePopup(cpuPopup)
                    }
                    WidgetButton {
                        id: wifiButton
                        theme: root.theme
                        selected: wifiPopup.visible
                        label: window.compact ? "◉" : (root.network.wifiConnected ? "◉ Wi-Fi" : "○ Wi-Fi")
                        onActivated: window.togglePopup(wifiPopup)
                    }
                    WidgetButton {
                        id: bluetoothButton
                        theme: root.theme
                        selected: bluetoothPopup.visible
                        label: root.bluetooth.enabled ? "ᛒ" + (window.compact ? "" : " " + root.bluetooth.connectedCount) : "ᛒ —"
                        onActivated: window.togglePopup(bluetoothPopup)
                    }
                    WidgetButton {
                        id: audioButton
                        theme: root.theme
                        selected: audioPopup.visible
                        label: root.audio.muted ? "♫ MUTE" : "♫ " + (root.audio.available ? root.audio.volume + "%" : "—")
                        onActivated: window.togglePopup(audioPopup)
                    }
                    WidgetButton {
                        id: batteryButton
                        theme: root.theme
                        selected: batteryPopup.visible
                        label: root.battery.available
                               ? (root.battery.charging ? "⚡" : "▣ ") + root.battery.percentage + "%"
                               : "▣ —"
                        onActivated: window.togglePopup(batteryPopup)
                    }
                    WidgetButton {
                        id: updatesButton
                        theme: root.theme
                        selected: updatesPopup.visible
                        label: "↑ " + root.updates.totalCount
                        onActivated: window.togglePopup(updatesPopup)
                    }
                    WidgetButton {
                        id: keyboardButton
                        theme: root.theme
                        label: root.keyboard.displayLabel
                        onActivated: root.keyboard.nextLayout()
                    }
                    PixelDivider { anchors.verticalCenter: parent.verticalCenter; theme: root.theme }
                    WidgetButton {
                        id: themeButton
                        theme: root.theme
                        selected: themePopup.visible
                        label: (window.compact ? "" : "◈ ") + root.theme.current.name + " ▾"
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
                AudioPopup { id: audioPopup; theme: root.theme; anchorItem: audioButton; audioService: root.audio; visible: false }
                WifiPopup { id: wifiPopup; theme: root.theme; anchorItem: wifiButton; networkService: root.network; visible: false }
                BluetoothPopup { id: bluetoothPopup; theme: root.theme; anchorItem: bluetoothButton; bluetoothService: root.bluetooth; visible: false }
                BatteryPopup { id: batteryPopup; theme: root.theme; anchorItem: batteryButton; batteryService: root.battery; visible: false }
                UpdatesPopup { id: updatesPopup; theme: root.theme; anchorItem: updatesButton; updateService: root.updates; visible: false }
                MediaPopup { id: mediaPopup; theme: root.theme; anchorItem: mediaButton; mediaService: root.media; visible: false }
                PopupWindow {
                    id: cpuPopup
                    visible: false
                    implicitWidth: 250; implicitHeight: 112
                    color: "transparent"
                    grabFocus: true
                    anchor.item: cpuButton
                    anchor.edges: Edges.Bottom | Edges.Right
                    anchor.gravity: Edges.Bottom | Edges.Left
                    anchor.margins.top: 7
                    PixelSurface {
                        anchors.fill: parent
                        theme: root.theme
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
