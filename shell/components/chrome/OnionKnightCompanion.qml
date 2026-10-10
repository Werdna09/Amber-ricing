import QtQuick

// AMBER_ONION_KNIGHT_V1
// Pixel companion for the top bar. Left-facing Onion Knight sleeps when CPU usage
// is below the threshold and wakes up / grips his sword when CPU usage is higher.
Item {
    id: root
    required property var theme
    property bool awake: false
    property int sleepInterval: 520
    property int awakeInterval: 180
    property int sleepFrame: 0
    property int awakeFrame: 0

    width: 56
    height: 62

    readonly property var sleepFrames: [
        Qt.resolvedUrl("../../assets/companions/onion-knight/sleep-0.png"),
        Qt.resolvedUrl("../../assets/companions/onion-knight/sleep-1.png"),
        Qt.resolvedUrl("../../assets/companions/onion-knight/sleep-2.png"),
        Qt.resolvedUrl("../../assets/companions/onion-knight/sleep-3.png")
    ]
    readonly property var awakeFrames: [
        Qt.resolvedUrl("../../assets/companions/onion-knight/awake-0.png"),
        Qt.resolvedUrl("../../assets/companions/onion-knight/awake-1.png"),
        Qt.resolvedUrl("../../assets/companions/onion-knight/awake-2.png"),
        Qt.resolvedUrl("../../assets/companions/onion-knight/awake-3.png")
    ]

    readonly property string currentSource: root.awake
        ? root.awakeFrames[root.awakeFrame]
        : root.sleepFrames[root.sleepFrame]

    onAwakeChanged: {
        if (awake) {
            awakeFrame = 0
        } else {
            sleepFrame = 0
        }
    }

    Timer {
        id: animator
        interval: root.awake ? root.awakeInterval : root.sleepInterval
        running: root.visible
        repeat: true
        onTriggered: {
            if (root.awake) {
                root.awakeFrame = (root.awakeFrame + 1) % root.awakeFrames.length
            } else {
                root.sleepFrame = (root.sleepFrame + 1) % root.sleepFrames.length
            }
        }
    }

    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        source: root.currentSource
        smooth: false
        mipmap: false
        asynchronous: false
    }
}
