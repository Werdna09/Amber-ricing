
 //@ pragma ShellId amber

import QtQuick
import Quickshell

import "theme"
import "services"
import "components"

ShellRoot {
    id: root

    ThemeManager {
        id: theme
    }

    KWinWorkspaces {
        id: workspaces
    }

    AmberTopPanel {
        theme: theme
        workspaces: workspaces
    }
}

