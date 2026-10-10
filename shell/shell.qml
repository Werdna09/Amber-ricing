//@ pragma ShellId amber
import QtQuick
import Quickshell
import "theme"
import "services"
import "components"

ShellRoot {
    ThemeManager { id: theme }
    KWinWorkspaces { id: workspaces }
    SystemStats { id: stats }
    NetworkStatus { id: network }
    BluetoothStatus { id: bluetooth }
    AudioStatus { id: audio }
    BatteryStatus { id: battery }
    UpdateStatus { id: updates }
    MediaStatus { id: media }
    BonfireNotifications { id: notifications }
    KeyboardStatus { id: keyboard }
    WindowStatus { id: windows }

    AmberTopPanel {
        theme: theme
        workspaces: workspaces
        stats: stats
        network: network
        bluetooth: bluetooth
        audio: audio
        battery: battery
        updates: updates
        media: media
        keyboard: keyboard
        notifications: notifications
    }
    // Amber Dock v1 — independent of the existing top panel.
    AmberDock {
        theme: theme
        windowService: windows
    }
}
