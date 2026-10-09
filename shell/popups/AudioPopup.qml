import QtQuick
import Quickshell
import "../components/chrome"

PopupWindow {
    id: root
    required property var theme

    required property Item anchorItem
    required property var audioService

    implicitWidth: 300
    implicitHeight: 148

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
                topMargin: 14
                leftMargin: 16
            }

            text: "Audio"

            color: root.theme.colors.text

            font.family: "JetBrains Mono"
            font.pixelSize: 14
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
                !root.audioService.available
                    ? "--"
                    : root.audioService.muted
                        ? "MUTED"
                        : root.audioService.volume + " %"

            color:
                root.audioService.muted
                    ? root.theme.colors.accent
                    : root.theme.colors.accent

            font.family: "JetBrains Mono"
            font.pixelSize: 11
            font.bold: true
        }


        Text {
            id: deviceName

            anchors {
                top: title.bottom
                left: parent.left
                right: parent.right

                topMargin: 5
                leftMargin: 16
                rightMargin: 16
            }

            text:
                root.audioService.available
                    ? (
                        root.audioService.sink.description.length > 0
                            ? root.audioService.sink.description
                            : root.audioService.sink.name
                    )
                    : "No audio output"

            elide: Text.ElideRight

            color: root.theme.colors.muted

            font.family: "JetBrains Mono"
            font.pixelSize: 9
        }


        Rectangle {
            id: volumeTrack

            anchors {
                top: deviceName.bottom
                left: parent.left
                right: parent.right

                topMargin: 15
                leftMargin: 16
                rightMargin: 16
            }

            height: 8

            radius: 2

            color: root.theme.colors.surface


            Rectangle {
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }

                width:
                    parent.width
                    * Math.max(
                        0,
                        Math.min(
                            1,
                            root.audioService.volume / 100
                        )
                    )

                radius: 2

                color:
                    root.audioService.muted
                        ? root.theme.colors.muted
                        : root.theme.colors.accent

                Behavior on width {
                    NumberAnimation {
                        duration: 100
                    }
                }
            }


            Rectangle {
                width: 14
                height: 14

                radius: 2

                anchors.verticalCenter:
                    parent.verticalCenter

                x:
                    Math.max(
                        0,
                        Math.min(
                            volumeTrack.width - width,
                            volumeTrack.width
                            * root.audioService.volume
                            / 100
                            - width / 2
                        )
                    )

                color: root.theme.colors.text

                Behavior on x {
                    NumberAnimation {
                        duration: 100
                    }
                }
            }


            MouseArea {
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }

                height: 28

                cursorShape: Qt.PointingHandCursor


                function setVolume(mouseX) {
                    const value =
                        Math.max(
                            0,
                            Math.min(
                                1,
                                mouseX / width
                            )
                        )

                    root.audioService.setVolume(value)
                }


                onPressed: mouse => {
                    setVolume(mouse.x)
                }


                onPositionChanged: mouse => {
                    if (pressed) {
                        setVolume(mouse.x)
                    }
                }


                onWheel: wheel => {
                    if (wheel.angleDelta.y > 0) {
                        root.audioService.increase()
                    } else if (wheel.angleDelta.y < 0) {
                        root.audioService.decrease()
                    }

                    wheel.accepted = true
                }
            }
        }


        Row {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom

                leftMargin: 16
                rightMargin: 16
                bottomMargin: 12
            }

            spacing: 6


            Rectangle {
                border.width: 1
                border.color: root.theme.colors.border
                width: 70
                height: 30

                radius: 2
                color: root.theme.colors.surface

                Text {
                    anchors.centerIn: parent

                    text: "-5%"

                    color: root.theme.colors.text

                    font.family: "JetBrains Mono"
                    font.pixelSize: 10
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.audioService.decrease()
                    }
                }
            }


            Rectangle {
                border.width: 1
                border.color: root.theme.colors.border
                width: 122
                height: 30

                radius: 2

                color:
                    root.audioService.muted
                        ? root.theme.colors.surface
                        : root.theme.colors.surface

                Text {
                    anchors.centerIn: parent

                    text:
                        root.audioService.muted
                            ? "UNMUTE"
                            : "MUTE"

                    color:
                        root.audioService.muted
                            ? root.theme.colors.accent
                            : root.theme.colors.accent

                    font.family: "JetBrains Mono"
                    font.pixelSize: 10
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.audioService.toggleMute()
                    }
                }
            }


            Rectangle {
                border.width: 1
                border.color: root.theme.colors.border
                width: 70
                height: 30

                radius: 2
                color: root.theme.colors.surface

                Text {
                    anchors.centerIn: parent

                    text: "+5%"

                    color: root.theme.colors.text

                    font.family: "JetBrains Mono"
                    font.pixelSize: 10
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.audioService.increase()
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
