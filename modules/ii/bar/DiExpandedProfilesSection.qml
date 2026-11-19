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

    property string newProfileName: ""
    property string newProfileDesc: ""
    property string newProfileIcon: "save"

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

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                onClicked: Profiles.refresh()
                MaterialSymbol {
                    Layout.alignment: Qt.AlignVCenter
                    text: "refresh"
                    iconSize: 20
                    fill: 1
                    color: Appearance.colors.colSubtext
                }
            }
        }

        // Create new profile
        Revealer {
            reveal: !Profiles.loading
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16

            Rectangle {
                Layout.fillWidth: true
                radius: 12
                color: Appearance.colors.colLayer1
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant

                ColumnLayout {
                    anchors.fill: parent
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                    Layout.topMargin: 12
                    Layout.bottomMargin: 12
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        StyledText {
                            text: Translation.tr("Create New Profile")
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: Font.Medium
                            color: Appearance.colors.colOnLayer0
                        }
                    }

                    // Name field
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 40
                        radius: 8
                        color: Appearance.colors.colLayer0
                        border.width: 1
                        border.color: Appearance.colors.colOutlineVariant

                        RowLayout {
                            anchors.fill: parent
                            Layout.leftMargin: 12
                            Layout.rightMargin: 12
                            spacing: 8

                            MaterialSymbol {
                                Layout.alignment: Qt.AlignVCenter
                                text: "badge"
                                iconSize: 18
                                fill: 1
                                color: Appearance.colors.colSubtext
                            }

                            TextField {
                                Layout.fillWidth: true
                                background: null
                                font.pixelSize: Appearance.font.pixelSize.normal
                                color: Appearance.colors.colOnLayer0
                                placeholderText: Translation.tr("Profile name (e.g., 'work', 'gaming', 'minimal')")
                                text: root.newProfileName
                                onTextChanged: root.newProfileName = text
                            }
                        }
                    }

                    // Description field
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 40
                        radius: 8
                        color: Appearance.colors.colLayer0
                        border.width: 1
                        border.color: Appearance.colors.colOutlineVariant

                        RowLayout {
                            anchors.fill: parent
                            Layout.leftMargin: 12
                            Layout.rightMargin: 12
                            spacing: 8

                            MaterialSymbol {
                                Layout.alignment: Qt.AlignVCenter
                                text: "description"
                                iconSize: 18
                                fill: 1
                                color: Appearance.colors.colSubtext
                            }

                            TextField {
                                Layout.fillWidth: true
                                background: null
                                font.pixelSize: Appearance.font.pixelSize.normal
                                color: Appearance.colors.colOnLayer0
                                placeholderText: Translation.tr("Description (optional)")
                                text: root.newProfileDesc
                                onTextChanged: root.newProfileDesc = text
                            }
                        }
                    }

                    // Icon picker
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        StyledText {
                            Layout.alignment: Qt.AlignVCenter
                            text: Translation.tr("Icon:")
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colSubtext
                        }

                        ConfigComboBox {
                            currentValue: root.newProfileIcon
                            onSelected: newValue => { root.newProfileIcon = newValue; }
                            options: [
                                { displayName: Translation.tr("Save"), icon: "save", value: "save" },
                                { displayName: Translation.tr("Work"), icon: "work", value: "work" },
                                { displayName: Translation.tr("Gaming"), icon: "sports_esports", value: "sports_esports" },
                                { displayName: Translation.tr("Minimal"), icon: "minimize", value: "minimize" },
                                { displayName: Translation.tr("Creative"), icon: "palette", value: "palette" },
                                { displayName: Translation.tr("Server"), icon: "dns", value: "dns" },
                                { displayName: Translation.tr("Travel"), icon: "flight", value: "flight" },
                                { displayName: Translation.tr("Custom"), icon: "tune", value: "tune" },
                            ]
                        }

                        Item { Layout.fillWidth: true }
                    }

                    // Save button
                    MouseArea {
                        Layout.fillWidth: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.newProfileName.trim()) {
                                Profiles.saveProfile(root.newProfileName.trim(), root.newProfileDesc, root.newProfileIcon);
                                root.newProfileName = "";
                                root.newProfileDesc = "";
                            }
                        }
                        Rectangle {
                            anchors.fill: parent
                            implicitHeight: 40
                            radius: 8
                            color: root.newProfileName.trim() ? Appearance.colors.colPrimary : Appearance.colors.colOutlineVariant

                            StyledText {
                                anchors.centerIn: parent
                                text: Translation.tr("Save Profile")
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: Font.Medium
                                color: root.newProfileName.trim() ? Appearance.colors.colOnPrimary : Appearance.colors.colSubtext
                            }
                        }
                    }
                }
            }
        }

        // Profiles list
        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            spacing: 4

            Revealer {
                reveal: Profiles.profiles.length > 0

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        StyledText {
                            text: Translation.tr("Saved Profiles (%1)").arg(Profiles.profiles.length)
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            font.weight: Font.Medium
                            color: Appearance.colors.colSubtext
                        }
                    }

                    Repeater {
                        model: Profiles.profiles
                        delegate: ProfileCard {
                            Layout.fillWidth: true
                            profile: modelData
                        }
                    }
                }
            }

            Revealer {
                reveal: Profiles.profiles.length === 0 && !Profiles.loading
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 80
                    radius: 12
                    color: Appearance.colors.colLayer1
                    border.width: 1
                    border.color: Appearance.colors.colOutlineVariant
                    opacity: 0.5

                    StyledText {
                        anchors.centerIn: parent
                        text: Translation.tr("No profiles saved yet")
                        font.pixelSize: Appearance.font.pixelSize.normal
                        color: Appearance.colors.colSubtext
                    }
                }
            }

            Revealer {
                reveal: Profiles.loading
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 60
                    radius: 12
                    color: Appearance.colors.colLayer1
                    border.width: 1
                    border.color: Appearance.colors.colOutlineVariant

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        BusySpinner { size: 20 }

                        StyledText {
                            text: Translation.tr("Loading profiles...")
                            font.pixelSize: Appearance.font.pixelSize.normal
                            color: Appearance.colors.colSubtext
                        }
                    }
                }
            }
        }
    }
}

// Profile card
Item {
    id: ProfileCard
    required property var profile
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
                        // Export to downloads
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