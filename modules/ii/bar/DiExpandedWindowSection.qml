import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root
    required property Item di
    Layout.fillWidth: true

    readonly property var activeWindow: ToplevelManager.activeToplevel

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
                text: "open_in_new"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Active Window")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }
        }

        Revealer {
            reveal: root.activeWindow !== null
            Layout.fillWidth: true

            // Window card
            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                radius: 16
                color: Appearance.colors.colLayer1
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant

                ColumnLayout {
                    anchors.fill: parent
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.topMargin: 16
                    Layout.bottomMargin: 16
                    spacing: 12

                    // Title bar
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        // App icon
                        Revealer {
                            reveal: activeWindow?.icon !== undefined && activeWindow.icon.length > 0
                            Rectangle {
                                Layout.alignment: Qt.AlignVCenter
                                implicitWidth: 40
                                implicitHeight: 40
                                radius: 20
                                color: Appearance.colors.colPrimary
                                opacity: 0.15

                                Image {
                                    anchors.fill: parent
                                    source: activeWindow.icon
                                    fillMode: Image.PreserveAspectCrop
                                    clip: true
                                }
                            }
                        }

                        Revealer {
                            reveal: !(activeWindow?.icon !== undefined && activeWindow.icon.length > 0)
                            Rectangle {
                                Layout.alignment: Qt.AlignVCenter
                                implicitWidth: 40
                                implicitHeight: 40
                                radius: 20
                                color: Appearance.colors.colPrimary
                                opacity: 0.15

                                MaterialSymbol {
                                    anchors.centerIn: parent
                                    text: "window"
                                    iconSize: 20
                                    fill: 1
                                    color: Appearance.colors.colPrimary
                                }
                            }
                        }

                        // Window title + class
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            StyledText {
                                Layout.fillWidth: true
                                text: activeWindow?.title ?? Translation.tr("Untitled")
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: Font.Medium
                                color: Appearance.colors.colOnLayer0
                                elide: Text.ElideRight
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: activeWindow?.class ?? activeWindow?.appId ?? ""
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colSubtext
                                elide: Text.ElideRight
                            }
                        }

                        // Workspace
                        Revealer {
                            reveal: activeWindow?.workspace !== undefined
                            StyledText {
                                Layout.alignment: Qt.AlignVCenter
                                text: Translation.tr("Workspace %1").arg(activeWindow.workspace?.id ?? activeWindow.workspace?.name ?? "")
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.weight: Font.Medium
                                color: Appearance.colors.colPrimary
                                padding: 4
                            }
                        }
                    }

                    // Window controls
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        WindowControlButton {
                            icon: "minimize"
                            tooltip: Translation.tr("Minimize")
                            onClicked: { if (activeWindow) activeWindow.minimized = true; }
                        }

                        WindowControlButton {
                            icon: activeWindow?.maximized ? "fullscreen_exit" : "fullscreen"
                            tooltip: Translation.tr("Maximize/Restore")
                            onClicked: { if (activeWindow) activeWindow.maximized = !activeWindow.maximized; }
                        }

                        WindowControlButton {
                            icon: "close"
                            color: Appearance.colors.colError
                            tooltip: Translation.tr("Close")
                            onClicked: { if (activeWindow) activeWindow.close(); }
                        }

                        Item { Layout.fillWidth: true }

                        // Window actions
                        WindowControlButton {
                            icon: activeWindow?.floating ? "border_all" : "border_clear"
                            tooltip: Translation.tr("Toggle float")
                            onClicked: { if (activeWindow) Hyprland.sendMessage("dispatch", "togglefloating", activeWindow.address); }
                        }

                        WindowControlButton {
                            icon: activeWindow?.pinned ? "push_pin" : "push_pin"
                            fill: activeWindow?.pinned ? 1 : 0
                            tooltip: Translation.tr("Toggle pin")
                            onClicked: { if (activeWindow) Hyprland.sendMessage("dispatch", "pin", activeWindow.address); }
                        }

                        WindowControlButton {
                            icon: "content_copy"
                            tooltip: Translation.tr("Copy title")
                            onClicked: { Quickshell.copyToClipboard(activeWindow?.title ?? ""); }
                        }
                    }

                    // Window info
                    Revealer {
                        reveal: activeWindow?.pid !== undefined || activeWindow?.address !== undefined
                        Rectangle {
                            Layout.fillWidth: true
                            radius: 8
                            color: Appearance.colors.colLayer0
                            implicitHeight: 36

                            RowLayout {
                                anchors.fill: parent
                                Layout.leftMargin: 12
                                Layout.rightMargin: 12
                                spacing: 16

                                InfoRow { label: Translation.tr("PID"); value: activeWindow?.pid ?? "—" }
                                InfoRow { label: Translation.tr("Address"); value: activeWindow?.address?.slice(-8) ?? "—" }
                                InfoRow { label: Translation.tr("Size"); value: activeWindow?.geometry ? `${activeWindow.geometry.width}x${activeWindow.geometry.height}` : "—" }
                                InfoRow { label: Translation.tr("Pos"); value: activeWindow?.geometry ? `${activeWindow.geometry.x},${activeWindow.geometry.y}` : "—" }
                            }
                        }
                    }
                }
            }
        }

        Revealer {
            reveal: root.activeWindow === null
            Layout.fillWidth: true

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                implicitHeight: 80
                radius: 12
                color: Appearance.colors.colLayer1
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant
                opacity: 0.5

                StyledText {
                    anchors.centerIn: parent
                    text: Translation.tr("No active window")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colSubtext
                }
            }
        }
    }
}

// Window control button
Item {
    id: WindowControlButton
    required property string icon
    property string tooltip: ""
    property color color: Appearance.colors.colOnLayer0
    property bool fill: 0
    implicitWidth: 36
    implicitHeight: 36

    Rectangle {
        id: btnBg
        anchors.centerIn: parent
        width: 32
        height: 32
        radius: 16
        color: "transparent"

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: windowControlButton.onClicked()
            onEntered: btnBg.color = Qt.lighter(Appearance.colors.colLayer1, 1.1)
            onExited: btnBg.color = "transparent"

            MaterialSymbol {
                anchors.centerIn: parent
                text: windowControlButton.icon
                iconSize: 18
                fill: windowControlButton.fill
                color: windowControlButton.color
            }
        }
    }
}

// Info row
Item {
    id: InfoRow
    required property string label
    required property string value
    Layout.fillWidth: true

    ColumnLayout {
        spacing: -2

        StyledText {
            text: label
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: Appearance.colors.colSubtext
        }

        StyledText {
            text: value
            font.pixelSize: Appearance.font.pixelSize.smaller
            font.weight: Font.Medium
            font.family: "monospace"
            color: Appearance.colors.colOnLayer0
        }
    }
}