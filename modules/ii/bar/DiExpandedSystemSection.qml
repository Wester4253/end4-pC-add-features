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

    // Reusable stat card component
    Component {
        id: systemStatCard
        Item {
            property string title
            property string value
            property string icon
            property color color
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

            Loader {
                sourceComponent: systemStatCard
                Binding { target: item; property: "title"; value: Translation.tr("CPU") }
                Binding { target: item; property: "value"; value: `${Math.round(ResourceUsage.cpuUsage * 100)}%` }
                Binding { target: item; property: "icon"; value: "memory" }
                Binding { target: item; property: "color"; value: ResourceUsage.cpuUsage > 0.8 ? Appearance.colors.colError : (ResourceUsage.cpuUsage > 0.5 ? Appearance.colors.colWarning : Appearance.colors.colPrimary) }
                Binding { target: item; property: "subtitle"; value: ResourceUsage.cpuTemp > 0 ? `${Math.round(ResourceUsage.cpuTemp)}°C` : "" }
                Binding { target: item; property: "progress"; value: ResourceUsage.cpuUsage }
            }

            Loader {
                sourceComponent: systemStatCard
                Binding { target: item; property: "title"; value: Translation.tr("Memory") }
                Binding { target: item; property: "value"; value: `${Math.round(ResourceUsage.memoryUsedPercentage * 100)}%` }
                Binding { target: item; property: "icon"; value: "memory" }
                Binding { target: item; property: "color"; value: ResourceUsage.memoryUsedPercentage > 0.85 ? Appearance.colors.colError : (ResourceUsage.memoryUsedPercentage > 0.7 ? Appearance.colors.colWarning : Appearance.colors.colSecondary) }
                Binding { target: item; property: "subtitle"; value: `${FileUtils.formatBytes(ResourceUsage.memoryUsed)} / ${FileUtils.formatBytes(ResourceUsage.memoryTotal)}` }
                Binding { target: item; property: "progress"; value: ResourceUsage.memoryUsedPercentage }
            }

            Loader {
                sourceComponent: systemStatCard
                Binding { target: item; property: "title"; value: Translation.tr("Battery") }
                Binding { target: item; property: "value"; value: `${Math.round(Battery.percentage * 100)}%` }
                Binding { target: item; property: "icon"; value: Battery.isCharging ? "battery_android_frame_bolt" : (Battery.percentage <= 0.2 ? "battery_android_frame_alert" : "battery_android_frame_full") }
                Binding { target: item; property: "color"; value: Battery.isCharging ? Appearance.m3colors.m3success : (Battery.percentage <= 0.2 ? Appearance.colors.colError : Appearance.colors.colTertiary) }
                Binding { target: item; property: "subtitle"; value: Battery.isCharging ? Translation.tr("Charging") : (Battery.percentage <= 0.2 ? Translation.tr("Low") : Translation.tr("On battery")) }
                Binding { target: item; property: "progress"; value: Battery.percentage }
            }

            Loader {
                sourceComponent: systemStatCard
                Binding { target: item; property: "title"; value: Translation.tr("Network") }
                Binding { target: item; property: "value"; value: Network.wifi ? (Network.active?.ssid ?? Translation.tr("Connected")) : Translation.tr("Disconnected") }
                Binding { target: item; property: "icon"; value: Network.wifi ? "wifi" : "wifi_off" }
                Binding { target: item; property: "color"; value: Network.wifi ? Appearance.colors.colPrimary : Appearance.colors.colError }
                Binding { target: item; property: "subtitle"; value: Network.wifi ? `${Math.round((Network.active?.strength ?? 0) * 100)}%` : "" }
                Binding { target: item; property: "progress"; value: Network.wifi ? (Network.active?.strength ?? 0) : 0 }
            }
        }
    }
}
