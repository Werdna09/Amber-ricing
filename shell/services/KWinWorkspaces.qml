import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root
    property int current: 1
    function refresh() {
        if (!currentDesktopQuery.running) currentDesktopQuery.running = true
    }
    function switchTo(desktop) {
        if (desktop < 1 || desktop > 4) return
        Quickshell.execDetached(["qdbus6", "org.kde.KWin", "/KWin", "org.kde.KWin.setCurrentDesktop", String(desktop)])
        root.current = desktop
    }
    Process {
        id: currentDesktopQuery
        command: ["qdbus6", "org.kde.KWin", "/KWin", "org.kde.KWin.currentDesktop"]
        stdout: StdioCollector {
            onStreamFinished: {
                const value = parseInt(text.trim())
                if (!isNaN(value) && value >= 1 && value <= 4) root.current = value
            }
        }
    }
    Process {
        id: workspaceMonitor
        running: true
        command: ["dbus-monitor", "--session", "type='signal',path='/VirtualDesktopManager',interface='org.kde.KWin.VirtualDesktopManager',member='currentChanged'"]
        stdout: SplitParser {
            onRead: line => { if (line.indexOf("member=currentChanged") !== -1) root.refresh() }
        }
    }
    Component.onCompleted: refresh()
}
