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
    property bool showFavoritesOnly: false

    function updateFilter() {
        var base = Cliphist.entries;
        if (root.showFavoritesOnly) {
            base = base.filter(e => Cliphist.isFavorite(e));
        }
        if (root.searchText.trim() === "") {
            root.filteredEntries = base.slice(0, 30);
        } else {
            root.filteredEntries = Cliphist.fuzzyQuery(root.searchText, base).slice(0, 30);
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

            // Favorites filter toggle
            MouseArea {
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.showFavoritesOnly = !root.showFavoritesOnly;
                    root.updateFilter();
                }
                hoverEnabled: true
                MaterialSymbol {
                    Layout.alignment: Qt.AlignVCenter
                    text: "bookmark"
                    iconSize: 20
                    fill: root.showFavoritesOnly ? 1 : 0
                    color: root.showFavoritesOnly ? Appearance.colors.colWarning : Appearance.colors.colSubtext
                }
            }

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

                // Clear search
                MouseArea {
                    Layout.alignment: Qt.AlignVCenter
                    visible: root.searchText !== ""
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        searchField.text = "";
                        root.searchText = "";
                        root.updateFilter();
                    }
                    hoverEnabled: true
                    MaterialSymbol {
                        Layout.alignment: Qt.AlignVCenter
                        text: "close"
                        iconSize: 20
                        fill: 1
                        color: Appearance.colors.colSubtext
                    }
                }
            }
        }

        // Stats bar
        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            implicitHeight: 28
            radius: 6
            color: Appearance.colors.colLayer1
            border.width: 1
            border.color: Appearance.colors.colOutlineVariant
            opacity: 0.6

            RowLayout {
                anchors.fill: parent
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                spacing: 16

                StyledText {
                    text: Translation.tr("Entries: %1").arg(root.filteredEntries.length)
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }

                StyledText {
                    text: Translation.tr("Total: %1").arg(Cliphist.entries.length)
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }

                StyledText {
                    text: Translation.tr("Favorites: %1").arg(Cliphist.favorites.length)
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colWarning
                }

                Item { Layout.fillWidth: true }

                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Cliphist.clearAll();
                        root.updateFilter();
                    }
                    hoverEnabled: true
                    MaterialSymbol {
                        Layout.alignment: Qt.AlignVCenter
                        text: "delete_sweep"
                        iconSize: 18
                        fill: 1
                        color: Appearance.colors.colError
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
                            di: root.di
                        }
                    }
                }
            }

            Revealer {
                reveal: root.filteredEntries.length === 0
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
                            text: root.showFavoritesOnly ? "bookmark_remove" : (root.searchText ? "search_off" : "content_copy")
                            iconSize: 32
                            fill: 1
                            color: Appearance.colors.colSubtext
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: root.showFavoritesOnly ? Translation.tr("No favorites yet") : (root.searchText ? Translation.tr("No matches") : Translation.tr("Clipboard empty"))
                            font.pixelSize: Appearance.font.pixelSize.normal
                            color: Appearance.colors.colSubtext
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            visible: root.showFavoritesOnly
                            text: Translation.tr("Star entries to add them here")
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colSubtext
                        }
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
    required property Item di
    Layout.fillWidth: true
    implicitHeight: 52

    property bool isImage: Cliphist.entryIsImage(entry)
    property string entryId: Cliphist.entryId(entry)
    property string entryText: Cliphist.entryText(entry)
    property bool isPinned: Cliphist.isPinned(entry)
    property bool isFavorite: Cliphist.isFavorite(entry)

    // Truncated text for display
    property string displayText: {
        var t = entryText;
        if (t.length > 120) t = t.substring(0, 120) + "…";
        return t;
    }

    Rectangle {
        id: cardBg
        anchors.fill: parent
        radius: 10
        color: root.isFavorite ? Qt.rgba(Appearance.colors.colWarning.r, Appearance.colors.colWarning.g, Appearance.colors.colWarning.b, 0.08) : Appearance.colors.colLayer1
        border.width: root.isFavorite ? 2 : 1
        border.color: root.isFavorite ? Appearance.colors.colWarning : Appearance.colors.colOutlineVariant

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
                color: root.isFavorite ? Appearance.colors.colWarning : (root.isPinned ? Appearance.colors.colWarning : Appearance.colors.colPrimary)
                opacity: 0.15

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: root.isImage ? "image" : (root.isFavorite ? "bookmark" : (root.isPinned ? "push_pin" : "content_copy"))
                    iconSize: 18
                    fill: 1
                    color: root.isFavorite ? Appearance.colors.colWarning : (root.isPinned ? Appearance.colors.colWarning : Appearance.colors.colPrimary)
                }
            }

            // Content
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    StyledText {
                        Layout.fillWidth: true
                        text: root.isImage ? Translation.tr("[Image: %1]").arg(displayText) : displayText
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        font.family: "monospace"
                        color: Appearance.colors.colOnLayer0
                        elide: Text.ElideRight
                    }

                    // Favorite badge
                    Rectangle {
                        visible: root.isFavorite
                        radius: 8
                        color: Appearance.colors.colWarning
                        implicitHeight: 18
                        implicitWidth: favoriteText.implicitWidth + 10

                        StyledText {
                            id: favoriteText
                            anchors.centerIn: parent
                            text: Translation.tr("★ Favorite")
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            font.weight: Font.Medium
                            color: Appearance.colors.colOnError
                        }
                    }

                    // Pinned badge
                    Rectangle {
                        visible: root.isPinned && !root.isFavorite
                        radius: 8
                        color: Appearance.colors.colWarning
                        implicitHeight: 18
                        implicitWidth: pinnedText.implicitWidth + 10

                        StyledText {
                            id: pinnedText
                            anchors.centerIn: parent
                            text: Translation.tr("📌 Pinned")
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            font.weight: Font.Medium
                            color: Appearance.colors.colOnError
                        }
                    }
                }

                StyledText {
                    Layout.fillWidth: true
                    text: root.isFavorite ? Translation.tr("Favorite • Click to paste") : (root.isPinned ? Translation.tr("Pinned • Click to paste") : Translation.tr("Press to paste"))
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: root.isFavorite ? Appearance.colors.colWarning : (root.isPinned ? Appearance.colors.colWarning : Appearance.colors.colSubtext)
                }
            }

            // Actions
            RowLayout {
                spacing: 4

                // Favorite toggle
                MouseArea {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Cliphist.toggleFavorite(entry)
                    hoverEnabled: true
                    tooltip: root.isFavorite ? Translation.tr("Remove from favorites") : Translation.tr("Add to favorites")

                    Rectangle {
                        anchors.centerIn: parent
                        width: 32
                        height: 32
                        radius: 16
                        color: root.isFavorite ? Qt.rgba(Appearance.colors.colWarning.r, Appearance.colors.colWarning.g, Appearance.colors.colWarning.b, 0.15) : "transparent"
                        border.width: root.isFavorite ? 2 : 1
                        border.color: root.isFavorite ? Appearance.colors.colWarning : Appearance.colors.colOutlineVariant

                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "bookmark"
                            iconSize: 18
                            fill: root.isFavorite ? 1 : 0
                            color: root.isFavorite ? Appearance.colors.colWarning : Appearance.colors.colSubtext
                        }
                    }
                }

                // Pin toggle (legacy)
                MouseArea {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Cliphist.togglePin(entry)
                    hoverEnabled: true
                    tooltip: root.isPinned ? Translation.tr("Unpin") : Translation.tr("Pin")

                    Rectangle {
                        anchors.centerIn: parent
                        width: 32
                        height: 32
                        radius: 16
                        color: root.isPinned ? Qt.rgba(Appearance.colors.colWarning.r, Appearance.colors.colWarning.g, Appearance.colors.colWarning.b, 0.15) : "transparent"
                        border.width: root.isPinned ? 2 : 1
                        border.color: root.isPinned ? Appearance.colors.colWarning : Appearance.colors.colOutlineVariant

                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "push_pin"
                            iconSize: 18
                            fill: root.isPinned ? 1 : 0
                            color: root.isPinned ? Appearance.colors.colWarning : Appearance.colors.colSubtext
                        }
                    }
                }

                // Paste
                MouseArea {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Cliphist.pasteEntry(entry);
                        di.expanded = false;
                    }
                    hoverEnabled: true
                    tooltip: Translation.tr("Paste")

                    Rectangle {
                        anchors.centerIn: parent
                        width: 32
                        height: 32
                        radius: 16
                        color: Qt.rgba(Appearance.colors.colPrimary.r, Appearance.colors.colPrimary.g, Appearance.colors.colPrimary.b, 0.15)
                        border.width: 1
                        border.color: Appearance.colors.colOutlineVariant

                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "content_paste"
                            iconSize: 18
                            fill: 1
                            color: Appearance.colors.colPrimary
                        }
                    }
                }

                // Delete
                MouseArea {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Cliphist.deleteEntry(entry);
                    }
                    hoverEnabled: true
                    tooltip: Translation.tr("Delete")

                    Rectangle {
                        anchors.centerIn: parent
                        width: 32
                        height: 32
                        radius: 16
                        color: Qt.rgba(Appearance.colors.colError.r, Appearance.colors.colError.g, Appearance.colors.colError.b, 0.15)
                        border.width: 1
                        border.color: Appearance.colors.colOutlineVariant

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
}