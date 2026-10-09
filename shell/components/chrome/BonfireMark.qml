import QtQuick

// 16x16 bitmap icon drawn at exactly 2x scale. Color follows the current palette.
Item {
    id: root
    required property var theme
    width: 32
    height: 32
    property color fire: root.theme.colors.accent
    property color flameLight: root.theme.colors.text
    property color timber: root.theme.colors.muted
    onFireChanged: { if (sprite) sprite.requestPaint(); }
    onFlameLightChanged: { if (sprite) sprite.requestPaint(); }
    onTimberChanged: { if (sprite) sprite.requestPaint(); }

    Canvas {
        id: sprite
        anchors.fill: parent
        antialiasing: false
        renderTarget: Canvas.Image
        onPaint: {
            const p = [
                "................",
                ".......l........",
                "......lf........",
                "......lf........",
                ".....lffl.......",
                ".....lfffl......",
                "....llfffl......",
                "....lfffffl.....",
                "...llflfffl.....",
                "...lffffffl.....",
                "...lfffffff.....",
                "....lffffffl....",
                "....tttttttt....",
                "...tttttttttt...",
                "..tt..tt..tt....",
                "................"
            ];
            const c = getContext("2d"); c.clearRect(0, 0, width, height);
            for (let y = 0; y < p.length; y++) {
                for (let x = 0; x < p[y].length; x++) {
                    const ch = p[y][x];
                    if (ch === '.') continue;
                    c.fillStyle = ch === 'l' ? root.flameLight.toString()
                                : ch === 'f' ? root.fire.toString() : root.timber.toString();
                    c.fillRect(x * 2, y * 2, 2, 2);
                }
            }
        }
    }
}
