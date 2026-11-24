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

    // Process row component
    Component {
        id: processRow
        property var process: modelData
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
                text: "memory"
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

            MouseArea {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                cursorShape: Qt.PointingHandCursor
                onClicked: GlobalStates.sessionOpen = true
                MaterialSymbol {
                    anchors.centerIn: parent
                    text: "more_vert"
                    iconSize: 20
                    fill: 1
                    color: Appearance.colors.colSubtext
                }
            }
        }

        Revealer {
            reveal: ProcessManager.available
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                spacing: 4

                Repeater {
                    model: ProcessManager.processes.slice(0, 10)
                    delegate: processRow
                }
            }
        }

        Revealer {
            reveal: !ProcessManager.available
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
                    text: Translation.tr("Process manager unavailable")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colSubtext
                }
            }
        }
    }
}
