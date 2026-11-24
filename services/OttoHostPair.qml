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
    property var tailscalePeers: []

    // --- Otto Daemon (local) ---
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
    property bool ottoBrainEnabled: false

    // --- Paired Remote Host ---
    property bool paired: false
    property string pairedHost: ""          // DNS name of paired host
    property string pairedHostIp: ""        // Tailscale IP of paired host
    property string pairedHostName: ""      // Display name of paired host
    property bool pairedHostOnline: false
    property string pairedHostOttoVersion: ""
    property int pairedHostActiveSessions: 0
    property int pairedHostActiveAgents: 0
    property var pairedHostAgents: []
    property var pairedHostSessions: []
    property int pairedHostAgentTotal: 0
    property int pairedHostAgentActive: 0
    property int pairedHostAgentFailed: 0
    property int pairedHostSessionTotal: 0
    property int pairedHostSessionActive: 0
    property int pairedHostSessionCompleted: 0
    property int pairedHostSessionFailed: 0
    property int pairedHostAgentLimit: 0
    property int pairedHostAgentUsed: 0
    property int pairedHostSessionLimit: 0
    property int pairedHostSessionUsed: 0

    // --- System (local) ---
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

    // --- Pairing state file ---
    readonly property var pairedHostFile: "/home/otto/.otto/host-pair-state.json"

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
                    root.tailscalePeers = peers;
                    root.tailscalePeerCount = peers.length;
                    root.tailscaleOnlinePeerCount = peers.filter(p => p.online).length;

                    // Update paired host online status
                    if (root.pairedHost !== "") {
                        const pairedPeer = peers.find(p => p.name === root.pairedHost || p.ip === root.pairedHostIp);
                        if (pairedPeer) {
                            root.pairedHostOnline = pairedPeer.online;
                        }
                    }
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

    // Fetch paired host status via its Tailscale IP
    Process {
        id: pairedHostStatusProc
        command: ["sh", "-c", ""]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const status = JSON.parse(text);
                    root.pairedHostOttoVersion = status.version ?? "";
                    root.pairedHostActiveSessions = status.activeSessions ?? 0;
                    root.pairedHostActiveAgents = status.activeAgents ?? 0;
                    root.pairedHostAgents = status.agents ?? [];
                    root.pairedHostSessions = status.sessions ?? [];
                    root.pairedHostAgentTotal = status.agentTotal ?? 0;
                    root.pairedHostAgentActive = status.agentActive ?? 0;
                    root.pairedHostAgentFailed = status.agentFailed ?? 0;
                    root.pairedHostSessionTotal = status.sessionTotal ?? 0;
                    root.pairedHostSessionActive = status.sessionActive ?? 0;
                    root.pairedHostSessionCompleted = status.sessionCompleted ?? 0;
                    root.pairedHostSessionFailed = status.sessionFailed ?? 0;
                    root.pairedHostAgentLimit = status.agentLimit ?? 0;
                    root.pairedHostAgentUsed = status.agentUsed ?? 0;
                    root.pairedHostSessionLimit = status.sessionLimit ?? 0;
                    root.pairedHostSessionUsed = status.sessionUsed ?? 0;
                } catch (e) {
                    console.error("[OttoHostPair] Failed to parse paired host status:", e);
                }
            }
        }
    }

    Process {
        id: systemUsageProc
        command: ["sh", "-c",
            "echo '{\"cpuPercent\":$(top -bn1 | grep \"Cpu(s)\" | awk '{print $2}' | cut -d'%' -f1 | cut -d'.' -f1),\"memoryTotalMB\":$(free -m | grep Mem | awk '{print $2}'),\"memoryUsedMB\":$(free -m | grep Mem | awk '{print $3}'),\"diskTotalGB\":$(df -BG / | awk 'NR==2{print $2}' | tr -d 'G'),\"diskUsedGB\":$(df -BG / | awk 'NR==2{print $3}' | tr -d 'G'),\"load1\":$(cat /proc/loadavg | awk '{print $1}'),\"load5\":$(cat /proc/loadavg | awk '{print $2}'),\"load15\":$(cat /proc/loadavg | awk '{print $3}'),\"uptimeSeconds\":$(cat /proc/uptime | awk '{print int($1)}')}'"
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

    // --- Load paired host state ---
    Process {
        id: pairedHostProc
        command: ["sh", "-c", `cat ${root.pairedHostFile} 2>/dev/null || echo '{}'`]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const state = JSON.parse(text);
                    root.pairedHost = state.pairedHost ?? "";
                    root.pairedHostIp = state.pairedHostIp ?? "";
                    root.pairedHostName = state.pairedHostName ?? "";
                    root.paired = root.pairedHost !== "" && root.pairedHost !== null;
                } catch (e) {
                    root.pairedHost = "";
                    root.pairedHostIp = "";
                    root.pairedHostName = "";
                    root.paired = false;
                }
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

        // If paired, fetch remote host status
        if (root.paired && root.pairedHostIp !== "") {
            pairedHostStatusProc.command = ["sh", "-c", `curl -s --max-time 5 http://${root.pairedHostIp}:6868/api/status 2>/dev/null || echo '{}'`];
            pairedHostStatusProc.running = true;
        }
    }

    // Pair with a tailnet device
    function pairWithHost(hostName, hostIp, displayName) {
        const state = {
            pairedHost: hostName,
            pairedHostIp: hostIp,
            pairedHostName: displayName,
            pairedAt: new Date().toISOString()
        };
        const cmd = `mkdir -p /home/otto/.otto && echo '${JSON.stringify(state)}' > ${root.pairedHostFile}`;
        Quickshell.execDetached(["sh", "-c", cmd]);

        // Update local state immediately
        root.pairedHost = hostName;
        root.pairedHostIp = hostIp;
        root.pairedHostName = displayName;
        root.paired = true;

        // Save to config for OttoUsage service
        Config.options.ottoHostPair.tailscaleIp = hostIp;
        Config.options.ottoHostPair.daemonUrl = `http://${hostIp}:6868`;
        Config.options.ottoHostPair.paired = true;

        // Refresh to get remote status
        refresh();
    }

    // Unpair
    function unpair() {
        Quickshell.execDetached(["sh", "-c", `rm -f ${root.pairedHostFile}`]);
        root.pairedHost = "";
        root.pairedHostIp = "";
        root.pairedHostName = "";
        root.paired = false;
        root.pairedHostOnline = false;
        root.pairedHostOttoVersion = "";
        root.pairedHostActiveSessions = 0;
        root.pairedHostActiveAgents = 0;
        root.pairedHostAgents = [];
        root.pairedHostSessions = [];

        Config.options.ottoHostPair.tailscaleIp = "";
        Config.options.ottoHostPair.daemonUrl = "";
        Config.options.ottoHostPair.paired = false;
    }

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