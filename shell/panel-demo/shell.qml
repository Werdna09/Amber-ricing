//@ pragma ShellId amber-panel-demo
import QtQuick
import Quickshell
import "../theme"
import "../components"
import "../services"

ShellRoot {
    ThemeManager { id: theme }
    KWinWorkspaces { id: workspaces }
    AmberTopPanel { theme: theme; workspaces: workspaces }
}
