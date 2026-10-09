import QtQuick
import Quickshell
import Quickshell.Io

// Lightweight KWin application tracker adapted from the working Crylia approach.
// Requires kdotool; never changes the user's desktop or KWin settings.
Scope {
    id: root
    property var applications: []

    readonly property string queryScript:
        "var result=[];" +
        "var ws=workspace.stackingOrder;" +
        "for (var i=0;i<ws.length;i++){" +
        "var w=ws[i];" +
        "if(w.deleted||w.skipTaskbar||w.specialWindow)continue;" +
        "if(!w.normalWindow&&!w.dialog)continue;" +
        "result.push({id:String(w.internalId)," +
        "caption:String(w.caption||'')," +
        "desktopFile:String(w.desktopFileName||'')," +
        "resourceClass:String(w.resourceClass||'')," +
        "active:Boolean(w.active),minimized:Boolean(w.minimized)});" +
        "}output_result(JSON.stringify(result));"

    function normalize(value) {
        let text = String(value || "").trim().toLowerCase()
        const slash = text.lastIndexOf("/")
        if (slash >= 0) text = text.substring(slash + 1)
        if (text.endsWith(".desktop")) text = text.slice(0, -8)
        return text
    }

    function applySnapshot(raw) {
        let entries
        try { entries = JSON.parse(String(raw || "").trim()) }
        catch (error) {
            console.warn("Amber WindowStatus: invalid kdotool output", error)
            return
        }
        if (!Array.isArray(entries)) return
        const map = {}
        for (let i = 0; i < entries.length; ++i) {
            const w = entries[i]
            const key = normalize(w.desktopFile || w.resourceClass || w.caption)
            if (!key) continue
            if (!map[key]) {
                map[key] = {
                    key: key, desktopFile: w.desktopFile, resourceClass: w.resourceClass,
                    caption: w.caption, active: false, minimized: true,
                    windowCount: 0, activeWindowId: "", representativeId: "", windows: []
                }
            }
            const app = map[key]
            app.windowCount++
            app.windows.push({
                id: String(w.id || ""),
                caption: String(w.caption || ""),
                minimized: Boolean(w.minimized),
                active: Boolean(w.active)
            })
            app.representativeId = w.id
            if (w.active) {
                app.active = true
                app.activeWindowId = w.id
                app.representativeId = w.id
            }
            if (!w.minimized) app.minimized = false
            if (!app.desktopFile && w.desktopFile) app.desktopFile = w.desktopFile
            if (!app.resourceClass && w.resourceClass) app.resourceClass = w.resourceClass
        }
        applications = Object.keys(map).sort().map(key => map[key])
    }

    function refresh() { if (!queryProcess.running) queryProcess.running = true }
    function refreshSoon(ms) {
        delay.interval = ms === undefined ? 300 : ms
        delay.restart()
    }
    function activate(id) {
        if (!id) return
        Quickshell.execDetached(["kdotool", "windowactivate", String(id)])
        refreshSoon(250)
    }
    function minimize(id) {
        if (!id) return
        Quickshell.execDetached(["kdotool", "windowminimize", String(id)])
        refreshSoon(250)
    }
    function close(id) {
        if (!id) return
        Quickshell.execDetached(["kdotool", "windowclose", String(id)])
        refreshSoon(350)
    }

    Process {
        id: queryProcess
        command: ["kdotool", "kwinscript", "--inline", root.queryScript]
        stdout: StdioCollector {
            onStreamFinished: root.applySnapshot(this.text)
        }
    }
    Timer { interval: 1000; repeat: true; running: true; onTriggered: root.refresh() }
    Timer { id: delay; interval: 300; repeat: false; onTriggered: root.refresh() }
    Component.onCompleted: root.refresh()
}
