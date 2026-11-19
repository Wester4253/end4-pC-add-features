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

    readonly property bool isRecording: Persistent.states.record.enable
    property int recordingElapsedSeconds: 0

    Timer {
        interval: 1000
        repeat: true
        running: root.isRecording
        onTriggered: root.recordingElapsedSeconds++
    }

    function formatTime(s) {
        var h = Math.floor(s / 3600);
        var m = Math.floor((s % 3600) / 60);
        var sec = s % 60;
        return (h > 0 ? h.toString().padStart(2, '0') + ':' : '') + m.toString().padStart(2, '0') + ':' + sec.toString().padStart(2, '0');
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
                text: "screen_record"
                iconSize: 20
                fill: 1
                color: root.isRecording ? Appearance.colors.colError : Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Screen Recording")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }

            Revealer {
                reveal: root.isRecording
                StyledText {
                    Layout.alignment: Qt.AlignVCenter
                    text: Translation.tr("LIVE")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.weight: Font.Bold
                    color: Appearance.colors.colError
                    padding: 4
                }
            }
        }

        Revealer {
            reveal: root.isRecording
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16

            // Recording card
            Rectangle {
                Layout.fillWidth: true
                radius: 16
                color: Appearance.colors.colError
                opacity: 0.1

                ColumnLayout {
                    anchors.fill: parent
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.topMargin: 20
                    Layout.bottomMargin: 20
                    spacing: 12

                    // Timer display
                    StyledText {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        text: root.formatTime(root.recordingElapsedSeconds)
                        font.pixelSize: 48
                        font.weight: Font.Bold
                        font.features: { "tnum": 1 }
                        color: Appearance.colors.colError
                    }

                    // Controls
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16

                        MaterialSymbolButton {
                            text: "pause_circle"
                            iconSize: 36
                            fill: 1
                            color: Appearance.colors.colError
                            onClicked: Quickshell.execDetached([Directories.recordScriptPath, "pause"])
                        }

                        MaterialSymbolButton {
                            text: "stop_circle"
                            iconSize: 40
                            fill: 1
                            color: Appearance.colors.colError
                            onClicked: Quickshell.execDetached([Directories.recordScriptPath, "stop"])
                        }

                        MaterialSymbolButton {
                            text: "cancel"
                            iconSize: 24
                            color: Appearance.colors.colError
                            onClicked: Quickshell.execDetached([Directories.recordScriptPath, "cancel"])
                        }
                    }
                }
            }
        }

        Revealer {
            reveal: !root.isRecording
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                // Start recording button
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 56
                    radius: 12
                    color: Appearance.colors.colError
                    opacity: 0.1
                    border.width: 1
                    border.color: Appearance.colors.colError

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Quickshell.execDetached([Directories.recordScriptPath])
                        hoverEnabled: true
                        onEntered: parent.opacity = 0.2
                        onExited: parent.opacity = 0.1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 12

                            MaterialSymbol {
                                Layout.alignment: Qt.AlignVCenter
                                text: "screen_record"
                                iconSize: 24
                                fill: 1
                                color: Appearance.colors.colError
                            }

                            StyledText {
                                Layout.alignment: Qt.AlignVCenter
                                text: Translation.tr("Start Recording")
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: Font.Medium
                                color: Appearance.colors.colError
                            }
                        }
                    }
                }

                // Recording options
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    RecordingOptionButton {
                        Layout.fillWidth: true
                        icon: "videocam"
                        label: Translation.tr("Video")
                        onClicked: Quickshell.execDetached([Directories.recordScriptPath, "video"])
                    }

                    RecordingOptionButton {
                        Layout.fillWidth: true
                        icon: "photo_camera"
                        label: Translation.tr("Screenshot")
                        onClicked: Quickshell.execDetached([Directories.recordScriptPath, "screenshot"])
                    }

                    RecordingOptionButton {
                        Layout.fillWidth: true
                        icon: "gif"
                        label: Translation.tr("GIF")
                        onClicked: Quickshell.execDetached([Directories.recordScriptPath, "gif"])
                    }
                }
            }
        }
    }
}

// Recording option button
Item {
    id: RecordingOptionButton
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