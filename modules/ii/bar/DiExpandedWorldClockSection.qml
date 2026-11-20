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
                text: "public"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("World Clock")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    GlobalStates.openSettingsAt("dashboard", Translation.tr("World Clock"), "", "")
                    root.di.expanded = false
                }
                MaterialSymbol {
                    Layout.alignment: Qt.AlignVCenter
                    text: "add"
                    iconSize: 20
                    fill: 1
                    color: Appearance.colors.colSubtext
                }
            }
        }

        // World clocks from WorldClock service
        Revealer {
            reveal: WorldClock.clocks.length > 0
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                Layout.leftMargin: 16
                Layout.rightMargin: 16

                Repeater {
                    model: WorldClock.clocks
                    delegate: worldClockCard
                }
            }
        }

        Revealer {
            reveal: WorldClock.clocks.length === 0
            Layout.fillWidth: true

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                implicitHeight: 80
                radius: 12
                color: Appearance.colors.colLayer1
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant
                opacity: 0.5

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: Translation.tr("No world clocks configured")
                        font.pixelSize: Appearance.font.pixelSize.normal
                        color: Appearance.colors.colSubtext
                    }

                    MouseArea {
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            GlobalStates.openSettingsAt("dashboard", Translation.tr("World Clock"), "", "")
                            root.di.expanded = false
                        }
                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: Translation.tr("Add clocks in settings")
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colPrimary
                        }
                    }
                }
            }
        }
    }

    // World clock card
    Component {
        id: worldClockCard

        Item {
            required property var clockData
            Layout.fillWidth: true
            implicitHeight: 56

            property string timeStr: {
                try {
                    var d = new Date();
                    var offset = clockData.utcOffset ?? 0;
                    d.setTime(d.getTime() + offset * 60 * 1000);
                    return Qt.formatDateTime(d, "HH:mm");
                } catch (e) { return "--:--"; }
            }
            property string dateStr: {
                try {
                    var d = new Date();
                    var offset = clockData.utcOffset ?? 0;
                    d.setTime(d.getTime() + offset * 60 * 1000);
                    return Qt.formatDateTime(d, "EEEE, MMMM d");
                } catch (e) { return ""; }
            }
            property bool isDST: clockData.dst ?? false

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

                    // Location icon
                    Rectangle {
                        Layout.alignment: Qt.AlignVCenter
                        implicitWidth: 40
                        implicitHeight: 40
                        radius: 20
                        color: Appearance.colors.colPrimary
                        opacity: 0.15

                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "location_on"
                            iconSize: 20
                            fill: 1
                            color: Appearance.colors.colPrimary
                        }
                    }

                    // Location info
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: -2

                        StyledText {
                            Layout.fillWidth: true
                            text: clockData.name ?? clockData.city ?? "Unknown"
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: Font.Medium
                            color: Appearance.colors.colOnLayer0
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: clockData.city ? `${clockData.city}  •  ${dateStr}` : dateStr
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colSubtext
                        }
                    }

                    // Time
                    ColumnLayout {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        spacing: 2

                        StyledText {
                            Layout.alignment: Qt.AlignRight
                            text: timeStr
                            font.pixelSize: Appearance.font.pixelSize.larger
                            font.weight: Font.Bold
                            font.features: { "tnum": 1 }
                            color: Appearance.colors.colOnLayer0
                        }

                        RowLayout {
                            Layout.alignment: Qt.AlignRight
                            spacing: 4

                            Revealer {
                                reveal: clockData.utcOffset !== undefined
                                StyledText {
                                    text: `UTC${clockData.utcOffset >= 0 ? "+" : ""}${clockData.utcOffset / 60}`
                                    font.pixelSize: Appearance.font.pixelSize.smaller
                                    color: Appearance.colors.colSubtext
                                }
                            }

                            Revealer {
                                reveal: isDST
                                MaterialSymbol {
                                    text: "wb_sunny"
                                    iconSize: 12
                                    fill: 1
                                    color: Appearance.m3colors.m3warning
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
