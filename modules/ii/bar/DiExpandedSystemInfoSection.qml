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

    // System info card component
    Component {
        id: systemInfoCard
        Item {
            required property string title
            required property string value
            required property string icon
            required color color
            Layout.fillWidth: true
            Layout.preferredHeight: 56

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
                        color: color
                        opacity: 0.15

                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: icon
                            iconSize: 20
                            fill: 1
                            color: color
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: -2

                        StyledText {
                            Layout.fillWidth: true
                            text: title
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colSubtext
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: value
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: Font.Medium
                            color: Appearance.colors.colOnLayer0
                            elide: Text.ElideRight
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
                text: Translation.tr("System Info")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 12
            rowSpacing: 12
            Layout.leftMargin: 16
            Layout.rightMargin: 16

            systemInfoCard

            systemInfoCard

            systemInfoCard

            systemInfoCard

            systemInfoCard

            systemInfoCard

            systemInfoCard

            systemInfoCard

            systemInfoCard

            systemInfoCard

            systemInfoCard

            systemInfoCard
    }
}
