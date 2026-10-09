import QtQuick

Item {
    id: root
    required property var theme
    implicitWidth: 32
    implicitHeight: 32

    Canvas {
        id: flameCanvas
        anchors.fill: parent
        antialiasing: false
        renderTarget: Canvas.Image
        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            const scale = Math.min(width, height) / 16
            function pixels(color, coordinates) {
                ctx.fillStyle = color
                for (const pair of coordinates)
                    ctx.fillRect(Math.round(pair[0] * scale), Math.round(pair[1] * scale), Math.ceil(scale), Math.ceil(scale))
            }
            const gold = root.theme.colors.accent
            const pale = root.theme.colors.text
            const shadow = root.theme.colors.muted
            pixels(shadow, [[2,12],[3,13],[4,12],[5,13],[6,12],[7,13],[8,12],[9,13],[10,12],[11,13],[12,12],[13,13]])
            pixels(gold, [[8,1],[8,2],[7,3],[9,3],[6,4],[8,4],[10,4],[6,5],[9,5],[5,6],[7,6],[10,6],[4,7],[6,7],[8,7],[10,7],[11,7],[4,8],[5,8],[7,8],[9,8],[11,8],[5,9],[6,9],[8,9],[9,9],[10,9],[6,10],[7,10],[8,10],[9,10],[7,11],[8,11]])
            pixels(pale, [[8,6],[8,8],[7,9],[8,9],[7,10],[8,10]])
            pixels(shadow, [[2,14],[3,14],[4,14],[5,14],[6,14],[7,14],[8,14],[9,14],[10,14],[11,14],[12,14],[13,14]])
        }
    }
    Connections {
        target: root.theme
        function onSelectedIdChanged() { flameCanvas.requestPaint() }
    }
}
