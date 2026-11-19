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
                text: Translation.tr("GPU")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }

            Revealer {
                reveal: ResourceUsage.gpuAvailable
                StyledText {
                    Layout.alignment: Qt.AlignVCenter
                    text: ResourceUsage.gpuName ?? Translation.tr("GPU")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }
            }
        }

        Revealer {
            reveal: ResourceUsage.gpuAvailable
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                spacing: 8

                // GPU Stats Grid
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 12
                    rowSpacing: 12

                    GPUStatCard {
                        title: Translation.tr("GPU Usage")
                        value: `${Math.round(ResourceUsage.gpuUsage * 100)}%`
                        icon: "memory"
                        color: ResourceUsage.gpuUsage > 0.85 ? Appearance.colors.colError : (ResourceUsage.gpuUsage > 0.6 ? Appearance.colors.colWarning : Appearance.colors.colPrimary)
                        subtitle: Translation.tr("Compute")
                        progress: ResourceUsage.gpuUsage
                    }

                    GPUStatCard {
                        title: Translation.tr("VRAM")
                        value: `${Math.round(ResourceUsage.gpuMemoryUsedPercentage * 100)}%`
                        icon: "storage"
                        color: ResourceUsage.gpuMemoryUsedPercentage > 0.9 ? Appearance.colors.colError : (ResourceUsage.gpuMemoryUsedPercentage > 0.75 ? Appearance.colors.colWarning : Appearance.colors.colSecondary)
                        subtitle: `${FileUtils.formatBytes(ResourceUsage.gpuMemoryUsed)} / ${FileUtils.formatBytes(ResourceUsage.gpuMemoryTotal)}`
                        progress: ResourceUsage.gpuMemoryUsedPercentage
                    }

                    GPUStatCard {
                        title: Translation.tr("Temperature")
                        value: ResourceUsage.gpuTemp > 0 ? `${Math.round(ResourceUsage.gpuTemp)}°C` : Translation.tr("N/A")
                        icon: "thermostat"
                        color: ResourceUsage.gpuTemp > 85 ? Appearance.colors.colError : (ResourceUsage.gpuTemp > 75 ? Appearance.colors.colWarning : Appearance.m3colors.m3success)
                        subtitle: ResourceUsage.gpuTemp > 0 ? Translation.tr("Junction") : ""
                        progress: ResourceUsage.gpuTemp > 0 ? Math.min(ResourceUsage.gpuTemp / 100, 1) : 0
                    }

                    GPUStatCard {
                        title: Translation.tr("Power Draw")
                        value: ResourceUsage.gpuPowerDraw > 0 ? `${Math.round(ResourceUsage.gpuPowerDraw)}W` : Translation.tr("N/A")
                        icon: "bolt"
                        color: Appearance.colors.colTertiary
                        subtitle: ResourceUsage.gpuPowerLimit > 0 ? `${Math.round(ResourceUsage.gpuPowerDraw / ResourceUsage.gpuPowerLimit * 100)}% of ${Math.round(ResourceUsage.gpuPowerLimit)}W` : ""
                        progress: ResourceUsage.gpuPowerLimit > 0 ? ResourceUsage.gpuPowerDraw / ResourceUsage.gpuPowerLimit : 0
                    }
                }

                // GPU Processes (top 5)
                Revealer {
                    reveal: ResourceUsage.gpuProcesses && ResourceUsage.gpuProcesses.length > 0
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            StyledText {
                                text: Translation.tr("GPU Processes")
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.weight: Font.Medium
                                color: Appearance.colors.colSubtext
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Repeater {
                                model: ResourceUsage.gpuProcesses.slice(0, 5)
                                delegate: GPUProcessCard {
                                    Layout.fillWidth: true
                                    process: modelData
                                }
                            }
                        }
                    }
                }

                // Clocks
                Revealer {
                    reveal: ResourceUsage.gpuCoreClock > 0 || ResourceUsage.gpuMemoryClock > 0
                    Layout.fillWidth: true

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16

                        ClockCard {
                            Layout.fillWidth: true
                            label: Translation.tr("Core Clock")
                            value: `${ResourceUsage.gpuCoreClock} MHz`
                            icon: "speed"
                            color: Appearance.colors.colPrimary
                        }

                        ClockCard {
                            Layout.fillWidth: true
                            label: Translation.tr("Memory Clock")
                            value: `${ResourceUsage.gpuMemoryClock} MHz`
                            icon: "storage"
                            color: Appearance.colors.colSecondary
                        }
                    }
                }
            }
        }

        Revealer {
            reveal: !ResourceUsage.gpuAvailable
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 80
                radius: 12
                color: Appearance.colors.colLayer1
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant
                opacity: 0.5

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    StyledText {
                        text: Translation.tr("GPU monitoring unavailable")
                        font.pixelSize: Appearance.font.pixelSize.normal
                        color: Appearance.colors.colSubtext
                    }

                    StyledText {
                        text: Translation.tr("Requires nvidia-smi or rocm-smi")
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colSubtext
                    }
                }
            }
        }
    }
}

// GPU stat card
Item {
    id: GPUStatCard
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

// GPU process card
Item {
    id: GPUProcessCard
    required property var process
    Layout.fillWidth: true
    implicitHeight: 40

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

            StyledText {
                Layout.fillWidth: true
                text: process.name ?? process.pid ?? Translation.tr("Unknown")
                font.pixelSize: Appearance.font.pixelSize.smaller
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
                elide: Text.ElideRight
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: process.gpuMemory ? `${FileUtils.formatBytes(process.gpuMemory)}` : ""
                font.pixelSize: Appearance.font.pixelSize.smaller
                font.family: "monospace"
                color: Appearance.colors.colSubtext
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: process.gpuUsage !== undefined ? `${Math.round(process.gpuUsage * 100)}%` : ""
                font.pixelSize: Appearance.font.pixelSize.smaller
                font.family: "monospace"
                color: Appearance.colors.colPrimary
            }
        }
    }
}

// Clock card
Item {
    id: ClockCard
    required property string label
    required property string value
    required property string icon
    required property color color
    Layout.fillWidth: true
    Layout.preferredHeight: 48

    Rectangle {
        anchors.fill: parent
        radius: 10
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
                implicitWidth: 36
                implicitHeight: 36
                radius: 18
                color: color
                opacity: 0.15

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: icon
                    iconSize: 18
                    fill: 1
                    color: color
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: -2

                StyledText {
                    Layout.fillWidth: true
                    text: label
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }

                StyledText {
                    Layout.fillWidth: true
                    text: value
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Medium
                    font.family: "monospace"
                    color: Appearance.colors.colOnLayer0
                }
            }
        }
    }
}