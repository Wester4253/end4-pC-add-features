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

    // Window control button component
    Component {
        id: windowControlButton
        Item {
            property string icon
            property string tooltip: ""
            property color color: Appearance.colors.colOnLayer0
            property bool fill: 0
            implicitWidth: 36
            implicitHeight: 36

            Rectangle {
                id: btnBg
                anchors.centerIn: parent
                width: 32
                height: 32
                radius: 16
                color: "transparent"

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: windowControlButton.onClicked()
                    onEntered: btnBg.color = Qt.lighter(Appearance.colors.colLayer1, 1.1)
                    onExited: btnBg.color = "transparent"

                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: windowControlButton.icon
                        iconSize: 18
                        fill: windowControlButton.fill
                        color: windowControlButton.color
                    }
                }
            }
        }
    }

    // Info row component
    Component {
        id: infoRow
        property string label
        property string value
        Layout.fillWidth: true

        ColumnLayout {
            spacing: -2

            StyledText {
                text: label
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colSubtext
            }

            StyledText {
                text: value
                font.pixelSize: Appearance.font.pixelSize.smaller
                font.weight: Font.Medium
                font.family: "monospace"
                color: Appearance.colors.colOnLayer0
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
                text: "window"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Active Window")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }
        }

        // Window info
        Revealer {
            reveal: Window.activeWindowId !== null
            Layout.fillWidth: true

            Rectangle {
                Layout.fillWidth: true
                radius: 12
                color: Appearance.colors.colLayer1
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant

                ColumnLayout {
                    anchors.fill: parent
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.topMargin: 12
                    Layout.bottomMargin: 12
                    spacing: 12

                    infoRow {
                        label: Translation.tr("Title")
                        value: Window.activeWindowTitle ?? ""
                    }

                    infoRow {
                        label: Translation.tr("Class")
                        value: Window.activeWindowClass ?? ""
                    }

                    infoRow {
                        label: Translation.tr("PID")
                        value: String(Window.activeWindowPid ?? 0)
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        windowControlButton {
                            icon: "close"
                            color: Appearance.colors.colError
                            onClicked: Window.closeActiveWindow()
                        }

                        windowControlButton {
                            icon: "minimize"
                            color: Appearance.colors.colOnLayer0
                            onClicked: Window.minimizeActiveWindow()
                        }

                        windowControlButton {
                            icon: "maximize"
                            color: Appearance.colors.colOnLayer0
                            onClicked: Window.maximizeActiveWindow()
                        }

                        Item { Layout.fillWidth: true }
                    }
                }
            }
        }

        Revealer {
            reveal: Window.activeWindowId === null
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
                    text: Translation.tr("No active window")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colSubtext
                }
            }
        }
    }
}
