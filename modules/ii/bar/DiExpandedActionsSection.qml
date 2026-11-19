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
                text: "bolt"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Quick Actions")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }
        }

        // Actions grid
        GridLayout {
            Layout.fillWidth: true
            columns: 4
            columnSpacing: 8
            rowSpacing: 8
            Layout.leftMargin: 16
            Layout.rightMargin: 16

            ActionButton {
                icon: "lock"
                label: Translation.tr("Lock")
                color: Appearance.colors.colPrimary
                onClicked: {
                    Quickshell.execDetached([Directories.scriptPath + "/hyprland/session.sh", "lock"]);
                    root.di.expanded = false;
                }
            }

            ActionButton {
                icon: "power_settings_new"
                label: Translation.tr("Power")
                color: Appearance.colors.colError
                onClicked: {
                    GlobalStates.sessionOpen = true;
                    root.di.expanded = false;
                }
            }

            ActionButton {
                icon: "settings"
                label: Translation.tr("Settings")
                color: Appearance.colors.colSecondary
                onClicked: {
                    GlobalStates.openSettingsAt("dashboard", Translation.tr("Dashboard"), "", "");
                    root.di.expanded = false;
                }
            }

            ActionButton {
                icon: "wallpaper"
                label: Translation.tr("Wallpaper")
                color: Appearance.colors.colTertiary
                onClicked: {
                    GlobalStates.wallpaperSelectorOpen = true;
                    root.di.expanded = false;
                }
            }

            ActionButton {
                icon: "brightness_6"
                label: Translation.tr("Brightness")
                color: Appearance.m3colors.m3warning
                onClicked: {
                    GlobalStates.osdIndicatorType = "brightness";
                    GlobalStates.osdBrightnessOpen = true;
                    root.di.expanded = false;
                }
            }

            ActionButton {
                icon: "volume_up"
                label: Translation.tr("Volume")
                color: Appearance.colors.colPrimary
                onClicked: {
                    GlobalStates.osdIndicatorType = "volume";
                    GlobalStates.osdVolumeOpen = true;
                    root.di.expanded = false;
                }
            }

            ActionButton {
                icon: "nightlight"
                label: Translation.tr("Night Light")
                color: Appearance.colors.colSecondary
                onClicked: {
                    Hyprsunset.enabled = !Hyprsunset.enabled;
                    root.di.expanded = false;
                }
            }

            ActionButton {
                icon: "do_not_disturb"
                label: Translation.tr("DND")
                color: Appearance.colors.colTertiary
                onClicked: {
                    // Toggle DND - would need a DND service
                    root.di.expanded = false;
                }
            }

            ActionButton {
                icon: "screen_record"
                label: Translation.tr("Record")
                color: Appearance.colors.colError
                onClicked: {
                    Quickshell.execDetached([Directories.recordScriptPath]);
                    root.di.expanded = false;
                }
            }

            ActionButton {
                icon: "terminal"
                label: Translation.tr("Terminal")
                color: Appearance.colors.colPrimary
                onClicked: {
                    Quickshell.execDetached(["foot"]);
                    root.di.expanded = false;
                }
            }

            ActionButton {
                icon: "folder_open"
                label: Translation.tr("Files")
                color: Appearance.colors.colSecondary
                onClicked: {
                    Quickshell.execDetached(["foot", "-e", "yazi"]);
                    root.di.expanded = false;
                }
            }

            ActionButton {
                icon: "refresh"
                label: Translation.tr("Reload")
                color: Appearance.colors.colTertiary
                onClicked: {
                    Quickshell.reload();
                    root.di.expanded = false;
                }
            }
        }
    }
}

// Reusable action button
Item {
    id: ActionButton
    required property string icon
    required property string label
    required property color color
    Layout.fillWidth: true
    implicitHeight: 72

    Rectangle {
        id: btnRect
        anchors.fill: parent
        radius: 12
        color: Appearance.colors.colLayer1
        border.width: 1
        border.color: Appearance.colors.colOutlineVariant

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: actionButton.onClicked()
            onEntered: btnRect.color = Qt.lighter(Appearance.colors.colLayer1, 1.05)
            onExited: btnRect.color = Appearance.colors.colLayer1

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 4

                MaterialSymbol {
                    Layout.alignment: Qt.AlignHCenter
                    text: actionButton.icon
                    iconSize: 24
                    fill: 1
                    color: actionButton.color
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: actionButton.label
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.weight: Font.Medium
                    color: Appearance.colors.colOnLayer0
                }
            }
        }
    }
}