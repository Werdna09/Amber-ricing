import QtQuick

Rectangle {
    id: root
    required property var theme
    property string label: ""
    property bool selected: false
    signal activated()

    readonly property bool hovered: mouse.containsMouse
    implicitWidth: buttonText.implicitWidth + 19
    implicitHeight: 32
    radius: 2
    color: selected || hovered ? theme.colors.surface : "#161515"
    border.width: 1
    border.color: selected || hovered ? theme.colors.accent : theme.colors.border

    Rectangle {
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 2 }
        height: 1
        color: root.theme.colors.accent
        opacity: root.selected ? 0.45 : (root.hovered ? 0.28 : 0)
    }

    Text {
        id: buttonText
        anchors.centerIn: parent
        text: root.label
        font.family: "JetBrains Mono"
        font.pixelSize: 11
        color: root.theme.colors.text
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
