import QtQuick

// AMBER_PHASE_A_V1: DS3-style focused gold lighting, with no solid hover block.
// Purely visual overlay; input remains handled by the parent row.
Item {
    id: root
    required property var theme
    property bool hovered: false
    property bool selected: false
    readonly property color gold: root.theme.colors.accent

    // Soft horizontal illumination fading from gold into the original background.
    Rectangle {
        anchors.fill: parent
        opacity: root.selected ? 1 : (root.hovered ? 0.74 : 0)
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0.0
                color: Qt.rgba(root.gold.r, root.gold.g, root.gold.b, 0.22)
            }
            GradientStop {
                position: 0.32
                color: Qt.rgba(root.gold.r, root.gold.g, root.gold.b, 0.085)
            }
            GradientStop { position: 1.0; color: "transparent" }
        }
        Behavior on opacity { NumberAnimation { duration: 170; easing.type: Easing.OutCubic } }
    }

    // Short luminous line, as in a restrained fantasy-settings selection.
    Rectangle {
        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
        height: 1
        opacity: root.selected ? 0.38 : (root.hovered ? 0.23 : 0)
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: root.gold }
            GradientStop { position: 0.7; color: "transparent" }
            GradientStop { position: 1.0; color: "transparent" }
        }
        Behavior on opacity { NumberAnimation { duration: 170 } }
    }

    // Pixel-sharp left marker and one subtle bottom edge; no rounded corners.
    Rectangle {
        anchors { left: parent.left; verticalCenter: parent.verticalCenter }
        width: 2
        height: Math.max(8, root.height - 14)
        color: root.gold
        opacity: root.selected ? 0.94 : (root.hovered ? 0.74 : 0)
        Behavior on opacity { NumberAnimation { duration: 170 } }
    }
    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 1
        color: root.gold
        opacity: root.selected ? 0.48 : (root.hovered ? 0.27 : 0)
        Behavior on opacity { NumberAnimation { duration: 170 } }
    }
}
