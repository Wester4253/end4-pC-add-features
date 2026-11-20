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

    property string searchText: ""
    property var filteredEntries: Cliphist.entries

    function updateFilter() {
        if (root.searchText.trim() === "") {
            root.filteredEntries = Cliphist.entries.slice(0, 20);
        } else {
            root.filteredEntries = Cliphist.fuzzyQuery(root.searchText).slice(0, 20);
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
                text: "content_copy"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Clipboard History")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Cliphist.refresh();
                    root.updateFilter();
                }
                MaterialSymbol {
                    Layout.alignment: Qt.AlignVCenter
                    text: "refresh"
                    iconSize: 20
                    fill: 1
                    color: Appearance.colors.colSubtext
                }
            }

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    GlobalStates.openSettingsAt("dashboard", Translation.tr("Search"), "clipboard", "");
                    root.di.expanded = false;
                }
                MaterialSymbol {
                    Layout.alignment: Qt.AlignVCenter
                    text: "settings"
                    iconSize: 20
                    fill: 1
                    color: Appearance.colors.colSubtext
                }
            }
        }

        // Search field
        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            implicitHeight: 40
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
                    text: "search"
                    iconSize: 20
                    fill: 1
                    color: Appearance.colors.colSubtext
                }

                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    background: null
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colOnLayer0
                    placeholderText: Translation.tr("Search clipboard...")
                    text: root.searchText
                    onTextChanged: {
                        root.searchText = text;
                        root.updateFilter();
                    }
                }
            }
        }

        // Entries list
        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            spacing: 4

            Revealer {
                reveal: root.filteredEntries.length > 0

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Repeater {
                        model: root.filteredEntries
                        delegate: ClipboardEntryCard {
                            Layout.fillWidth: true
                            entry: modelData
                            index: index
                        }
                    }
                }
            }

            Revealer {
                reveal: root.filteredEntries.length === 0
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
                        text: root.searchText ? Translation.tr("No matches") : Translation.tr("Clipboard empty")
                        font.pixelSize: Appearance.font.pixelSize.normal
                        color: Appearance.colors.colSubtext
                    }
                }
            }
        }
    }
}

// Clipboard entry card
Item {
    id: ClipboardEntryCard
    required property string entry
    required property int index
    Layout.fillWidth: true
    implicitHeight: 48

    property bool isImage: Cliphist.entryIsImage(entry)
    property string entryId: Cliphist.entryId(entry)
    property string entryText: Cliphist.entryText(entry)
    property bool isPinned: Cliphist.isPinned(entry)

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

            // Icon
            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 36
                implicitHeight: 36
                radius: 18
                color: root.isPinned ? Appearance.colors.colWarning : Appearance.colors.colPrimary
                opacity: 0.15

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: root.isImage ? "image" : (root.isPinned ? "push_pin" : "content_copy")
                    iconSize: 18
                    fill: 1
                    color: root.isPinned ? Appearance.colors.colWarning : Appearance.colors.colPrimary
                }
            }

            // Content
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    Layout.fillWidth: true
                    text: root.isImage ? Translation.tr("[Image: %1]").arg(entryText) : entryText
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.family: "monospace"
                    color: Appearance.colors.colOnLayer0
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: root.isPinned ? Translation.tr("Pinned") : Translation.tr("Press to paste")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }
            }

            // Actions
            RowLayout {
                spacing: 4

                // Pin toggle
                MouseArea {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Cliphist.togglePin(entry)
                    hoverEnabled: true
                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: root.isPinned ? "push_pin" : "push_pin"
                        iconSize: 18
                        fill: root.isPinned ? 1 : 0
                        color: root.isPinned ? Appearance.colors.colWarning : Appearance.colors.colSubtext
                    }
                }

                // Paste
                MouseArea {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Cliphist.pasteEntry(entry);
                        root.di.expanded = false;
                    }
                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "content_paste"
                        iconSize: 18
                        fill: 1
                        color: Appearance.colors.colSubtext
                    }
                }
            }
        }
    }
}