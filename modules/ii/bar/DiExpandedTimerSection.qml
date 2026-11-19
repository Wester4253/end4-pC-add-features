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

    readonly property string engagedTimerKind: root.di.engagedTimerKind
    readonly property bool hasActiveTimer: root.di.hasActiveTimer

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
                text: root.di.timerIcon()
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
        }

        // Active timer (large)
        Revealer {
            reveal: root.hasActiveTimer
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16

            Rectangle {
                Layout.fillWidth: true
                radius: 16
                color: Appearance.colors.colLayer1
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant

                ColumnLayout {
                    anchors.fill: parent
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.topMargin: 20
                    Layout.bottomMargin: 20
                    spacing: 12

                    // Timer type badge
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            implicitHeight: 28
                            radius: 14
                            color: Appearance.colors.colPrimary
                            opacity: 0.15

                            StyledText {
                                anchors.centerIn: parent
                                Layout.leftMargin: 12
                                Layout.rightMargin: 12
                                text: {
                                    switch (root.engagedTimerKind) {
                                        case "pomodoro": return TimerService.pomodoroBreak ? Translation.tr("Break") : Translation.tr("Focus");
                                        case "countdown": return Translation.tr("Countdown");
                                        case "stopwatch": return Translation.tr("Stopwatch");
                                        default: return "";
                                    }
                                }
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.weight: Font.Medium
                                color: Appearance.colors.colPrimary
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Current session count for pomodoro
                        Revealer {
                            reveal: root.engagedTimerKind === "pomodoro"
                            StyledText {
                                text: `${Translation.tr("Session")} ${TimerService.pomodoroSessionsCompleted + 1}`
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colSubtext
                            }
                        }
                    }

                    // Large timer display
                    StyledText {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        text: root.di.timerValueText()
                        font.pixelSize: 48
                        font.weight: Font.Bold
                        font.features: { "tnum": 1 }
                        color: Appearance.colors.colOnLayer0
                    }

                    // Progress bar for pomodoro/countdown
                    Revealer {
                        reveal: root.engagedTimerKind === "pomodoro" || root.engagedTimerKind === "countdown"
                        StyledProgressBar {
                            Layout.fillWidth: true
                            valueBarWidth: 300
                            value: {
                                switch (root.engagedTimerKind) {
                                    case "pomodoro":
                                        const total = TimerService.pomodoroBreak ? TimerService.pomodoroBreakDuration : TimerService.pomodoroWorkDuration;
                                        return total > 0 ? 1 - (TimerService.pomodoroSecondsLeft / total) : 0;
                                    case "countdown":
                                        return TimerService.countdownDuration > 0 ? 1 - (TimerService.countdownSecondsLeft / TimerService.countdownDuration) : 0;
                                    default: return 0;
                                }
                            }
                            color: Appearance.colors.colPrimary
                        }
                    }

                    // Controls
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16

                        MaterialSymbolButton {
                            text: "replay"
                            iconSize: 24
                            color: Appearance.colors.colSubtext
                            onClicked: root.di.resetActiveTimer()
                        }

                        MaterialSymbolButton {
                            text: TimerService.pomodoroRunning || TimerService.countdownRunning || TimerService.stopwatchRunning ? "pause_circle" : "play_circle"
                            iconSize: 36
                            fill: 1
                            color: Appearance.colors.colPrimary
                            onClicked: root.di.toggleActiveTimer()
                        }

                        MaterialSymbolButton {
                            text: "stop"
                            iconSize: 24
                            color: Appearance.colors.colError
                            onClicked: {
                                switch (root.engagedTimerKind) {
                                    case "pomodoro": TimerService.resetPomodoro(); break;
                                    case "countdown": TimerService.resetCountdown(); break;
                                    case "stopwatch": TimerService.stopwatchReset(); break;
                                }
                            }
                        }
                    }
                }
            }
        }

        // Timer type selectors (when no active timer)
        Revealer {
            reveal: !root.hasActiveTimer
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                spacing: 8

                // Pomodoro
                TimerTypeCard {
                    Layout.fillWidth: true
                    title: Translation.tr("Pomodoro")
                    subtitle: Translation.tr("%1 min work / %2 min break").arg(TimerService.pomodoroWorkDuration / 60).arg(TimerService.pomodoroBreakDuration / 60)
                    icon: "visibility"
                    color: Appearance.colors.colPrimary
                    onClicked: {
                        TimerService.resetPomodoro();
                        TimerService.togglePomodoro();
                        root.di.expanded = false;
                    }
                }

                // Countdown
                TimerTypeCard {
                    Layout.fillWidth: true
                    title: Translation.tr("Countdown")
                    subtitle: Translation.tr("Set a custom timer")
                    icon: "hourglass_top"
                    color: Appearance.colors.colSecondary
                    onClicked: {
                        GlobalStates.openSettingsAt("dashboard", Translation.tr("Timers"), "countdown", "");
                        root.di.expanded = false;
                    }
                }

                // Stopwatch
                TimerTypeCard {
                    Layout.fillWidth: true
                    title: Translation.tr("Stopwatch")
                    subtitle: Translation.tr("Track elapsed time")
                    icon: "timer"
                    color: Appearance.colors.colTertiary
                    onClicked: {
                        TimerService.toggleStopwatch();
                        root.di.expanded = false;
                    }
                }
            }
        }
    }
}

// Timer type selection card
Item {
    id: TimerTypeCard
    required property string title
    required property string subtitle
    required property string icon
    required property color color
    required property var onClicked
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