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
    property bool enabled: Config.options.ottoHostPair.enable ?? true

    // --- Tailscale ---
    property bool tailscaleRunning: false
    property string tailscaleIp: ""
    property string tailscaleDns: ""
    property bool tailscaleOnline: false
    property string tailscaleVersion: ""
    property string tailscaleExitNodeStatus: ""
    property string tailscaleExitNodeIP: ""
    property int tailscalePeerCount: 0
    property int tailscaleOnlinePeerCount: 0

    // --- Otto Daemon ---
    property bool ottoRunning: false
    property string ottoVersion: ""
    property string ottoServerId: ""
    property string ottoHostname: ""
    property string ottoListen: ""
    property int ottoUptimeSeconds: 0
    property int ottoMemoryUsageMB: 0
    property int ottoCpuPercent: 0
    property int ottoActiveSessions: 0
    property int ottoActiveAgents: 0
    property bool ottoPluginsEnabled: false
    property bool ottoRelayEnabled: false
    property bool ottoVoiceEnabled: false
    // --- Agent / Session Status ---
    property int agentTotal: 0
    property int agentActive: 0
    property int agentFailed: 0
    property string agentLastError: ""
    property string agentLastErrorAgent: ""
    property int sessionTotal: 0
    property int sessionActive: 0
    property int sessionCompleted: 0
    property int sessionFailed: 0

    // --- Desktop App Link ---
    property string desktopUrl: "otto://"

    // --- System ---
    property int systemCpuPercent: 0
    property int systemMemoryTotalMB: 0
    property int systemMemoryUsedMB: 0
    property int systemMemoryPercent: 0
    property int systemDiskTotalGB: 0
    property int systemDiskUsedGB: 0
    property int systemDiskPercent: 0
    property number systemLoad1: 0
    property number systemLoad5: 0
    property number systemLoad15: 0
    property int systemUptimeSeconds: 0

    // --- Pairing ---
    property bool paired: false
    property string pairedHost: ""

    // --- Processes ---
    Process {
        id: tailscaleStatusProc
        command: ["tailscale", "status", "--json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const status = JSON.parse(text);
                    root.tailscaleRunning = true;
                    root.tailscaleIp = status.Self?.TailscaleIPs?.[0] ?? "";
                    root.tailscaleDns = status.Self?.DNSName ?? "";
                    root.tailscaleOnline = true;
                    root.tailscaleVersion = status.Version ?? "";
                    root.tailscaleExitNodeStatus = status.ExitNodeStatus ?? "";
                    root.tailscaleExitNodeIP = status.ExitNodeIP ?? "";

                    const peers = [];
                    const peerObj = status.Peer;
                    if (peerObj) {
                        Object.keys(peerObj).forEach(name => {
                            const p = peerObj[name];
                            peers.push({
                                name,
                                ip: p.TailscaleIPs?.[0] ?? "",
                                online: p.Online ?? false,
                                lastSeen: p.LastSeen ?? "",
                                exitNode: p.ExitNodeStatus === "active",
                            });
                        });
                    }
                    root.tailscalePeerCount = peers.length;
                    root.tailscaleOnlinePeerCount = peers.filter(p => p.online).length;
                    root.tailscalePeers = peers;
                } catch (e) {
                    root.tailscaleRunning = false;
                    console.error("[OttoHostPair] Failed to parse tailscale status:", e);
                }
            }
        }
    }

    Process {
        id: ottoStatusProc
        command: ["sh", "-c", "curl -s --max-time 3 http://127.0.0.1:6868/api/status 2>/dev/null || echo '{}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const status = JSON.parse(text);
                    root.ottoRunning = true;
                    root.ottoVersion = status.version ?? "";
                    root.ottoServerId = status.serverId ?? "";
                    root.ottoHostname = status.hostname ?? "";
                    root.ottoListen = status.listen ?? "";
                    root.ottoUptimeSeconds = status.uptimeSeconds ?? 0;
                    root.ottoMemoryUsageMB = status.memoryUsageMB ?? 0;
                    root.ottoCpuPercent = status.cpuPercent ?? 0;
                    root.ottoActiveSessions = status.activeSessions ?? 0;
                    root.ottoActiveAgents = status.activeAgents ?? 0;
                    root.ottoPluginsEnabled = status.pluginsEnabled ?? false;
                    root.ottoRelayEnabled = status.relayEnabled ?? false;
                    root.ottoVoiceEnabled = status.voiceEnabled ?? false;
                    root.ottoBrainEnabled = status.brainEnabled ?? false;
                } catch (e) {
                    root.ottoRunning = false;
                    console.error("[OttoHostPair] Failed to parse otto status:", e);
                }
            }
        }
    }

    Process {
        id: systemUsageProc
        command: ["sh", "-c",
            "echo '{\"cpuPercent\":$(top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1 | cut -d'.' -f1),'memoryTotalMB':$(free -m | grep Mem | awk '{print $2}'),\"memoryUsedMB':$(free -m | grep Mem | awk '{print $3}'),\"diskTotalGB':$(df -BG / | awk 'NR==2{print $2}' | tr -d 'G'),\"diskUsedGB':$(df -BG / | awk 'NR==2{print $3}' | tr -d 'G'),\"load1':$(cat /proc/loadavg | awk '{print $1}'),\"load5':$(cat /proc/loadavg | awk '{print $2}'),\"load15':$(cat /proc/loadavg | awk '{print $3}'),\"uptimeSeconds':$(cat /proc/uptime | awk '{print int($1)}')}'"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const usage = JSON.parse(text);
                    root.systemCpuPercent = usage.cpuPercent ?? 0;
                    root.systemMemoryTotalMB = usage.memoryTotalMB ?? 0;
                    root.systemMemoryUsedMB = usage.memoryUsedMB ?? 0;
                    root.systemMemoryPercent = usage.memoryPercent ?? 0;
                    root.systemDiskTotalGB = usage.diskTotalGB ?? 0;
                    root.systemDiskUsedGB = usage.diskUsedGB ?? 0;
                    root.systemDiskPercent = usage.diskPercent ?? 0;
                    root.systemLoad1 = usage.load1 ?? 0;
                    root.systemLoad5 = usage.load5 ?? 0;
                    root.systemLoad15 = usage.load15 ?? 0;
                    root.systemUptimeSeconds = usage.uptimeSeconds ?? 0;
                } catch (e) {
                    console.error("[OttoHostPair] Failed to parse system usage:", e);
                }
            }
        }
    }

    // --- Paired host state ---
    readonly property var pairedHostFile: "/home/otto/.otto/host-pair-state.json"

    Process {
        id: pairedHostProc
        command: ["sh", "-c", `cat ${root.pairedHostFile} 2>/dev/null || echo '{}'`]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const state = JSON.parse(text);
                    root.pairedHost = state.pairedHost ?? "";
                    root.paired = root.pairedHost !== "" && root.pairedHost !== null;
                } catch (e) {
                    root.pairedHost = "";
                    root.paired = false;
                }
            }

    // --- Summary status file ---
    readonly property var summaryFile: "/home/otto/.otto/host-pair-summary.json"

    Process {
        id: summaryProc
        command: ["sh", "-c", `cat ${root.summaryFile} 2>/dev/null || echo '{}'`]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const summary = JSON.parse(text);
                    const ag = summary.agents ?? {};
                    const ss = summary.sessions ?? {};
                    root.agentTotal = ag.total ?? 0;
                    root.agentActive = ag.active ?? 0;
                    root.agentFailed = ag.failed ?? 0;
                    root.sessionTotal = ss.total ?? 0;
                    root.sessionActive = ss.active ?? 0;
                    root.sessionCompleted = ss.completed ?? 0;
                    root.sessionFailed = ss.failed ?? 0;
                } catch (e) {
                    console.error("[OttoHostPair] Failed to parse summary:", e);
                }
            }
        }


    // --- Refresh all ---
    function refresh() {
        if (!enabled) return;
        tailscaleStatusProc.running = true;
        ottoStatusProc.running = true;
        systemUsageProc.running = true;
        pairedHostProc.running = true;
        summaryProc.running = true;

    Component.onCompleted: {
        Qt.callLater(() => {
            refresh();
        });
    }

    // --- Auto-refresh every 30 seconds ---
    Timer {
        id: refreshTimer
        interval: 30000
        repeat: true
        running: root.enabled
        onTriggered: root.refresh()
    }
}
