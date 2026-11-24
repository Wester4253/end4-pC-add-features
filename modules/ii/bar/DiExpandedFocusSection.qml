import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root
    required property Item di
    Layout.fillWidth: true

    // Preset button component
    Component {
        id: presetButton
        Item {
            required property string icon
            required property string label
            required property color color
            required property var onClicked
            Layout.fillWidth: true
            Layout.preferredHeight: 48

            Rectangle {
                anchors.fill: parent
                radius: 10
                color: Appearance.colors.colLayer1
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: presetButton.onClicked()
                    onEntered: parent.color = Qt.lighter(Appearance.colors.colLayer1, 1.05)
                    onExited: parent.color = Appearance.colors.colLayer1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        MaterialSymbol {
                            Layout.alignment: Qt.AlignVCenter
                            text: presetButton.icon
                            iconSize: 20
                            fill: 1
                            color: presetButton.color
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignVCenter
                            text: presetButton.label
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: Font.Medium
                            color: Appearance.colors.colOnLayer0
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
                text: FocusMode.enabled ? "center_focus_strong" : "center_focus_weak"
                iconSize: 20
                fill: 1
                color: FocusMode.enabled ? Appearance.colors.colPrimary : Appearance.colors.colSubtext
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Focus Mode")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }

            // Main toggle
            Switch {
                checked: FocusMode.enabled
                onCheckedChanged: {
                    if (checked) FocusMode.enable(0, "focus");
                    else FocusMode.disable();
                }
            }
        }

        // Presets
        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            spacing: 6

            Repeater {
                model: FocusMode.presets
                delegate: presetButton {
                    icon: modelData.icon
                    label: modelData.label
                    color: modelData.color
                    onClicked: modelData.onClicked
                }
            }
        }
    }
}
