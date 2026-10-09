import QtQuick
import Quickshell
import "../components/chrome"

PopupWindow {
    id: root
    required property var theme

    required property Item anchorItem
    required property var batteryService

    implicitWidth: 330
    implicitHeight: 270

    color: "transparent"
    grabFocus: true

    anchor.item: root.anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.margins.top: 7


    function formatTime(seconds) {
        if (seconds <= 0) {
            return "—"
        }

        const totalMinutes =
            Math.round(seconds / 60)

        const hours =
            Math.floor(totalMinutes / 60)

        const minutes =
            totalMinutes % 60

        if (hours <= 0) {
            return minutes + " min"
        }

        if (minutes === 0) {
            return hours + " h"
        }

        return hours + " h " + minutes + " min"
    }


    function stateText() {
        if (!root.batteryService.available) {
            return "Nedostupná"
        }

        if (root.batteryService.fullyCharged) {
            return "Plně nabito"
        }

        if (root.batteryService.charging) {
            return "Nabíjení"
        }

        if (root.batteryService.discharging) {
            return "Vybíjení"
        }

        return "Neznámý stav"
    }


    function stateColor() {
        if (!root.batteryService.available) {
            return root.theme.colors.muted
        }

        if (root.batteryService.charging) {
            return "#6dcae8"
        }

        if (root.batteryService.fullyCharged) {
            return "#9ed06c"
        }

        if (root.batteryService.percentage <= 15) {
            return root.theme.colors.accent
        }

        if (root.batteryService.percentage <= 35) {
            return "#edc763"
        }

        return "#9ed06c"
    }


    function batteryColor() {
        if (!root.batteryService.available) {
            return root.theme.colors.muted
        }

        if (root.batteryService.percentage <= 15) {
            return root.theme.colors.accent
        }

        if (root.batteryService.percentage <= 35) {
            return "#edc763"
        }

        return "#9ed06c"
    }


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

            text: "Battery"

            color: root.theme.colors.text

            font.family: "JetBrains Mono"
            font.pixelSize: 15
            font.bold: true
        }


        Text {
            anchors {
                top: parent.top
                right: parent.right

                topMargin: 14
                rightMargin: 16
            }

            text:
                root.batteryService.available
                    ? root.batteryService.percentage
                        + " %"
                    : "--"

            color:
                root.batteryColor()

            font.family: "JetBrains Mono"
            font.pixelSize: 15
            font.bold: true
        }


        Rectangle {
            id: batteryTrack

            anchors {
                top: title.bottom
                left: parent.left
                right: parent.right

                topMargin: 19
                leftMargin: 16
                rightMargin: 16
            }

            height: 14

            radius: 7

            color: root.theme.colors.surface


            Rectangle {
                width:
                    parent.width
                    * Math.max(
                        0,
                        Math.min(
                            1,
                            root.batteryService.percentage
                            / 100
                        )
                    )

                height: parent.height

                radius: 7

                color:
                    root.batteryColor()


                Behavior on width {
                    NumberAnimation {
                        duration: 250
                    }
                }


                Behavior on color {
                    ColorAnimation {
                        duration: 180
                    }
                }
            }
        }


        Column {
            anchors {
                top: batteryTrack.bottom
                left: parent.left
                right: parent.right

                topMargin: 20
                leftMargin: 16
                rightMargin: 16
            }

            spacing: 9


            Row {
                width: parent.width
                height: 18

                Text {
                    width: parent.width / 2

                    text: "Stav"

                    color: root.theme.colors.muted

                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                }

                Text {
                    width: parent.width / 2

                    text:
                        root.stateText()

                    horizontalAlignment:
                        Text.AlignRight

                    color:
                        root.stateColor()

                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    font.bold: true
                }
            }


            Row {
                width: parent.width
                height: 18

                Text {
                    width: parent.width / 2

                    text: "Nabití"

                    color: root.theme.colors.muted

                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                }

                Text {
                    width: parent.width / 2

                    text:
                        root.batteryService.available
                            ? root.batteryService.percentage
                                + " %"
                            : "—"

                    horizontalAlignment:
                        Text.AlignRight

                    color: root.theme.colors.text

                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    font.bold: true
                }
            }


            Row {
                width: parent.width
                height: 18

                Text {
                    width: parent.width / 2

                    text: "Kondice"

                    color: root.theme.colors.muted

                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                }

                Text {
                    width: parent.width / 2

                    text:
                        root.batteryService.healthAvailable
                            ? root.batteryService.health
                                + " %"
                            : "—"

                    horizontalAlignment:
                        Text.AlignRight

                    color:
                        root.batteryService.healthAvailable
                            ? root.batteryService.health >= 80
                                ? "#9ed06c"
                                : root.batteryService.health >= 60
                                    ? "#edc763"
                                    : root.theme.colors.accent
                            : root.theme.colors.muted

                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    font.bold: true
                }
            }


            Row {
                width: parent.width
                height: 18

                Text {
                    width: parent.width / 2

                    text:
                        root.batteryService.charging
                            ? "Do nabití"
                            : root.batteryService.discharging
                                ? "Zbývá"
                                : "Napájení"

                    color: root.theme.colors.muted

                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                }

                Text {
                    width: parent.width / 2

                    text:
                        root.batteryService.charging
                            ? root.formatTime(
                                root.batteryService.timeToFull
                            )
                            : root.batteryService.discharging
                                ? root.formatTime(
                                    root.batteryService.timeToEmpty
                                )
                                : root.batteryService.fullyCharged
                                    ? "Adaptér"
                                    : "—"

                    horizontalAlignment:
                        Text.AlignRight

                    color:
                        root.batteryService.charging
                            ? "#6dcae8"
                            : root.theme.colors.text

                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    font.bold: true
                }
            }
        }


        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom

                leftMargin: 16
                rightMargin: 16
                bottomMargin: 14
            }

            height: 34

            radius: 6

            color:
                root.batteryService.charging
                    ? "#354157"
                    : root.batteryService.fullyCharged
                        ? "#394634"
                        : root.theme.colors.surface


            Text {
                anchors.centerIn: parent

                text:
                    root.batteryService.charging
                        ? "⚡  Napájení připojeno"
                        : root.batteryService.fullyCharged
                            ? "✓  Baterie je plně nabitá"
                            : "◌  Provoz na baterii"

                color:
                    root.batteryService.charging
                        ? "#6dcae8"
                        : root.batteryService.fullyCharged
                            ? "#9ed06c"
                            : root.theme.colors.text

                font.family: "JetBrains Mono"
                font.pixelSize: 10
                font.bold: true
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
