import QtQuick

Item {
    id: root
    required property var theme
    property bool decorated: true
    property bool textureVisible: true

    Rectangle {
        anchors.fill: parent
        color: Qt.darker(root.theme.colors.background, 1.23)
    }
    // Low-contrast seamless grain; the active palette still controls the surface.
    Image {
        anchors.fill: parent
        source: "../../assets/stone-grain.png"
        fillMode: Image.Tile
        opacity: root.textureVisible ? 0.18 : 0
        smooth: false
        mipmap: false
    }
    PixelBorder {
        anchors.fill: parent
        accent: root.theme.colors.accent
        secondary: root.theme.colors.border
        innerLine: root.decorated
    }
}
