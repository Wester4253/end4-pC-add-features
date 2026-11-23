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

diff --git a/scripts/clipboard/cliphist-favorites.py b/scripts/clipboard/cliphist-favorites.py
new file mode 100644
index 00000000..cdd861cd
--- /dev/null
+++ b/scripts/clipboard/cliphist-favorites.py
@@ -0,0 +1,100 @@
+#!/usr/bin/env python3
+"""Cliphist favorites/pin manager."""
+import json
+import os
+import sys
+import sqlite3
+
+FAV_DB = os.path.expanduser("~/.cache/cliphist/fav.db")
+
+def init_db():
+    """Initialize favorites database."""
+    os.makedirs(os.path.dirname(FAV_DB), exist_ok=True)
+    conn = sqlite3.connect(FAV_DB)
+    conn.execute("""
+        CREATE TABLE IF NOT EXISTS favorites (
+            id INTEGER PRIMARY KEY AUTOINCREMENT,
+            entry TEXT NOT NULL UNIQUE,
+            entry_hash TEXT NOT NULL,
+            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
+        )
+    """)
+    conn.commit()
+    return conn
+
+def is_favorite(conn, entry):
+    """Check if entry is favorited."""
+    cursor = conn.execute("SELECT 1 FROM favorites WHERE entry_hash = ?", (hash_entry(entry),))
+    return cursor.fetchone() is not None
+
+def hash_entry(entry):
+    """Generate hash for entry."""
+    import hashlib
+    return hashlib.sha256(entry.encode()).hexdigest()[:16]
+
+def add_favorite(conn, entry):
+    """Add entry to favorites."""
+    try:
+        conn.execute("INSERT INTO favorites (entry, entry_hash) VALUES (?, ?)", (entry, hash_entry(entry)))
+        conn.commit()
+        return True
+    except sqlite3.IntegrityError:
+        return False
+
+def remove_favorite(conn, entry):
+    """Remove entry from favorites."""
+    conn.execute("DELETE FROM favorites WHERE entry_hash = ?", (hash_entry(entry),))
+    conn.commit()
+    return True
+
+def get_favorites(conn):
+    """Get all favorites."""
+    cursor = conn.execute("SELECT entry FROM favorites ORDER BY created_at DESC")
+    return [row[0] for row in cursor.fetchall()]
+
+def main():
+    if len(sys.argv) < 2:
+        print("Usage: cliphist-favorites.py <command> [entry]")
+        print("Commands: list, add, remove, check, toggle")
+        sys.exit(1)
+
+    command = sys.argv[1]
+    conn = init_db()
+
+    if command == "list":
+        favorites = get_favorites(conn)
+        print(json.dumps(favorites))
+    elif command == "check":
+        if len(sys.argv) < 3:
+            print(json.dumps({"isFavorite": False}))
+            return
+        entry = sys.argv[2]
+        print(json.dumps({"isFavorite": is_favorite(conn, entry)}))
+    elif command == "add":
+        if len(sys.argv) < 3:
+            print(json.dumps({"success": False}))
+            return
+        entry = sys.argv[2]
+        print(json.dumps({"success": add_favorite(conn, entry)}))
+    elif command == "remove":
+        if len(sys.argv) < 3:
+            print(json.dumps({"success": False}))
+            return
+        entry = sys.argv[2]
+        print(json.dumps({"success": remove_favorite(conn, entry)}))
+    elif command == "toggle":
+        if len(sys.argv) < 3:
+            print(json.dumps({"success": False}))
+            return
+        entry = sys.argv[2]
+        if is_favorite(conn, entry):
+            print(json.dumps({"success": remove_favorite(conn, entry), "isFavorite": False}))
+        else:
+            print(json.dumps({"success": add_favorite(conn, entry), "isFavorite": True}))
+    else:
+        print(json.dumps({"error": "Unknown command"}))
+        sys.exit(1)
+
+if __name__ == "__main__":
+    import json
+    main()
\ No newline at end of file
