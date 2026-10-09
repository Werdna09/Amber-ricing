import QtQuick
import Quickshell

PopupWindow {
    id: root
    required property Item anchorItem
    required property var theme
    required property var clockService
    property int monthOffset: 0
    readonly property date viewed: new Date(clockService.date.getFullYear(), clockService.date.getMonth() + monthOffset, 1)
    readonly property var months: ["Leden", "Únor", "Březen", "Duben", "Květen", "Červen", "Červenec", "Srpen", "Září", "Říjen", "Listopad", "Prosinec"]
    implicitWidth: 322
    implicitHeight: 352
    color: "transparent"
    grabFocus: true
    anchor.item: root.anchorItem
    anchor.rect.x: Math.round((root.anchorItem.width - root.implicitWidth) / 2)
    anchor.rect.y: root.anchorItem.height + 8
    anchor.edges: Edges.Bottom | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right
    anchor.adjustment: PopupAdjustment.SlideX 
    anchor.margins.top: 7
    onVisibleChanged: if (visible) monthOffset = 0

    Rectangle {
        anchors.fill: parent
        radius: 2
        color: root.theme.colors.background
        border.width: 1
        border.color: root.theme.colors.accent

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            Row {
                width: parent.width
                height: 32
                Text {
                    width: parent.width - 80
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.months[root.viewed.getMonth()] + " " + root.viewed.getFullYear()
                    color: root.theme.colors.accent
                    font.family: "JetBrains Mono"; font.pixelSize: 15; font.bold: true
                }
                Text {
                    text: "‹"; width: 40; height: 32
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    color: root.theme.colors.text; font.pixelSize: 24
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.monthOffset-- }
                }
                Text {
                    text: "›"; width: 40; height: 32
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    color: root.theme.colors.text; font.pixelSize: 24
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.monthOffset++ }
                }
            }
            Grid {
                columns: 7
                spacing: 3
                Repeater {
                    model: ["Po", "Út", "St", "Čt", "Pá", "So", "Ne"]
                    delegate: Text {
                        required property string modelData
                        width: 38; height: 23
                        text: modelData
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: root.theme.colors.muted
                        font.family: "JetBrains Mono"; font.pixelSize: 11
                    }
                }
                Repeater {
                    model: 42
                    delegate: Rectangle {
                        required property int index
                        readonly property int firstWeekday: (root.viewed.getDay() + 6) % 7
                        readonly property int day: index - firstWeekday + 1
                        readonly property int daysInMonth: new Date(root.viewed.getFullYear(), root.viewed.getMonth() + 1, 0).getDate()
                        readonly property bool inMonth: day >= 1 && day <= daysInMonth
                        readonly property bool today: inMonth && day === root.clockService.date.getDate() && root.viewed.getMonth() === root.clockService.date.getMonth() && root.viewed.getFullYear() === root.clockService.date.getFullYear()
                        width: 38; height: 30
                        radius: 2
                        color: today ? root.theme.colors.surface : "transparent"
                        border.width: today ? 1 : 0
                        border.color: root.theme.colors.accent
                        Text {
                            anchors.centerIn: parent
                            text: parent.inMonth ? parent.day : ""
                            color: parent.today ? root.theme.colors.accent : root.theme.colors.text
                            font.family: "JetBrains Mono"; font.pixelSize: 12
                        }
                    }
                }
            }
            Text {
                text: "Dnes · " + Qt.formatDate(root.clockService.date, "d. M. yyyy")
                color: root.theme.colors.muted
                font.family: "JetBrains Mono"; font.pixelSize: 11
            }
        }
    }
}
