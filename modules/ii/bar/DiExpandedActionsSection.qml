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

    // Reusable action button component
    Component {
        id: actionButton
        Item {
            property string icon
            property string label
            property color color
            property var onClicked
            Layout.fillWidth: true
            implicitHeight: 72

            Rectangle {
                anchors.fill: parent
                radius: 12
                color: Appearance.colors.colLayer1
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: actionButton.onClicked()
                    onEntered: parent.color = Qt.lighter(Appearance.colors.colLayer1, 1.05)
                    onExited: parent.color = Appearance.colors.colLayer1

                    RowLayout {
                        anchors.fill: parent
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16
                        spacing: 12

                        MaterialSymbol {
                            Layout.alignment: Qt.AlignVCenter
                            text: actionButton.icon
                            iconSize: 24
                            fill: 1
                            color: actionButton.color
                        }

                        StyledText {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            text: actionButton.label
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: Font.Medium
                            color: Appearance.colors.colOnLayer0
                        }

                        Item { Layout.fillWidth: true }

                        MaterialSymbol {
                            Layout.alignment: Qt.AlignVCenter
                            text: "chevron_right"
                            iconSize: 20
                            fill: 1
                            color: Appearance.colors.colSubtext
                        }
                    }
                }
            }
        }
    }

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
                text: Translation.tr("Actions")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }
        }

        Loader {
            sourceComponent: actionButton
            Binding { target: item; property: "icon"; value: "power_settings_new" }
            Binding { target: item; property: "label"; value: Translation.tr("Power") }
            Binding { target: item; property: "color"; value: Appearance.colors.colError }
            Binding { target: item; property: "onClicked"; value: { GlobalStates.sessionOpen = true; root.di.expanded = false; } }
        }

        Loader {
            sourceComponent: actionButton
            Binding { target: item; property: "icon"; value: "settings" }
            Binding { target: item; property: "label"; value: Translation.tr("Settings") }
            Binding { target: item; property: "color"; value: Appearance.colors.colSecondary }
            Binding { target: item; property: "onClicked"; value: { GlobalStates.openSettingsAt("dashboard", Translation.tr("Dashboard"), "", ""); root.di.expanded = false; } }
        }

        Loader {
            sourceComponent: actionButton
            Binding { target: item; property: "icon"; value: "wallpaper" }
            Binding { target: item; property: "label"; value: Translation.tr("Wallpaper") }
            Binding { target: item; property: "color"; value: Appearance.colors.colTertiary }
            Binding { target: item; property: "onClicked"; value: { GlobalStates.wallpaperSelectorOpen = true; root.di.expanded = false; } }
        }

        Loader {
            sourceComponent: actionButton
            Binding { target: item; property: "icon"; value: "brightness_6" }
            Binding { target: item; property: "label"; value: Translation.tr("Brightness") }
            Binding { target: item; property: "color"; value: Appearance.m3colors.m3warning }
            Binding { target: item; property: "onClicked"; value: { GlobalStates.osdIndicatorType = "brightness"; GlobalStates.osdBrightnessOpen = true; root.di.expanded = false; } }
        }

        Loader {
            sourceComponent: actionButton
            Binding { target: item; property: "icon"; value: "volume_up" }
            Binding { target: item; property: "label"; value: Translation.tr("Volume") }
            Binding { target: item; property: "color"; value: Appearance.colors.colPrimary }
            Binding { target: item; property: "onClicked"; value: { GlobalStates.osdIndicatorType = "volume"; GlobalStates.osdVolumeOpen = true; root.di.expanded = false; } }
        }

        Loader {
            sourceComponent: actionButton
            Binding { target: item; property: "icon"; value: "screen_share" }
            Binding { target: item; property: "label"; value: Translation.tr("Project Display") }
            Binding { target: item; property: "color"; value: Appearance.colors.colInfo }
            Binding { target: item; property: "onClicked"; value: { GlobalStates.projectDisplayOpen = true; root.di.expanded = false; } }
        }
    }
}
