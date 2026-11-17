pragma Singleton
import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io

// Usage of Oh My Pi (omp) agents: token totals from the last 5h window
// (parsed from session files) and active agent processes.
Singleton {
    id: root

    property bool available: false
    property int tokens: 0
    property int requestsLastMinute: 0
    property int rpmLimit: 40
    property int activeSessions: 0
    property var sessions: []
    property var models: []
    // NIM limits are requests per minute, not tokens
    readonly property real percentage: root.rpmLimit > 0 ? Math.min(root.requestsLastMinute / root.rpmLimit, 1) : 0
    readonly property int resetsAt: 0

    function refresh() {
        if (Config.options.bar.aiUsage.ompEnabled && !usageProc.running) usageProc.running = true;
    }

    Timer {
        interval: Config.options.bar.aiUsage.updateInterval * 1000
        repeat: true
        running: Config.ready && Config.options.bar.aiUsage.ompEnabled
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Process {
        id: usageProc
        command: ["python3", Quickshell.shellPath("scripts/ai/omp-usage.py")]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    root.available = data.available === true;
                    root.tokens = data.tokens ?? 0;
                    root.requestsLastMinute = data.requestsLastMinute ?? 0;
                    root.rpmLimit = data.rpmLimit ?? 40;
                    root.activeSessions = data.activeSessions ?? 0;
                    root.sessions = data.sessions ?? [];
                    root.models = data.models ?? [];
                } catch (e) { root.available = false; }
            }
        }
    }
}
