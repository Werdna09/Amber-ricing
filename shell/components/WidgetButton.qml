import QtQuick
import "chrome"

// AMBER_PIXEL_ICONS_V1: preserve WidgetButton signals, colors, hover, and label API.
Rectangle {
    id: root
    required property var theme
    property string label: ""
    property string iconName: ""
    // AMBER_THEME_POWER_V1: optional second sprite beside the existing Tome.
    property string secondaryIconName: ""
    property bool selected: false
    property int paddingX: 8
    signal activated()

    readonly property bool hovered: hit.containsMouse
    implicitWidth: content.implicitWidth + paddingX * 2
    implicitHeight: 36
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

    Row {
        id: content
        anchors.centerIn: parent
        spacing: root.iconName !== "" && (root.label !== "" || root.secondaryIconName !== "") ? 5 : 0
        Image {
            width: 32
            height: 32
            visible: root.iconName !== ""
            source: root.iconName !== ""
                    ? Qt.resolvedUrl("../assets/icons/" + root.iconName + ".png") : ""
            fillMode: Image.PreserveAspectFit
            smooth: false
            mipmap: false
            asynchronous: false
        }
        Image {
            width: 32
            height: 32
            visible: root.secondaryIconName !== ""
            source: root.secondaryIconName !== ""
                    ? Qt.resolvedUrl("../assets/theme-icons/" + root.secondaryIconName + ".png") : ""
            fillMode: Image.PreserveAspectFit
            smooth: false
            mipmap: false
            asynchronous: false
        }
        Text {
            id: caption
            height: 32
            visible: root.label !== ""
            verticalAlignment: Text.AlignVCenter
            text: root.label
            color: root.theme.colors.text
            font.family: "JetBrains Mono"
            font.pixelSize: 11
            font.bold: root.selected
            renderType: Text.QtRendering
        }
    }

    MouseArea {
        id: hit
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
