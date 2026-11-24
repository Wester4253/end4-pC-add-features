import qs
import qs.services
import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton
pragma ComponentBehavior: Bound

Singleton {
    id: root
    property bool sloppySearch: Config.options?.search.sloppy ?? false
    property real scoreThreshold: 0.2
    property list<string> entries: []
    property var favorites: []

    readonly property var preparedEntries: entries.map(a => ({
        name: Fuzzy.prepare(`${a.replace(/^\s*\S+\s+/, "")}`),
        text: a
    }))

    function entryText(entry) {
        return entry.replace(/^\s*\S+\s+/, "")
    }

    function entryId(entry) {
        return entry.replace(/\s+.*$/, "")
    }

    function isFavorite(entry) {
        if (!root.favorites.length) return false;
        const text = root.entryText(entry);
        return root.favorites.some(fav => fav.text === text);
    }

    function toggleFavorite(entry) {
        if (favoritesProc.running) return;
        const entryText = root.entryText(entry);
        const isFav = root.isFavorite(entry);
        favoritesProc.command = ["python3", FileUtils.trimFileProtocol(`${Directories.scriptPath}/clipboard/cliphist-favorites.py`), isFav ? "remove" : "add", entryText];
        favoritesProc.running = true;
    }

    // Legacy pin system (for backward compatibility)
    function pinIndex(entry) {
        const pins = Config.options.search.clipboardPins ?? []
        const id = root.entryId(entry)
        return pins.includes(id)
    }

    function togglePin(entry) {
        if (dedupeProc.running) return;
        const id = root.entryId(entry)
        let pins = (Config.options.search.clipboardPins ?? []).slice()
        if (pins.includes(id)) {
            pins = pins.filter(p => p !== id)
        } else {
            pins.push(id)
        }
        Config.options.search.clipboardPins = pins
    }

    function dedupePinned() {
        if (dedupeProc.running) return;
        const pins = (Config.options.search.clipboardPins ?? []).slice();
        // dedup logic
    }

    Process {
        id: readProc
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text) {
                    root.entries = text.split("\n").filter(l => l.length > 0)
                    root.dedupePinned()
                    favoritesProc.running = true
                } else {
                    root.entries = []
                    console.error("[Cliphist] Failed to refresh")
                }
            }
        }
    }

    Process {
        id: dedupeProc
        command: ["python3", FileUtils.trimFileProtocol(`${Directories.scriptPath}/clipboard/dedupe.py`), JSON.stringify([])]
        stdout: StdioCollector {
            onStreamFinished: {
                // dedupe complete
            }
        }
    }

    Process {
        id: favoritesProc
        command: ["python3", FileUtils.trimFileProtocol(`${Directories.scriptPath}/clipboard/cliphist-favorites.py`), "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.favorites = JSON.parse(text);
                } catch (e) {
                    root.favorites = [];
                }
            }
        }
    }

    Component.onCompleted: {
        readProc.running = true
    }

    function refresh() {
        readProc.running = false
        readProc.running = true
    }
}
