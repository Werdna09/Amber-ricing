import QtQuick
import Quickshell
import Quickshell.Io
import "../components/chrome"

PopupWindow {
    id: root
    required property var theme

    required property Item anchorItem
    required property var updateService

    property var repoEntries: []
    property var aurEntries: []

    readonly property var allEntries:
        repoEntries.concat(aurEntries)

    readonly property bool checkingDetails:
        repoProcess.running
        || aurProcess.running

    implicitWidth: 430
    implicitHeight: 470

    color: "transparent"
    grabFocus: true

    anchor.item: root.anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.margins.top: 7


    function parseOutput(text, source) {
        const output = text.trim()

        if (output.length === 0) {
            return []
        }

        const lines =
            output
                .split("\n")
                .filter(
                    line =>
                        line.trim().length > 0
                )

        const result = []

        for (const rawLine of lines) {
            const line = rawLine.trim()

            const match =
                line.match(
                    /^(\S+)\s+(\S+)\s+->\s+(\S+)$/
                )

            if (match !== null) {
                result.push({
                    name: match[1],
                    oldVersion: match[2],
                    newVersion: match[3],
                    source: source
                })
            } else {
                result.push({
                    name: line,
                    oldVersion: "",
                    newVersion: "",
                    source: source
                })
            }
        }

        return result
    }


    function refreshDetails() {
        if (!repoProcess.running) {
            repoProcess.running = true
        }

        if (!aurProcess.running) {
            aurProcess.running = true
        }
    }


    function runUpgrade() {
        Quickshell.execDetached([
            "alacritty",
            "-e",
            "fish",
            "-lc",
            "paru -Syu"
        ])
    }


    Process {
        id: repoProcess

        command: [
            "checkupdates"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.repoEntries =
                    root.parseOutput(
                        text,
                        "REPO"
                    )
            }
        }
    }


    Process {
        id: aurProcess

        command: [
            "paru",
            "-Qua"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.aurEntries =
                    root.parseOutput(
                        text,
                        "AUR"
                    )
            }
        }
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

            text: "Updates"

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
                root.updateService.checking
                    ? "…"
                    : root.updateService.totalCount

            color:
                root.updateService.totalCount > 0
                    ? root.theme.colors.text
                    : root.theme.colors.accent

            font.family: "JetBrains Mono"
            font.pixelSize: 15
            font.bold: true
        }


        Row {
            id: summaryRow

            anchors {
                top: title.bottom
                left: parent.left
                right: parent.right

                topMargin: 16
                leftMargin: 14
                rightMargin: 14
            }

            spacing: 8


            Rectangle {
                width:
                    (summaryRow.width - 8) / 2

                height: 54

                radius: 2

                color: root.theme.colors.surface

                border.width: 1
                border.color: root.theme.colors.surface


                Text {
                    anchors {
                        top: parent.top
                        left: parent.left

                        topMargin: 8
                        leftMargin: 10
                    }

                    text: "REPO"

                    color: root.theme.colors.muted

                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                    font.bold: true
                }


                Text {
                    anchors {
                        right: parent.right
                        verticalCenter:
                            parent.verticalCenter

                        rightMargin: 12
                    }

                    text:
                        root.updateService.repoCount

                    color: root.theme.colors.accent

                    font.family: "JetBrains Mono"
                    font.pixelSize: 18
                    font.bold: true
                }
            }


            Rectangle {
                width:
                    (summaryRow.width - 8) / 2

                height: 54

                radius: 2

                color: root.theme.colors.surface

                border.width: 1
                border.color: root.theme.colors.surface


                Text {
                    anchors {
                        top: parent.top
                        left: parent.left

                        topMargin: 8
                        leftMargin: 10
                    }

                    text: "AUR"

                    color: root.theme.colors.muted

                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                    font.bold: true
                }


                Text {
                    anchors {
                        right: parent.right
                        verticalCenter:
                            parent.verticalCenter

                        rightMargin: 12
                    }

                    text:
                        root.updateService.aurCount

                    color: root.theme.colors.accent

                    font.family: "JetBrains Mono"
                    font.pixelSize: 18
                    font.bold: true
                }
            }
        }


        // Amber Souls details v1 — separate summary from package details.
        Rectangle {
            anchors.top: summaryRow.bottom
            anchors.topMargin: 7
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.rightMargin: 16
            height: 1
            color: root.theme.colors.border
            opacity: 0.8
        }

        Text {
            id: listTitle

            anchors {
                top: summaryRow.bottom
                left: parent.left

                topMargin: 15
                leftMargin: 16
            }

            text:
                root.checkingDetails
                    ? "Kontroluji balíčky…"
                    : "Balíčky"

            color: root.theme.colors.muted

            font.family: "JetBrains Mono"
            font.pixelSize: 10
            font.bold: true
        }


        Rectangle {
            border.width: 1
            border.color: root.theme.colors.border
            id: refreshButton

            anchors {
                right: parent.right
                verticalCenter:
                    listTitle.verticalCenter

                rightMargin: 14
            }

            width: 82
            height: 26

            radius: 2

            color:
                root.checkingDetails
                    ? root.theme.colors.border
                    : root.theme.colors.surface


            Text {
                anchors.centerIn: parent

                text:
                    root.checkingDetails
                        ? "ČEKÁM…"
                        : "OBNOVIT"

                color:
                    root.checkingDetails
                        ? root.theme.colors.accent
                        : root.theme.colors.text

                font.family: "JetBrains Mono"
                font.pixelSize: 9
                font.bold: true
            }


            MouseArea {
                anchors.fill: parent

                enabled:
                    !root.checkingDetails

                cursorShape:
                    Qt.PointingHandCursor

                onClicked: {
                    root.refreshDetails()
                }
            }
        }


        ListView {
            id: updateList

            anchors {
                top: listTitle.bottom
                left: parent.left
                right: parent.right
                bottom: actionRow.top

                topMargin: 9
                leftMargin: 10
                rightMargin: 10
                bottomMargin: 10
            }

            clip: true
            spacing: 3

            model: root.allEntries


            delegate: Rectangle {
                border.width: 1
                border.color: updateMouse.containsMouse ? root.theme.colors.accent : root.theme.colors.border
                required property var modelData

                width: ListView.view.width
                height: 52

                radius: 2

                color: "transparent"

                SoulsHighlight {
                    anchors.fill: parent
                    theme: root.theme
                    hovered: updateMouse.containsMouse
                }

                Text {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: sourceBadge.left

                        topMargin: 7
                        leftMargin: 9
                        rightMargin: 8
                    }

                    text: modelData.name

                    elide: Text.ElideRight

                    color: root.theme.colors.text

                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    font.bold: true
                }


                Text {
                    anchors {
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right

                        bottomMargin: 7
                        leftMargin: 9
                        rightMargin: 9
                    }

                    text:
                        modelData.oldVersion.length > 0
                            ? modelData.oldVersion
                                + "  →  "
                                + modelData.newVersion
                            : "Aktualizace dostupná"

                    elide: Text.ElideRight

                    color: root.theme.colors.muted

                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                }


                Rectangle {
                    id: sourceBadge

                    anchors {
                        right: parent.right
                        top: parent.top

                        rightMargin: 8
                        topMargin: 7
                    }

                    width: 42
                    height: 18

                    radius: 2

                    color:
                        modelData.source === "AUR"
                            ? root.theme.colors.border
                            : root.theme.colors.surface


                    Text {
                        anchors.centerIn: parent

                        text:
                            modelData.source

                        color:
                            modelData.source === "AUR"
                                ? root.theme.colors.accent
                                : root.theme.colors.accent

                        font.family: "JetBrains Mono"
                        font.pixelSize: 8
                        font.bold: true
                    }
                }


                MouseArea {
                    id: updateMouse

                    anchors.fill: parent

                    hoverEnabled: true

                    acceptedButtons:
                        Qt.NoButton
                }
            }
        }


        Text {
            visible:
                !root.checkingDetails
                && updateList.count === 0

            anchors.centerIn: updateList

            text: "Systém je aktuální ✓"

            color: root.theme.colors.accent

            font.family: "JetBrains Mono"
            font.pixelSize: 11
            font.bold: true
        }


        Row {
            id: actionRow

            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom

                leftMargin: 14
                rightMargin: 14
                bottomMargin: 12
            }

            spacing: 8


            Rectangle {
                border.width: 1
                border.color: root.theme.colors.border
                width: 125
                height: 34

                radius: 2

                color: root.theme.colors.surface


                Text {
                    anchors.centerIn: parent

                    text: "OBNOVIT"

                    color: root.theme.colors.text

                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                    font.bold: true
                }


                MouseArea {
                    anchors.fill: parent

                    enabled:
                        !root.checkingDetails

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked: {
                        root.refreshDetails()
                    }
                }
            }


            Rectangle {
                border.width: 1
                border.color: root.theme.colors.border
                width:
                    actionRow.width
                    - 133

                height: 34

                radius: 2

                color:
                    root.updateService.totalCount > 0
                        ? root.theme.colors.text
                        : root.theme.colors.surface


                Text {
                    anchors.centerIn: parent

                    text:
                        root.updateService.totalCount > 0
                            ? "AKTUALIZOVAT"
                            : "AKTUÁLNÍ"

                    color:
                        root.updateService.totalCount > 0
                            ? root.theme.colors.background
                            : root.theme.colors.accent

                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                    font.bold: true
                }


                MouseArea {
                    anchors.fill: parent

                    enabled:
                        root.updateService.totalCount > 0

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked: {
                        root.runUpgrade()
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


    onVisibleChanged: {
        if (visible) {
            root.refreshDetails()
        }


    }
}
