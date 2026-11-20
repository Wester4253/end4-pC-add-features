import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root
    required property Item di
    anchors.fill: parent

    readonly property bool showIcon: !di.isMaterial

    RowLayout {
        anchors.fill: parent
        Layout.leftMargin: root.di.isMaterial ? 0 : 8
        Layout.rightMargin: 10
        spacing: 6

        // AI icon
        Revealer {
            reveal: root.showIcon
            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: root.di.pillHeight - 8
                implicitHeight: root.di.pillHeight - 8
                radius: width / 2
                color: Appearance.colors.colPrimary
                opacity: 0.15

                CustomIcon {
                    anchors.centerIn: parent
                    width: 16
                    height: 16
                    source: "neurology"
                    colorize: true
                    color: Appearance.colors.colPrimary
                }
            }
        }

        // Provider indicators
        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            // Claude
            Revealer {
                reveal: Config.options.bar.aiUsage.claudeEnabled && ClaudeUsage.available
                Item {
                    Layout.alignment: Qt.AlignVCenter
                    implicitWidth: 48
                    implicitHeight: 20

                    StyledProgressBar {
                        anchors.fill: parent
                        value: ClaudeUsage.percentage
                        color: Appearance.colors.colPrimary
                        background: Appearance.colors.colLayer0
                    }
                }
            }

            // Codex
            Revealer {
                reveal: Config.options.bar.aiUsage.codexEnabled && CodexUsage.available
                Item {
                    Layout.alignment: Qt.AlignVCenter
                    implicitWidth: 48
                    implicitHeight: 20

                    StyledProgressBar {
                        anchors.fill: parent
                        value: CodexUsage.percentage
                        color: Appearance.colors.colSecondary
                        background: Appearance.colors.colLayer0
                    }
                }
            }

            // Oh My Pi
            Revealer {
                reveal: Config.options.bar.aiUsage.ompEnabled && OmpUsage.available
                Item {
                    Layout.alignment: Qt.AlignVCenter
                    implicitWidth: 56
                    implicitHeight: 20

                    StyledProgressBar {
                        anchors.fill: parent
                        value: OmpUsage.requestsLastMinute / OmpUsage.rpmLimit
                        color: Appearance.colors.colTertiary
                        background: Appearance.colors.colLayer0
                    }
                }
            }

            // Otto
            Revealer {
                reveal: Config.options.bar.aiUsage.ottoEnabled && OttoUsage.available
                Item {
                    Layout.alignment: Qt.AlignVCenter
                    implicitWidth: 56
                    implicitHeight: 20

                    StyledProgressBar {
                        anchors.fill: parent
                        value: OttoUsage.totalSessions > 0 ? OttoUsage.activeSessions / OttoUsage.totalSessions : 0
                        color: Appearance.colors.colError
                        background: Appearance.colors.colLayer0
                    }
                }
            }
        }

        // Summary text
        StyledText {
            Layout.alignment: Qt.AlignVCenter
            text: root.di.aiUsageSummary()
            font.pixelSize: Appearance.font.pixelSize.small
            font.features: { "tnum": 1 }
            color: Appearance.colors.colOnLayer0
            elide: Text.ElideRight
            maximumHorizontalAdvance: 120
        }
    }
}