import QtQuick
import Quickshell
import "../components/chrome"

PopupWindow {
    id: root
    required property var theme

    required property Item anchorItem
    required property var mediaService


    /*
     * ============================================================
     * PLAYER
     * ============================================================
     */

    readonly property var player:
        mediaService.player


    readonly property bool hasPlayer:
        player !== null
        && player !== undefined


    /*
     * ============================================================
     * SAFE METADATA
     *
     * MPRIS player se může za běhu změnit nebo úplně zmizet.
     * Do UI proto neposíláme přímé player.* bindingy.
     * ============================================================
     */

    readonly property string safeTitle: {
        const p = root.player

        if (p === null || p === undefined) {
            return ""
        }

        return p.trackTitle || ""
    }


    readonly property string safeArtist: {
        const p = root.player

        if (p === null || p === undefined) {
            return ""
        }

        return p.trackArtist || ""
    }


    readonly property string safeAlbum: {
        const p = root.player

        if (p === null || p === undefined) {
            return ""
        }

        return p.trackAlbum || ""
    }


    readonly property string safeArtUrl: {
        const p = root.player

        if (p === null || p === undefined) {
            return ""
        }

        return p.trackArtUrl || ""
    }


    readonly property string safeIdentity: {
        const p = root.player

        if (p === null || p === undefined) {
            return ""
        }

        return p.identity || ""
    }


    /*
     * ============================================================
     * SAFE PLAYER STATE
     * ============================================================
     */

    readonly property bool playing: {
        const p = root.player

        return p !== null
            && p !== undefined
            && p.isPlaying
    }


    readonly property bool positionSupported: {
        const p = root.player

        return p !== null
            && p !== undefined
            && p.positionSupported
    }


    readonly property bool lengthSupported: {
        const p = root.player

        return p !== null
            && p !== undefined
            && p.lengthSupported
    }


    readonly property bool canSeek: {
        const p = root.player

        return p !== null
            && p !== undefined
            && p.canSeek
    }


    readonly property bool canGoPrevious: {
        const p = root.player

        return p !== null
            && p !== undefined
            && p.canGoPrevious
    }


    readonly property bool canGoNext: {
        const p = root.player

        return p !== null
            && p !== undefined
            && p.canGoNext
    }


    readonly property bool canTogglePlaying: {
        const p = root.player

        return p !== null
            && p !== undefined
            && p.canTogglePlaying
    }


    readonly property bool canRaise: {
        const p = root.player

        return p !== null
            && p !== undefined
            && p.canRaise
    }


    readonly property real reportedLength: {
        const p = root.player

        if (
            p === null
            || p === undefined
            || !p.lengthSupported
        ) {
            return 0
        }

        const value = Number(p.length)

        if (
            !isFinite(value)
            || value <= 0
        ) {
            return 0
        }

        return value
    }


    // AMBER_PHASE_A_V1: preserve last known duration across transient MPRIS metadata gaps.
    property real rememberedLength: 0
    readonly property real trackLength: root.reportedLength > 0 ? root.reportedLength : root.rememberedLength
    onReportedLengthChanged: {
        if (root.reportedLength > 0) root.rememberedLength = root.reportedLength
    }

    // Preview drag locally, commit to MPRIS only on release.
    property real currentPosition: 0
    property bool seekDragging: false
    property int seekGraceTicks: 0


    /*
     * ============================================================
     * WINDOW
     * ============================================================
     */

    implicitWidth: 400
    implicitHeight: 260

    color: "transparent"
    grabFocus: true

    anchor.item: root.anchorItem

    anchor.edges:
        Edges.Bottom | Edges.Right

    anchor.gravity:
        Edges.Bottom | Edges.Left

    anchor.margins.top: 7


    /*
     * ============================================================
     * HELPERS
     * ============================================================
     */

    function formatTime(seconds) {
        if (
            !isFinite(seconds)
            || seconds < 0
        ) {
            return "--:--"
        }

        const value =
            Math.floor(seconds)

        const hours =
            Math.floor(
                value / 3600
            )

        const minutes =
            Math.floor(
                (value % 3600) / 60
            )

        const secs =
            value % 60


        if (hours > 0) {
            return hours
                + ":"
                + String(minutes)
                    .padStart(2, "0")
                + ":"
                + String(secs)
                    .padStart(2, "0")
        }


        return minutes
            + ":"
            + String(secs)
                .padStart(2, "0")
    }


    function refreshPosition() {
        const p = root.player
        if (root.seekDragging || root.seekGraceTicks > 0) return
        if (p === null || p === undefined) {
            root.currentPosition = 0
            return
        }
        // Some browser players briefly stop exporting Position after a seek.
        // Do not erase the last valid location during this transient state.
        if (!p.positionSupported) return
        const value = Number(p.position)
        if (isFinite(value) && value >= 0)
            root.currentPosition = root.trackLength > 0
                    ? Math.min(value, root.trackLength) : value
    }

    function seekFromMouse(mouseX, trackWidth, commit) {
        const p = root.player
        if (p === null || p === undefined || !p.canSeek ||
            !p.positionSupported || trackWidth <= 0)
            return
        const length = root.trackLength
        if (!isFinite(length) || length <= 0) return
        const ratio = Math.max(0, Math.min(1, mouseX / trackWidth))
        const target = length * ratio
        // Local UI follows mouse at frame rate without spamming MPRIS over D-Bus.
        root.currentPosition = target
        if (commit) {
            root.seekGraceTicks = 3
            // Quickshell MprisPlayer.position is writable when canSeek is true.
            p.position = target
        }
    }

    function raisePlayer() {
        const p =
            root.player

        if (
            p === null
            || p === undefined
            || !p.canRaise
        ) {
            return
        }

        p.raise()
    }


    /*
     * ============================================================
     * POSITION TIMER
     *
     * MPRIS position se záměrně neposílá jako nový údaj
     * několikrát za sekundu. Čteme ji pouze při otevřeném popupu.
     * ============================================================
     */

    Timer {
        interval: 1000
        repeat: true
        running: root.visible && root.positionSupported
        onTriggered: {
            if (root.seekDragging) return
            if (root.seekGraceTicks > 0) {
                root.seekGraceTicks -= 1
                if (root.playing && root.trackLength > 0)
                    root.currentPosition = Math.min(root.trackLength, root.currentPosition + 1)
                return
            }
            root.refreshPosition()
        }
    }

    Connections {
        target: root.player
        function onTrackChanged() {
            root.seekDragging = false
            root.seekGraceTicks = 0
            root.rememberedLength = 0
            root.currentPosition = 0
            Qt.callLater(root.refreshPosition)
        }
        function onPositionChanged() {
            if (root.seekDragging) return
            if (root.seekGraceTicks > 0) {
                if (!root.player || !root.player.positionSupported) return
                const actual = Number(root.player.position)
                if (!isFinite(actual) || Math.abs(actual - root.currentPosition) > 4) return
                root.seekGraceTicks = 0
            }
            root.refreshPosition()
        }
    }


    /*
     * ============================================================
     * POPUP CONTENT
     * ============================================================
     */

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


        /*
         * ========================================================
         * HEADER
         * ========================================================
         */

        Text {
            id: header

            anchors {
                top: parent.top
                left: parent.left

                topMargin: 15
                leftMargin: 16
            }

            text: "Media"

            color: root.theme.colors.text

            font.family:
                "JetBrains Mono"

            font.pixelSize: 15
            font.bold: true
        }


        Text {
            anchors {
                right: parent.right
                verticalCenter:
                    header.verticalCenter

                rightMargin: 16
            }

            text:
                root.safeIdentity !== ""
                    ? root.safeIdentity
                    : "No player"

            color: root.theme.colors.muted

            font.family:
                "JetBrains Mono"

            font.pixelSize: 9
            font.bold: true
        }


        /*
         * ========================================================
         * ALBUM ART
         * ========================================================
         */

        Rectangle {
            border.width: 1
            border.color: root.theme.colors.border
            id: artworkContainer

            anchors {
                top: header.bottom
                left: parent.left

                topMargin: 15
                leftMargin: 16
            }

            width: 110
            height: 110

            radius: 2

            color: root.theme.colors.surface

            clip: true


            Image {
                anchors.fill: parent

                visible:
                    root.safeArtUrl !== ""

                source:
                    root.safeArtUrl

                fillMode:
                    Image.PreserveAspectCrop

                asynchronous: true
                cache: true
            }


            Text {
                anchors.centerIn: parent

                visible:
                    root.safeArtUrl === ""

                text: "♪"

                color: root.theme.colors.accent

                font.family:
                    "JetBrains Mono"

                font.pixelSize: 38
                font.bold: true
            }
        }


        /*
         * ========================================================
         * TRACK INFORMATION
         * ========================================================
         */

        Column {
            anchors {
                top: artworkContainer.top
                left: artworkContainer.right
                right: parent.right

                leftMargin: 16
                rightMargin: 16
            }

            spacing: 7


            Text {
                width: parent.width

                text:
                    root.safeTitle !== ""
                        ? root.safeTitle
                        : "Unknown title"

                elide:
                    Text.ElideRight

                color: root.theme.colors.text

                font.family:
                    "JetBrains Mono"

                font.pixelSize: 14
                font.bold: true
            }


            Text {
                width: parent.width

                text:
                    root.safeArtist !== ""
                        ? root.safeArtist
                        : "Unknown artist"

                elide:
                    Text.ElideRight

                color: root.theme.colors.accent

                font.family:
                    "JetBrains Mono"

                font.pixelSize: 11
                font.bold: true
            }


            Text {
                width: parent.width

                text:
                    root.safeAlbum !== ""
                        ? root.safeAlbum
                        : "Unknown album"

                elide:
                    Text.ElideRight

                color: root.theme.colors.muted

                font.family:
                    "JetBrains Mono"

                font.pixelSize: 10
            }


            /*
             * PLAYER STATE
             */

            Rectangle {
                border.width: 1
                border.color: root.theme.colors.border
                width:
                    stateText.width + 16

                height: 24

                radius: 2

                color:
                    root.playing
                        ? root.theme.colors.surface
                        : root.theme.colors.surface


                Text {
                    id: stateText

                    anchors.centerIn: parent

                    text:
                        !root.hasPlayer
                            ? "NO PLAYER"
                            : root.playing
                                ? "PLAYING"
                                : "PAUSED"

                    color:
                        root.playing
                            ? root.theme.colors.accent
                            : root.theme.colors.muted

                    font.family:
                        "JetBrains Mono"

                    font.pixelSize: 9
                    font.bold: true
                }
            }
        }


        /*
         * ========================================================
         * PROGRESS
         * ========================================================
         */

        // Amber Souls details v1 — thin section separator.
        Rectangle {
            anchors.top: artworkContainer.bottom
            anchors.topMargin: 9
            anchors.left: progressTrack.left
            anchors.right: progressTrack.right
            height: 1
            color: root.theme.colors.border
            opacity: 0.8
        }

        Rectangle {
            id: progressTrack

            anchors {
                top: artworkContainer.bottom
                left: parent.left
                right: parent.right

                topMargin: 20
                leftMargin: 16
                rightMargin: 16
            }

            height: 5

            radius: 0
            border.width: 1
            border.color: root.theme.colors.border

            color: root.theme.colors.surface


            /*
             * PROGRESS FILL
             */

            Rectangle {
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                }

                width:
                    root.trackLength > 0
                        ? parent.width
                            * Math.max(
                                0,
                                Math.min(
                                    1,
                                    root.currentPosition
                                    / root.trackLength
                                )
                            )
                        : 0

                radius: 0

                color: root.theme.colors.accent
            }


            /*
             * PROGRESS KNOB
             */

            Rectangle {
                visible:
                    root.trackLength > 0

                width: 8
                height: 16

                radius: 1

                anchors.verticalCenter:
                    parent.verticalCenter

                x:
                    root.trackLength > 0
                        ? Math.max(
                            0,
                            Math.min(
                                progressTrack.width - width,
                                (
                                    progressTrack.width
                                    * root.currentPosition
                                    / root.trackLength
                                )
                                - width / 2
                            )
                        )
                        : 0

                color: root.theme.colors.accent
                border.width: 1
                border.color: root.theme.colors.text
            }


            /*
             * SEEK INPUT
             */

            MouseArea {
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter:
                        parent.verticalCenter
                }

                height: 28

                enabled:
                    root.canSeek
                    && root.positionSupported
                    && root.trackLength > 0

                cursorShape:
                    enabled
                        ? Qt.PointingHandCursor
                        : Qt.ArrowCursor


                onPressed: mouse => {
                    root.seekDragging = true
                    root.seekGraceTicks = 0
                    root.seekFromMouse(mouse.x, width, false)
                }

                onPositionChanged: mouse => {
                    if (pressed)
                        root.seekFromMouse(mouse.x, width, false)
                }

                onReleased: mouse => {
                    root.seekFromMouse(mouse.x, width, true)
                    root.seekDragging = false
                }

                onCanceled: {
                    root.seekDragging = false
                    root.seekGraceTicks = 0
                    root.refreshPosition()
                }
            }
        }


        /*
         * ========================================================
         * TIME
         * ========================================================
         */

        Text {
            anchors {
                top: progressTrack.bottom
                left: progressTrack.left

                topMargin: 5
            }

            text:
                root.positionSupported
                    ? root.formatTime(
                        root.currentPosition
                    )
                    : "--:--"

            color: root.theme.colors.muted

            font.family:
                "JetBrains Mono"

            font.pixelSize: 9
        }


        Text {
            anchors {
                top: progressTrack.bottom
                right: progressTrack.right

                topMargin: 5
            }

            text:
                root.trackLength > 0
                    ? root.formatTime(
                        root.trackLength
                    )
                    : "--:--"

            color: root.theme.colors.muted

            font.family:
                "JetBrains Mono"

            font.pixelSize: 9
        }


        /*
         * ========================================================
         * CONTROLS
         * ========================================================
         */

        Row {
            id: controls

            anchors {
                horizontalCenter:
                    parent.horizontalCenter

                bottom:
                    parent.bottom

                bottomMargin: 15
            }

            spacing: 8


            /*
             * PREVIOUS
             */

            Rectangle {
                border.width: 1
                border.color: soulsPrevious.containsMouse ? root.theme.colors.accent : root.theme.colors.border
                width: 56
                height: 36

                radius: 2

                color:
                    root.canGoPrevious
                        ? root.theme.colors.surface
                        : root.theme.colors.background


                Rectangle {
                    anchors.fill: parent
                    radius: 1
                    color: root.theme.colors.accent
                    opacity: soulsPrevious.containsMouse ? 0.09 : 0
                    Behavior on opacity { NumberAnimation { duration: 110 } }
                }

                Text {
                    anchors.centerIn: parent

                    text: "◀"

                    color:
                        root.canGoPrevious
                            ? root.theme.colors.text
                            : root.theme.colors.muted

                    font.family:
                        "JetBrains Mono"

                    font.pixelSize: 13
                    font.bold: true
                }


                MouseArea {
                    id: soulsPrevious
                    hoverEnabled: true
                  anchors.fill: parent

                    enabled:
                        root.canGoPrevious

                    cursorShape:
                        enabled
                            ? Qt.PointingHandCursor
                            : Qt.ArrowCursor


                    onClicked: {
                        root.mediaService.previous()
                    }
                }
            }


            /*
             * PLAY / PAUSE
             */

            Rectangle {
                border.width: 1
                border.color: soulsPlay.containsMouse ? root.theme.colors.accent : root.theme.colors.border
                width: 92
                height: 36

                radius: 2

                color:
                    root.hasPlayer
                        ? root.theme.colors.accent
                        : root.theme.colors.surface


                Rectangle {
                    anchors.fill: parent
                    radius: 1
                    color: root.theme.colors.accent
                    opacity: soulsPlay.containsMouse ? 0.09 : 0
                    Behavior on opacity { NumberAnimation { duration: 110 } }
                }

                Text {
                    anchors.centerIn: parent

                    text:
                        !root.hasPlayer
                            ? "—"
                            : root.playing
                                ? "PAUSE"
                                : "PLAY"

                    color:
                        root.hasPlayer
                            ? root.theme.colors.background
                            : root.theme.colors.muted

                    font.family:
                        "JetBrains Mono"

                    font.pixelSize: 10
                    font.bold: true
                }


                MouseArea {
                    id: soulsPlay
                    hoverEnabled: true
                  anchors.fill: parent

                    enabled:
                        root.canTogglePlaying

                    cursorShape:
                        enabled
                            ? Qt.PointingHandCursor
                            : Qt.ArrowCursor


                    onClicked: {
                        root.mediaService.togglePlaying()
                    }
                }
            }


            /*
             * NEXT
             */

            Rectangle {
                border.width: 1
                border.color: soulsNext.containsMouse ? root.theme.colors.accent : root.theme.colors.border
                width: 56
                height: 36

                radius: 2

                color:
                    root.canGoNext
                        ? root.theme.colors.surface
                        : root.theme.colors.background


                Rectangle {
                    anchors.fill: parent
                    radius: 1
                    color: root.theme.colors.accent
                    opacity: soulsNext.containsMouse ? 0.09 : 0
                    Behavior on opacity { NumberAnimation { duration: 110 } }
                }

                Text {
                    anchors.centerIn: parent

                    text: "▶"

                    color:
                        root.canGoNext
                            ? root.theme.colors.text
                            : root.theme.colors.muted

                    font.family:
                        "JetBrains Mono"

                    font.pixelSize: 13
                    font.bold: true
                }


                MouseArea {
                    id: soulsNext
                    hoverEnabled: true
                  anchors.fill: parent

                    enabled:
                        root.canGoNext

                    cursorShape:
                        enabled
                            ? Qt.PointingHandCursor
                            : Qt.ArrowCursor


                    onClicked: {
                        root.mediaService.next()
                    }
                }
            }


            /*
             * OPEN PLAYER
             */

            Rectangle {
                border.width: 1
                border.color: soulsOpen.containsMouse ? root.theme.colors.accent : root.theme.colors.border
                width: 92
                height: 36

                radius: 2

                color:
                    root.canRaise
                        ? root.theme.colors.surface
                        : root.theme.colors.background


                Rectangle {
                    anchors.fill: parent
                    radius: 1
                    color: root.theme.colors.accent
                    opacity: soulsOpen.containsMouse ? 0.09 : 0
                    Behavior on opacity { NumberAnimation { duration: 110 } }
                }

                Text {
                    anchors.centerIn: parent

                    text: "PLAYER"

                    color:
                        root.canRaise
                            ? root.theme.colors.accent
                            : root.theme.colors.muted

                    font.family:
                        "JetBrains Mono"

                    font.pixelSize: 9
                    font.bold: true
                }


                MouseArea {
                    id: soulsOpen
                    hoverEnabled: true
                  anchors.fill: parent

                    enabled:
                        root.canRaise

                    cursorShape:
                        enabled
                            ? Qt.PointingHandCursor
                            : Qt.ArrowCursor


                    onClicked: {
                        root.raisePlayer()
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


    /*
     * ============================================================
     * PLAYER CHANGES
     * ============================================================
     */

    onPlayerChanged: {
        root.seekDragging = false
        root.seekGraceTicks = 0
        root.rememberedLength = 0
        root.refreshPosition()
    }


    /*
     * ============================================================
     * POPUP OPEN
     * ============================================================
     */

    onVisibleChanged: {
        if (visible) {
            root.refreshPosition()
        }


    }
}
