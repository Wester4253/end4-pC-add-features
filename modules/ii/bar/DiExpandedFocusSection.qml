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

    property string customMinutes: ""

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

        Revealer {
            reveal: FocusMode.enabled
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            spacing: 8

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                // Current status
                Rectangle {
                    Layout.fillWidth: true
                    radius: 12
                    color: Appearance.colors.colPrimary
                    opacity: 0.1

                    ColumnLayout {
                        anchors.fill: parent
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16
                        Layout.topMargin: 16
                        Layout.bottomMargin: 16
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            MaterialSymbol {
                                Layout.alignment: Qt.AlignVCenter
                                text: {
                                    switch (FocusMode.mode) {
                                        case "dnd": return "notifications_off";
                                        case "gaming": return "sports_esports";
                                        default: return "center_focus_strong";
                                    }
                                }
                                iconSize: 24
                                fill: 1
                                color: Appearance.colors.colPrimary
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                StyledText {
                                    Layout.fillWidth: true
                                    text: {
                                        switch (FocusMode.mode) {
                                            case "dnd": return Translation.tr("Do Not Disturb");
                                            case "gaming": return Translation.tr("Gaming Mode");
                                            default: return Translation.tr("Focus Mode");
                                        }
                                    }
                                    font.pixelSize: Appearance.font.pixelSize.normal
                                    font.weight: Font.Medium
                                    color: Appearance.colors.colPrimary
                                }

                                StyledText {
                                    Layout.fillWidth: true
                                    text: FocusMode.duration > 0
                                        ? Translation.tr("Ends in %1 min").arg(Math.max(0, Math.ceil((FocusMode.endTime - Date.now()) / 60000)))
                                        : Translation.tr("Indefinite")
                                    font.pixelSize: Appearance.font.pixelSize.smaller
                                    color: Appearance.colors.colSubtext
                                }
                            }

                            // Stop button
                            MouseArea {
                                cursorShape: Qt.PointingHandCursor
                                onClicked: FocusMode.disable()
                                MaterialSymbol {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: "stop_circle"
                                    iconSize: 24
                                    fill: 1
                                    color: Appearance.colors.colError
                                }
                            }
                        }

                        // Mode selector
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            StyledText {
                                Layout.alignment: Qt.AlignVCenter
                                text: Translation.tr("Mode:")
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colSubtext
                            }

                            ConfigComboBox {
                                currentValue: FocusMode.mode
                                onSelected: newValue => { FocusMode.setMode(newValue); }
                                options: [
                                    { displayName: Translation.tr("Focus"), icon: "center_focus_strong", value: "focus" },
                                    { displayName: Translation.tr("Do Not Disturb"), icon: "notifications_off", value: "dnd" },
                                    { displayName: Translation.tr("Gaming"), icon: "sports_esports", value: "gaming" },
                                ]
                            }
                        }
                    }
                }
            }

            // Preset buttons
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    StyledText {
                        text: Translation.tr("Quick Presets")
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        font.weight: Font.Medium
                        color: Appearance.colors.colSubtext
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 4
                    columnSpacing: 8
                    rowSpacing: 8

                    PresetButton {
                        icon: "timer"
                        label: Translation.tr("25 min")
                        color: Appearance.colors.colPrimary
                        onClicked: FocusMode.focus25()
                    }

                    PresetButton {
                        icon: "timer"
                        label: Translation.tr("50 min")
                        color: Appearance.colors.colSecondary
                        onClicked: FocusMode.focus50()
                    }

                    PresetButton {
                        icon: "notifications_off"
                        label: Translation.tr("1 hr DND")
                        color: Appearance.colors.colTertiary
                        onClicked: FocusMode.dnd1h()
                    }

                    PresetButton {
                        icon: "sports_esports"
                        label: Translation.tr("4 hr Gaming")
                        color: Appearance.m3colors.m3warning
                        onClicked: FocusMode.gaming4h()
                    }

                    PresetButton {
                        icon: "timer"
                        label: Translation.tr("Custom")
                        color: Appearance.colors.colPrimary
                        onClicked: { root.showCustomDialog = true; }
                    }
                }

                // Custom duration input
                Revealer {
                    reveal: root.showCustomDialog
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
                            Layout.topMargin: 16
                            Layout.bottomMargin: 16
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                StyledText {
                                    text: Translation.tr("Duration (minutes):")
                                    font.pixelSize: Appearance.font.pixelSize.normal
                                    color: Appearance.colors.colOnLayer0
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: 40
                                    radius: 8
                                    color: Appearance.colors.colLayer0
                                    border.width: 1
                                    border.color: Appearance.colors.colOutlineVariant

                                    TextField {
                                        anchors.fill: parent
                                        Layout.leftMargin: 12
                                        Layout.rightMargin: 12
                                        background: null
                                        font.pixelSize: Appearance.font.pixelSize.normal
                                        color: Appearance.colors.colOnLayer0
                                        placeholderText: Translation.tr("e.g., 90")
                                        text: root.customMinutes
                                        onTextChanged: root.customMinutes = text
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                ConfigComboBox {
                                    currentValue: "focus"
                                    onSelected: newValue => { root.customMode = newValue; }
                                    options: [
                                        { displayName: Translation.tr("Focus"), icon: "center_focus_strong", value: "focus" },
                                        { displayName: Translation.tr("DND"), icon: "notifications_off", value: "dnd" },
                                        { displayName: Translation.tr("Gaming"), icon: "sports_esports", value: "gaming" },
                                    ]
                                }

                                MouseArea {
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        var mins = parseInt(root.customMinutes);
                                        if (!isNaN(mins) && mins > 0) {
                                            FocusMode.enable(mins, root.customMode);
                                            root.showCustomDialog = false;
                                            root.customMinutes = "";
                                        }
                                    }
                                    Rectangle {
                                        Layout.fillWidth: true
                                        implicitHeight: 40
                                        radius: 8
                                        color: Appearance.colors.colPrimary

                                        StyledText {
                                            anchors.centerIn: parent
                                            text: Translation.tr("Start")
                                            font.pixelSize: Appearance.font.pixelSize.normal
                                            font.weight: Font.Medium
                                            color: Appearance.colors.colOnPrimary
                                        }
                                    }
                                }

                                MouseArea {
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: { root.showCustomDialog = false; root.customMinutes = ""; }
                                    Rectangle {
                                        implicitWidth: 40
                                        implicitHeight: 40
                                        radius: 20
                                        color: Appearance.colors.colLayer1
                                        border.width: 1
                                        border.color: Appearance.colors.colOutlineVariant

                                        MaterialSymbol {
                                            anchors.centerIn: parent
                                            text: "close"
                                            iconSize: 20
                                            fill: 1
                                            color: Appearance.colors.colSubtext
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Notifications status
        Revealer {
            reveal: Notifications.dnd
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16

            Rectangle {
                Layout.fillWidth: true
                radius: 10
                color: Appearance.colors.colWarning
                opacity: 0.15
                border.width: 1
                border.color: Appearance.colors.colWarning

                RowLayout {
                    anchors.fill: parent
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                    Layout.topMargin: 8
                    Layout.bottomMargin: 8
                    spacing: 8

                    MaterialSymbol {
                        Layout.alignment: Qt.AlignVCenter
                        text: "notifications_off"
                        iconSize: 20
                        fill: 1
                        color: Appearance.colors.colWarning
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("Notifications are silenced (Do Not Disturb active)")
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colWarning
                    }
                }
            }
        }
    }
}

// Preset button
Item {
    id: PresetButton
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