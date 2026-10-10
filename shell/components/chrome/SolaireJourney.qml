import QtQuick

// AMBER_SOLAIRE_V1 — frame-by-frame ambient appearance, no GIF, no MouseArea.
// Kept inside the existing 62px panel surface; the sun enters through its top.
Item {
    id: root
    property real journeyStart: 0
    property real journeyEnd: 80
    property real travel: 0
    property real sunProgress: 0
    property int phase: 0
    property int frameStep: 0
    property int firstAppearanceMs: 12000
    property int repeatMs: 145000

    readonly property bool performing: sequence.running
    readonly property real knightX: root.journeyStart +
                                     (root.journeyEnd - root.journeyStart) * root.travel

    readonly property var sprites: [
        Qt.resolvedUrl("../../assets/companions/solaire/solaire-00.png"),
        Qt.resolvedUrl("../../assets/companions/solaire/solaire-01.png"),
        Qt.resolvedUrl("../../assets/companions/solaire/solaire-02.png"),
        Qt.resolvedUrl("../../assets/companions/solaire/solaire-03.png"),
        Qt.resolvedUrl("../../assets/companions/solaire/solaire-04.png"),
        Qt.resolvedUrl("../../assets/companions/solaire/solaire-05.png"),
        Qt.resolvedUrl("../../assets/companions/solaire/solaire-06.png"),
        Qt.resolvedUrl("../../assets/companions/solaire/solaire-07.png"),
        Qt.resolvedUrl("../../assets/companions/solaire/solaire-08.png"),
        Qt.resolvedUrl("../../assets/companions/solaire/solaire-09.png"),
        Qt.resolvedUrl("../../assets/companions/solaire/solaire-10.png"),
        Qt.resolvedUrl("../../assets/companions/solaire/solaire-11.png"),
        Qt.resolvedUrl("../../assets/companions/solaire/solaire-12.png"),
        Qt.resolvedUrl("../../assets/companions/solaire/solaire-13.png"),
        Qt.resolvedUrl("../../assets/companions/solaire/solaire-14.png"),
        Qt.resolvedUrl("../../assets/companions/solaire/solaire-15.png")
    ]

    function activeFrame() {
        if (phase === 1) return [0, 1, 2, 3, 4, 5][frameStep % 6];
        if (phase === 2) return 6;
        if (phase === 3) return 8;
        if (phase === 4 || phase === 5 || phase === 6) return 9;
        if (phase === 7) return 7;
        if (phase === 8) return 10;
        if (phase === 9) return [11, 12, 13, 14, 15][frameStep % 5];
        return 7;
    }

    function startJourney() {
        if (root.enabled && root.visible && !sequence.running && root.width >= 1100) {
            root.travel = 0;
            root.sunProgress = 0;
            root.frameStep = 0;
            sequence.start();
        }
    }

    Timer {
        interval: root.firstAppearanceMs
        repeat: false
        running: root.enabled
        onTriggered: root.startJourney()
    }

    Timer {
        interval: root.repeatMs
        repeat: true
        running: root.enabled
        onTriggered: root.startJourney()
    }

    Timer {
        interval: 155
        repeat: true
        running: sequence.running
        onTriggered: root.frameStep++
    }

    SequentialAnimation {
        id: sequence
        running: false

        ScriptAction { script: root.phase = 1 }
        NumberAnimation {
            target: root; property: "travel"
            from: 0; to: 1; duration: 3100
            easing.type: Easing.InOutSine
        }
        ScriptAction { script: root.phase = 2 }
        PauseAnimation { duration: 310 }
        ScriptAction { script: root.phase = 3 }
        PauseAnimation { duration: 380 }
        ScriptAction { script: root.phase = 4 }
        NumberAnimation {
            target: root; property: "sunProgress"
            from: 0; to: 1; duration: 950
            easing.type: Easing.OutQuad
        }
        ScriptAction { script: root.phase = 5 }
        PauseAnimation { duration: 1550 }
        ScriptAction { script: root.phase = 6 }
        NumberAnimation {
            target: root; property: "sunProgress"
            from: 1; to: 0; duration: 980
            easing.type: Easing.InQuad
        }
        ScriptAction { script: root.phase = 7 }
        PauseAnimation { duration: 330 }
        ScriptAction { script: root.phase = 8 }
        PauseAnimation { duration: 280 }
        ScriptAction { script: root.phase = 9 }
        NumberAnimation {
            target: root; property: "travel"
            from: 1; to: 0; duration: 3100
            easing.type: Easing.InOutSine
        }
        ScriptAction { script: root.phase = 0 }
    }

    Image {
        id: sun
        width: 24
        height: 24
        x: knight.x + (knight.width - width) / 2
        // y starts beyond the top edge of the monitor, descends and then retreats.
        y: -height - 3 + root.sunProgress * 20
        source: Qt.resolvedUrl("../../assets/companions/solaire/sun.png")
        fillMode: Image.PreserveAspectFit
        smooth: false
        mipmap: false
        visible: root.phase >= 4 && root.phase <= 6 && sequence.running
    }
    Image {
        id: knight
        x: root.knightX
        y: root.height - height - 2
        width: 32
        height: 48
        source: root.sprites[root.activeFrame()]
        fillMode: Image.PreserveAspectFit
        smooth: false
        mipmap: false
        visible: root.phase !== 0 && sequence.running
    }
}
