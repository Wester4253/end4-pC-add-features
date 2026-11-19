import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

StyledPopup {
    id: root
    property var today: new Date()
    property bool showCalendar: false

    function usageColor(value) {
        if (value > 0.9) return Appearance.colors.colError
        if (value > 0.6) return Appearance.m3colors.m3tertiary
        return Appearance.colors.colPrimary
    }

    ColumnLayout {
        spacing: 8
        width: 340

        Row {
            width: parent.width

            StyledText {
                text: Qt.locale().toString(root.today, " MMMM")
                font.pixelSize: Appearance.font.pixelSize.huge
                font.weight: Font.Bold
                color: Appearance.colors.colOnLayer1
            }

            StyledText {
                text: " " + Qt.locale().toString(root.today, "yyyy")
                font.pixelSize: Appearance.font.pixelSize.huge
                color: Appearance.colors.colOnSurfaceVariant
            }
        }

        RowLayout {
            width: parent.width
            spacing: 4

            Repeater {
                model: 7
                delegate: Rectangle {
                    required property int index

                    readonly property var date: {
                        const today = root.today
                        const dow = today.getDay()
                        const d = new Date(today)
                        d.setDate(today.getDate() - dow + index)
                        return d
                    }
                    readonly property bool isToday: {
                        const t = root.today
                        return date.getDate()     === t.getDate() &&
                               date.getMonth()    === t.getMonth() &&
                               date.getFullYear() === t.getFullYear()
                    }

                    Layout.fillWidth: true
                    height: 56
                    radius: Appearance.rounding.normal
                    color: isToday
                        ? Appearance.colors.colPrimaryContainer
                        : Appearance.colors.colSurfaceContainerHigh

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: Qt.locale().toString(date, "ddd").slice(0, 2)
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: isToday
                                ? Appearance.colors.colPrimary
                                : Appearance.colors.colOnSurfaceVariant
                            font.weight: isToday ? Font.Bold : Font.Normal
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: date.getDate()
                            font.pixelSize: isToday
                                ? Appearance.font.pixelSize.normal
                                : Appearance.font.pixelSize.small
                            font.weight: isToday ? Font.Bold : Font.Normal
                            color: isToday
                                ? Appearance.colors.colPrimary
                                : Appearance.colors.colOnLayer1
                        }
                    }
                }
            }
        }

        // Calendar section (replaces uptime/todo when showCalendar is true)
        Revealer {
            reveal: root.showCalendar
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    StyledText {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.locale().toString(root.today, "MMMM yyyy")
                        font.pixelSize: Appearance.font.pixelSize.large
                        font.weight: Font.Bold
                        color: Appearance.colors.colOnLayer1
                    }

                    // Month navigation
                    RowLayout {
                        spacing: 8

                        MouseArea {
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                const d = new Date(root.today)
                                d.setMonth(d.getMonth() - 1)
                                root.today = d
                            }
                            MaterialSymbol {
                                Layout.alignment: Qt.AlignVCenter
                                text: "chevron_left"
                                iconSize: 20
                                fill: 1
                                color: Appearance.colors.colOnLayer0
                            }
                        }

                        MouseArea {
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                const d = new Date(root.today)
                                d.setMonth(d.getMonth() + 1)
                                root.today = d
                            }
                            MaterialSymbol {
                                Layout.alignment: Qt.AlignVCenter
                                text: "chevron_right"
                                iconSize: 20
                                fill: 1
                                color: Appearance.colors.colOnLayer0
                            }
                        }
                    }
                }

                // Weekday headers
                RowLayout {
                    Layout.fillWidth: true
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
                    spacing: 2

                    Repeater {
                        model: 6
                        delegate: WeekRow {
                            Layout.fillWidth: true
                            weekIndex: index
                            currentMonth: root.today
                            today: new Date()
                        }
                    }
                }

                // Back to main view
                MouseArea {
                    Layout.fillWidth: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.showCalendar = false

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 4

                        MaterialSymbol {
                            Layout.alignment: Qt.AlignVCenter
                            text: "arrow_back"
                            iconSize: 18
                            fill: 1
                            color: Appearance.colors.colPrimary
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignVCenter
                            text: Translation.tr("Back to clock")
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colPrimary
                        }
                    }
                }
            }
        }

        // Main content (uptime/todo) - hidden when calendar is shown
        Revealer {
            reveal: !root.showCalendar
            Layout.fillWidth: true

            Row {
                width: parent.width
                spacing: 6

                Column {
                    spacing: 2
                    anchors.verticalCenter: parent.verticalCenter

                    MaterialShapeWrappedMaterialSymbol {
                        shape: MaterialShape.Shape.Clover4Leaf
                        text: "checklist"
                        iconSize: Appearance.font.pixelSize.large
                        implicitSize: 36
                        color: Appearance.colors.colPrimaryContainer
                        colSymbol: Appearance.colors.colPrimary
                    }

                    StyledText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: `${Todo.list.filter(t => !t.done).length}`
                        font.pixelSize: Appearance.font.pixelSize.huge
                        font.weight: Font.Bold
                        color: Appearance.colors.colPrimary
                    }
                }

                Column {
                    width: parent.width - 36 - 6
                    spacing: 2

                    Repeater {
                        id: todoRepeater
                        model: Math.min(3, Todo.list.filter(t => !t.done).length)

                        delegate: Rectangle {
                            required property int index
                            readonly property var filteredList: Todo.list.filter(t => !t.done)
                            readonly property var todo: filteredList[filteredList.length - 1 - index]
                            readonly property int total: todoRepeater.count
                            readonly property bool isFirst: index === 0
                            readonly property bool isLast: index === total - 1
                            readonly property real bigRadius: Appearance.rounding.normal
                            readonly property real smallRadius: Appearance.rounding.unsharpenmore

                            width: parent.width
                            height: 32
                            topLeftRadius:     isFirst ? bigRadius : smallRadius
                            topRightRadius:    isFirst ? bigRadius : smallRadius
                            bottomLeftRadius:  isLast  ? bigRadius : smallRadius
                            bottomRightRadius: isLast  ? bigRadius : smallRadius
                            color: Appearance.colors.colSurfaceContainerHigh

                            StyledText {
                                anchors {
                                    left: parent.left
                                    leftMargin: 10
                                    verticalCenter: parent.verticalCenter
                                    right: parent.right
                                    rightMargin: 10
                                }
                                text: `    ${todo.content} `
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colOnLayer1
                                elide: Text.ElideRight
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 64
                        visible: Todo.list.filter(t => !t.done).length === 0
                        radius: Appearance.rounding.normal
                        color: Appearance.colors.colSurfaceContainerHigh

                        StyledText {
                            anchors.centerIn: parent
                            text: Translation.tr("No pending tasks")
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colOnLayer1
                        }
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 10
            color: "transparent"

            RowLayout {
                anchors.centerIn: parent
                spacing: 6

                MaterialSymbol {
                    text: "timelapse"
                    iconSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnSurfaceVariant
                }

                StyledText {
                    text: Translation.tr("System Uptime")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colOnSurfaceVariant
                }

                StyledText {
                    text: "•"
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colOnSurfaceVariant
                }

                StyledText {
                    text: DateTime.uptime
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colOnSurfaceVariant
                }
            }
        }
    }
}

// Week row component for calendar
Item {
    id: WeekRow
    required property int weekIndex
    required property var currentMonth
    required property var today

    Layout.fillWidth: true
    implicitHeight: 36

    property var firstDay: firstDayOfMonth(currentMonth)
    property var daysInMonth: daysInMonth(currentMonth)
    property var startDate: weekIndex * 7 - firstDay + 1

    function firstDayOfMonth(date) { return new Date(date.getFullYear(), date.getMonth(), 1).getDay() }
    function daysInMonth(date) { return new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate() }
    function isToday(date) { return date.getDate() === today.getDate() && date.getMonth() === today.getMonth() && date.getFullYear() === today.getFullYear() }
    function isCurrentMonth(date) { return date.getMonth() === currentMonth.getMonth() }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Repeater {
            model: 7
            delegate: DayCell {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                dayIndex: index
                weekIndex: root.weekIndex
                startDate: root.startDate
                daysInMonth: root.daysInMonth
                currentMonth: root.currentMonth
                today: root.today
            }
        }
    }
}

// Day cell component
Item {
    id: DayCell
    required property int dayIndex
    required property int weekIndex
    required property int startDate
    required property int daysInMonth
    required property var currentMonth
    required property var today

    implicitHeight: 36

    property int dayNumber: startDate + dayIndex
    property bool validDay: dayNumber >= 1 && dayNumber <= daysInMonth
    property var dateObj: validDay ? new Date(currentMonth.getFullYear(), currentMonth.getMonth(), dayNumber) : null
    property bool isToday: validDay ? (dateObj.getDate() === today.getDate() && dateObj.getMonth() === today.getMonth() && dateObj.getFullYear() === today.getFullYear()) : false
    property bool isCurrentMonth: validDay ? (dateObj.getMonth() === currentMonth.getMonth()) : false

    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        radius: 8
        color: isToday ? Appearance.colors.colPrimaryContainer : "transparent"

        MouseArea {
            anchors.fill: parent
            enabled: validDay
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: {
                root.today = dateObj
            }
            onEntered: parent.color = isToday ? Appearance.colors.colPrimaryContainer : Qt.lighter(Appearance.colors.colLayer1, 1.1)
            onExited: parent.color = isToday ? Appearance.colors.colPrimaryContainer : "transparent"
        }

        StyledText {
            anchors.centerIn: parent
            text: validDay ? dayNumber : ""
            font.pixelSize: Appearance.font.pixelSize.smaller
            font.weight: isToday ? Font.Bold : Font.Normal
            color: isCurrentMonth ? Appearance.colors.colOnLayer0 : Appearance.colors.colSubtext
        }
    }
}