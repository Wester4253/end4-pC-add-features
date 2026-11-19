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

    property string newNoteText: ""
    property int editingNoteId: -1
    property string editingNoteContent: ""

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
                text: "notes"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Notes")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: `${Notes.list.length}`
                font.pixelSize: Appearance.font.pixelSize.smaller
                font.weight: Font.Bold
                font.features: { "tnum": 1 }
                color: Appearance.colors.colSubtext
            }
        }

        // Add/Edit note input
        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            implicitHeight: root.editingNoteId >= 0 ? 80 : 44
            radius: 10
            color: Appearance.colors.colLayer1
            border.width: 1
            border.color: Appearance.colors.colOutlineVariant

            ColumnLayout {
                anchors.fill: parent
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                Layout.topMargin: 8
                Layout.bottomMargin: 8
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    MaterialSymbol {
                        Layout.alignment: Qt.AlignVCenter
                        text: root.editingNoteId >= 0 ? "edit" : "add"
                        iconSize: 20
                        fill: 1
                        color: Appearance.colors.colPrimary
                    }

                    TextField {
                        id: noteInputField
                        Layout.fillWidth: true
                        background: null
                        font.pixelSize: Appearance.font.pixelSize.normal
                        color: Appearance.colors.colOnLayer0
                        placeholderText: root.editingNoteId >= 0 ? Translation.tr("Edit note...") : Translation.tr("Add a note...")
                        text: root.editingNoteId >= 0 ? root.editingNoteContent : root.newNoteText
                        onTextChanged: {
                            if (root.editingNoteId >= 0) {
                                root.editingNoteContent = text;
                            } else {
                                root.newNoteText = text;
                            }
                        }
                        onAccepted: {
                            if (text.trim()) {
                                if (root.editingNoteId >= 0) {
                                    Notes.updateNote(root.editingNoteId, text.trim());
                                    root.editingNoteId = -1;
                                    root.editingNoteContent = "";
                                } else {
                                    Notes.addNote(text.trim());
                                }
                                root.newNoteText = "";
                            }
                        }
                    }
                }

                Revealer {
                    reveal: root.editingNoteId >= 0
                    Layout.fillWidth: true

                    RowLayout {
                        spacing: 8

                        MouseArea {
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.editingNoteId = -1;
                                root.editingNoteContent = "";
                            }
                            MaterialSymbol {
                                Layout.alignment: Qt.AlignVCenter
                                text: "close"
                                iconSize: 18
                                fill: 1
                                color: Appearance.colors.colSubtext
                            }
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignVCenter
                            text: Translation.tr("Editing note")
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colPrimary
                        }
                    }
                }
            }
        }

        // Notes list
        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            spacing: 4

            Revealer {
                reveal: Notes.list.length > 0

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Repeater {
                        model: Notes.list
                        delegate: NoteItem {
                            Layout.fillWidth: true
                            noteData: modelData
                        }
                    }
                }
            }

            Revealer {
                reveal: Notes.list.length === 0
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
                            text: "notes"
                            iconSize: 32
                            fill: 1
                            color: Appearance.colors.colSubtext
                        }

                        StyledText {
                            text: Translation.tr("No notes yet")
                            font.pixelSize: Appearance.font.pixelSize.normal
                            color: Appearance.colors.colSubtext
                        }

                        StyledText {
                            text: Translation.tr("Add your first note above")
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colSubtext
                        }
                    }
                }
            }
        }
    }
}

// Note item component
Item {
    id: NoteItem
    required property var noteData
    Layout.fillWidth: true
    implicitHeight: 64

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

            // Note icon
            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 40
                implicitHeight: 40
                radius: 20
                color: Appearance.colors.colSecondary
                opacity: 0.15

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: "notes"
                    iconSize: 20
                    fill: 1
                    color: Appearance.colors.colSecondary
                }
            }

            // Note content
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    Layout.fillWidth: true
                    text: noteData.content
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Medium
                    color: Appearance.colors.colOnLayer0
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: noteData.attachments && noteData.attachments.length > 0
                        ? Translation.tr("%1 attachment(s)").arg(noteData.attachments.length)
                        : ""
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }

                StyledText {
                    Layout.fillWidth: true
                    text: Qt.formatDateTime(new Date(noteData.createdAt), "MMM d, HH:mm")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }
            }

            // Actions
            RowLayout {
                spacing: 4

                // Edit button
                MouseArea {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.editingNoteId = noteData.id;
                        root.editingNoteContent = noteData.content;
                    }
                    hoverEnabled: true
                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "edit"
                        iconSize: 18
                        fill: 1
                        color: Appearance.colors.colPrimary
                    }
                }

                // Delete button
                MouseArea {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Notes.deleteNote(noteData.id);
                    }
                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "delete"
                        iconSize: 18
                        fill: 1
                        color: Appearance.colors.colError
                    }
                }
            }
        }
    }
}