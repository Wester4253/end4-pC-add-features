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

    property string newTaskText: ""

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
                text: "checklist"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Tasks")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }

            // Task counter
            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: `${Todo.list.filter(t => !t.done).length} / ${Todo.list.length}`
                font.pixelSize: Appearance.font.pixelSize.smaller
                font.weight: Font.Bold
                font.features: { "tnum": 1 }
                color: Appearance.colors.colSubtext
            }
        }

        // Add task input
        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            implicitHeight: 44
            radius: 10
            color: Appearance.colors.colLayer1
            border.width: 1
            border.color: Appearance.colors.colOutlineVariant

            RowLayout {
                anchors.fill: parent
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                spacing: 8

                MaterialSymbol {
                    Layout.alignment: Qt.AlignVCenter
                    text: "add"
                    iconSize: 20
                    fill: 1
                    color: Appearance.colors.colSubtext
                }

                TextField {
                    id: taskInputField
                    Layout.fillWidth: true
                    background: null
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colOnLayer0
                    placeholderText: Translation.tr("Add a task...")
                    text: root.newTaskText
                    onTextChanged: root.newTaskText = text
                    onAccepted: {
                        if (text.trim()) {
                            Todo.addTask(text.trim());
                            root.newTaskText = "";
                        }
                    }
                }
            }
        }

        // Task list
        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            spacing: 4

            Revealer {
                reveal: Todo.list.length > 0

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Repeater {
                        model: Todo.list
                        delegate: TodoItem {
                            Layout.fillWidth: true
                            taskData: modelData
                            taskIndex: index
                        }
                    }
                }
            }

            Revealer {
                reveal: Todo.list.length === 0
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 80
                    radius: 12
                    color: Appearance.colors.colLayer1
                    border.width: 1
                    border.color: Appearance.colors.colOutlineVariant
                    opacity: 0.5

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        MaterialSymbol {
                            Layout.alignment: Qt.AlignHCenter
                            text: "checklist"
                            iconSize: 32
                            fill: 1
                            color: Appearance.colors.colSubtext
                        }

                        StyledText {
                            text: Translation.tr("No tasks yet")
                            font.pixelSize: Appearance.font.pixelSize.normal
                            color: Appearance.colors.colSubtext
                        }

                        StyledText {
                            text: Translation.tr("Add your first task above")
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colSubtext
                        }
                    }
                }
            }
        }

        // Clear completed
        Revealer {
            reveal: Todo.list.some(t => t.done)
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    // Mark all done as undone or remove them
                    const doneIndices = Todo.list.map((t, i) => t.done ? i : -1).filter(i => i >= 0);
                    for (let i = doneIndices.length - 1; i >= 0; i--) {
                        Todo.list.splice(doneIndices[i], 1);
                    }
                    Todo.list = Todo.list.slice(0);
                }
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 40
                    radius: 10
                    color: Appearance.colors.colLayer1
                    border.width: 1
                    border.color: Appearance.colors.colOutlineVariant

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        MaterialSymbol {
                            Layout.alignment: Qt.AlignVCenter
                            text: "delete_sweep"
                            iconSize: 20
                            fill: 1
                            color: Appearance.colors.colWarning
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignVCenter
                            text: Translation.tr("Clear completed (%1)").arg(Todo.list.filter(t => t.done).length)
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            font.weight: Font.Medium
                            color: Appearance.colors.colWarning
                        }
                    }
                }
            }
        }
    }
}

// Task item component
Item {
    id: TodoItem
    required property var taskData
    required property int taskIndex
    Layout.fillWidth: true
    implicitHeight: 48

    property bool isDone: taskData.done === true

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: Appearance.colors.colLayer1
        border.width: 1
        border.color: Appearance.colors.colOutlineVariant

        RowLayout {
            anchors.fill: parent
            Layout.leftMargin: 12
            Layout.rightMargin: 12
            spacing: 12

            // Checkbox
            MouseArea {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (todoItem.taskData.done) {
                        Todo.markUnfinished(todoItem.taskIndex);
                    } else {
                        Todo.markDone(todoItem.taskIndex);
                    }
                }
                hoverEnabled: true
                Rectangle {
                    anchors.centerIn: parent
                    width: 24
                    height: 24
                    radius: 6
                    color: todoItem.isDone ? Appearance.colors.colPrimary : "transparent"
                    border.width: 2
                    border.color: todoItem.isDone ? Appearance.colors.colPrimary : Appearance.colors.colOutlineVariant

                    Revealer {
                        reveal: todoItem.isDone
                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "check"
                            iconSize: 16
                            fill: 1
                            color: Appearance.colors.colOnPrimary
                        }
                    }
                }
            }

            // Task content
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    Layout.fillWidth: true
                    text: todoItem.taskData.content
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: todoItem.isDone ? Font.Normal : Font.Medium
                    color: todoItem.isDone ? Appearance.colors.colSubtext : Appearance.colors.colOnLayer0
                    elide: Text.ElideRight
                    textFormat: todoItem.isDone ? Text.PlainText : Text.PlainText
                    // Strikethrough for done tasks
                    font.strikeout: todoItem.isDone
                }
            }

            // Delete button
            MouseArea {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Todo.list.splice(todoItem.taskIndex, 1);
                    Todo.list = Todo.list.slice(0);
                }
                hoverEnabled: true
                MaterialSymbol {
                    anchors.centerIn: parent
                    text: "delete"
                    iconSize: 18
                    fill: 1
                    color: Appearance.colors.colSubtext
                }
            }
        }
    }
}