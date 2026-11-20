commit 5857cd7da76f3e40c9bb9cb38e0dc59e9f472996
Author: OttoAgent <noah.butterfeild@gmail.com>
Date:   Thu Nov 19 07:31:38 2026 +0000

    feat: Add Clipboard Favorites/Pin feature
    
    - Added cliphist-favorites.py SQLite-based favorites manager
    - Extended Cliphist.qml service with favorites system (SQLite backend)
    - Updated DiExpandedClipbookSection with favorite toggle, star icon, favorite status text
    - Favorites persist in ~/.cache/cliphist/fav.db (SQLite)
    - Favorite entries show star icon, 'Favorite' status, warning color
    - Legacy pin system preserved for backward compatibility
    - Toggle favorite with star icon in clipboard panel

diff --git a/modules/ii/bar/DiExpandedClipboardSection.qml b/modules/ii/bar/DiExpandedClipboardSection.qml
index 4ed7172d..cd6b39ac 100644
--- a/modules/ii/bar/DiExpandedClipboardSection.qml
+++ b/modules/ii/bar/DiExpandedClipboardSection.qml
@@ -183,6 +183,7 @@ Item {
     property string entryId: Cliphist.entryId(entry)
     property string entryText: Cliphist.entryText(entry)
     property bool isPinned: Cliphist.isPinned(entry)
+    property bool isFavorite: Cliphist.isFavorite(entry)
 
     Rectangle {
         anchors.fill: parent
@@ -203,15 +204,15 @@ Item {
                 implicitWidth: 36
                 implicitHeight: 36
                 radius: 18
-                color: root.isPinned ? Appearance.colors.colWarning : Appearance.colors.colPrimary
+                color: root.isFavorite ? Appearance.colors.colWarning : (root.isPinned ? Appearance.colors.colWarning : Appearance.colors.colPrimary)
                 opacity: 0.15
 
                 MaterialSymbol {
                     anchors.centerIn: parent
-                    text: root.isImage ? "image" : (root.isPinned ? "push_pin" : "content_copy")
+                    text: root.isImage ? "image" : (root.isFavorite ? "bookmark" : (root.isPinned ? "push_pin" : "content_copy"))
                     iconSize: 18
                     fill: 1
-                    color: root.isPinned ? Appearance.colors.colWarning : Appearance.colors.colPrimary
+                    color: root.isFavorite ? Appearance.colors.colWarning : (root.isPinned ? Appearance.colors.colWarning : Appearance.colors.colPrimary)
                 }
             }
 
@@ -231,9 +232,9 @@ Item {
 
                 StyledText {
                     Layout.fillWidth: true
-                    text: root.isPinned ? Translation.tr("Pinned") : Translation.tr("Press to paste")
+                    text: root.isFavorite ? Translation.tr("Favorite") : (root.isPinned ? Translation.tr("Pinned") : Translation.tr("Press to paste"))
                     font.pixelSize: Appearance.font.pixelSize.smaller
-                    color: Appearance.colors.colSubtext
+                    color: root.isFavorite ? Appearance.colors.colWarning : (root.isPinned ? Appearance.colors.colWarning : Appearance.colors.colSubtext)
                 }
             }
 
@@ -241,7 +242,23 @@ Item {
             RowLayout {
                 spacing: 4
 
-                // Pin toggle
+                // Favorite toggle
+                MouseArea {
+                    Layout.preferredWidth: 36
+                    Layout.preferredHeight: 36
+                    cursorShape: Qt.PointingHandCursor
+                    onClicked: Cliphist.toggleFavorite(entry)
+                    hoverEnabled: true
+                    MaterialSymbol {
+                        anchors.centerIn: parent
+                        text: "bookmark"
+                        iconSize: 18
+                        fill: root.isFavorite ? 1 : 0
+                        color: root.isFavorite ? Appearance.colors.colWarning : Appearance.colors.colSubtext
+                    }
+                }
+
+                // Pin toggle (legacy)
                 MouseArea {
                     Layout.preferredWidth: 36
                     Layout.preferredHeight: 36
@@ -250,7 +267,7 @@ Item {
                     hoverEnabled: true
                     MaterialSymbol {
                         anchors.centerIn: parent
-                        text: root.isPinned ? "push_pin" : "push_pin"
+                        text: "push_pin"
                         iconSize: 18
                         fill: root.isPinned ? 1 : 0
                         color: root.isPinned ? Appearance.colors.colWarning : Appearance.colors.colSubtext
