import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

ContentPage {
    id: page
    forceWidth: true
    bottomContentPadding: 35

    readonly property bool isMinimal: Config.options.settings.style === "minimal"

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 20

        ContentSection {
            icon: "device_hub"
            shape: MaterialShape.Shape.Gem
            title: Translation.tr("Otto Host Pair")

            GroupedList {
                ConfigSwitch {
                    buttonIcon: "tailscale"
                    text: Translation.tr("Enable Otto Host Pairing")
                    checked: Config.options.ottoHostPair.enable ?? true
                    onCheckedChanged: { Config.options.ottoHostPair.enable = checked; }
                }

                ConfigRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    spacing: 10

                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("Pair with Otto daemon over Tailscale")
                        color: Appearance.colors.colOnSecondaryContainer
                    }
                    StyledText {
                        text: Translation.tr("Connect to remote Otto daemon features")
                        color: Appearance.colors.colSubtext
                    }
                }

                ConfigSwitch {
                    buttonIcon: "sync"
                    text: Translation.tr("Auto-pair on startup")
                    checked: Config.options.ottoHostPair.autoPair ?? false
                    onCheckedChanged: { Config.options.ottoHostPair.autoPair = checked; }
                    enabled: Config.options.ottoHostPair.enable
                }
            }
        }

        ContentSection {
            icon: "wifi_tethering"
            shape: MaterialShape.Shape.Cookie4Sided
            title: Translation.tr("Connection Status")

            GroupedList {
                ConfigRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    spacing: 10

                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("Tailscale")
                        color: Appearance.colors.colOnSecondaryContainer
                    }
                    StyledText {
                        text: OttoHostPair.tailscaleRunning
                            ? (OttoHostPair.tailscaleOnline ? Translation.tr("Online") : Translation.tr("Offline"))
                            : Translation.tr("Checking…")
                        color: OttoHostPair.tailscaleRunning && OttoHostPair.tailscaleOnline
                            ? Appearance.colors.colSuccess
                            : Appearance.colors.colSubtext
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: OttoHostPair.refresh()
                    }
                }

                ConfigRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    spacing: 10

                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("Otto Daemon")
                        color: Appearance.colors.colOnSecondaryContainer
                    }
                    StyledText {
                        text: OttoHostPair.ottoRunning ? Translation.tr("Running") : Translation.tr("Stopped")
                        color: OttoHostPair.ottoRunning ? Appearance.colors.colSuccess : Appearance.colors.colSubtext
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: OttoHostPair.refresh()
                    }
                }

                ConfigRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    spacing: 10

                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("Paired Host")
                        color: Appearance.colors.colOnSecondaryContainer
                    }
                    StyledText {
                        text: OttoHostPair.pairedHost === ""
                            ? Translation.tr("Not paired")
                            : OttoHostPair.pairedHost
                        color: Appearance.colors.colSubtext
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            GlobalStates.settingsOpen = false;
                            Qt.callLater(() => {
                                Quickshell.ipcCall("otto-host-pair", "open-surface");
                            });
                        }
                    }
                }

                // Pair/Unpair action
                ConfigRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    spacing: 10

                    StyledText {
                        Layout.fillWidth: true
                        text: OttoHostPair.paired ? Translation.tr("Unpair from host") : Translation.tr("Pair new host")
                        color: Appearance.colors.colOnSecondaryContainer
                    }
                    StyledText {
                        text: OttoHostPair.paired ? Translation.tr("Disconnect from the paired Otto host") : Translation.tr("Open Dynamic Island to select a Tailnet device")
                        color: Appearance.colors.colSubtext
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (OttoHostPair.paired) {
                                OttoHostPair.unpair();
                            } else {
                                GlobalStates.settingsOpen = false;
                                Qt.callLater(() => {
                                    // Trigger dynamic island expansion to show pairing section
                                    Quickshell.ipcCall("otto-host-pair", "open-surface");
                                });
                            }
                        }
                    }
                }

                ConfigRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    spacing: 10

                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("Tailscale IP")
                        color: Appearance.colors.colOnSecondaryContainer
                    }
                    StyledText {
                        text: OttoHostPair.tailscaleIp === "" ? Translation.tr("—") : OttoHostPair.tailscaleIp
                        color: Appearance.colors.colSubtext
                    }
                }
            }
        ContentSection {
            icon: "account_circle"
            shape: MaterialShape.Shape.Gem
            title: Translation.tr("Agent Status")

            GroupedList {
                ConfigRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    spacing: 10

                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("Total Agents")
                        color: Appearance.colors.colOnSecondaryContainer
                    }
                    StyledText {
                        text: String(OttoHostPair.agentTotal)
                        color: Appearance.colors.colSubtext
                    }
                }

                ConfigRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    spacing: 10

                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("Active")
                        color: Appearance.colors.colOnSecondaryContainer
                    }
                    StyledText {
                        text: String(OttoHostPair.agentActive)
                        color: OttoHostPair.agentActive > 0 ? Appearance.colors.colSuccess : Appearance.colors.colSubtext
                    }
                }

                ConfigRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    spacing: 10

                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("Failed")
                        color: Appearance.colors.colOnSecondaryContainer
                    }
                    StyledText {
                        text: String(OttoHostPair.agentFailed)
                        color: OttoHostPair.agentFailed > 0 ? Appearance.colors.colError : Appearance.colors.colSubtext
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: OttoHostPair.refresh()
                    }
                }
            }
        }

        ContentSection {
            icon: "history"
            shape: MaterialShape.Shape.Bun
            title: Translation.tr("Session Status")

            GroupedList {
                ConfigRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    spacing: 10

                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("Total Sessions")
                        color: Appearance.colors.colOnSecondaryContainer
                    }
                    StyledText {
                        text: String(OttoHostPair.sessionTotal)
                        color: Appearance.colors.colSubtext
                    }
                }

                ConfigRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    spacing: 10

                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("Active")
                        color: Appearance.colors.colOnSecondaryContainer
                    }
                    StyledText {
                        text: String(OttoHostPair.sessionActive)
                        color: OttoHostPair.sessionActive > 0 ? Appearance.colors.colSuccess : Appearance.colors.colSubtext
                    }
                }

                ConfigRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    spacing: 10

                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("Completed")
                        color: Appearance.colors.colOnSecondaryContainer
                    }
                    StyledText {
                        text: String(OttoHostPair.sessionCompleted)
                        color: Appearance.colors.colSubtext
                    }
                }

                ConfigRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    spacing: 10

                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("Failed")
                        color: Appearance.colors.colOnSecondaryContainer
                    }
                    StyledText {
                        text: String(OttoHostPair.sessionFailed)
                        color: OttoHostPair.sessionFailed > 0 ? Appearance.colors.colError : Appearance.colors.colSubtext
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: OttoHostPair.refresh()
                    }
                }
            }
        }

        ContentSection {
            icon: "tune"
            shape: MaterialShape.Shape.Bun
            title: Translation.tr("Daemon Features")

            GroupedList {
                ConfigSwitch {
                    buttonIcon: "extension"
                    text: Translation.tr("Otto Plugins")
                    checked: OttoHostPair.ottoPluginsEnabled
                    enabled: false
                }
                ConfigSwitch {
                    buttonIcon: "wifi"
                    text: Translation.tr("Relay Connection")
                    checked: OttoHostPair.ottoRelayEnabled
                    enabled: false
                }
                ConfigSwitch {
                    buttonIcon: "mic"
                    text: Translation.tr("Voice Mode")
                    checked: OttoHostPair.ottoVoiceEnabled
                    enabled: false
                }
                ConfigSwitch {
                    buttonIcon: "sms"
                    text: Translation.tr("Otto Brain")
                    checked: OttoHostPair.ottoBrainEnabled
                    enabled: false
                }
            }
        }

        ContentSection {
            icon: "memory"
            shape: MaterialShape.Shape.Gem
            title: Translation.tr("System Usage")

            GroupedList {
                ConfigRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    spacing: 10

                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("CPU")
                        color: Appearance.colors.colOnSecondaryContainer
                    }
                    StyledText {
                        text: `${OttoHostPair.systemCpuPercent}%`
                        color: Appearance.colors.colSubtext
                    }
                }

                ConfigRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    spacing: 10

                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("Memory")
                        color: Appearance.colors.colOnSecondaryContainer
                    }
                    StyledText {
                        text: `${OttoHostPair.systemMemoryUsedMB} MB / ${OttoHostPair.systemMemoryTotalMB} MB (${OttoHostPair.systemMemoryPercent}%)`
                        color: Appearance.colors.colSubtext
                    }
                }

                ConfigRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    spacing: 10

                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("Disk")
                        color: Appearance.colors.colOnSecondaryContainer
                    }
                    StyledText {
                        text: `${OttoHostPair.systemDiskUsedGB} GB / ${OttoHostPair.systemDiskTotalGB} GB (${OttoHostPair.systemDiskPercent}%)`
                        color: Appearance.colors.colSubtext
                    }
                }

                ConfigRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    spacing: 10

                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("Load Average")
                        color: Appearance.colors.colOnSecondaryContainer
                    }
                    StyledText {
                        text: `${OttoHostPair.systemLoad1.toFixed(2)} / ${OttoHostPair.systemLoad5.toFixed(2)} / ${OttoHostPair.systemLoad15.toFixed(2)}`
                        color: Appearance.colors.colSubtext
                    }
                }

                ConfigRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    spacing: 10

                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("Uptime")
                        color: Appearance.colors.colOnSecondaryContainer
                    }
                    StyledText {
                        text: `${Math.floor(OttoHostPair.systemUptimeSeconds / 3600)}h ${Math.floor((OttoHostPair.systemUptimeSeconds % 3600) / 60)}m`
                        color: Appearance.colors.colSubtext
                    }
                }
            }
        }

        ContentSection {
            icon: "desktop"
            shape: MaterialShape.Shape.Clover4Leaf
            title: Translation.tr("Otto Desktop App")

            GroupedList {
                ConfigRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    spacing: 10

                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("Open Otto Desktop")
                        color: Appearance.colors.colPrimary
                    }
                    StyledText {
                        text: Translation.tr("Launch the Otto desktop app to manage agents and plugins locally")
                        color: Appearance.colors.colSubtext
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Qt.openUrlExternally("otto://");
                        }
                    }
                }
            }
        }

    }

    Component.onCompleted: {
        OttoHostPair.refresh()
    }
}
