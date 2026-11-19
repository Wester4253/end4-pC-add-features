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

    property string filterLevel: "all" // "all", "error", "warning", "info", "debug"
    property int maxLines: 100
    property var logLines: []

    // Simulated log entries - in reality this would hook into the shell's logging
    function generateSampleLogs() {
        var logs = [];
        var levels = ["debug", "info", "warning", "error"];
        var sources = ["Hyprland", "Audio", "Network", "Bluetooth", "Battery", "Notifications", "Mpris", "Weather", "Updates", "Resources", "Shell", "Config", "Docker", "VPN"];
        var messages = [
            "Service started successfully",
            "Configuration loaded",
            "Connected to daemon",
            "Polling for updates",
            "State changed",
            "Event received",
            "Cache refreshed",
            "Timeout occurred",
            "Retrying connection",
            "Operation completed",
            "Warning: high memory usage",
            "Error: connection failed",
            "Debug: processing message",
            "Info: user action detected"
        ];
        var now = Date.now();
        for (var i = 0; i < 50; i++) {
            var level = levels[Math.floor(Math.random() * levels.length)];
            logs.push({
                timestamp: new Date(now - Math.random() * 3600000),
                level: level,
                source: sources[Math.floor(Math.random() * sources.length)],
                message: messages[Math.floor(Math.random() * messages.length)]
            });
        }
        logs.sort((a, b) => b.timestamp - a.timestamp);
        return logs;
    }

    Component.onCompleted: {
        root.logLines = root.generateSampleLogs();
    }

    function filteredLogs() {
        if (root.filterLevel === "all") return root.logLines;
        return root.logLines.filter(l => l.level === root.filterLevel);
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
                text: "terminal"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Debug Logs")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }

            // Level filter
            ConfigComboBox {
                currentValue: root.filterLevel
                onSelected: newValue => { root.filterLevel = newValue; }
                options: [
                    { displayName: Translation.tr("All"), icon: "list", value: "all" },
                    { displayName: Translation.tr("Error"), icon: "error", value: "error" },
                    { displayName: Translation.tr("Warning"), icon: "warning", value: "warning" },
                    { displayName: Translation.tr("Info"), icon: "info", value: "info" },
                    { displayName: Translation.tr("Debug"), icon: "bug_report", value: "debug" }
                ]
            }

            // Clear button
            MouseArea {
                cursorShape: Qt.PointingHandCursor
                onClicked: { root.logLines = []; }
                MaterialSymbol {
                    Layout.alignment: Qt.AlignVCenter
                    text: "delete_sweep"
                    iconSize: 20
                    fill: 1
                    color: Appearance.colors.colSubtext
                }
            }

            // Refresh button
            MouseArea {
                cursorShape: Qt.PointingHandCursor
                onClicked: { root.logLines = root.generateSampleLogs(); }
                MaterialSymbol {
                    Layout.alignment: Qt.AlignVCenter
                    text: "refresh"
                    iconSize: 20
                    fill: 1
                    color: Appearance.colors.colSubtext
                }
            }
        }

        // Log entries
        Flickable {
            id: logFlickable
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentHeight: logColumn.implicitHeight
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: logColumn
                Layout.fillWidth: true
                spacing: 1
                Layout.leftMargin: 16
                Layout.rightMargin: 16

                Repeater {
                    model: root.filteredLogs()
                    delegate: LogEntry {
                        Layout.fillWidth: true
                        entry: modelData
                    }
                }
            }
        }
    }
}

// Log entry
Item {
    id: LogEntry
    required property var entry
    Layout.fillWidth: true
    implicitHeight: 32

    property color levelColor: {
        switch (entry.level) {
            case "error": return Appearance.colors.colError;
            case "warning": return Appearance.m3colors.m3warning;
            case "info": return Appearance.colors.colPrimary;
            case "debug": return Appearance.colors.colSubtext;
            default: return Appearance.colors.colOnLayer0;
        }
    }

    property string levelIcon: {
        switch (entry.level) {
            case "error": return "error";
            case "warning": return "warning";
            case "info": return "info";
            case "debug": return "bug_report";
            default: return "circle";
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: Appearance.colors.colLayer1
        opacity: 0.7

        RowLayout {
            anchors.fill: parent
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            spacing: 8

            // Timestamp
            StyledText {
                Layout.preferredWidth: 70
                text: Qt.formatDateTime(entry.timestamp, "HH:mm:ss")
                font.pixelSize: Appearance.font.pixelSize.smaller
                font.family: "monospace"
                color: Appearance.colors.colSubtext
            }

            // Level badge
            Rectangle {
                implicitWidth: 48
                implicitHeight: 20
                radius: 10
                color: levelColor
                opacity: 0.2

                StyledText {
                    anchors.centerIn: parent
                    text: entry.level.toUpperCase()
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.weight: Font.Bold
                    color: levelColor
                }
            }

            // Source
            StyledText {
                Layout.preferredWidth: 80
                text: entry.source
                font.pixelSize: Appearance.font.pixelSize.smaller
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            // Message
            StyledText {
                Layout.fillWidth: true
                text: entry.message
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colOnLayer0
                elide: Text.ElideRight
            }
        }
    }
}