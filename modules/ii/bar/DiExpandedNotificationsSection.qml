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
        spacing: 8

        // Section header
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            spacing: 8

            MaterialSymbol {
                Layout.alignment: Qt.AlignVCenter
                text: "notifications"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Notifications")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }

            Revealer {
                reveal: Notifications.unreadCount > 0
                StyledText {
                    Layout.alignment: Qt.AlignVCenter
                    text: `${Notifications.unreadCount}`
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.weight: Font.Bold
                    color: Appearance.colors.colOnPrimary
                    padding: 4
                }
            }

            MouseArea {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    GlobalStates.sidebarRightOpen = true;
                    root.di.expanded = false;
                }
                MaterialSymbol {
                    anchors.centerIn: parent
                    text: "chevron_right"
                    iconSize: 20
                    fill: 1
                    color: Appearance.colors.colSubtext
                }
            }
        }

        // Notifications list
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Repeater {
                model: Notifications.popupList.length > 0 ? Notifications.popupList.slice(0, 5) : [{ empty: true }]
                delegate: NotificationCard {
                    Layout.fillWidth: true
                    notification: modelData
                }
            }

            Revealer {
                reveal: Notifications.popupList.length === 0
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
                        text: Translation.tr("No notifications")
                        font.pixelSize: Appearance.font.pixelSize.normal
                        color: Appearance.colors.colSubtext
                    }
                }
            }
        }
    }
}

// Notification card
Item {
    id: NotificationCard
    required property var notification
    Layout.fillWidth: true
    implicitHeight: 64

    property bool isEmpty: notification.empty === true

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: isEmpty ? "transparent" : Appearance.colors.colLayer1
        border.width: isEmpty ? 0 : 1
        border.color: isEmpty ? "transparent" : Appearance.colors.colOutlineVariant

        RowLayout {
            anchors.fill: parent
            Layout.leftMargin: 12
            Layout.rightMargin: 12
            spacing: 12

            // App icon
            Revealer {
                reveal: !isEmpty
                Rectangle {
                    Layout.alignment: Qt.AlignTop
                    implicitWidth: 40
                    implicitHeight: 40
                    radius: 20
                    color: Appearance.colors.colPrimary
                    opacity: 0.15

                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: notification?.appIcon ?? "notifications"
                        iconSize: 20
                        fill: 1
                        color: Appearance.colors.colPrimary
                    }
                }
            }

            // Notification content
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: !isEmpty ? (notification?.appName ?? Translation.tr("Notification")) : Translation.tr("No notifications")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Medium
                    color: isEmpty ? Appearance.colors.colSubtext : Appearance.colors.colOnLayer0
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: !isEmpty ? (notification?.summary ?? notification?.body ?? "") : ""
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                    elide: Text.ElideRight
                    maxLines: 2
                }
            }

            // Dismiss button
            Revealer {
                reveal: !isEmpty
                MouseArea {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (notification?.id !== undefined) {
                            Notifications.close(notification.id);
                        }
                    }
                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "close"
                        iconSize: 18
                        fill: 1
                        color: Appearance.colors.colSubtext
                    }
                }
            }
        }
    }
}