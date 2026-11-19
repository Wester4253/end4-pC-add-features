import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root
    required property Item di
    Layout.fillWidth: true

    property string filterText: ""

    // Keybindings from Hyprland config
    readonly property var categories: [
        {
            name: Translation.tr("Window Management"),
            icon: "window",
            shortcuts: [
                { key: "SUPER + Q", action: Translation.tr("Close window") },
                { key: "SUPER + F", action: Translation.tr("Fullscreen") },
                { key: "SUPER + SHIFT + F", action: Translation.tr("Toggle float") },
                { key: "SUPER + P", action: Translation.tr("Pin window") },
                { key: "SUPER + SHIFT + P", action: Translation.tr("Unpin window") },
                { key: "SUPER + LEFT/RIGHT/UP/DOWN", action: Translation.tr("Move focus") },
                { key: "SUPER + SHIFT + LEFT/RIGHT/UP/DOWN", action: Translation.tr("Move window") },
                { key: "SUPER + CTRL + LEFT/RIGHT/UP/DOWN", action: Translation.tr("Resize window") },
                { key: "SUPER + V", action: Translation.tr("Toggle split") },
                { key: "SUPER + S", action: Translation.tr("Toggle pseudo") },
            ]
        },
        {
            name: Translation.tr("Workspaces"),
            icon: "view_carousel",
            shortcuts: [
                { key: "SUPER + 1-9", action: Translation.tr("Switch to workspace 1-9") },
                { key: "SUPER + SHIFT + 1-9", action: Translation.tr("Move window to workspace 1-9") },
                { key: "SUPER + CTRL + 1-9", action: Translation.tr("Move workspace to monitor") },
                { key: "SUPER + TAB", action: Translation.tr("Previous workspace") },
                { key: "SUPER + SHIFT + TAB", action: Translation.tr("Next workspace") },
                { key: "SUPER + SCROLL", action: Translation.tr("Cycle workspaces") },
            ]
        },
        {
            name: Translation.tr("Applications"),
            icon: "apps",
            shortcuts: [
                { key: "SUPER + RETURN", action: Translation.tr("Terminal") },
                { key: "SUPER + SPACE", action: Translation.tr("Launcher/Overview") },
                { key: "SUPER + D", action: Translation.tr("App launcher (rofi/wofi)") },
                { key: "SUPER + B", action: Translation.tr("Browser") },
                { key: "SUPER + E", action: Translation.tr("File manager") },
                { key: "SUPER + T", action: Translation.tr("Terminal (alt)") },
            ]
        },
        {
            name: Translation.tr("System"),
            icon: "settings",
            shortcuts: [
                { key: "SUPER + ESC", action: Translation.tr("Session menu") },
                { key: "SUPER + SHIFT + R", action: Translation.tr("Reload Hyprland") },
                { key: "SUPER + SHIFT + Q", action: Translation.tr("Kill active window") },
                { key: "PRINT", action: Translation.tr("Screenshot") },
                { key: "SHIFT + PRINT", action: Translation.tr("Screenshot region") },
                { key: "SUPER + PRINT", action: Translation.tr("Screenshot window") },
                { key: "SUPER + L", action: Translation.tr("Lock screen") },
                { key: "SUPER + SHIFT + L", action: Translation.tr("Logout") },
            ]
        },
        {
            name: Translation.tr("Media & Volume"),
            icon: "volume_up",
            shortcuts: [
                { key: "XF86AudioRaiseVolume", action: Translation.tr("Volume up") },
                { key: "XF86AudioLowerVolume", action: Translation.tr("Volume down") },
                { key: "XF86AudioMute", action: Translation.tr("Mute toggle") },
                { key: "XF86AudioPlay", action: Translation.tr("Play/Pause") },
                { key: "XF86AudioNext", action: Translation.tr("Next track") },
                { key: "XF86AudioPrev", action: Translation.tr("Previous track") },
            ]
        },
        {
            name: Translation.tr("Brightness"),
            icon: "brightness_6",
            shortcuts: [
                { key: "XF86MonBrightnessUp", action: Translation.tr("Brightness up") },
                { key: "XF86MonBrightnessDown", action: Translation.tr("Brightness down") },
            ]
        },
        {
            name: Translation.tr("Dynamic Island"),
            icon: "nest_wifi_pro",
            shortcuts: [
                { key: "Click pill", action: Translation.tr("Expand panel") },
                { key: "Scroll on pill", action: Translation.tr("Toggle idle") },
                { key: "Click badge", action: Translation.tr("Focus provider") },
            ]
        },
        {
            name: Translation.tr("Shell"),
            icon: "extension",
            shortcuts: [
                { key: "SUPER + SHIFT + C", action: Translation.tr("Color picker") },
                { key: "SUPER + SHIFT + S", action: Translation.tr("Screen snip") },
                { key: "SUPER + K", action: Translation.tr("Keyboard toggle") },
                { key: "SUPER + M", action: Translation.tr("Mic toggle") },
                { key: "SUPER + SHIFT + M", action: Translation.tr("Dark/Light toggle") },
            ]
        }
    ]

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8

        // Section header
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            spacing: 8

            MaterialSymbol {
                Layout.alignment: Qt.AlignVCenter
                text: "keyboard"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Keybindings")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }

            // Search
            Rectangle {
                implicitWidth: 180
                implicitHeight: 32
                radius: 8
                color: Appearance.colors.colLayer1
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant

                RowLayout {
                    anchors.fill: parent
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    spacing: 6

                    MaterialSymbol {
                        Layout.alignment: Qt.AlignVCenter
                        text: "search"
                        iconSize: 18
                        fill: 1
                        color: Appearance.colors.colSubtext
                    }

                    TextField {
                        Layout.fillWidth: true
                        background: null
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colOnLayer0
                        placeholderText: Translation.tr("Search shortcuts...")
                        text: root.filterText
                        onTextChanged: root.filterText = text
                    }
                }
            }
        }

        // Categories
        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            spacing: 8

            Repeater {
                model: root.categories
                delegate: ShortcutCategory {
                    Layout.fillWidth: true
                    categoryData: modelData
                    filterText: root.filterText
                }
            }
        }
    }
}

// Shortcut category
Item {
    id: ShortcutCategory
    required property var categoryData
    required property string filterText
    Layout.fillWidth: true

    property var filteredShortcuts: {
        if (!categoryData.shortcuts) return [];
        if (!filterText) return categoryData.shortcuts;
        var f = filterText.toLowerCase();
        return categoryData.shortcuts.filter(s =>
            s.key.toLowerCase().includes(f) || s.action.toLowerCase().includes(f)
        );
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4

        Revealer {
            reveal: root.filteredShortcuts.length > 0

            // Category header
            Rectangle {
                Layout.fillWidth: true
                radius: 10
                color: Appearance.colors.colPrimary
                opacity: 0.1

                RowLayout {
                    anchors.fill: parent
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                    Layout.topMargin: 8
                    Layout.bottomMargin: 8
                    spacing: 8

                    MaterialSymbol {
                        Layout.alignment: Qt.AlignVCenter
                        text: categoryData.icon
                        iconSize: 20
                        fill: 1
                        color: Appearance.colors.colPrimary
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: categoryData.name
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: Font.Medium
                        color: Appearance.colors.colPrimary
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignVCenter
                        text: `${root.filteredShortcuts.length} ${Translation.tr("shortcuts")}`
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colSubtext
                    }
                }
            }

            // Shortcuts list
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Repeater {
                    model: root.filteredShortcuts
                    delegate: ShortcutRow {
                        Layout.fillWidth: true
                        shortcut: modelData
                    }
                }
            }
        }
    }
}

// Shortcut row
Item {
    id: ShortcutRow
    required property var shortcut
    Layout.fillWidth: true
    implicitHeight: 36

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: Appearance.colors.colLayer1
        border.width: 1
        border.color: Appearance.colors.colOutlineVariant

        RowLayout {
            anchors.fill: parent
            Layout.leftMargin: 12
            Layout.rightMargin: 12
            spacing: 12

            // Key combination
            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                Layout.minimumWidth: 140
                implicitHeight: 28
                radius: 6
                color: Appearance.colors.colPrimary
                opacity: 0.15

                StyledText {
                    anchors.centerIn: parent
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    text: shortcut.key
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.weight: Font.Bold
                    font.family: "monospace"
                    color: Appearance.colors.colPrimary
                }
            }

            // Action description
            StyledText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: shortcut.action
                font.pixelSize: Appearance.font.pixelSize.normal
                color: Appearance.colors.colOnLayer0
            }
        }
    }
}