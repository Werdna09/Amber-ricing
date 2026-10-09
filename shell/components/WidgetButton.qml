import QtQuick
import "chrome"

// API preserved: theme, label, selected, paddingX, activated().
Rectangle {
    id: root
    required property var theme
    property string label: ""
    property bool selected: false
    property int paddingX: 10
    signal activated()

    readonly property bool hovered: hit.containsMouse
    implicitWidth: caption.implicitWidth + paddingX * 2
    implicitHeight: 32
    radius: 1
    color: root.selected ? root.theme.colors.surface
          : Qt.darker(root.theme.colors.background, 1.35)
    border.width: root.selected ? 2 : 1
    border.color: root.selected || root.hovered
                  ? root.theme.colors.accent : root.theme.colors.border
    Behavior on border.color { ColorAnimation { duration: 145 } }

    SoulsHighlight {
        anchors.fill: parent
        theme: root.theme
        hovered: root.hovered
        selected: root.selected
    }

    Text {
        id: caption
        anchors.centerIn: parent
        text: root.label
        color: root.theme.colors.text
        font.family: "JetBrains Mono"
        font.pixelSize: 11
        font.bold: root.selected
        renderType: Text.QtRendering
    }

    MouseArea {
        id: hit
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
