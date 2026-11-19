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
                text: "hard_drive"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Storage")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }
        }

        // Disk list
        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            spacing: 4

            Repeater {
                model: SystemInfo.mounts ?? []
                delegate: DiskCard {
                    Layout.fillWidth: true
                    mount: modelData
                }
            }
        }

        // IO stats
        Revealer {
            reveal: ResourceUsage.diskReadSpeed > 0 || ResourceUsage.diskWriteSpeed > 0
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16

            Rectangle {
                Layout.fillWidth: true
                radius: 12
                color: Appearance.colors.colLayer1
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant

                RowLayout {
                    anchors.fill: parent
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                    Layout.topMargin: 12
                    Layout.bottomMargin: 12
                    spacing: 16

                    // Read speed
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        StyledText {
                            text: Translation.tr("Read")
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colSubtext
                        }

                        StyledText {
                            text: FileUtils.formatBytes(ResourceUsage.diskReadSpeed) + "/s"
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: Font.Medium
                            font.family: "monospace"
                            color: Appearance.colors.colPrimary
                        }
                    }

                    // Divider
                    Rectangle {
                        width: 1
                        Layout.fillHeight: true
                        color: Appearance.colors.colOutlineVariant
                        opacity: 0.3
                    }

                    // Write speed
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        StyledText {
                            text: Translation.tr("Write")
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colSubtext
                        }

                        StyledText {
                            text: FileUtils.formatBytes(ResourceUsage.diskWriteSpeed) + "/s"
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: Font.Medium
                            font.family: "monospace"
                            color: Appearance.colors.colSecondary
                        }
                    }
                }
            }
        }
    }
}

// Disk mount card
Item {
    id: DiskCard
    required property var mount
    Layout.fillWidth: true
    implicitHeight: 56

    property real usedPercent: mount.total > 0 ? mount.used / mount.total : 0
    property color usageColor: usedPercent > 0.9 ? Appearance.colors.colError : (usedPercent > 0.75 ? Appearance.colors.colWarning : Appearance.colors.colPrimary)

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Appearance.colors.colLayer1
        border.width: 1
        border.color: Appearance.colors.colOutlineVariant

        RowLayout {
            anchors.fill: parent
            Layout.leftMargin: 12
            Layout.rightMargin: 12
            spacing: 12

            // Drive icon
            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 40
                implicitHeight: 40
                radius: 20
                color: usageColor
                opacity: 0.15

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: mount.fsType?.includes("ntfs") || mount.fsType?.includes("fat") || mount.fsType?.includes("exfat") ? "usb" : "hard_drive"
                    iconSize: 20
                    fill: 1
                    color: usageColor
                }
            }

            // Mount info
            ColumnLayout {
                Layout.fillWidth: true
                spacing: -2

                StyledText {
                    Layout.fillWidth: true
                    text: mount.mountPoint ?? mount.device ?? Translation.tr("Unknown")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Medium
                    color: Appearance.colors.colOnLayer0
                }

                StyledText {
                    Layout.fillWidth: true
                    text: `${FileUtils.formatBytes(mount.used)} / ${FileUtils.formatBytes(mount.total)}  (${mount.fsType ?? ""})`
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }
            }

            // Usage
            ColumnLayout {
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                spacing: 4
                Layout.minimumWidth: 80

                StyledText {
                    Layout.alignment: Qt.AlignRight
                    text: `${Math.round(usedPercent * 100)}%`
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Bold
                    color: usageColor
                }

                StyledProgressBar {
                    Layout.fillWidth: true
                    valueBarWidth: 100
                    value: usedPercent
                    color: usageColor
                }
            }
        }
    }
}