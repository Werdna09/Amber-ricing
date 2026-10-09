import QtQuick

// Amber / Pixel Bonfire v1: six hand-authored 16x16 frames at 2x scale.
// Reuses the original icon, its geometry and the existing Theme Bank palette.
// This component is already used by both AmberTopPanel and AmberDock.
Item {
    id: root
    required property var theme
    width: 32
    height: 32

    // Set animated: false on an instance to show the original static icon.
    property bool animated: true
    property int frameInterval: 210
    property int frameIndex: 0

    property color fire: root.theme.colors.accent
    property color flameLight: root.theme.colors.text
    property color timber: root.theme.colors.muted

    onFireChanged: { if (sprite) sprite.requestPaint() }
    onFlameLightChanged: { if (sprite) sprite.requestPaint() }
    onTimberChanged: { if (sprite) sprite.requestPaint() }
    onAnimatedChanged: {
        if (!animated) {
            frameIndex = 0
            if (sprite) sprite.requestPaint()
        }
    }

    // The three log rows stay unchanged; only the flame flickers.
    readonly property var frames: [
        [
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
        ],
        [
            "................",
            "........l.......",
            ".......lf.......",
            ".......lf..l....",
            ".....lffl.......",
            ".....lfffl......",
            "....llfffl......",
            "....lffflfl.....",
            "...llflfffl.....",
            "...lffffffl.....",
            "...lfffffff.....",
            "....lffffffl....",
            "....tttttttt....",
            "...tttttttttt...",
            "..tt..tt..tt....",
            "................"
        ],
        [
            "................",
            ".........l......",
            "........lf......",
            "........lf......",
            "......lffl......",
            "....l.lfffl.....",
            ".....llfffl.....",
            "....lfffffl.....",
            "...llflffll.....",
            "...lffffffl.....",
            "...lfffffff.....",
            "....lffffffl....",
            "....tttttttt....",
            "...tttttttttt...",
            "..tt..tt..tt....",
            "................"
        ],
        [
            "................",
            "........l.......",
            ".......lf.......",
            ".......lf.......",
            "......lffl......",
            "......lfffl.....",
            "...l.llfffl.....",
            "....lfflffl.....",
            "...llflfffl.....",
            "...lffffffl.....",
            "...lfffffff.....",
            "....lffffffl....",
            "....tttttttt....",
            "...tttttttttt...",
            "..tt..tt..tt....",
            "................"
        ],
        [
            "................",
            "......l.........",
            ".....lf.........",
            ".....lf.........",
            "....lffl........",
            "....lfffl...l...",
            "...llfffl.......",
            "....lffflfl.....",
            "...llflfffl.....",
            "...lffffffl.....",
            "...lfffffff.....",
            "....lffffffl....",
            "....tttttttt....",
            "...tttttttttt...",
            "..tt..tt..tt....",
            "................"
        ],
        [
            "................",
            ".....l..........",
            "....lf..........",
            "....lf..........",
            "....lffl........",
            "....lfffl.......",
            "...llfffl..l....",
            "....lfffffl.....",
            "...llflfffl.....",
            "...lffffffl.....",
            "...lfffffff.....",
            "....lffffffl....",
            "....tttttttt....",
            "...tttttttttt...",
            "..tt..tt..tt....",
            "................"
        ]
    ]

    Timer {
        id: flicker
        interval: root.frameInterval
        repeat: true
        running: root.animated && root.visible
        onTriggered: {
            root.frameIndex = (root.frameIndex + 1) % root.frames.length
            sprite.requestPaint()
        }
    }

    Canvas {
        id: sprite
        anchors.fill: parent
        antialiasing: false
        renderTarget: Canvas.Image
        onPaint: {
            const bitmap = root.frames[root.frameIndex]
            const c = getContext("2d")
            c.clearRect(0, 0, width, height)
            for (let y = 0; y < 16; ++y) {
                for (let x = 0; x < 16; ++x) {
                    const ch = bitmap[y][x]
                    if (ch === '.') continue
                    c.fillStyle = ch === 'l' ? root.flameLight.toString()
                                : ch === 'f' ? root.fire.toString() : root.timber.toString()
                    c.fillRect(x * 2, y * 2, 2, 2)
                }
            }
        }
    }
}
