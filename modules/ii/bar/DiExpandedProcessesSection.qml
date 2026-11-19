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

    property string sortBy: "cpu" // "cpu", "memory", "pid", "name"
    property bool sortDescending: true

    function sortProcesses(processes) {
        var arr = processes.slice();
        arr.sort(function(a, b) {
            var va, vb;
            switch (root.sortBy) {
                case "cpu": va = a.cpuUsage ?? 0; vb = b.cpuUsage ?? 0; break;
                case "memory": va = a.memoryUsage ?? 0; vb = b.memoryUsage ?? 0; break;
                case "pid": va = a.pid ?? 0; vb = b.pid ?? 0; break;
                case "name": va = (a.name ?? "").toLowerCase(); vb = (b.name ?? "").toLowerCase(); break;
                default: va = a.cpuUsage ?? 0; vb = b.cpuUsage ?? 0;
            }
            if (va < vb) return root.sortDescending ? 1 : -1;
            if (va > vb) return root.sortDescending ? -1 : 1;
            return 0;
        });
        return arr;
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
                text: "task_alt"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Processes")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }

            // Sort selector
            ConfigComboBox {
                currentValue: root.sortBy
                onSelected: newValue => { root.sortBy = newValue; }
                options: [
                    { displayName: Translation.tr("CPU"), icon: "speed", value: "cpu" },
                    { displayName: Translation.tr("Memory"), icon: "memory", value: "memory" },
                    { displayName: Translation.tr("PID"), icon: "filter_1", value: "pid" },
                    { displayName: Translation.tr("Name"), icon: "sort_by_alpha", value: "name" }
                ]
            }

            // Sort direction
            MouseArea {
                cursorShape: Qt.PointingHandCursor
                onClicked: { root.sortDescending = !root.sortDescending; }
                MaterialSymbol {
                    Layout.alignment: Qt.AlignVCenter
                    text: root.sortDescending ? "arrow_downward" : "arrow_upward"
                    iconSize: 20
                    fill: 1
                    color: Appearance.colors.colSubtext
                }
            }

            // Refresh
            MouseArea {
                cursorShape: Qt.PointingHandCursor
                onClicked: { ResourceUsage.refreshProcesses(); }
                MaterialSymbol {
                    Layout.alignment: Qt.AlignVCenter
                    text: "refresh"
                    iconSize: 20
                    fill: 1
                    color: Appearance.colors.colSubtext
                }
            }
        }

        // Process list
        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            spacing: 2

            // Header row
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 32
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                    spacing: 8

                    StyledText { Layout.fillWidth: true; Layout.alignment: Qt.AlignLeft; text: Translation.tr("PID"); font.pixelSize: Appearance.font.pixelSize.smaller; font.weight: Font.Medium; color: Appearance.colors.colSubtext; Layout.minimumWidth: 60 }
                    StyledText { Layout.fillWidth: true; Layout.alignment: Qt.AlignLeft; text: Translation.tr("Name"); font.pixelSize: Appearance.font.pixelSize.smaller; font.weight: Font.Medium; color: Appearance.colors.colSubtext; Layout.minimumWidth: 120 }
                    StyledText { Layout.fillWidth: true; Layout.alignment: Qt.AlignRight; text: Translation.tr("CPU%"); font.pixelSize: Appearance.font.pixelSize.smaller; font.weight: Font.Medium; color: Appearance.colors.colSubtext; Layout.preferredWidth: 60 }
                    StyledText { Layout.fillWidth: true; Layout.alignment: Qt.AlignRight; text: Translation.tr("MEM%"); font.pixelSize: Appearance.font.pixelSize.smaller; font.weight: Font.Medium; color: Appearance.colors.colSubtext; Layout.preferredWidth: 60 }
                    StyledText { Layout.fillWidth: true; Layout.alignment: Qt.AlignRight; text: Translation.tr("User"); font.pixelSize: Appearance.font.pixelSize.smaller; font.weight: Font.Medium; color: Appearance.colors.colSubtext; Layout.preferredWidth: 80 }
                }
            }

            Repeater {
                model: root.sortProcesses(ResourceUsage.processes ?? [])
                delegate: ProcessRow {
                    Layout.fillWidth: true
                    process: modelData
                }
            }
        }
    }
}

// Process row
Item {
    id: ProcessRow
    required property var process
    Layout.fillWidth: true
    implicitHeight: 36

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
            spacing: 8

            StyledText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
                Layout.minimumWidth: 60
                text: process.pid ?? "—"
                font.pixelSize: Appearance.font.pixelSize.smaller
                font.family: "monospace"
                color: Appearance.colors.colOnLayer0
            }

            StyledText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
                Layout.minimumWidth: 120
                text: process.name ?? process.command ?? Translation.tr("Unknown")
                font.pixelSize: Appearance.font.pixelSize.smaller
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                Layout.preferredWidth: 60
                text: process.cpuUsage !== undefined ? `${(process.cpuUsage * 100).toFixed(1)}%` : "—"
                font.pixelSize: Appearance.font.pixelSize.smaller
                font.family: "monospace"
                color: (process.cpuUsage ?? 0) > 0.5 ? Appearance.colors.colError : ((process.cpuUsage ?? 0) > 0.2 ? Appearance.colors.colWarning : Appearance.colors.colOnLayer0)
            }

            StyledText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                Layout.preferredWidth: 60
                text: process.memoryUsage !== undefined ? `${(process.memoryUsage * 100).toFixed(1)}%` : "—"
                font.pixelSize: Appearance.font.pixelSize.smaller
                font.family: "monospace"
                color: (process.memoryUsage ?? 0) > 0.5 ? Appearance.colors.colError : ((process.memoryUsage ?? 0) > 0.2 ? Appearance.colors.colWarning : Appearance.colors.colOnLayer0)
            }

            StyledText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                Layout.preferredWidth: 80
                text: process.user ?? "—"
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colSubtext
            }
        }
    }
}