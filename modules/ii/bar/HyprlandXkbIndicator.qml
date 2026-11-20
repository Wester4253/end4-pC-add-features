import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.modules.common
import qs.modules.common.models
import qs.modules.common.widgets
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Loader {
    id: root
    property color contentColor: Appearance.colors.colOnLayer0
    property bool contentColorOverridden: false
    property bool vertical: false
    property color color: Appearance.colors.colOnSurfaceVariant

    sourceComponent: Item {
        implicitWidth: root.vertical ? null : rowLayout.implicitWidth + 8
        implicitHeight: root.vertical ? rowLayout.implicitHeight + 6 : null

        RowLayout {
            id: rowLayout
            anchors.centerIn: parent
            spacing: 5

            StyledText {
                id: layoutCodeText
                horizontalAlignment: Text.AlignHCenter
                text: WM.compositor === "niri" ? NiriXkb.currentLayoutCode : root.currentLayoutCode
                font.pixelSize: Appearance.font.pixelSize.small
                color: root.contentColor
                animateChange: true
            }
        }
    }

    // Current layout code - falls back to HyprlandXkb, with initial read from Hyprland
    property string currentLayoutCode: HyprlandXkb.currentLayoutCode

    // Read initial layout on startup if not already set
    Component.onCompleted: {
        if (!HyprlandXkb.currentLayoutCode && WM.compositor === "hyprland") {
            initialLayoutProc.running = true;
        }
    }

    Process {
        id: initialLayoutProc
        command: ["hyprctl", "devices", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const result = JSON.parse(text);
                    if (result && result.keyboards) {
                        const kb = result.keyboards.find(k => k.main);
                        if (kb && kb.active_keymap) {
                            currentLayoutCode = kb.active_keymap.split(":")[0] || kb.active_keymap;
                        }
                    }
                } catch (e) {}
            }
        }
    }

    // Listen for layout changes
    Connections {
        target: HyprlandXkb
        function onCurrentLayoutCodeChanged() {
            if (HyprlandXkb.currentLayoutCode) {
                currentLayoutCode = HyprlandXkb.currentLayoutCode;
            }
        }
    }
}