import QtQuick

// Passive Amber selection lighting. No MouseArea: it cannot intercept input.
// Colors are always supplied by ThemeManager through the caller.
Item {
    id: root
    required property var theme
    property bool hovered: false
    property bool selected: false

    Rectangle {
        anchors.fill: parent
        color: root.theme.colors.accent
        opacity: root.selected ? 0.125 : (root.hovered ? 0.080 : 0)
        Behavior on opacity {
            NumberAnimation { duration: 145; easing.type: Easing.OutCubic }
        }
    }

    // Very thin illuminated line: DS3-inspired, not a heavy game HUD.
    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 1
        color: root.theme.colors.accent
        opacity: root.selected ? 0.85 : (root.hovered ? 0.63 : 0)
        Behavior on opacity { NumberAnimation { duration: 145 } }
    }

    Rectangle {
        anchors { left: parent.left; verticalCenter: parent.verticalCenter }
        width: 2
        height: Math.max(8, root.height - 12)
        color: root.theme.colors.accent
        opacity: root.selected ? 0.9 : (root.hovered ? 0.65 : 0)
        Behavior on opacity { NumberAnimation { duration: 145 } }
    }
}
