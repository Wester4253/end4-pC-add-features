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

diff --git a/scripts/search/everything-query.py b/scripts/search/everything-query.py
new file mode 100644
index 00000000..4fa1ca25
--- /dev/null
+++ b/scripts/search/everything-query.py
@@ -0,0 +1,102 @@
+#!/usr/bin/env python3
+"""Everything-style file search using plocate with fd fallback."""
+import json
+import os
+import subprocess
+import sys
+import time
+from pathlib import Path
+
+def run_plocate(query, filter_type, sort_by, sort_order):
+    """Search using plocate database."""
+    try:
+        cmd = ["plocate", "-i", query]
+        if filter_type == "folders":
+            cmd.extend(["-t", "d"])
+        elif filter_type == "files":
+            cmd.extend(["-t", "f"])
+        
+        result = subprocess.run(cmd, capture_output=True, text=True, timeout=5)
+        lines = result.stdout.strip().split("\n") if result.stdout else []
+        return [{"path": line, "name": os.path.basename(line), "isDirectory": os.path.isdir(line)} for line in lines if line]
+    except (subprocess.TimeoutExpired, FileNotFoundError, subprocess.SubprocessError):
+        return None
+
+def run_fd(query, filter_type, sort_by, sort_order):
+    """Search using fd as fallback."""
+    try:
+        cmd = ["fd", "--hidden", "--no-ignore"]
+        if filter_type == "folders":
+            cmd.extend(["-t", "d"])
+        elif filter_type == "files":
+            cmd.extend(["-t", "f"])
+        
+        cmd.extend([query, "/"])
+        
+        if sort_by == "modified":
+            cmd.extend(["-X", "stat", "-c", "%Y %n"])
+        
+        result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
+        lines = result.stdout.strip().split("\n") if result.stdout else []
+        return [{"path": line, "name": os.path.basename(line), "isDirectory": os.path.isdir(line)} for line in lines if line]
+    except (subprocess.TimeoutExpired, FileNotFoundError, subprocess.SubprocessError):
+        return []
+
+def get_file_info(path):
+    """Get file metadata."""
+    try:
+        stat = os.stat(path)
+        return {
+            "path": path,
+            "name": os.path.basename(path),
+            "isDirectory": os.path.isdir(path),
+            "size": stat.st_size if not os.path.isdir(path) else 0,
+            "modified": int(stat.st_mtime),
+            "type": ""  # Could add MIME type detection
+        }
+    except (OSError, FileNotFoundError):
+        return None
+
+def main():
+    if len(sys.argv) < 6:
+        print(json.dumps([]))
+        return
+
+    query = sys.argv[1]
+    search_mode = sys.argv[2]  # "name", "content", "type"
+    filter_type = sys.argv[3]  # "all", "folders", "files", "images", etc.
+    sort_by = sys.argv[4]      # "relevance", "name", "size", "type", "modified"
+    sort_order = sys.argv[5]   # "asc", "desc"
+
+    if not query or query.strip() == "":
+        print(json.dumps([]))
+        return
+
+    # Try plocate first, fall back to fd
+    results = run_plocate(query, filter_type, sort_by, sort_order)
+    if results is None:
+        results = run_fd(query, filter_type, sort_by, sort_order)
+
+    # Enrich with file info
+    enriched = []
+    for r in results[:100]:  # Limit results
+        info = get_file_info(r["path"])
+        if info:
+            enriched.append(info)
+
+    # Sort
+    reverse = sort_order == "desc"
+    if sort_by == "name":
+        enriched.sort(key=lambda x: x["name"].lower(), reverse=reverse)
+    elif sort_by == "size":
+        enriched.sort(key=lambda x: x["size"], reverse=reverse)
+    elif sort_by == "type":
+        enriched.sort(key=lambda x: (not x["isDirectory"], x["name"].lower()), reverse=reverse)
+    elif sort_by == "modified":
+        enriched.sort(key=lambda x: x["modified"], reverse=reverse)
+
+    print(json.dumps(enriched))
+
+if __name__ == "__main__":
+    import json
+    main()
\ No newline at end of file
