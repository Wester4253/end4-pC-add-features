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

    // Week row component
    Component {
        id: weekRow
        Item {
            property var weekIndex: modelData
            required property var currentMonth
            required property var today
            required property var selectedDate
            required property var onDateClicked

            Layout.fillWidth: true
            implicitHeight: 36

            property var firstDay: firstDayOfMonth(currentMonth)
            property var daysInMonth: daysInMonth(currentMonth)
            property var startDate: weekIndex * 7 - firstDay + 1

            function firstDayOfMonth(date) { return new Date(date.getFullYear(), date.getMonth(), 1).getDay() }
            function daysInMonth(date) { return new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate() }
            function isToday(date) { return date.getDate() === today.getDate() && date.getMonth() === today.getMonth() && date.getFullYear() === today.getFullYear() }
            function isSelected(date) { return date.getDate() === selectedDate.getDate() && date.getMonth() === selectedDate.getMonth() && date.getFullYear() === selectedDate.getFullYear() }
            function isCurrentMonth(date) { return date.getMonth() === currentMonth.getMonth() }

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Repeater {
                    model: 7
                    delegate: dayCell
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    dayIndex: index
                    weekIndex: root.weekIndex
                    startDate: root.startDate
                    daysInMonth: root.daysInMonth
                    currentMonth: root.currentMonth
                    today: root.today
                    selectedDate: root.selectedDate
                    onClicked: root.onDateClicked
                }
            }
        }
    }

    // Day cell component
    Component {
        id: dayCell
        Item {
            property int dayIndex: modelData
            required property int weekIndex
            required property int startDate
            required property int daysInMonth
            required property var currentMonth
            required property var today
            required property var selectedDate
            required property var onClicked

            implicitHeight: 36

            property int dayNumber: startDate + dayIndex
            property bool validDay: dayNumber >= 1 && dayNumber <= daysInMonth
            property var dateObj: validDay ? new Date(currentMonth.getFullYear(), currentMonth.getMonth(), dayNumber) : null
            property bool isToday: validDay ? (dateObj.getDate() === today.getDate() && dateObj.getMonth() === today.getMonth() && dateObj.getFullYear() === today.getFullYear()) : false
            property bool isSelected: validDay ? (dateObj.getDate() === selectedDate.getDate() && dateObj.getMonth() === selectedDate.getMonth() && dateObj.getFullYear() === selectedDate.getFullYear()) : false

            Rectangle {
                anchors.fill: parent
                radius: 6
                color: isSelected ? Appearance.colors.colPrimary : (isToday ? Appearance.colors.colLayer1 : "transparent")
                border.width: isToday ? 1 : 0
                border.color: Appearance.colors.colPrimary

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 2

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: validDay ? dayNumber : ""
                        font.pixelSize: Appearance.font.pixelSize.normal
                        color: isSelected ? Appearance.colors.colOnPrimary : Appearance.colors.colOnLayer0
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: validDay
                    onClicked: onClicked(dateObj)
                }
            }
        }
    }

    property var today: new Date()
    property var selectedDate: new Date()
    property var currentMonth: new Date(today.getFullYear(), today.getMonth(), 1)

    function daysInMonth(date) {
        return new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate()
    }
    function firstDayOfMonth(date) {
        return new Date(date.getFullYear(), date.getMonth(), 1).getDay()
    }
    function formatMonth(date) {
        return Qt.formatDateTime(date, "MMMM yyyy")
    }
    function prevMonth() { currentMonth = new Date(currentMonth.getFullYear(), currentMonth.getMonth() - 1, 1) }
    function nextMonth() { currentMonth = new Date(currentMonth.getFullYear(), currentMonth.getMonth() + 1, 1) }
    function isToday(date) {
        return date.getDate() === today.getDate() && date.getMonth() === today.getMonth() && date.getFullYear() === today.getFullYear()
    }
    function isSelected(date) {
        return date.getDate() === selectedDate.getDate() && date.getMonth() === selectedDate.getMonth() && date.getFullYear() === selectedDate.getFullYear()
    }
    function hasEvents(date) {
        return false
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
                text: "calendar_month"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Calendar")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }
        }

        // Month header with navigation
        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            radius: 12
            color: Appearance.colors.colLayer1
            border.width: 1
            border.color: Appearance.colors.colOutlineVariant

            RowLayout {
                anchors.fill: parent
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                spacing: 8

                MouseArea {
                    Layout.alignment: Qt.AlignVCenter
                    implicitWidth: 36
                    implicitHeight: 36
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.prevMonth()
                    hoverEnabled: true
                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "chevron_left"
                        iconSize: 24
                        fill: 1
                        color: Appearance.colors.colOnLayer0
                    }
                }

                StyledText {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    text: root.formatMonth(root.currentMonth)
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Medium
                    color: Appearance.colors.colOnLayer0
                }

                MouseArea {
                    Layout.alignment: Qt.AlignVCenter
                    implicitWidth: 36
                    implicitHeight: 36
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.nextMonth()
                    hoverEnabled: true
                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "chevron_right"
                        iconSize: 24
                        fill: 1
                        color: Appearance.colors.colOnLayer0
                    }
                }
            }
        }

        // Weekday headers
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            spacing: 0

            Repeater {
                model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                delegate: StyledText {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    text: modelData
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.weight: Font.Medium
                    color: Appearance.colors.colSubtext
                }
            }
        }

        // Calendar grid
        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            spacing: 2

            Repeater {
                model: 6 // Max 6 weeks
                delegate: weekRow
                currentMonth: root.currentMonth
                today: root.today
                selectedDate: root.selectedDate
                onDateClicked: (date) => { root.selectedDate = date }
            }
        }

        // Events for selected date
        Revealer {
            reveal: root.selectedDate !== root.today || true // Always show for now
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
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        MaterialSymbol {
                            Layout.alignment: Qt.AlignVCenter
                            text: "event"
                            iconSize: 20
                            fill: 1
                            color: Appearance.colors.colPrimary
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignVCenter
                            text: Translation.tr("Events for %1").arg(Qt.formatDateTime(root.selectedDate, "MMMM d, yyyy"))
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: Font.Medium
                            color: Appearance.colors.colOnLayer0
                        }
                    }

                    // Placeholder for events - would integrate with a calendar service
                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("No events scheduled")
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colSubtext
                    }

                    MouseArea {
                        Layout.fillWidth: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            GlobalStates.openSettingsAt("dashboard", Translation.tr("Calendar"), "", "")
                            root.di.expanded = false
                        }
                        StyledText {
                            anchors.centerIn: parent
                            Layout.fillWidth: true
                            text: Translation.tr("Open Calendar settings")
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colPrimary
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }
        }
    }
}
