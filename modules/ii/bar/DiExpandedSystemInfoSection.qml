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
                text: "info"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("System Info")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }
        }

        // System info grid
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 12
            rowSpacing: 12
            Layout.leftMargin: 16
            Layout.rightMargin: 16

            SystemInfoCard {
                title: Translation.tr("Hostname")
                value: SystemInfo.hostname
                icon: "dns"
                color: Appearance.colors.colPrimary
            }

            SystemInfoCard {
                title: Translation.tr("OS")
                value: `${SystemInfo.distroName} ${SystemInfo.distroVersion}`
                icon: "computer"
                color: Appearance.colors.colSecondary
            }

            SystemInfoCard {
                title: Translation.tr("Kernel")
                value: SystemInfo.kernelVersion
                icon: "memory"
                color: Appearance.colors.colTertiary
            }

            SystemInfoCard {
                title: Translation.tr("Uptime")
                value: SystemInfo.uptime
                icon: "schedule"
                color: Appearance.m3colors.m3warning
            }

            SystemInfoCard {
                title: Translation.tr("CPU")
                value: `${SystemInfo.cpuModel ?? ""} (${SystemInfo.cpuCores ?? 0} cores)`
                icon: "memory"
                color: Appearance.colors.colPrimary
            }

            SystemInfoCard {
                title: Translation.tr("Memory")
                value: `${FileUtils.formatBytes(SystemInfo.memoryTotal)}`
                icon: "storage"
                color: Appearance.colors.colSecondary
            }

            SystemInfoCard {
                title: Translation.tr("GPU")
                value: SystemInfo.gpuModel ?? Translation.tr("Unknown")
                icon: "memory"
                color: Appearance.colors.colTertiary
            }

            SystemInfoCard {
                title: Translation.tr("Shell")
                value: `end4-pC ${Quickshell.version ?? ""}`
                icon: "extension"
                color: Appearance.colors.colPrimary
            }

            SystemInfoCard {
                title: Translation.tr("Qt")
                value: Qt.version
                icon: "code"
                color: Appearance.colors.colSecondary
            }

            SystemInfoCard {
                title: Translation.tr("Display Server")
                value: SystemInfo.windowingSystem
                icon: "monitor"
                color: Appearance.colors.colTertiary
            }

            SystemInfoCard {
                title: Translation.tr("DE")
                value: SystemInfo.desktopEnvironment
                icon: "desktop_mac"
                color: Appearance.colors.colPrimary
            }

            SystemInfoCard {
                title: Translation.tr("Architecture")
                value: SystemInfo.kernelArchitecture
                icon: "architecture"
                color: Appearance.colors.colSecondary
            }
        }
    }
}

// System info card
Item {
    id: SystemInfoCard
    required property string title
    required property string value
    required property string icon
    required property color color
    Layout.fillWidth: true
    Layout.preferredHeight: 56

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

            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 40
                implicitHeight: 40
                radius: 20
                color: color
                opacity: 0.15

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: icon
                    iconSize: 20
                    fill: 1
                    color: color
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: -2

                StyledText {
                    Layout.fillWidth: true
                    text: title
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }

                StyledText {
                    Layout.fillWidth: true
                    text: value
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Medium
                    color: Appearance.colors.colOnLayer0
                    elide: Text.ElideRight
                }
            }
        }
    }
}