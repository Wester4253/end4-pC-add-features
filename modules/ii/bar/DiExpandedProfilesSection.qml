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

    // Profile card component
    Component {
        id: profileCard
        property var profile: modelData
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
                        text: profile.icon ?? "save"
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
                        text: profile.name
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: Font.Medium
                        color: Appearance.colors.colOnLayer0
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: profile.description || Translation.tr("No description")
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colSubtext
                    }
                }

                StyledText {
                    Layout.alignment: Qt.AlignVCenter
                    text: profile.created ? Qt.formatDateTime(new Date(profile.created), "MMM d, yyyy") : ""
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }

                // Actions
                RowLayout {
                    spacing: 4

                    MouseArea {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Profiles.loadProfile(profile.name)
                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "download"
                            iconSize: 18
                            fill: 1
                            color: Appearance.colors.colPrimary
                        }
                    }

                    MouseArea {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            const path = `${Directories.downloads}/${profile.name}.json`;
                            Profiles.exportProfile(profile.name, path);
                        }
                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "file_download"
                            iconSize: 18
                            fill: 1
                            color: Appearance.colors.colSubtext
                        }
                    }

                    MouseArea {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Profiles.deleteProfile(profile.name)
                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "delete"
                            iconSize: 18
                            fill: 1
                            color: Appearance.colors.colError
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
                text: "save"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Profiles")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }
        }

        Revealer {
            reveal: Profiles.available
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                spacing: 4

                Repeater {
                    model: Profiles.list ?? []
                    delegate: profileCard
                }
            }
        }

        Revealer {
            reveal: !Profiles.available
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
                    text: Translation.tr("Profiles unavailable")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colSubtext
                }
            }
        }
    }
}
