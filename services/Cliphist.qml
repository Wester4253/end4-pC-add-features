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

diff --git a/services/Cliphist.qml b/services/Cliphist.qml
index ec23d81a..e6f27c88 100644
--- a/services/Cliphist.qml
+++ b/services/Cliphist.qml
@@ -17,6 +17,7 @@ Singleton {
     property bool sloppySearch: Config.options?.search.sloppy ?? false
     property real scoreThreshold: 0.2
     property list<string> entries: []
+    property var favorites: []
 
     readonly property var preparedEntries: entries.map(a => ({
         name: Fuzzy.prepare(`${a.replace(/^\s*\S+\s+/, "")}`),
@@ -56,6 +57,22 @@ Singleton {
         return entry.replace(/^\s*\S+\s+/, "")
     }
 
+    // Favorites (new SQLite-based system)
+    function isFavorite(entry) {
+        if (!root.favorites.length) return false;
+        const text = root.entryText(entry);
+        return root.favorites.some(fav => fav.text === text);
+    }
+
+    function toggleFavorite(entry) {
+        if (favoritesProc.running) return;
+        const entryText = root.entryText(entry);
+        const isFav = root.isFavorite(entry);
+        favoritesProc.command = ["python3", FileUtils.trimFileProtocol(`${Directories.scriptPath}/clipboard/cliphist-favorites.py`), isFav ? "remove" : "add", entryText];
+        favoritesProc.running = true;
+    }
+
+    // Legacy pin system (for backward compatibility)
     function pinIndex(entry) {
         const pins = Config.options.search.clipboardPins ?? []
         const id = root.entryId(entry)
@@ -107,6 +124,20 @@ Singleton {
         }
     }
 
+    Process {
+        id: favoritesProc
+        command: ["python3", FileUtils.trimFileProtocol(`${Directories.scriptPath}/clipboard/cliphist-favorites.py`), "list"]
+        stdout: StdioCollector {
+            onStreamFinished: {
+                try {
+                    root.favorites = JSON.parse(text);
+                } catch (e) {
+                    root.favorites = [];
+                }
+            }
+        }
+    }
+
     function dedupePinned() {
         if (dedupeProc.running) return;
         const pins = (Config.options.search.clipboardPins ?? []).slice();
@@ -237,6 +268,7 @@ Singleton {
             if (exitCode === 0) {
                 root.entries = readProc.buffer
                 root.dedupePinned()
+                favoritesProc.running = true
             } else {
                 root.entries = []
                 console.error("[Cliphist] Failed to refresh with code", exitCode, "and status", exitStatus)
