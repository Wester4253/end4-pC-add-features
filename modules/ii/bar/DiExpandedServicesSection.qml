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

    property string filterText: ""

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
                text: "build"
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

            // Filter field
            Rectangle {
                implicitWidth: 160
                implicitHeight: 32
                radius: 8
                color: Appearance.colors.colLayer1
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant

                RowLayout {
                    anchors.fill: parent
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    spacing: 6

                    MaterialSymbol {
                        Layout.alignment: Qt.AlignVCenter
                        text: "search"
                        iconSize: 18
                        fill: 1
                        color: Appearance.colors.colSubtext
                    }

                    TextField {
                        Layout.fillWidth: true
                        background: null
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colOnLayer0
                        placeholderText: Translation.tr("Filter services...")
                        text: root.filterText
                        onTextChanged: root.filterText = text
                    }
                }
            }
        }

        // Services list
        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            spacing: 4

            Repeater {
                model: {
                    var allServices = [
                        { id: "bluetooth", name: Translation.tr("Bluetooth"), service: Bluetooth, icon: "bluetooth", check: "enabled" },
                        { id: "network", name: Translation.tr("Network"), service: Network, icon: "wifi", check: "wifiEnabled" },
                        { id: "audio", name: Translation.tr("Audio"), service: Audio, icon: "volume_up", check: null },
                        { id: "battery", name: Translation.tr("Battery"), service: Battery, icon: "battery_full", check: "available" },
                        { id: "notifications", name: Translation.tr("Notifications"), service: Notifications, icon: "notifications", check: null },
                        { id: "mpris", name: Translation.tr("Media (MPRIS)"), service: MprisController, icon: "music_note", check: null },
                        { id: "timer", name: Translation.tr("Timers"), service: TimerService, icon: "timer", check: null },
                        { id: "cliphist", name: Translation.tr("Clipboard"), service: Cliphist, icon: "content_copy", check: null },
                        { id: "weather", name: Translation.tr("Weather"), service: Weather, icon: "partly_cloudy_day", check: "available" },
                        { id: "worldclock", name: Translation.tr("World Clock"), service: WorldClock, icon: "public", check: null },
                        { id: "hyprland", name: Translation.tr("Hyprland"), service: HyprlandBackend, icon: "window", check: "available" },
                        { id: "niri", name: Translation.tr("Niri"), service: NiriBackend, icon: "window", check: "available" },
                        { id: "vpn", name: Translation.tr("VPN"), service: Vpn, icon: "vpn_lock", check: "enabled" },
                        { id: "docker", name: Translation.tr("Docker"), service: Docker, icon: "whatshot", check: "available" },
                        { id: "updates", name: Translation.tr("Updates"), service: Updates, icon: "system_update", check: null },
                        { id: "resources", name: Translation.tr("Resources"), service: ResourceUsage, icon: "memory", check: null },
                        { id: "football", name: Translation.tr("Football"), service: Football, icon: "sports_soccer", check: null },
                        { id: "hyprsunset", name: Translation.tr("Night Light"), service: Hyprsunset, icon: "nightlight", check: "enabled" },
                        { id: "idle", name: Translation.tr("Idle"), service: Idle, icon: "bedtime", check: null },
                    ];
                    if (root.filterText) {
                        var f = root.filterText.toLowerCase();
                        allServices = allServices.filter(s => s.name.toLowerCase().includes(f) || s.id.includes(f));
                    }
                    return allServices;
                }
                delegate: ServiceCard {
                    Layout.fillWidth: true
                    serviceData: modelData
                }
            }
        }
    }
}

// Service card
Item {
    id: ServiceCard
    required property var serviceData
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