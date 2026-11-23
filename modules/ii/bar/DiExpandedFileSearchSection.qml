commit 9b7bbb176aa8218430097222dade56b613ab8806
Author: OttoAgent <noah.butterfeild@gmail.com>
Date:   Thu Nov 19 07:12:56 2026 +0000

    feat: Add File Search and Calculator sections to Dynamic Island
    
    - Added DiExpandedFileSearchSection.qml with Everything-style search (plocate/fd)
    - Added DiExpandedCalculatorSection.qml with safe Python eval and quick expressions
    - Added showFileSearch and showCalculator config options
    - Full settings integration in BarConfig and DashboardSettingsCatalog
    - Added scripts/search/everything-query.py for plocate/fd search
    - Updated DiExpanded.qml to include new sections

diff --git a/modules/ii/bar/DiExpandedFileSearchSection.qml b/modules/ii/bar/DiExpandedFileSearchSection.qml
new file mode 100644
index 00000000..fdae3d52
--- /dev/null
+++ b/modules/ii/bar/DiExpandedFileSearchSection.qml
@@ -0,0 +1,499 @@
+import QtQuick
+import QtQuick.Layouts
+import Quickshell
+import qs
+import qs.services
+import qs.modules.common
+import qs.modules.common.widgets
+
+Item {
+    id: root
+    required property Item di
+    Layout.fillWidth: true
+
+    property string searchQuery: ""
+    property var searchResults: []
+    property bool isSearching: false
+    property string searchMode: "name" // "name", "content", "type"
+    property string filterType: "all" // "all", "folders", "files", "images", "videos", "audio", "documents", "archives", "apps", "code"
+    property string sortBy: "relevance" // "relevance", "name", "size", "type", "modified"
+    property bool sortAscending: true
+
+    ColumnLayout {
+        Layout.fillWidth: true
+        spacing: 8
+
+        // Section header
+        RowLayout {
+            Layout.fillWidth: true
+            Layout.leftMargin: 16
+            Layout.rightMargin: 16
+            spacing: 8
+
+            MaterialSymbol {
+                Layout.alignment: Qt.AlignVCenter
+                text: "search"
+                iconSize: 20
+                fill: 1
+                color: Appearance.colors.colPrimary
+            }
+
+            StyledText {
+                Layout.alignment: Qt.AlignVCenter
+                text: Translation.tr("File Search")
+                font.pixelSize: Appearance.font.pixelSize.normal
+                font.weight: Font.Medium
+                color: Appearance.colors.colOnLayer0
+            }
+
+            Item { Layout.fillWidth: true }
+
+            // Clear button
+            Revealer {
+                reveal: root.searchQuery.length > 0
+                MouseArea {
+                    cursorShape: Qt.PointingHandCursor
+                    onClicked: { root.searchQuery = ""; root.searchResults = []; }
+                    MaterialSymbol {
+                        Layout.alignment: Qt.AlignVCenter
+                        text: "clear"
+                        iconSize: 20
+                        fill: 1
+                        color: Appearance.colors.colSubtext
+                    }
+                }
+            }
+        }
+
+        // Search field
+        Rectangle {
+            Layout.fillWidth: true
+            Layout.leftMargin: 16
+            Layout.rightMargin: 16
+            implicitHeight: 44
+            radius: 12
+            color: Appearance.colors.colLayer1
+            border.width: 1
+            border.color: Appearance.colors.colOutlineVariant
+
+            RowLayout {
+                anchors.fill: parent
+                Layout.leftMargin: 12
+                Layout.rightMargin: 12
+                spacing: 8
+
+                MaterialSymbol {
+                    Layout.alignment: Qt.AlignVCenter
+                    text: "search"
+                    iconSize: 20
+                    fill: 1
+                    color: Appearance.colors.colSubtext
+                }
+
+                TextField {
+                    id: searchField
+                    Layout.fillWidth: true
+                    background: null
+                    font.pixelSize: Appearance.font.pixelSize.normal
+                    color: Appearance.colors.colOnLayer0
+                    placeholderText: Translation.tr("Search files... (# for everything, @ for content, ! for type)")
+                    text: root.searchQuery
+                    onTextChanged: {
+                        root.searchQuery = text;
+                        debounceTimer.restart();
+                    }
+                }
+
+                Revealer {
+                    reveal: root.isSearching
+                    BusySpinner {
+                        Layout.alignment: Qt.AlignVCenter
+                        size: 20
+                    }
+                }
+            }
+        }
+
+        // Toolbar with sort/filter
+        Revealer {
+            reveal: root.searchQuery.length > 0
+            Layout.fillWidth: true
+            Layout.leftMargin: 16
+            Layout.rightMargin: 16
+
+            Rectangle {
+                Layout.fillWidth: true
+                radius: 10
+                color: Appearance.colors.colLayer1
+                border.width: 1
+                border.color: Appearance.colors.colOutlineVariant
+
+                ColumnLayout {
+                    anchors.fill: parent
+                    Layout.leftMargin: 8
+                    Layout.rightMargin: 8
+                    Layout.topMargin: 8
+                    Layout.bottomMargin: 8
+                    spacing: 8
+
+                    // Sort row
+                    RowLayout {
+                        Layout.fillWidth: true
+                        spacing: 8
+
+                        StyledText {
+                            Layout.alignment: Qt.AlignVCenter
+                            text: Translation.tr("Sort:")
+                            font.pixelSize: Appearance.font.pixelSize.smaller
+                            color: Appearance.colors.colSubtext
+                        }
+
+                        ConfigComboBox {
+                            currentValue: root.sortBy
+                            onSelected: newValue => { root.sortBy = newValue; performSearch(); }
+                            options: [
+                                { displayName: Translation.tr("Relevance"), icon: "recommend", value: "relevance" },
+                                { displayName: Translation.tr("Name"), icon: "sort_by_alpha", value: "name" },
+                                { displayName: Translation.tr("Size"), icon: "storage", value: "size" },
+                                { displayName: Translation.tr("Type"), icon: "category", value: "type" },
+                                { displayName: Translation.tr("Modified"), icon: "schedule", value: "modified" }
+                            ]
+                        }
+
+                        MouseArea {
+                            cursorShape: Qt.PointingHandCursor
+                            onClicked: { root.sortAscending = !root.sortAscending; performSearch(); }
+                            MaterialSymbol {
+                                Layout.alignment: Qt.AlignVCenter
+                                text: root.sortAscending ? "arrow_upward" : "arrow_downward"
+                                iconSize: 20
+                                fill: 1
+                                color: Appearance.colors.colSubtext
+                            }
+                        }
+                    }
+
+                    // Filter row
+                    RowLayout {
+                        Layout.fillWidth: true
+                        spacing: 8
+
+                        StyledText {
+                            Layout.alignment: Qt.AlignVCenter
+                            text: Translation.tr("Filter:")
+                            font.pixelSize: Appearance.font.pixelSize.smaller
+                            color: Appearance.colors.colSubtext
+                        }
+
+                        ConfigComboBox {
+                            currentValue: root.filterType
+                            onSelected: newValue => { root.filterType = newValue; performSearch(); }
+                            options: [
+                                { displayName: Translation.tr("All"), icon: "apps", value: "all" },
+                                { displayName: Translation.tr("Folders"), icon: "folder", value: "folders" },
+                                { displayName: Translation.tr("Files"), icon: "insert_drive_file", value: "files" },
+                                { displayName: Translation.tr("Images"), icon: "image", value: "images" },
+                                { displayName: Translation.tr("Videos"), icon: "videocam", value: "videos" },
+                                { displayName: Translation.tr("Audio"), icon: "music_note", value: "audio" },
+                                { displayName: Translation.tr("Documents"), icon: "description", value: "documents" },
+                                { displayName: Translation.tr("Archives"), icon: "archive", value: "archives" },
+                                { displayName: Translation.tr("Apps"), icon: "smartphone", value: "apps" },
+                                { displayName: Translation.tr("Code"), icon: "code", value: "code" }
+                            ]
+                        }
+                    }
+
+                    // Search mode row
+                    RowLayout {
+                        Layout.fillWidth: true
+                        spacing: 8
+
+                        StyledText {
+                            Layout.alignment: Qt.AlignVCenter
+                            text: Translation.tr("Mode:")
+                            font.pixelSize: Appearance.font.pixelSize.smaller
+                            color: Appearance.colors.colSubtext
+                        }
+
+                        ConfigComboBox {
+                            currentValue: root.searchMode
+                            onSelected: newValue => { root.searchMode = newValue; performSearch(); }
+                            options: [
+                                { displayName: Translation.tr("Name"), icon: "text_fields", value: "name" },
+                                { displayName: Translation.tr("Content"), icon: "article", value: "content" },
+                                { displayName: Translation.tr("Type"), icon: "label", value: "type" }
+                            ]
+                        }
+                    }
+                }
+            }
+        }
+
+        // Results
+        Revealer {
+            reveal: root.searchResults.length > 0
+            Layout.fillWidth: true
+
+            ColumnLayout {
+                Layout.fillWidth: true
+                Layout.leftMargin: 16
+                Layout.rightMargin: 16
+                spacing: 4
+
+                Repeater {
+                    model: root.searchResults
+                    delegate: SearchResultItem {
+                        Layout.fillWidth: true
+                        result: modelData
+                    }
+                }
+            }
+        }
+
+        Revealer {
+            reveal: root.searchQuery.length > 0 && root.searchResults.length === 0 && !root.isSearching
+            Layout.fillWidth: true
+            Layout.leftMargin: 16
+            Layout.rightMargin: 16
+
+            Rectangle {
+                Layout.fillWidth: true
+                implicitHeight: 60
+                radius: 12
+                color: Appearance.colors.colLayer1
+                border.width: 1
+                border.color: Appearance.colors.colOutlineVariant
+                opacity: 0.5
+
+                StyledText {
+                    anchors.centerIn: parent
+                    text: Translation.tr("No results found")
+                    font.pixelSize: Appearance.font.pixelSize.normal
+                    color: Appearance.colors.colSubtext
+                }
+            }
+        }
+
+        Revealer {
+            reveal: root.searchQuery.length === 0
+            Layout.fillWidth: true
+            Layout.leftMargin: 16
+            Layout.rightMargin: 16
+
+            Rectangle {
+                Layout.fillWidth: true
+                implicitHeight: 80
+                radius: 12
+                color: Appearance.colors.colLayer1
+                border.width: 1
+                border.color: Appearance.colors.colOutlineVariant
+                opacity: 0.5
+
+                ColumnLayout {
+                    anchors.centerIn: parent
+                    spacing: 4
+
+                    StyledText {
+                        text: Translation.tr("Start typing to search files")
+                        font.pixelSize: Appearance.font.pixelSize.normal
+                        color: Appearance.colors.colSubtext
+                    }
+
+                    StyledText {
+                        text: Translation.tr("Prefixes: # = everything, @ = content, ! = type")
+                        font.pixelSize: Appearance.font.pixelSize.smaller
+                        color: Appearance.colors.colSubtext
+                    }
+                }
+            }
+        }
+    }
+
+    // Debounce timer for search
+    Timer {
+        id: debounceTimer
+        interval: 300
+        repeat: false
+        onTriggered: root.performSearch()
+    }
+
+    function performSearch() {
+        if (root.searchQuery.trim() === "") {
+            root.searchResults = [];
+            return;
+        }
+
+        root.isSearching = true;
+        searchProc.running = true;
+    }
+
+    Process {
+        id: searchProc
+        command: ["python3", Quickshell.shellPath("scripts/search/everything-query.py"), root.searchQuery, root.searchMode, root.filterType, root.sortBy, root.sortAscending ? "asc" : "desc"]
+        stdout: StdioCollector {
+            onStreamFinished: {
+                root.isSearching = false;
+                try {
+                    root.searchResults = JSON.parse(text);
+                } catch (e) {
+                    root.searchResults = [];
+                }
+            }
+        }
+    }
+}
+
+// Search result item
+Item {
+    id: SearchResultItem
+    required property var result
+    Layout.fillWidth: true
+    implicitHeight: 56
+
+    property bool isDirectory: result.isDirectory === true
+    property string fileType: result.type || ""
+    property string fileSize: result.size !== undefined ? FileUtils.formatBytes(result.size) : ""
+    property string modifiedDate: result.modified ? Qt.formatDateTime(new Date(result.modified * 1000), "MMM d, yyyy HH:mm") : ""
+
+    Rectangle {
+        anchors.fill: parent
+        radius: 12
+        color: Appearance.colors.colLayer1
+        border.width: 1
+        border.color: Appearance.colors.colOutlineVariant
+
+        MouseArea {
+            anchors.fill: parent
+            cursorShape: Qt.PointingHandCursor
+            hoverEnabled: true
+            onClicked: {
+                if (searchResultItem.result.isDirectory) {
+                    Quickshell.execDetached(["xdg-open", searchResultItem.result.path]);
+                } else {
+                    Quickshell.execDetached(["xdg-open", searchResultItem.result.path]);
+                }
+            }
+            onEntered: parent.color = Qt.lighter(Appearance.colors.colLayer1, 1.05)
+            onExited: parent.color = Appearance.colors.colLayer1
+
+            RowLayout {
+                anchors.fill: parent
+                Layout.leftMargin: 12
+                Layout.rightMargin: 12
+                spacing: 12
+
+                // File icon
+                Rectangle {
+                    Layout.alignment: Qt.AlignVCenter
+                    implicitWidth: 40
+                    implicitHeight: 40
+                    radius: 20
+                    color: searchResultItem.isDirectory ? Appearance.colors.colPrimary : Appearance.colors.colSecondary
+                    opacity: 0.15
+
+                    MaterialSymbol {
+                        anchors.centerIn: parent
+                        text: searchResultItem.isDirectory ? "folder" : getFileIcon(searchResultItem.fileType)
+                        iconSize: 20
+                        fill: 1
+                        color: searchResultItem.isDirectory ? Appearance.colors.colPrimary : Appearance.colors.colSecondary
+                    }
+                }
+
+                // File info
+                ColumnLayout {
+                    Layout.fillWidth: true
+                    spacing: -2
+
+                    StyledText {
+                        Layout.fillWidth: true
+                        text: searchResultItem.result.name || searchResultItem.result.path.split("/").pop()
+                        font.pixelSize: Appearance.font.pixelSize.normal
+                        font.weight: Font.Medium
+                        color: Appearance.colors.colOnLayer0
+                        elide: Text.ElideRight
+                    }
+
+                    StyledText {
+                        Layout.fillWidth: true
+                        text: `${searchResultItem.result.path.split("/").slice(0, -1).join("/")}  ${searchResultItem.fileSize ? "• " + searchResultItem.fileSize : ""}  ${searchResultItem.modifiedDate ? "• " + searchResultItem.modifiedDate : ""}`
+                        font.pixelSize: Appearance.font.pixelSize.smaller
+                        color: Appearance.colors.colSubtext
+                        elide: Text.ElideRight
+                    }
+                }
+
+                // Actions
+                RowLayout {
+                    spacing: 4
+
+                    Revealer {
+                        reveal: !searchResultItem.isDirectory
+                        MouseArea {
+                            Layout.preferredWidth: 36
+                            Layout.preferredHeight: 36
+                            cursorShape: Qt.PointingHandCursor
+                            onClicked: { Quickshell.execDetached(["xdg-open", searchResultItem.result.path]); }
+                            MaterialSymbol {
+                                anchors.centerIn: parent
+                                text: "open_in_new"
+                                iconSize: 18
+                                fill: 1
+                                color: Appearance.colors.colSubtext
+                            }
+                        }
+                    }
+
+                    MouseArea {
+                        Layout.preferredWidth: 36
+                        Layout.preferredHeight: 36
+                        cursorShape: Qt.PointingHandCursor
+                        onClicked: { Quickshell.execDetached(["xdg-open", searchResultItem.isDirectory ? searchResultItem.result.path : searchResultItem.result.path.split("/").slice(0, -1).join("/")]); }
+                        MaterialSymbol {
+                            anchors.centerIn: parent
+                            text: "folder_open"
+                            iconSize: 18
+                            fill: 1
+                            color: Appearance.colors.colSubtext
+                        }
+                    }
+
+                    MouseArea {
+                        Layout.preferredWidth: 36
+                        Layout.preferredHeight: 36
+                        cursorShape: Qt.PointingHandCursor
+                        onClicked: { Quickshell.copyToClipboard(searchResultItem.result.path); }
+                        MaterialSymbol {
+                            anchors.centerIn: parent
+                            text: "content_copy"
+                            iconSize: 18
+                            fill: 1
+                            color: Appearance.colors.colSubtext
+                        }
+                    }
+                }
+            }
+        }
+    }
+
+    function getFileTypeIcon(type) {
+        if (type.startsWith("image")) return "image";
+        if (type.startsWith("video")) return "videocam";
+        if (type.startsWith("audio")) return "music_note";
+        if (type.startsWith("application/pdf")) return "picture_as_pdf";
+        if (type.startsWith("application/zip") || type.startsWith("application/x-")) return "archive";
+        if (type.startsWith("text/")) return "description";
+        return "insert_drive_file";
+    }
+
+    function getFileIcon(type) {
+        if (type.startsWith("image")) return "image";
+        if (type.startsWith("video")) return "videocam";
+        if (type.startsWith("audio")) return "music_note";
+        if (type.startsWith("application/pdf")) return "picture_as_pdf";
+        if (type.startsWith("application/zip") || type.startsWith("application/x-")) return "archive";
+        if (type.startsWith("text/")) return "description";
+        if (type.startsWith("application/")) return "smartphone";
+        return "insert_drive_file";
+    }
+}
\ No newline at end of file
