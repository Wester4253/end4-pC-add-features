pragma Singleton
import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io

// Shell Profiles - Save/load complete configurations
Singleton {
    id: root

    property var profiles: []
    property string currentProfile: ""
    property bool loading: false

    function refresh() {
        if (loadProc.running) return;
        loadProc.running = true;
    }

    Component.onCompleted: refresh()

    Process {
        id: loadProc
        command: ["python3", Quickshell.shellPath("scripts/presets/profile_manager.py"), "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.profiles = JSON.parse(text);
                } catch (e) { root.profiles = []; }
            }
        }
    }

    function saveProfile(name, description, icon) {
        if (saveProc.running) return;
        saveProc.command = ["python3", Quickshell.shellPath("scripts/presets/profile_manager.py"), "save", name, "--description", description ?? "", "--icon", icon ?? "save"];
        saveProc.running = true;
    }

    Process {
        id: saveProc
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const result = JSON.parse(text);
                    if (result.success) {
                        root.refresh();
                    }
                } catch (e) {}
            }
        }
    }

    function loadProfile(name) {
        if (loadProfileProc.running) return;
        root.loading = true;
        loadProfileProc.command = ["python3", Quickshell.shellPath("scripts/presets/profile_manager.py"), "load", name];
        loadProfileProc.running = true;
    }

    Process {
        id: loadProfileProc
        stdout: StdioCollector {
            onStreamFinished: {
                root.loading = false;
                try {
                    const result = JSON.parse(text);
                    if (result.success) {
                        root.currentProfile = name;
                        root.refresh();
                        // Trigger shell reload
                        Quickshell.reload();
                    }
                } catch (e) {}
            }
        }
    }

    function deleteProfile(name) {
        if (deleteProc.running) return;
        deleteProc.command = ["python3", Quickshell.shellPath("scripts/presets/profile_manager.py"), "delete", name];
        deleteProc.running = true;
    }

    Process {
        id: deleteProc
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const result = JSON.parse(text);
                    if (result.success) {
                        root.refresh();
                    }
                } catch (e) {}
            }
        }
    }

    function exportProfile(name, outputPath) {
        if (exportProc.running) return;
        exportProc.command = ["python3", Quickshell.shellPath("scripts/presets/profile_manager.py"), "export", name, outputPath];
        exportProc.running = true;
    }

    Process {
        id: exportProc
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const result = JSON.parse(text);
                } catch (e) {}
            }
        }
    }

    function importProfile(inputPath, name) {
        if (importProc.running) return;
        var cmd = ["python3", Quickshell.shellPath("scripts/presets/profile_manager.py"), "import", inputPath];
        if (name) cmd.push("--name", name);
        importProc.command = cmd;
        importProc.running = true;
    }

    Process {
        id: importProc
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const result = JSON.parse(text);
                    if (result.success) {
                        root.refresh();
                    }
                } catch (e) {}
            }
        }
    }
}