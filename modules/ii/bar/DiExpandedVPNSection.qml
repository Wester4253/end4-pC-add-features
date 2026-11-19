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
                text: "vpn_lock"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("VPN")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }

            Switch {
                id: vpnToggle
                checked: Vpn.enabled
                onCheckedChanged: Vpn.enabled = checked
            }
        }

        Revealer {
            reveal: Vpn.enabled
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            spacing: 8

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                // Active connection
                Revealer {
                    reveal: Vpn.activeConnection !== null
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
                                color: Appearance.m3colors.m3success
                                opacity: 0.15

                                MaterialSymbol {
                                    anchors.centerIn: parent
                                    text: "vpn_lock"
                                    iconSize: 24
                                    fill: 1
                                    color: Appearance.m3colors.m3success
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                StyledText {
                                    Layout.fillWidth: true
                                    text: Vpn.activeConnection?.name ?? Translation.tr("Connected")
                                    font.pixelSize: Appearance.font.pixelSize.normal
                                    font.weight: Font.Medium
                                    color: Appearance.colors.colOnLayer0
                                }

                                StyledText {
                                    Layout.fillWidth: true
                                    text: `${Vpn.activeConnection?.type ?? "VPN"}  •  ${Vpn.activeConnection?.ipAddress ?? ""}`
                                    font.pixelSize: Appearance.font.pixelSize.smaller
                                    color: Appearance.colors.colSubtext
                                }
                            }

                            // Disconnect button
                            MouseArea {
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Vpn.disconnect()
                                MaterialSymbol {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: "vpn_lock_off"
                                    iconSize: 24
                                    fill: 1
                                    color: Appearance.colors.colError
                                }
                            }
                        }
                    }
                }

                // Available connections
                Revealer {
                    reveal: Vpn.connections.length > 0
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            StyledText {
                                text: Translation.tr("Available Connections")
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.weight: Font.Medium
                                color: Appearance.colors.colSubtext
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Repeater {
                                model: Vpn.connections
                                delegate: VpnConnectionCard {
                                    Layout.fillWidth: true
                                    connection: modelData
                                }
                            }
                        }
                    }
                }

                // No connections
                Revealer {
                    reveal: Vpn.connections.length === 0 && Vpn.activeConnection === null
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 60
                        radius: 12
                        color: Appearance.colors.colLayer1
                        border.width: 1
                        border.color: Appearance.colors.colOutlineVariant
                        opacity: 0.5

                        StyledText {
                            anchors.centerIn: parent
                            text: Translation.tr("No VPN connections configured")
                            font.pixelSize: Appearance.font.pixelSize.normal
                            color: Appearance.colors.colSubtext
                        }
                    }
                }
            }
        }

        Revealer {
            reveal: !Vpn.enabled
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 60
                radius: 12
                color: Appearance.colors.colLayer1
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant
                opacity: 0.5

                StyledText {
                    anchors.centerIn: parent
                    text: Translation.tr("VPN disabled")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colSubtext
                }
            }
        }
    }
}

// VPN connection card
Item {
    id: VpnConnectionCard
    required property var connection
    Layout.fillWidth: true
    implicitHeight: 56

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Appearance.colors.colLayer1
        border.width: 1
        border.color: connection.active ? Appearance.m3colors.m3success : Appearance.colors.colOutlineVariant

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
                color: connection.active ? Appearance.m3colors.m3success : Appearance.colors.colPrimary
                opacity: 0.15

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: "vpn_lock"
                    iconSize: 20
                    fill: 1
                    color: connection.active ? Appearance.m3colors.m3success : Appearance.colors.colPrimary
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: -2

                StyledText {
                    Layout.fillWidth: true
                    text: connection.name ?? Translation.tr("Unnamed")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Medium
                    color: Appearance.colors.colOnLayer0
                }

                StyledText {
                    Layout.fillWidth: true
                    text: `${connection.type ?? "VPN"}  ${connection.active ? " • " + Translation.tr("Connected") : ""}`
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }
            }

            RowLayout {
                spacing: 4

                MouseArea {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    cursorShape: Qt.PointingHandCursor
                    enabled: !connection.active
                    onClicked: Vpn.connect(connection.name)
                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: connection.active ? "vpn_lock" : "play_arrow"
                        iconSize: 20
                        fill: 1
                        color: connection.active ? Appearance.m3colors.m3success : Appearance.colors.colPrimary
                    }
                }

                MouseArea {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Vpn.remove(connection.name)
                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "delete"
                        iconSize: 18
                        fill: 1
                        color: Appearance.colors.colSubtext
                    }
                }
            }
        }
    }
}