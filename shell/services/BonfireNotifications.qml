import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// Amber notification broker; one D-Bus notification server per Quickshell process.
// History is intentionally in-memory only. DND silences Amber toasts, not incoming messages.
Scope {
    id: root

    property var entries: []
    property int unreadCount: 0
    property bool doNotDisturb: false
    property int nextId: 0
    property int toastSerial: 0
    property var latestToast: null
    readonly property int maxHistory: 40

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: false
        actionsSupported: true
        persistenceSupported: true
        imageSupported: true
        onNotification: notification => {
            // Transient alerts only need the toast; do not persist them on D-Bus.
            notification.tracked = !notification.transient
            root.receive(notification)
        }
    }

    function receive(notification) {
        const uid = ++nextId
        const actions = []
        for (let i = 0; i < notification.actions.length; ++i) {
            const action = notification.actions[i]
            actions.push({ label: String(action.text || "Action"), index: i })
        }
        const item = {
            uid: uid,
            app: String(notification.appName || "Application"),
            title: String(notification.summary || "Notification"),
            body: String(notification.body || ""),
            time: Qt.formatTime(new Date(), "HH:mm"),
            icon: String(notification.appIcon || ""),
            actions: actions,
            live: notification,
            unread: !notification.lastGeneration
        }
        notification.closed.connect(function(reason) {
            root.markClosed(uid)
        })

        if (!notification.transient) {
            const updated = [item].concat(entries)
            while (updated.length > maxHistory) {
                const old = updated.pop()
                if (old.live !== null) old.live.dismiss()
            }
            entries = updated
            unreadCount = unreadTotal()
        }

        // A transient notification is shown but not placed into the history.
        if (!doNotDisturb && !notification.lastGeneration) {
            latestToast = {
                app: item.app, title: item.title,
                body: item.body, time: item.time
            }
            toastSerial += 1
        }
    }

    function unreadTotal() {
        let count = 0
        for (const item of entries) {
            if (item.unread) count += 1
        }
        return count
    }

    function markRead() {
        entries = entries.map(function(item) {
            return {
                uid: item.uid, app: item.app, title: item.title,
                body: item.body, time: item.time, icon: item.icon,
                actions: item.actions, live: item.live, unread: false
            }
        })
        unreadCount = 0
    }

    function markClosed(uid) {
        // Keep a history snapshot, but never touch a destroyed notification object.
        entries = entries.map(function(item) {
            if (item.uid !== uid) return item
            return {
                uid: item.uid, app: item.app, title: item.title,
                body: item.body, time: item.time, icon: item.icon,
                actions: [], live: null, unread: item.unread
            }
        })
    }

    function dismiss(uid) {
        let live = null
        for (const item of entries) {
            if (item.uid === uid) { live = item.live; break }
        }
        entries = entries.filter(function(item) { return item.uid !== uid })
        unreadCount = unreadTotal()
        if (live !== null) live.dismiss()
    }

    function clearAll() {
        const previous = entries
        entries = []
        unreadCount = 0
        for (const item of previous) {
            if (item.live !== null) item.live.dismiss()
        }
    }

    function invokeAction(uid, index) {
        for (const item of entries) {
            if (item.uid === uid && item.live !== null && index < item.live.actions.length) {
                item.live.actions[index].invoke()
                return
            }
        }
    }
}
