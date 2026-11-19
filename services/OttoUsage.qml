pragma Singleton
import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io

// Status of Otto agents (https://github.com/otto-code), queried from the
// Otto daemon over WebSocket by scripts/ai/otto-usage.py. The daemon may
// run on this machine or remotely (LXC/server); point ottoHost at it.
Singleton {
    id: root

    property bool available: false
    property string host: ""
    property var agents: []
    property int activeSessions: 0 // agents currently running a turn
    property int totalSessions: 0
    property int attentionCount: 0
    property int pendingPermissionCount: 0
    property int tokens: 0
    property int resetsAt: 0
    // Share of agents that are busy; 0 when there are no agents.
    readonly property real percentage: root.totalSessions > 0 ? Math.min(root.activeSessions / root.totalSessions, 1) : 0

    function refresh() {
        if (Config.options.bar.aiUsage.ottoEnabled && !usageProc.running) usageProc.running = true;
    }

    Timer {
        interval: Config.options.bar.aiUsage.updateInterval * 1000
        repeat: true
        running: Config.ready && Config.options.bar.aiUsage.ottoEnabled
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Process {
        id: usageProc
        command: ["python3", Quickshell.shellPath("scripts/ai/otto-usage.py")]
        environment: ({
            "OTTO_HOST": Config.options.bar.aiUsage.ottoHost ?? "",
            "OTTO_PASSWORD": Config.options.bar.aiUsage.ottoPassword ?? "",
        })
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    root.available = data.available === true;
                    root.host = data.host ?? "";
                    root.agents = data.agents ?? [];
                    root.activeSessions = data.activeSessions ?? 0;
                    root.totalSessions = data.totalSessions ?? 0;
                    root.attentionCount = data.attentionCount ?? 0;
                    root.pendingPermissionCount = data.pendingPermissionCount ?? 0;
                    root.tokens = data.tokens ?? 0;
                    root.resetsAt = data.resetsAt ?? 0;
                } catch (e) { root.available = false; }
            }
        }
    }
}
