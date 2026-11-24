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

    // Timer type selection card component
    Component {
        id: timerTypeCard
        Item {
            property string title
            property string subtitle
            property string icon
            property color color
            property var onClicked
            Layout.fillWidth: true
            implicitHeight: 56

            Rectangle {
                anchors.fill: parent
                radius: 12
                color: Appearance.colors.colLayer1
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: timerTypeCard.onClicked()
                    onEntered: parent.color = Qt.lighter(Appearance.colors.colLayer1, 1.05)
                    onExited: parent.color = Appearance.colors.colLayer1

                    RowLayout {
                        anchors.fill: parent
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16
                        spacing: 16

                        Rectangle {
                            Layout.alignment: Qt.AlignVCenter
                            implicitWidth: 44
                            implicitHeight: 44
                            radius: 22
                            color: timerTypeCard.color
                            opacity: 0.15

                            MaterialSymbol {
                                anchors.centerIn: parent
                                text: timerTypeCard.icon
                                iconSize: 22
                                fill: 1
                                color: timerTypeCard.color
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: -2

                            StyledText {
                                Layout.fillWidth: true
                                text: timerTypeCard.title
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: Font.Medium
                                color: Appearance.colors.colOnLayer0
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: timerTypeCard.subtitle
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colSubtext
                            }
                        }

                        MaterialSymbol {
                            Layout.alignment: Qt.AlignVCenter
                            text: "chevron_right"
                            iconSize: 20
                            fill: 1
                            color: Appearance.colors.colSubtext
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
                text: "timer"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Timers")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }
        }

        Revealer {
            reveal: Timer.available
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                spacing: 4

                Loader {
                    sourceComponent: timerTypeCard
                    Binding { target: item; property: "title"; value: Translation.tr("Pomodoro") }
                    Binding { target: item; property: "subtitle"; value: Translation.tr("25 min focus session") }
                    Binding { target: item; property: "icon"; value: "timer" }
                    Binding { target: item; property: "color"; value: Appearance.colors.colPrimary }
                    Binding { target: item; property: "onClicked"; value: Timer.startPomodoro() }
                }

                Loader {
                    sourceComponent: timerTypeCard
                    Binding { target: item; property: "title"; value: Translation.tr("Short Break") }
                    Binding { target: item; property: "subtitle"; value: Translation.tr("5 min break") }
                    Binding { target: item; property: "icon"; value: "coffee" }
                    Binding { target: item; property: "color"; value: Appearance.colors.colSecondary }
                    Binding { target: item; property: "onClicked"; value: Timer.startShortBreak() }
                }

                Loader {
                    sourceComponent: timerTypeCard
                    Binding { target: item; property: "title"; value: Translation.tr("Long Break") }
                    Binding { target: item; property: "subtitle"; value: Translation.tr("15 min break") }
                    Binding { target: item; property: "icon"; value: "spa" }
                    Binding { target: item; property: "color"; value: Appearance.colors.colTertiary }
                    Binding { target: item; property: "onClicked"; value: Timer.startLongBreak() }
                }
            }
        }

        Revealer {
            reveal: !Timer.available
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
                    text: Translation.tr("Timer unavailable")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colSubtext
                }
            }
        }
    }
}
