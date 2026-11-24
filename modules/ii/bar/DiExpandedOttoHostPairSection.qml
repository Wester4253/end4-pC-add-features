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
        spacing: 12

        // Section header
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            spacing: 8

            MaterialSymbol {
                Layout.alignment: Qt.AlignVCenter
                text: "device_hub"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Otto Host Pair")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                onClicked: OttoHostPair.refresh()
                hoverEnabled: true
                MaterialSymbol {
                    Layout.alignment: Qt.AlignVCenter
                    text: "refresh"
                    iconSize: 20
                    fill: 1
                    color: Appearance.colors.colSubtext
                }
            }

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    GlobalStates.openSettingsAt("dashboard", Translation.tr("Bar"), Translation.tr("Otto Host Pair"), "");
                    root.di.expanded = false;
                }
                MaterialSymbol {
                    Layout.alignment: Qt.AlignVCenter
                    text: "settings"
                    iconSize: 20
                    fill: 1
                    color: Appearance.colors.colSubtext
                }
            }
        }

        // Not paired state - show tailnet devices
        Revealer {
            reveal: !OttoHostPair.paired
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                // Description
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    radius: 12
                    color: Appearance.colors.colPrimaryContainer
                    border.width: 1
                    border.color: Appearance.colors.colOutlineVariant
                    implicitHeight: 56

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 4

                        StyledText {
                            Layout.fillWidth: true
                            text: Translation.tr("Pair with an Otto daemon on your Tailnet")
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: Font.Medium
                            color: Appearance.colors.colOnPrimaryContainer
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: Translation.tr("Select a device below to connect and access remote agent status, limits, and sessions")
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Qt.rgba(Appearance.colors.colOnPrimaryContainer.r, Appearance.colors.colOnPrimaryContainer.g, Appearance.colors.colOnPrimaryContainer.b, 0.7)
                        }
                    }
                }

                // Tailscale status
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    radius: 10
                    color: Appearance.colors.colLayer1
                    border.width: 1
                    border.color: Appearance.colors.colOutlineVariant

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        // Tailscale header
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.leftMargin: 12
                            Layout.rightMargin: 12
                            implicitHeight: 44
                            color: "transparent"
                            border.width: 0

                            RowLayout {
                                anchors.fill: parent
                                spacing: 8

                                MaterialSymbol {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: "wifi_tethering"
                                    iconSize: 20
                                    fill: 1
                                    color: OttoHostPair.tailscaleOnline ? Appearance.colors.colSuccess : Appearance.colors.colError
                                }

                                StyledText {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: Translation.tr("Tailscale")
                                    font.pixelSize: Appearance.font.pixelSize.normal
                                    font.weight: Font.Medium
                                    color: Appearance.colors.colOnLayer0
                                }

                                Item { Layout.fillWidth: true }

                                StyledText {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: OttoHostPair.tailscaleOnline ? Translation.tr("Online") : Translation.tr("Offline")
                                    font.pixelSize: Appearance.font.pixelSize.smaller
                                    color: OttoHostPair.tailscaleOnline ? Appearance.colors.colSuccess : Appearance.colors.colError
                                }

                                StyledText {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: OttoHostPair.tailscaleIp
                                    font.pixelSize: Appearance.font.pixelSize.smaller
                                    font.family: "monospace"
                                    color: Appearance.colors.colSubtext
                                }
                            }
                        }

                        // Device list
                        Revealer {
                            reveal: OttoHostPair.tailscaleOnline && OttoHostPair.tailscalePeers.length > 0

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                Repeater {
                                    model: OttoHostPair.tailscalePeers
                                    delegate: TailnetDeviceCard {
                                        Layout.fillWidth: true
                                        device: modelData
                                    }
                                }
                            }
                        }

                        Revealer {
                            reveal: !OttoHostPair.tailscaleOnline
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.leftMargin: 12
                                Layout.rightMargin: 12
                                implicitHeight: 48
                                color: "transparent"

                                StyledText {
                                    anchors.centerIn: parent
                                    text: Translation.tr("Tailscale not running or not authenticated")
                                    font.pixelSize: Appearance.font.pixelSize.smaller
                                    color: Appearance.colors.colSubtext
                                }
                            }
                        }

                        Revealer {
                            reveal: OttoHostPair.tailscaleOnline && OttoHostPair.tailscalePeers.length === 0
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.leftMargin: 12
                                Layout.rightMargin: 12
                                implicitHeight: 48
                                color: "transparent"

                                StyledText {
                                    anchors.centerIn: parent
                                    text: Translation.tr("No other devices on Tailnet")
                                    font.pixelSize: Appearance.font.pixelSize.smaller
                                    color: Appearance.colors.colSubtext
                                }
                            }
                        }
                    }
                }

                // Local Otto daemon status
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    radius: 10
                    color: Appearance.colors.colLayer1
                    border.width: 1
                    border.color: Appearance.colors.colOutlineVariant

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.leftMargin: 12
                            Layout.rightMargin: 12
                            implicitHeight: 44
                            color: "transparent"

                            RowLayout {
                                anchors.fill: parent
                                spacing: 8

                                MaterialSymbol {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: "hub"
                                    iconSize: 20
                                    fill: 1
                                    color: OttoHostPair.ottoRunning ? Appearance.colors.colSuccess : Appearance.colors.colError
                                }

                                StyledText {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: Translation.tr("Local Otto Daemon")
                                    font.pixelSize: Appearance.font.pixelSize.normal
                                    font.weight: Font.Medium
                                    color: Appearance.colors.colOnLayer0
                                }

                                Item { Layout.fillWidth: true }

                                StyledText {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: OttoHostPair.ottoRunning ? Translation.tr("Running") : Translation.tr("Stopped")
                                    font.pixelSize: Appearance.font.pixelSize.smaller
                                    color: OttoHostPair.ottoRunning ? Appearance.colors.colSuccess : Appearance.colors.colError
                                }

                                StyledText {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: OttoHostPair.ottoVersion !== "" ? "v" + OttoHostPair.ottoVersion : ""
                                    font.pixelSize: Appearance.font.pixelSize.smaller
                                    font.family: "monospace"
                                    color: Appearance.colors.colSubtext
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.leftMargin: 12
                            Layout.rightMargin: 12
                            Layout.bottomMargin: 12
                            implicitHeight: 40
                            color: "transparent"

                            RowLayout {
                                anchors.fill: parent
                                spacing: 16

                                // Active agents
                                ColumnLayout {
                                    spacing: 2
                                    StyledText {
                                        text: String(OttoHostPair.ottoActiveAgents)
                                        font.pixelSize: Appearance.font.pixelSize.larger
                                        font.weight: Font.Bold
                                        color: Appearance.colors.colOnLayer0
                                    }
                                    StyledText {
                                        text: Translation.tr("Active Agents")
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colSubtext
                                    }
                                }

                                // Active sessions
                                ColumnLayout {
                                    spacing: 2
                                    StyledText {
                                        text: String(OttoHostPair.ottoActiveSessions)
                                        font.pixelSize: Appearance.font.pixelSize.larger
                                        font.weight: Font.Bold
                                        color: Appearance.colors.colOnLayer0
                                    }
                                    StyledText {
                                        text: Translation.tr("Active Sessions")
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colSubtext
                                    }
                                }

                                // Uptime
                                ColumnLayout {
                                    spacing: 2
                                    StyledText {
                                        text: {
                                            const h = Math.floor(OttoHostPair.ottoUptimeSeconds / 3600);
                                            const m = Math.floor((OttoHostPair.ottoUptimeSeconds % 3600) / 60);
                                            return h > 0 ? `${h}h ${m}m` : `${m}m`;
                                        }
                                        font.pixelSize: Appearance.font.pixelSize.larger
                                        font.weight: Font.Bold
                                        color: Appearance.colors.colOnLayer0
                                    }
                                    StyledText {
                                        text: Translation.tr("Uptime")
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colSubtext
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Paired state - show remote host status
        Revealer {
            reveal: OttoHostPair.paired
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                // Paired host header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    radius: 12
                    color: Qt.rgba(Appearance.colors.colSuccess.r, Appearance.colors.colSuccess.g, Appearance.colors.colSuccess.b, 0.15)
                    border.width: 1
                    border.color: Appearance.colors.colSuccess
                    implicitHeight: 72

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            MaterialSymbol {
                                Layout.alignment: Qt.AlignVCenter
                                text: "check_circle"
                                iconSize: 20
                                fill: 1
                                color: Appearance.colors.colSuccess
                            }

                            StyledText {
                                Layout.alignment: Qt.AlignVCenter
                                text: Translation.tr("Paired with %1").arg(OttoHostPair.pairedHostName !== "" ? OttoHostPair.pairedHostName : OttoHostPair.pairedHost)
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: Font.Medium
                                color: Appearance.colors.colSuccess
                            }

                            Item { Layout.fillWidth: true }

                            StyledText {
                                Layout.alignment: Qt.AlignVCenter
                                text: OttoHostPair.pairedHostOnline ? Translation.tr("Online") : Translation.tr("Offline")
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.weight: Font.Medium
                                color: OttoHostPair.pairedHostOnline ? Appearance.colors.colSuccess : Appearance.colors.colError
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 16

                            StyledText {
                                text: Translation.tr("IP: %1").arg(OttoHostPair.pairedHostIp)
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.family: "monospace"
                                color: Appearance.colors.colSubtext
                            }

                            StyledText {
                                text: OttoHostPair.pairedHostOttoVersion !== "" ? Translation.tr("Otto v%1").arg(OttoHostPair.pairedHostOttoVersion) : Translation.tr("Otto version unknown")
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colSubtext
                            }

                            Item { Layout.fillWidth: true }

                            MouseArea {
                                cursorShape: Qt.PointingHandCursor
                                onClicked: OttoHostPair.unpair()
                                hoverEnabled: true
                                MaterialSymbol {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: "unlink"
                                    iconSize: 18
                                    fill: 1
                                    color: Appearance.colors.colError
                                }
                            }

                            StyledText {
                                Layout.alignment: Qt.AlignVCenter
                                text: Translation.tr("Unpair")
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colError
                            }
                        }
                    }
                }

                // Remote host stats
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    radius: 10
                    color: Appearance.colors.colLayer1
                    border.width: 1
                    border.color: Appearance.colors.colOutlineVariant

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.leftMargin: 12
                            Layout.rightMargin: 12
                            Layout.bottomMargin: 12
                            implicitHeight: 48
                            color: "transparent"

                            RowLayout {
                                anchors.fill: parent
                                spacing: 16

                                // Active agents
                                ColumnLayout {
                                    spacing: 2
                                    StyledText {
                                        text: String(OttoHostPair.pairedHostActiveAgents)
                                        font.pixelSize: Appearance.font.pixelSize.larger
                                        font.weight: Font.Bold
                                        color: OttoHostPair.pairedHostActiveAgents > 0 ? Appearance.colors.colSuccess : Appearance.colors.colOnLayer0
                                    }
                                    StyledText {
                                        text: Translation.tr("Active Agents")
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colSubtext
                                    }
                                }

                                // Active sessions
                                ColumnLayout {
                                    spacing: 2
                                    StyledText {
                                        text: String(OttoHostPair.pairedHostActiveSessions)
                                        font.pixelSize: Appearance.font.pixelSize.larger
                                        font.weight: Font.Bold
                                        color: Appearance.colors.colOnLayer0
                                    }
                                    StyledText {
                                        text: Translation.tr("Active Sessions")
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colSubtext
                                    }
                                }

                                // Agent limit
                                ColumnLayout {
                                    spacing: 2
                                    StyledText {
                                        text: OttoHostPair.pairedHostAgentLimit > 0 ? `${OttoHostPair.pairedHostAgentUsed}/${OttoHostPair.pairedHostAgentLimit}` : "—"
                                        font.pixelSize: Appearance.font.pixelSize.larger
                                        font.weight: Font.Bold
                                        color: Appearance.colors.colOnLayer0
                                    }
                                    StyledText {
                                        text: Translation.tr("Agent Limit")
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colSubtext
                                    }
                                }

                                // Session limit
                                ColumnLayout {
                                    spacing: 2
                                    StyledText {
                                        text: OttoHostPair.pairedHostSessionLimit > 0 ? `${OttoHostPair.pairedHostSessionUsed}/${OttoHostPair.pairedHostSessionLimit}` : "—"
                                        font.pixelSize: Appearance.font.pixelSize.larger
                                        font.weight: Font.Bold
                                        color: Appearance.colors.colOnLayer0
                                    }
                                    StyledText {
                                        text: Translation.tr("Session Limit")
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colSubtext
                                    }
                                }
                            }
                        }
                    }
                }

                // Agent list
                Revealer {
                    reveal: OttoHostPair.pairedHostAgents.length > 0
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.leftMargin: 16
                            Layout.rightMargin: 16
                            implicitHeight: 32
                            color: "transparent"

                            StyledText {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: Translation.tr("Remote Agents (%1)").arg(OttoHostPair.pairedHostAgents.length)
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.weight: Font.Medium
                                color: Appearance.colors.colSubtext
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.leftMargin: 16
                            Layout.rightMargin: 16
                            spacing: 4

                            Repeater {
                                model: OttoHostPair.pairedHostAgents
                                delegate: RemoteAgentCard {
                                    Layout.fillWidth: true
                                    agent: modelData
                                }
                            }
                        }
                    }
                }

                // Session list
                Revealer {
                    reveal: OttoHostPair.pairedHostSessions.length > 0
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.leftMargin: 16
                            Layout.rightMargin: 16
                            implicitHeight: 32
                            color: "transparent"

                            StyledText {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: Translation.tr("Recent Sessions (%1)").arg(OttoHostPair.pairedHostSessions.length)
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.weight: Font.Medium
                                color: Appearance.colors.colSubtext
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.leftMargin: 16
                            Layout.rightMargin: 16
                            spacing: 4

                            Repeater {
                                model: OttoHostPair.pairedHostSessions
                                delegate: RemoteSessionCard {
                                    Layout.fillWidth: true
                                    session: modelData
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// Tailnet device card for pairing
Item {
    id: TailnetDeviceCard
    required property var device
    Layout.fillWidth: true
    implicitHeight: 48

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: Appearance.colors.colLayer0
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
                implicitWidth: 36
                implicitHeight: 36
                radius: 18
                color: device.online ? Qt.rgba(Appearance.colors.colSuccess.r, Appearance.colors.colSuccess.g, Appearance.colors.colSuccess.b, 0.15) : Qt.rgba(Appearance.colors.colError.r, Appearance.colors.colError.g, Appearance.colors.colError.b, 0.15)
                border.width: 1
                border.color: device.online ? Appearance.colors.colSuccess : Appearance.colors.colError

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: "computer"
                    iconSize: 18
                    fill: 1
                    color: device.online ? Appearance.colors.colSuccess : Appearance.colors.colError
                }
            }

            // Device info
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    StyledText {
                        Layout.fillWidth: true
                        text: device.name
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: Font.Medium
                        color: Appearance.colors.colOnLayer0
                        elide: Text.ElideRight
                    }

                    // Online badge
                    Rectangle {
                        radius: 6
                        color: device.online ? Appearance.colors.colSuccess : Appearance.colors.colError
                        implicitHeight: 18
                        implicitWidth: onlineText.implicitWidth + 10

                        StyledText {
                            id: onlineText
                            anchors.centerIn: parent
                            text: device.online ? Translation.tr("Online") : Translation.tr("Offline")
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            color: Appearance.colors.colOnError
                        }
                    }
                }

                StyledText {
                    Layout.fillWidth: true
                    text: device.ip
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.family: "monospace"
                    color: Appearance.colors.colSubtext
                }
            }

            // Pair button
            MouseArea {
                Layout.preferredWidth: 80
                Layout.preferredHeight: 32
                cursorShape: Qt.PointingHandCursor
                enabled: device.online
                onClicked: {
                    // Pair with this device
                    const displayName = device.name;
                    OttoHostPair.pairWithHost(device.name, device.ip, displayName);
                }
                hoverEnabled: true

                Rectangle {
                    anchors.fill: parent
                    radius: 16
                    color: device.online ? Appearance.colors.colPrimary : Appearance.colors.colOutlineVariant
                    opacity: device.online ? 1 : 0.5

                    StyledText {
                        anchors.centerIn: parent
                        text: Translation.tr("Pair")
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        font.weight: Font.Medium
                        color: device.online ? Appearance.colors.colOnPrimary : Appearance.colors.colSubtext
                    }
                }
            }
        }
    }
}

// Remote agent card
Item {
    id: RemoteAgentCard
    required property var agent
    Layout.fillWidth: true
    implicitHeight: 44

    property string status: agent.status ?? "idle"
    property string name: agent.name ?? agent.id ?? Translation.tr("Unknown")
    property string model: agent.model ?? ""
    property bool needsAttention: agent.needsAttention ?? false
    property bool pendingPermission: agent.pendingPermission ?? false

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: Appearance.colors.colLayer0
        border.width: 1
        border.color: needsAttention ? Appearance.colors.colWarning : (pendingPermission ? Appearance.colors.colError : Appearance.colors.colOutlineVariant)

        RowLayout {
            anchors.fill: parent
            Layout.leftMargin: 12
            Layout.rightMargin: 12
            spacing: 12

            // Status indicator
            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 10
                implicitHeight: 10
                radius: 5
                color: status === "running" ? Appearance.colors.colSuccess :
                       status === "failed" ? Appearance.colors.colError :
                       needsAttention ? Appearance.colors.colWarning :
                       pendingPermission ? Appearance.colors.colError :
                       Appearance.colors.colSubtext
            }

            // Agent info
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    StyledText {
                        Layout.fillWidth: true
                        text: name
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: Font.Medium
                        color: Appearance.colors.colOnLayer0
                        elide: Text.ElideRight
                    }

                    // Status badge
                    Rectangle {
                        radius: 6
                        color: status === "running" ? Appearance.colors.colSuccess :
                               status === "failed" ? Appearance.colors.colError :
                               needsAttention ? Appearance.colors.colWarning :
                               pendingPermission ? Appearance.colors.colError :
                               Appearance.colors.colLayer1
                        implicitHeight: 18
                        implicitWidth: statusText.implicitWidth + 10

                        StyledText {
                            id: statusText
                            anchors.centerIn: parent
                            text: status === "running" ? Translation.tr("Running") :
                                  status === "failed" ? Translation.tr("Failed") :
                                  needsAttention ? Translation.tr("Needs Attention") :
                                  pendingPermission ? Translation.tr("Pending Permission") :
                                  Translation.tr("Idle")
                            font.pixelSize: 10
                            font.weight: Font.Medium
                            color: status === "running" || status === "failed" || needsAttention || pendingPermission ? Appearance.colors.colOnError : Appearance.colors.colSubtext
                        }
                    }
                }

                StyledText {
                    Layout.fillWidth: true
                    visible: model !== ""
                    text: model
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }
            }
        }
    }
}

// Remote session card
Item {
    id: RemoteSessionCard
    required property var session
    Layout.fillWidth: true
    implicitHeight: 44

    property string status: session.status ?? "completed"
    property string agentName: session.agentName ?? session.agent ?? Translation.tr("Unknown")
    property string started: session.startedAt ?? ""
    property string duration: session.duration ?? ""

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: Appearance.colors.colLayer0
        border.width: 1
        border.color: Appearance.colors.colOutlineVariant

        RowLayout {
            anchors.fill: parent
            Layout.leftMargin: 12
            Layout.rightMargin: 12
            spacing: 12

            // Session icon
            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 36
                implicitHeight: 36
                radius: 18
                color: status === "active" ? Qt.rgba(Appearance.colors.colSuccess.r, Appearance.colors.colSuccess.g, Appearance.colors.colSuccess.b, 0.15) :
                       status === "failed" ? Qt.rgba(Appearance.colors.colError.r, Appearance.colors.colError.g, Appearance.colors.colError.b, 0.15) :
                       Appearance.colors.colPrimaryContainer

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: status === "active" ? "play_circle" : (status === "failed" ? "error" : "check_circle")
                    iconSize: 18
                    fill: 1
                    color: status === "active" ? Appearance.colors.colSuccess :
                           status === "failed" ? Appearance.colors.colError :
                           Appearance.colors.colPrimary
                }
            }

            // Session info
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    StyledText {
                        Layout.fillWidth: true
                        text: agentName
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: Font.Medium
                        color: Appearance.colors.colOnLayer0
                        elide: Text.ElideRight
                    }

                    // Status badge
                    Rectangle {
                        radius: 6
                        color: status === "active" ? Appearance.colors.colSuccess :
                               status === "failed" ? Appearance.colors.colError :
                               Appearance.colors.colSuccess
                        implicitHeight: 18
                        implicitWidth: statusText.implicitWidth + 10

                        StyledText {
                            id: statusText
                            anchors.centerIn: parent
                            text: status === "active" ? Translation.tr("Active") :
                                  status === "failed" ? Translation.tr("Failed") :
                                  Translation.tr("Completed")
                            font.pixelSize: 10
                            font.weight: Font.Medium
                            color: Appearance.colors.colOnError
                        }
                    }
                }

                StyledText {
                    Layout.fillWidth: true
                    text: (started !== "" ? Translation.tr("Started: %1").arg(started) : "") + (duration !== "" ? " • " + Translation.tr("Duration: %1").arg(duration) : "")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }
            }
        }
    }
}