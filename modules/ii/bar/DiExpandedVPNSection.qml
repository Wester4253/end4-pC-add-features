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

    // VPN connection card component
    Component {
        id: vpnConnectionCard
        property var connection: modelData
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

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.leftMargin: 16
                            Layout.rightMargin: 16
                            Layout.topMargin: 12
                            Layout.bottomMargin: 12
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                MaterialSymbol {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: "vpn_lock"
                                    iconSize: 20
                                    fill: 1
                                    color: Appearance.m3colors.m3success
                                }

                                StyledText {
                                    Layout.fillWidth: true
                                    text: Vpn.activeConnection?.name ?? Translation.tr("Connected")
                                    font.pixelSize: Appearance.font.pixelSize.normal
                                    font.weight: Font.Medium
                                    color: Appearance.colors.colOnLayer0
                                }

                                MouseArea {
                                    Layout.preferredWidth: 36
                                    Layout.preferredHeight: 36
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Vpn.disconnect()
                                    MaterialSymbol {
                                        anchors.centerIn: parent
                                        text: "vpn_lock_off"
                                        iconSize: 20
                                        fill: 1
                                        color: Appearance.m3colors.m3success
                                    }
                                }
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: `${Vpn.activeConnection?.type ?? "VPN"}  •  ${Vpn.activeConnection?.server ?? ""}`
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colSubtext
                            }
                        }
                    }
                }

                // Connections list
                Revealer {
                    reveal: Vpn.connections.length > 0
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            StyledText {
                                text: Translation.tr("Connections")
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.weight: Font.Medium
                                color: Appearance.colors.colSubtext
                            }
                        }

                        Repeater {
                            model: Vpn.connections
                            delegate: vpnConnectionCard
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
                            text: Translation.tr("No VPN connections")
                            font.pixelSize: Appearance.font.pixelSize.normal
                            color: Appearance.colors.colSubtext
                        }
                    }
                }

                // Add connection
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 50
                    radius: 12
                    color: Appearance.colors.colPrimary

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Vpn.addConnection()
                        hoverEnabled: true

                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            radius: 12

                            MouseArea {
                                anchors.fill: parent
                                onEntered: parent.color = Qt.lighter(Appearance.colors.colPrimary, 1.1)
                                onExited: parent.color = "transparent"
                            }

                            StyledText {
                                anchors.centerIn: parent
                                text: Translation.tr("Add VPN Connection")
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: Font.Medium
                                color: Appearance.colors.colOnPrimary
                            }
                        }
                    }
                }
            }
        }

        Revealer {
            reveal: !Vpn.enabled
            Layout.fillWidth: true

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
