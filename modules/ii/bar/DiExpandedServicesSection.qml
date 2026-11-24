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

    // Service card component
    Component {
        id: serviceCard
        property var serviceData: modelData
        Layout.fillWidth: true
        implicitHeight: 48

        property var svc: serviceData.service
        property string checkProp: serviceData.check
        property bool available: checkProp ? (svc[checkProp] ?? false) : true
        property bool running: checkProp && checkProp === "enabled" ? (svc.enabled === true) : available

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
                    color: running ? Appearance.m3colors.m3success : Appearance.colors.colPrimary
                    opacity: 0.15

                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: serviceData.icon
                        iconSize: 18
                        fill: 1
                        color: running ? Appearance.m3colors.m3success : Appearance.colors.colPrimary
                    }
                }

                StyledText {
                    Layout.fillWidth: true
                    text: serviceData.name
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Medium
                    color: Appearance.colors.colOnLayer0
                }

                // Status indicator
                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    implicitWidth: 10
                    implicitHeight: 10
                    radius: 5
                    color: running ? Appearance.m3colors.m3success : (available ? Appearance.colors.colWarning : Appearance.colors.colError)
                }

                // Toggle for services with enabled property
                Revealer {
                    reveal: checkProp && (checkProp === "enabled")
                    Switch {
                        Layout.alignment: Qt.AlignVCenter
                        checked: running
                        onCheckedChanged: svc.enabled = checked
                    }
                }

                // Action buttons for specific services
                Revealer {
                    reveal: serviceData.id === "bluetooth" && !running
                    MouseArea {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Bluetooth.startScan()
                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "search"
                            iconSize: 18
                            fill: 1
                            color: Appearance.colors.colSubtext
                        }
                    }
                }

                Revealer {
                    reveal: serviceData.id === "network" && !running
                    MouseArea {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Network.scan()
                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "wifi_find"
                            iconSize: 18
                            fill: 1
                            color: Appearance.colors.colSubtext
                        }
                    }
                }

                Revealer {
                    reveal: serviceData.id === "cliphist"
                    MouseArea {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Cliphist.refresh()
                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "refresh"
                            iconSize: 18
                            fill: 1
                            color: Appearance.colors.colSubtext
                        }
                    }
                }

                Revealer {
                    reveal: serviceData.id === "updates"
                    MouseArea {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Updates.check()
                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "system_update"
                            iconSize: 18
                            fill: 1
                            color: Appearance.colors.colSubtext
                        }
                    }
                }

                Revealer {
                    reveal: serviceData.id === "docker"
                    MouseArea {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Docker.refresh()
                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "refresh"
                            iconSize: 18
                            fill: 1
                            color: Appearance.colors.colSubtext
                        }
                    }
                }

                Revealer {
                    reveal: serviceData.id === "weather"
                    MouseArea {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Weather.refresh()
                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "refresh"
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
                text: "info"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Services")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }
        }

        Revealer {
            reveal: true
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                spacing: 4

                Repeater {
                    model: root.availableServices ?? []
                    delegate: serviceCard
                }
            }
        }
    }
}
