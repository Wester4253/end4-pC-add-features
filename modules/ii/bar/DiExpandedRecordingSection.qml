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

    // Recording option button component
    Component {
        id: recordingOptionButton
        Item {
            required property string icon
            required property string label
            required property var onClicked
            Layout.fillWidth: true
            implicitHeight: 48

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
                    onClicked: recordingOptionButton.onClicked()
                    onEntered: parent.color = Qt.lighter(Appearance.colors.colLayer1, 1.05)
                    onExited: parent.color = Appearance.colors.colLayer1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        MaterialSymbol {
                            Layout.alignment: Qt.AlignVCenter
                            text: recordingOptionButton.icon
                            iconSize: 20
                            fill: 1
                            color: Appearance.colors.colError
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignVCenter
                            text: recordingOptionButton.label
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
                text: "record_voice_over"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Recording")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }
        }

        Revealer {
            reveal: Recording.available
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                spacing: 4

                Loader {
                    sourceComponent: recordingOptionButton
                    Binding { target: item; property: "icon"; value: "mic" }
                    Binding { target: item; property: "label"; value: Translation.tr("Record Microphone") }
                    Binding { target: item; property: "onClicked"; value: Recording.startMic() }
                }

                Loader {
                    sourceComponent: recordingOptionButton
                    Binding { target: item; property: "icon"; value: "desktop" }
                    Binding { target: item; property: "label"; value: Translation.tr("Record Screen") }
                    Binding { target: item; property: "onClicked"; value: Recording.startScreen() }
                }

                Loader {
                    sourceComponent: recordingOptionButton
                    Binding { target: item; property: "icon"; value: "stop" }
                    Binding { target: item; property: "label"; value: Translation.tr("Stop Recording") }
                    Binding { target: item; property: "onClicked"; value: Recording.stop() }
                }
            }
        }

        Revealer {
            reveal: !Recording.available
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
                    text: Translation.tr("Recording unavailable")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colSubtext
                }
            }
        }
    }
}
