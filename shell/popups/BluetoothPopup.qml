import QtQuick
import Quickshell
import Quickshell.Bluetooth
import "../components/chrome"

PopupWindow {
    id: root
    required property var theme

    required property Item anchorItem
    required property var bluetoothService

    implicitWidth: 360
    implicitHeight: 420

    color: "transparent"
    grabFocus: true

    anchor.item: root.anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.margins.top: 7


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

        radius: 1

        color: root.theme.colors.background

        border.width: 1
        border.color: root.theme.colors.border


        Text {
            id: title

            anchors {
                top: parent.top
                left: parent.left

                topMargin: 15
                leftMargin: 16
            }

            text: "Bluetooth"

            color: root.theme.colors.text

            font.family: "JetBrains Mono"
            font.pixelSize: 15
            font.bold: true
        }


        Rectangle {
            // Amber pixel-switch: theme-aware, square frame.
            border.width: 1
            border.color: root.bluetoothService.enabled ? root.theme.colors.accent : root.theme.colors.border
            anchors {
                right: parent.right
                verticalCenter:
                    title.verticalCenter

                rightMargin: 16
            }

            width: 44
            height: 24

            radius: 2

            color:
                root.bluetoothService.enabled
                    ? root.theme.colors.accent
                    : root.theme.colors.surface


            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }


            Rectangle {
                width: 18
                height: 18

                radius: 1

                anchors.verticalCenter:
                    parent.verticalCenter

                x:
                    root.bluetoothService.enabled
                        ? parent.width - width - 3
                        : 3

                color:
                    root.bluetoothService.enabled
                        ? root.theme.colors.background
                        : root.theme.colors.muted


                Behavior on x {
                    NumberAnimation {
                        duration: 150
                    }
                }
            }


            MouseArea {
                anchors.fill: parent

                cursorShape:
                    Qt.PointingHandCursor

                onClicked: {
                    root.bluetoothService
                        .toggleEnabled()
                }
            }
        }


        Rectangle {
            id: statusCard

            // Passive pixel corner frame, follows Theme Bank instantly.
            PixelBorder {
                anchors.fill: parent
                z: 10
                innerLine: false
                opacity: 0.62
                visible: root.bluetoothService.enabled
                accent: root.theme.colors.accent
                secondary: root.theme.colors.border
            }

            anchors {
                top: title.bottom
                left: parent.left
                right: parent.right

                topMargin: 14
                leftMargin: 14
                rightMargin: 14
            }

            height: 58

            radius: 2

            color:
                root.bluetoothService.enabled
                    ? root.theme.colors.surface
                    : root.theme.colors.surface

            border.width: 1

            border.color:
                root.bluetoothService.enabled
                    ? root.theme.colors.accent
                    : root.theme.colors.surface


            Text {
                anchors {
                    top: parent.top
                    left: parent.left

                    topMargin: 10
                    leftMargin: 12
                }

                text:
                    !root.bluetoothService.available
                        ? "Bluetooth není dostupný"
                        : root.bluetoothService.enabled
                            ? "Bluetooth zapnutý"
                            : "Bluetooth vypnutý"

                color: root.theme.colors.text

                font.family: "JetBrains Mono"
                font.pixelSize: 12
                font.bold: true
            }


            Text {
                anchors {
                    bottom: parent.bottom
                    left: parent.left

                    bottomMargin: 9
                    leftMargin: 12
                }

                text:
                    root.bluetoothService.connectedCount === 0
                        ? "Žádné připojené zařízení"
                        : root.bluetoothService.connectedCount === 1
                            ? "1 připojené zařízení"
                            : root.bluetoothService.connectedCount
                                + " připojená zařízení"

                color:
                    root.bluetoothService.connectedCount > 0
                        ? root.theme.colors.accent
                        : root.theme.colors.muted

                font.family: "JetBrains Mono"
                font.pixelSize: 10
            }
        }


        Text {
            id: devicesTitle

            anchors {
                top: statusCard.bottom
                left: parent.left

                topMargin: 14
                leftMargin: 16
            }

            text: "Zařízení"

            color: root.theme.colors.muted

            font.family: "JetBrains Mono"
            font.pixelSize: 10
            font.bold: true
        }


        Rectangle {
            anchors {
                right: parent.right
                verticalCenter:
                    devicesTitle.verticalCenter

                rightMargin: 14
            }

            width: 82
            height: 26
            border.width: 1
            border.color: root.bluetoothService.discovering
                ? root.theme.colors.accent : root.theme.colors.border

            radius: 2

            color:
                root.bluetoothService.discovering
                    ? root.theme.colors.accent
                    : root.theme.colors.surface


            Text {
                anchors.centerIn: parent

                text:
                    root.bluetoothService.discovering
                        ? "STOP"
                        : "HLEDAT"

                color:
                    root.bluetoothService.discovering
                        ? root.theme.colors.background
                        : root.theme.colors.text

                font.family: "JetBrains Mono"
                font.pixelSize: 9
                font.bold: true
            }


            MouseArea {
                anchors.fill: parent

                enabled:
                    root.bluetoothService.enabled

                cursorShape:
                    Qt.PointingHandCursor

                onClicked: {
                    root.bluetoothService
                        .toggleDiscovery()
                }
            }
        }


        ListView {
            id: deviceList

            anchors {
                top: devicesTitle.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom

                topMargin: 10
                leftMargin: 10
                rightMargin: 10
                bottomMargin: 10
            }

            spacing: 3
            clip: true

            model:
                root.bluetoothService.enabled
                    ? root.bluetoothService.devices
                    : null


            delegate: Rectangle {
                id: deviceRow

                // Only the connected row gets an ornamental pixel outline.
                PixelBorder {
                    anchors.fill: parent
                    z: 8
                    innerLine: false
                    opacity: 0.55
                    visible: modelData.connected
                    accent: root.theme.colors.accent
                    secondary: root.theme.colors.border
                }

                required property var modelData

                width: ListView.view.width
                height: 58

                radius: 1

                color: "transparent"

                border.width:
                    modelData.connected || modelData.paired || deviceMouse.containsMouse ? 1 : 0

                border.color: root.theme.colors.accent


                SoulsHighlight {
                    anchors.fill: parent
                    theme: root.theme
                    selected: deviceRow.modelData.connected
                    hovered: deviceMouse.containsMouse
                }

                Text {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: actionButton.left

                        topMargin: 8
                        leftMargin: 9
                        rightMargin: 8
                    }

                    text:
                        modelData.name.length > 0
                            ? modelData.name
                            : modelData.address

                    elide: Text.ElideRight

                    color: root.theme.colors.text

                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    font.bold: modelData.connected
                }


                Text {
                    anchors {
                        bottom: parent.bottom
                        left: parent.left

                        bottomMargin: 8
                        leftMargin: 9
                    }

                    text:
                        modelData.connected
                            ? (
                                modelData.batteryAvailable
                                    ? "Připojeno · "
                                        + Math.round(
                                            modelData.battery
                                            * 100
                                        )
                                        + "%"
                                    : "Připojeno"
                            )
                            : modelData.pairing
                                ? "Párování…"
                                : modelData.paired
                                    ? "Spárováno"
                                    : "Nové zařízení"

                    color:
                        modelData.connected
                            ? root.theme.colors.accent
                            : modelData.paired
                                ? root.theme.colors.accent
                                : root.theme.colors.muted

                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                }


                Rectangle {
                    id: actionButton
                    border.width: 1
                    border.color: modelData.connected || modelData.paired
                        ? root.theme.colors.accent : root.theme.colors.border

                    anchors {
                        right: parent.right
                        verticalCenter:
                            parent.verticalCenter

                        rightMargin: 8
                    }

                    width: 82
                    height: 30

                    radius: 2

                    color:
                        modelData.connected
                            ? root.theme.colors.surface
                            : modelData.paired
                                ? root.theme.colors.surface
                                : root.theme.colors.border


                    Text {
                        anchors.centerIn: parent

                        text:
                            modelData.connected
                                ? "ODPOJIT"
                                : modelData.pairing
                                    ? "ZRUŠIT"
                                    : modelData.paired
                                        ? "PŘIPOJIT"
                                        : "PÁROVAT"

                        color:
                            modelData.connected
                                ? root.theme.colors.accent
                                : modelData.paired
                                    ? root.theme.colors.accent
                                    : root.theme.colors.accent

                        font.family: "JetBrains Mono"
                        font.pixelSize: 9
                        font.bold: true
                    }


                    MouseArea {
                        anchors.fill: parent

                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked: {
                            if (
                                deviceRow.modelData.connected
                            ) {
                                deviceRow.modelData
                                    .disconnect()

                                return
                            }

                            if (
                                deviceRow.modelData.pairing
                            ) {
                                deviceRow.modelData
                                    .cancelPair()

                                return
                            }

                            if (
                                deviceRow.modelData.paired
                            ) {
                                deviceRow.modelData
                                    .connect()

                                return
                            }

                            deviceRow.modelData.pair()
                        }
                    }
                }


                MouseArea {
                    id: deviceMouse

                    anchors {
                        left: parent.left
                        right: actionButton.left
                        top: parent.top
                        bottom: parent.bottom
                    }

                    hoverEnabled: true

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked: {
                        if (
                            deviceRow.modelData.connected
                        ) {
                            deviceRow.modelData.disconnect()
                        } else if (
                            deviceRow.modelData.paired
                        ) {
                            deviceRow.modelData.connect()
                        }
                    }
                }
            }
        }


        Text {
            visible:
                root.bluetoothService.enabled
                && deviceList.count === 0

            anchors.centerIn: deviceList

            text:
                root.bluetoothService.discovering
                    ? "Hledám zařízení…"
                    : "Žádná zařízení"

            color: root.theme.colors.muted

            font.family: "JetBrains Mono"
            font.pixelSize: 11
        }

        // Decorative only: never intercepts clicks on controls or network rows.
        PixelBorder {
            anchors.fill: parent
            z: 50
            accent: root.theme.colors.accent
            secondary: root.theme.colors.border
        }
    }


    onVisibleChanged: {
        if (visible) {
            if (
                root.bluetoothService.enabled
            ) {
                root.bluetoothService
                    .startDiscovery()
            }
        } else {
            root.bluetoothService
                .stopDiscovery()
        }


    }
}
