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
                text: "memory"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("System")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }
        }

        // Stats grid
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 12
            rowSpacing: 12
            Layout.leftMargin: 16
            Layout.rightMargin: 16

            SystemStatCard {
                title: Translation.tr("CPU")
                value: `${Math.round(ResourceUsage.cpuUsage * 100)}%`
                icon: "memory"
                color: ResourceUsage.cpuUsage > 0.8 ? Appearance.colors.colError : (ResourceUsage.cpuUsage > 0.5 ? Appearance.colors.colWarning : Appearance.colors.colPrimary)
                subtitle: ResourceUsage.cpuTemp > 0 ? `${Math.round(ResourceUsage.cpuTemp)}°C` : ""
                progress: ResourceUsage.cpuUsage
            }

            SystemStatCard {
                title: Translation.tr("Memory")
                value: `${Math.round(ResourceUsage.memoryUsedPercentage * 100)}%`
                icon: "memory"
                color: ResourceUsage.memoryUsedPercentage > 0.85 ? Appearance.colors.colError : (ResourceUsage.memoryUsedPercentage > 0.7 ? Appearance.colors.colWarning : Appearance.colors.colSecondary)
                subtitle: `${FileUtils.formatBytes(ResourceUsage.memoryUsed)} / ${FileUtils.formatBytes(ResourceUsage.memoryTotal)}`
                progress: ResourceUsage.memoryUsedPercentage
            }

            SystemStatCard {
                title: Translation.tr("Battery")
                value: `${Math.round(Battery.percentage * 100)}%`
                icon: Battery.isCharging ? "battery_android_frame_bolt" : (Battery.percentage <= 0.2 ? "battery_android_frame_alert" : "battery_android_frame_full")
                color: Battery.isCharging ? Appearance.m3colors.m3success : (Battery.percentage <= 0.2 ? Appearance.colors.colError : Appearance.colors.colTertiary)
                subtitle: Battery.isCharging ? Translation.tr("Charging") : (Battery.percentage <= 0.2 ? Translation.tr("Low") : Translation.tr("On battery"))
                progress: Battery.percentage
            }

            SystemStatCard {
                title: Translation.tr("Network")
                value: Network.wifi ? (Network.active?.ssid ?? Translation.tr("Connected")) : Translation.tr("Disconnected")
                icon: Network.wifi ? "wifi" : "wifi_off"
                color: Network.wifi ? Appearance.colors.colPrimary : Appearance.colors.colError
                subtitle: Network.wifi ? `${Math.round((Network.active?.strength ?? 0) * 100)}%` : ""
                progress: Network.wifi ? (Network.active?.strength ?? 0) : 0
            }
        }
    }
}

// Reusable stat card
Item {
    id: SystemStatCard
    required property string title
    required property string value
    required property string icon
    required property color color
    property string subtitle: ""
    property real progress: 0
    Layout.fillWidth: true
    Layout.preferredHeight: 72

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

            // Icon circle
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

            // Title + value + subtitle
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
                    font.pixelSize: Appearance.font.pixelSize.larger
                    font.weight: Font.Bold
                    color: Appearance.colors.colOnLayer0
                }

                Revealer {
                    reveal: subtitle !== ""
                    StyledText {
                        Layout.fillWidth: true
                        text: subtitle
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colSubtext
                    }
                }
            }

            // Progress bar on the right
            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter
                Layout.minimumWidth: 60
                spacing: 4

                StyledProgressBar {
                    Layout.fillWidth: true
                    valueBarWidth: 80
                    value: progress
                    color: color
                }
            }
        }
    }
}