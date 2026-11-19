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
                text: Network.wifi ? "wifi" : "wifi_off"
                iconSize: 20
                fill: 1
                color: Network.wifi ? Appearance.colors.colPrimary : Appearance.colors.colError
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Network")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }

            // WiFi toggle
            Switch {
                id: wifiToggle
                checked: Network.wifiEnabled
                onCheckedChanged: Network.wifiEnabled = checked
            }
        }

        Revealer {
            reveal: Network.wifiEnabled
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                spacing: 8

                // Current connection
                Revealer {
                    reveal: Network.active !== null
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
                            spacing: 12

                            // Signal strength icon
                            Rectangle {
                                Layout.alignment: Qt.AlignVCenter
                                implicitWidth: 48
                                implicitHeight: 48
                                radius: 24
                                color: Appearance.colors.colPrimary
                                opacity: 0.15

                                MaterialSymbol {
                                    anchors.centerIn: parent
                                    text: Network.active?.icon ?? "wifi"
                                    iconSize: 24
                                    fill: 1
                                    color: Appearance.colors.colPrimary
                                }
                            }

                            // Network info
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    StyledText {
                                        Layout.fillWidth: true
                                        text: Network.active?.ssid ?? Translation.tr("Unknown Network")
                                        font.pixelSize: Appearance.font.pixelSize.normal
                                        font.weight: Font.Medium
                                        color: Appearance.colors.colOnLayer0
                                    }

                                    // Signal bars
                                    RowLayout {
                                        spacing: 2
                                        Repeater {
                                            model: 4
                                            delegate: Rectangle {
                                                implicitWidth: 4
                                                implicitHeight: (index + 1) * 5
                                                radius: 1
                                                color: index < Math.round((Network.active?.strength ?? 0) * 4)
                                                    ? Appearance.colors.colPrimary
                                                    : Appearance.colors.colOutlineVariant
                                            }
                                        }
                                    }
                                }

                                StyledText {
                                    Layout.fillWidth: true
                                    text: `${Network.active?.security ?? ""}  •  ${Network.active?.frequency ?? 0} MHz  •  ${Network.active?.ipAddress ?? ""}`
                                    font.pixelSize: Appearance.font.pixelSize.smaller
                                    color: Appearance.colors.colSubtext
                                }
                            }

                            // Disconnect button
                            MouseArea {
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Network.disconnect()
                                MaterialSymbol {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: "wifi_off"
                                    iconSize: 24
                                    fill: 1
                                    color: Appearance.colors.colError
                                }
                            }
                        }
                    }
                }

                // Available networks
                Revealer {
                    reveal: Network.wifiNetworks.length > 0
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            StyledText {
                                text: Translation.tr("Available Networks")
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.weight: Font.Medium
                                color: Appearance.colors.colSubtext
                            }

                            Revealer {
                                reveal: Network.wifiScanning
                                BusySpinner {
                                    Layout.alignment: Qt.AlignVCenter
                                    size: 16
                                }
                            }

                            MouseArea {
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Network.scan()
                                MaterialSymbol {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: "refresh"
                                    iconSize: 20
                                    fill: 1
                                    color: Appearance.colors.colSubtext
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Repeater {
                                model: Network.wifiNetworks.filter(n => !n.active).slice(0, 10)
                                delegate: NetworkAvailableCard {
                                    Layout.fillWidth: true
                                    network: modelData
                                }
                            }
                        }
                    }
                }

                // Ethernet
                Revealer {
                    reveal: Network.ethernet
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
                            spacing: 12

                            Rectangle {
                                Layout.alignment: Qt.AlignVCenter
                                implicitWidth: 48
                                implicitHeight: 48
                                radius: 24
                                color: Appearance.colors.colSecondary
                                opacity: 0.15

                                MaterialSymbol {
                                    anchors.centerIn: parent
                                    text: "lan"
                                    iconSize: 24
                                    fill: 1
                                    color: Appearance.colors.colSecondary
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                StyledText {
                                    Layout.fillWidth: true
                                    text: Translation.tr("Ethernet Connected")
                                    font.pixelSize: Appearance.font.pixelSize.normal
                                    font.weight: Font.Medium
                                    color: Appearance.colors.colOnLayer0
                                }

                                StyledText {
                                    Layout.fillWidth: true
                                    text: `${Network.ipAddress ?? ""}  •  ${Network.publicIpAddress ?? ""}`
                                    font.pixelSize: Appearance.font.pixelSize.smaller
                                    color: Appearance.colors.colSubtext
                                }
                            }
                        }
                    }
                }
            }
        }

        Revealer {
            reveal: !Network.wifiEnabled && !Network.ethernet
            Layout.fillWidth: true

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                implicitHeight: 60
                radius: 12
                color: Appearance.colors.colLayer1
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant
                opacity: 0.5

                StyledText {
                    anchors.centerIn: parent
                    text: Translation.tr("Network disabled")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colSubtext
                }
            }
        }
    }
}

// Available network card
Item {
    id: NetworkAvailableCard
    required property var network
    Layout.fillWidth: true
    implicitHeight: 48

    property real signalStrength: network.strength ?? 0
    property bool isKnown: network.known ?? false

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

            // Signal icon
            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 36
                implicitHeight: 36
                radius: 18
                color: Appearance.colors.colPrimary
                opacity: 0.15

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: network.icon ?? "wifi"
                    iconSize: 18
                    fill: 1
                    color: Appearance.colors.colPrimary
                }
            }

            // Network info
            ColumnLayout {
                Layout.fillWidth: true
                spacing: -2

                StyledText {
                    Layout.fillWidth: true
                    text: network.ssid ?? Translation.tr("Hidden Network")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Medium
                    color: Appearance.colors.colOnLayer0
                }

                StyledText {
                    Layout.fillWidth: true
                    text: `${network.security ?? Translation.tr("Open")}  •  ${Math.round(signalStrength * 100)}%${isKnown ? " • " + Translation.tr("Saved") : ""}`
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }
            }

            // Signal bars
            RowLayout {
                spacing: 2
                Repeater {
                    model: 4
                    delegate: Rectangle {
                        implicitWidth: 3
                        implicitHeight: (index + 1) * 4
                        radius: 1
                        color: index < Math.round(signalStrength * 4)
                            ? Appearance.colors.colPrimary
                            : Appearance.colors.colOutlineVariant
                    }
                }
            }

            // Connect button
            MouseArea {
                cursorShape: Qt.PointingHandCursor
                onClicked: Network.connect(network.ssid, network.bssid)
                MaterialSymbol {
                    Layout.alignment: Qt.AlignVCenter
                    text: isKnown ? "wifi" : "wifi_tethering"
                    iconSize: 20
                    fill: 1
                    color: Appearance.colors.colPrimary
                }
            }
        }
    }
}