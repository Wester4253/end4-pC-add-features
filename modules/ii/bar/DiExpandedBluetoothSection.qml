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

    // Local property to avoid triggering adapter power on during init
    property bool _adapterEnabled: BluetoothStatus.enabled

    // Sync adapter state only on user interaction
    Connections {
        target: BluetoothStatus
        function onEnabledChanged() {
            root._adapterEnabled = BluetoothStatus.enabled;
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
                text: "bluetooth"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Bluetooth")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }

            // Toggle - use local property to avoid triggering adapter on init
            Switch {
                id: btToggle
                checked: root._adapterEnabled
                onCheckedChanged: BluetoothStatus.enabled = checked
            }
        }

        Revealer {
            reveal: root._adapterEnabled
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                spacing: 4

                // Connected devices
                Revealer {
                    reveal: BluetoothStatus.devices.length > 0

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            StyledText {
                                text: Translation.tr("Connected Devices")
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.weight: Font.Medium
                                color: Appearance.colors.colSubtext
                            }
                        }

                        Repeater {
                            model: BluetoothStatus.devices
                            delegate: BluetoothDeviceCard {
                                Layout.fillWidth: true
                                device: modelData
                            }
                        }
                    }
                }

                // Available devices (when scanning)
                Revealer {
                    reveal: BluetoothStatus.scanning && BluetoothStatus.availableDevices.length > 0

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            StyledText {
                                text: Translation.tr("Available Devices")
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.weight: Font.Medium
                                color: Appearance.colors.colSubtext
                            }

                            BusySpinner {
                                Layout.alignment: Qt.AlignVCenter
                                size: 16
                            }
                        }

                        Repeater {
                            model: BluetoothStatus.availableDevices.slice(0, 10)
                            delegate: BluetoothAvailableCard {
                                Layout.fillWidth: true
                                device: modelData
                            }
                        }
                    }
                }

                // No devices
                Revealer {
                    reveal: BluetoothStatus.devices.length === 0 && !BluetoothStatus.scanning
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 60
                        radius: 12
                        color: Appearance.colors.colLayer1
                        border.width: 1
                        border.color: Appearance.colors.colOutlineVariant
                        opacity: 0.5

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            StyledText {
                                text: Translation.tr("No devices connected")
                                font.pixelSize: Appearance.font.pixelSize.normal
                                color: Appearance.colors.colSubtext
                            }

                            MouseArea {
                                cursorShape: Qt.PointingHandCursor
                                onClicked: BluetoothStatus.startScan()
                                StyledText {
                                    text: Translation.tr("Scan for devices")
                                    font.pixelSize: Appearance.font.pixelSize.smaller
                                    color: Appearance.colors.colPrimary
                                }
                            }
                        }
                    }
                }
            }
        }

        Revealer {
            reveal: !root._adapterEnabled
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
                    text: Translation.tr("Bluetooth disabled")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colSubtext
                }
            }
        }
    }
}

// Connected device card
Item {
    id: BluetoothDeviceCard
    required property var device
    Layout.fillWidth: true
    implicitHeight: 56

    property string batteryStr: device.battery !== undefined ? ` • ${Math.round(device.battery * 100)}%` : ""

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

            // Device icon
            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 40
                implicitHeight: 40
                radius: 20
                color: Appearance.colors.colPrimary
                opacity: 0.15

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: device.icon ?? "bluetooth"
                    iconSize: 20
                    fill: 1
                    color: Appearance.colors.colPrimary
                }
            }

            // Device info
            ColumnLayout {
                Layout.fillWidth: true
                spacing: -2

                StyledText {
                    Layout.fillWidth: true
                    text: device.name ?? device.alias ?? Translation.tr("Unknown Device")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Medium
                    color: Appearance.colors.colOnLayer0
                }

                StyledText {
                    Layout.fillWidth: true
                    text: `${device.mac ?? ""}${batteryStr}`
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }
            }

            // Actions
            RowLayout {
                spacing: 4

                MouseArea {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    cursorShape: Qt.PointingHandCursor
                    onClicked: BluetoothStatus.toggleConnect(device.mac)
                    hoverEnabled: true
                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: device.connected ? "bluetooth_connected" : "bluetooth_disabled"
                        iconSize: 20
                        fill: 1
                        color: device.connected ? Appearance.colors.colPrimary : Appearance.colors.colSubtext
                    }
                }

                MouseArea {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    cursorShape: Qt.PointingHandCursor
                    onClicked: BluetoothStatus.removeDevice(device.mac)
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

// Available device card
Item {
    id: BluetoothAvailableCard
    required property var device
    Layout.fillWidth: true
    implicitHeight: 56

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
                color: Appearance.colors.colPrimary
                opacity: 0.15

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: device.icon ?? "bluetooth"
                    iconSize: 20
                    fill: 1
                    color: Appearance.colors.colPrimary
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: -2

                StyledText {
                    Layout.fillWidth: true
                    text: device.name ?? device.alias ?? Translation.tr("Unknown Device")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Medium
                    color: Appearance.colors.colOnLayer0
                }

                StyledText {
                    Layout.fillWidth: true
                    text: device.mac ?? ""
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }
            }

            MouseArea {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                cursorShape: Qt.PointingHandCursor
                onClicked: BluetoothStatus.pair(device.mac)
                MaterialSymbol {
                    anchors.centerIn: parent
                    text: "add"
                    iconSize: 20
                    fill: 1
                    color: Appearance.colors.colPrimary
                }
            }
        }
    }
}