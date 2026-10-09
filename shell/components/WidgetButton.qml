import QtQuick
Rectangle {
    id: root
    required property var theme
    property string label: ""
    signal activated()
    readonly property bool hovered: mouse.containsMouse
    implicitWidth: buttonText.implicitWidth + 16
    implicitHeight: 30
    radius: 3
    color: hovered ? theme.colors.border : theme.colors.surface
    border.width: 1
    border.color: hovered ? theme.colors.accent : theme.colors.border
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
