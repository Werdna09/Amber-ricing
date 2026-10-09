import QtQuick

// A passive 1-pixel decorative frame. Does not intercept mouse or keyboard input.
Item {
    id: root
    property color accent: "#DAA45C"
    property color secondary: "#644A35"
    property bool innerLine: true
    property int cornerSize: 11

    onAccentChanged: { if (ink) ink.requestPaint(); }
    onSecondaryChanged: { if (ink) ink.requestPaint(); }
    onWidthChanged: { if (ink) ink.requestPaint(); }
    onHeightChanged: { if (ink) ink.requestPaint(); }

    Canvas {
        id: ink
        anchors.fill: parent
        antialiasing: false
        renderTarget: Canvas.Image
        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            const w = Math.floor(width), h = Math.floor(height);
            if (w < 30 || h < 20) return;
            // The frame and corners are drawn on the same pixel grid.
            ctx.fillStyle = root.accent.toString();
            ctx.fillRect(1, 1, w - 2, 1);
            ctx.fillRect(1, h - 2, w - 2, 1);
            ctx.fillRect(1, 1, 1, h - 2);
            ctx.fillRect(w - 2, 1, 1, h - 2);
            if (root.innerLine && w > 15 && h > 15) {
                ctx.fillStyle = root.secondary.toString();
                ctx.fillRect(4, 4, w - 8, 1);
                ctx.fillRect(4, h - 5, w - 8, 1);
            }
            // Four tiny mirrored, stepped corner engravings, no rotation or offset.
            ctx.fillStyle = root.accent.toString();
            for (let a = 0; a < 2; a++) for (let b = 0; b < 2; b++) {
                const ox = a === 0 ? 0 : w - 1;
                const oy = b === 0 ? 0 : h - 1;
                const sx = a === 0 ? 1 : -1;
                const sy = b === 0 ? 1 : -1;
                const dots = [[2,2,7,1],[2,2,1,7],[5,5,5,1],[5,5,1,5],[8,8,3,1],[8,8,1,3]];
                for (let k = 0; k < dots.length; k++) {
                    const d = dots[k];
                    const px = sx === 1 ? ox + d[0] : ox - d[0] - d[2] + 1;
                    const py = sy === 1 ? oy + d[1] : oy - d[1] - d[3] + 1;
                    ctx.fillRect(px, py, d[2], d[3]);
                }
            }
        }
    }
}
