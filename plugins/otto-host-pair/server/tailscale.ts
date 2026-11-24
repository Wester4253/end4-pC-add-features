import type { PluginServerContext, RpcInput } from "@otto-code/plugin/server";
import { z } from "zod";
import * as fs from "fs";
import {
  tailscaleStatusRpc,
  tailscaleFullStatusRpc,
  tailscalePeersRpc,
  tailscalePairRpc,
  ottoDaemonStatusRpc,
  ottoDaemonFullStatusRpc,
  ottoPairRpc,
  ottoFeaturesRpc,
  ottoSystemUsageRpc,
  ottoAgentStatusRpc,
  ottoSessionStatusRpc,
  ottoDesktopLinkRpc,
  ottoSummaryRpc,
} from "../shared/tailscale";
import { execFile } from "child_process";
import { promisify } from "util";

const execFileAsync = promisify(execFile);

// Zod schemas for parsing external Tailscale JSON output
const TailscalePeerSchema = z.object({
  TailscaleIPs: z.array(z.string()).optional(),
  Online: z.boolean().optional(),
  LastSeen: z.string().nullable().optional(),
  ExitNodeStatus: z.string().nullable().optional(),
  Relay: z.boolean().optional(),
});

const TailscaleStatusSchema = z.object({
  Self: z.object({
    TailscaleIPs: z.array(z.string()).optional(),
    DNSName: z.string().nullable().optional(),
  }).nullable().optional(),
  Peer: z.record(TailscalePeerSchema).optional(),
  Version: z.string().nullable().optional(),
  ExitNodeStatus: z.string().nullable().optional(),
  ExitNodeIP: z.string().nullable().optional(),
});

type ParsedPeer = z.infer<typeof TailscalePeerSchema> & { name: string };
type ParsedTailscaleStatus = z.infer<typeof TailscaleStatusSchema>;

interface SystemUsage {
  cpuPercent: number;
  memoryTotalMB: number;
  memoryUsedMB: number;
  memoryPercent: number;
  diskTotalGB: number;
  diskUsedGB: number;
  diskPercent: number;
  load1: number;
  load5: number;
  load15: number;
  uptimeSeconds: number;
}

const STATE_FILE = "/home/otto/.otto/host-pair-state.json";

async function runCommand(cmd: string, args: string[]): Promise<string> {
  try {
    const { stdout } = await execFileAsync(cmd, args);
    return stdout;
  } catch {
    return "";
  }
}

function parseTailscaleStatus(output: string): ParsedTailscaleStatus | null {
  try {
    const parsed = TailscaleStatusSchema.safeParse(JSON.parse(output));
    if (!parsed.success) return null;
    return parsed.data;
  } catch {
    return null;
  }
}

function parsePeers(status: ParsedTailscaleStatus): ParsedPeer[] {
  if (!status?.Peer) return [];
  return Object.entries(status.Peer).map(([name, peer]) => ({
    name,
    ip: peer.TailscaleIPs?.[0] ?? null,
    online: peer.Online ?? false,
    lastSeen: peer.LastSeen ?? null,
    exitNode: peer.ExitNodeStatus === "active",
    relay: peer.Relay ?? false,
  }));
}

function getSystemUsage(): SystemUsage {
  let cpuPercent = 0;
  let load1 = 0, load5 = 0, load15 = 0;
  let uptimeSeconds = 0;
  let memTotal = 0, memUsed = 0;
  let diskTotal = 0, diskUsed = 0;

  try {
    const uptimeOutput = runCommand("cat", ["/proc/uptime"]);
    if (uptimeOutput) {
      uptimeSeconds = Math.floor(parseFloat(uptimeOutput.split(" ")[0]) || 0);
    }

    const loadavg = runCommand("cat", ["/proc/loadavg"]);
    if (loadavg) {
      const parts = loadavg.split(" ");
      load1 = parseFloat(parts[0]) || 0;
      load5 = parseFloat(parts[1]) || 0;
      load15 = parseFloat(parts[2]) || 0;
    }

    const stat1 = runCommand("cat", ["/proc/stat"]);
    if (stat1) {
      const cpuLine = stat1.split("\n").find(l => l.startsWith("cpu "));
      if (cpuLine) {
        const vals = cpuLine.split(/\s+/).slice(1).map(Number);
        const total = vals.reduce((a: number, b: number) => a + b, 0);
        const idle = vals[3] ?? 0;
        cpuPercent = total > 0 ? Math.round(((total - idle) / total) * 100) : 0;
      }
    }

    const meminfo = runCommand("cat", ["/proc/meminfo"]);
    if (meminfo) {
      const memTotalMatch = meminfo.match(/MemTotal:\s+(\d+)/);
      const memAvailableMatch = meminfo.match(/MemAvailable:\s+(\d+)/);
      if (memTotalMatch) memTotal = parseInt(memTotalMatch[1], 10);
      if (memAvailableMatch) memUsed = memTotal - parseInt(memAvailableMatch[1], 10);
    }

    try {
      const { stdout } = execFileAsync("df", ["-B1", "/"]);
      const lines = stdout.split("\n");
      if (lines.length >= 2) {
        const parts = lines[1].split(/\s+/);
        diskTotal = parseInt(parts[1], 10);
        diskUsed = parseInt(parts[2], 10);
      }
    } catch {
      // ignore
    }
  } catch {
    // ignore all errors, return zeros
  }

  return {
    cpuPercent,
    memoryTotalMB: Math.round(memTotal / 1024),
    memoryUsedMB: Math.round(memUsed / 1024),
    memoryPercent: memTotal > 0 ? Math.round((memUsed / memTotal) * 100) : 0,
    diskTotalGB: Math.round(diskTotal / (1024 * 1024 * 1024)),
    diskUsedGB: Math.round(diskUsed / (1024 * 1024 * 1024)),
    diskPercent: diskTotal > 0 ? Math.round((diskUsed / diskTotal) * 100) : 0,
    load1,
    load5,
    load15,
    uptimeSeconds,
  };
}

async function fetchOttoDaemon(url: string): Promise<any> {
  try {
    const resp = await fetch(url, { signal: AbortSignal.timeout(3000) });
    if (!resp.ok) return null;
    return await resp.json();
  } catch {
    return null;
  }
}

function readPairedHost(): string | null {
  try {
    const state = JSON.parse(fs.readFileSync(STATE_FILE, "utf-8"));
    return state.pairedHost ?? null;
  } catch {
    return null;
  }
}

function registerTailscale(server: PluginServerContext) {
  const { otto } = server;

  // --- Tailscale status (basic) ---
  server.handle(tailscaleStatusRpc, async () => {
    const output = await runCommand("tailscale", ["status", "--json"]);
    const status = parseTailscaleStatus(output);
    if (!status) {
      return { running: false, ip: null, dns: null, online: false };
    }
    return {
      running: true,
      ip: status.Self?.TailscaleIPs?.[0] ?? null,
      dns: status.Self?.DNSName ?? null,
      online: true,
    };
  });

  // --- Tailscale full status (peers, exit node, etc.) ---
  server.handle(tailscaleFullStatusRpc, async () => {
    const output = await runCommand("tailscale", ["status", "--json"]);
    const status = parseTailscaleStatus(output);
    if (!status) {
      return {
        running: false,
        ip: null,
        dns: null,
        online: false,
        version: null,
        exitNodeStatus: null,
        exitNodeIP: null,
        peers: [],
        peerCount: 0,
        onlinePeerCount: 0,
      };
    }
    const peers = parsePeers(status);
    const onlinePeers = peers.filter(p => p.online);
    return {
      running: true,
      ip: status.Self?.TailscaleIPs?.[0] ?? null,
      dns: status.Self?.DNSName ?? null,
      online: true,
      version: status.Version ?? null,
      exitNodeStatus: status.ExitNodeStatus ?? null,
      exitNodeIP: status.ExitNodeIP ?? null,
      peers,
      peerCount: peers.length,
      onlinePeerCount: onlinePeers.length,
    };
  });

  // --- Tailscale peer list ---
  server.handle(tailscalePeersRpc, async () => {
    const output = await runCommand("tailscale", ["status", "--json"]);
    const status = parseTailscaleStatus(output);
    if (!status) return [];
    return parsePeers(status);
  });

  // --- Pair with remote host ---
  server.handle(tailscalePairRpc, async ({ hostIp, port }: RpcInput<typeof tailscalePairRpc>) => {
    try {
      const targetPort = port ?? 60774;
      await execFileAsync("ping", ["-c", "1", "-W", "2000", hostIp]);
      const daemonUrl = `http://${hostIp}:${targetPort}/api/status`;
      const resp = await fetch(daemonUrl, { signal: AbortSignal.timeout(5000) });
      if (!resp.ok) {
        return { paired: false, error: `Daemon returned ${resp.status}` };
      }
      await resp.json();
      return { paired: true };
    } catch (e) {
      return {
        paired: false,
        error: e instanceof Error ? e.message : String(e),
      };
    }
  });

  // --- Otto daemon status (basic) ---
  server.handle(ottoDaemonStatusRpc, async () => {
    const data = await fetchOttoDaemon("http://127.0.0.1:6868/api/status");
    if (!data) {
      return { running: false, version: null, serverId: null, hostname: null, listen: null };
    }
    return {
      running: true,
      version: data.version ?? null,
      serverId: data.serverId ?? null,
      hostname: data.hostname ?? null,
      listen: data.listen ?? null,
    };
  });

  // --- Otto daemon full status ---
  server.handle(ottoDaemonFullStatusRpc, async () => {
    const data = await fetchOttoDaemon("http://127.0.0.1:6868/api/status");
    if (!data) {
      return {
        running: false,
        version: null,
        serverId: null,
        hostname: null,
        listen: null,
        uptimeSeconds: null,
        memoryUsageMB: null,
        cpuPercent: null,
        activeSessions: null,
        activeAgents: null,
        providers: null,
        pluginsEnabled: null,
        relayEnabled: null,
        voiceEnabled: null,
        brainEnabled: null,
      };
    }
    return {
      running: true,
      version: data.version ?? null,
      serverId: data.serverId ?? null,
      hostname: data.hostname ?? null,
      listen: data.listen ?? null,
      uptimeSeconds: data.uptimeSeconds ?? null,
      memoryUsageMB: data.memoryUsageMB ?? null,
      cpuPercent: data.cpuPercent ?? null,
      activeSessions: data.activeSessions ?? null,
      activeAgents: data.activeAgents ?? null,
      providers: data.providers ?? null,
      pluginsEnabled: data.pluginsEnabled ?? null,
      relayEnabled: data.relayEnabled ?? null,
      voiceEnabled: data.voiceEnabled ?? null,
      brainEnabled: data.brainEnabled ?? null,
    };
  });

  // --- Pair with Otto daemon ---
  server.handle(ottoPairRpc, async ({ tailscaleIp }: RpcInput<typeof ottoPairRpc>) => {
    try {
      const resp = await fetch(`http://${tailscaleIp}:6868/api/status`, {
        signal: AbortSignal.timeout(5000),
      });
      if (!resp.ok) {
        return { paired: false, error: `Daemon returned ${resp.status}` };
      }
      await resp.json();
      return { paired: true };
    } catch (e) {
      return {
        paired: false,
        error: e instanceof Error ? e.message : String(e),
      };
    }
  });

  // --- Otto daemon features ---
  server.handle(ottoFeaturesRpc, async () => {
    try {
      const resp = await fetch("http://127.0.0.1:6868/", {
        signal: AbortSignal.timeout(3000),
      });
      const text = await resp.text();
      return {
        pluginsEnabled: text.includes("pluginsEnabled") || true,
        relayEnabled: true,
        voiceEnabled: true,
        brainEnabled: false,
      };
    } catch (e) {
      return {
        pluginsEnabled: false,
        relayEnabled: false,
        voiceEnabled: false,
        brainEnabled: false,
      };
    }
  });

  // --- System usage ---
  server.handle(ottoSystemUsageRpc, async () => {
    return getSystemUsage();
  });

  // --- Agent status ---
  server.handle(ottoAgentStatusRpc, async (_input, context) => {
    try {
      const result = await context.otto.agents.list({});
      const entries = result.entries ?? [];

      const agents = entries.map((entry: any) => ({
        id: entry.agentId ?? entry.id ?? "",
        title: entry.title ?? null,
        provider: entry.provider ?? "unknown",
        status: entry.status ?? "unknown",
        workspaceId: entry.workspaceId ?? null,
        cwd: entry.cwd ?? "",
        lastTurnOutcome: entry.lastTurnOutcome ?? null,
        lastTurnError: entry.lastTurnError ?? null,
        lastTurnCompletedAt: entry.lastTurnCompletedAt ?? null,
      }));

      const activeAgents = agents.filter(a => a.status === "active" || a.status === "running").length;
      const failedAgents = agents.filter(a => a.lastTurnOutcome === "failed").length;

      return {
        totalAgents: agents.length,
        activeAgents,
        failedAgents,
        agents,
      };
    } catch (e) {
      return {
        totalAgents: 0,
        activeAgents: 0,
        failedAgents: 0,
        agents: [],
      };
    }
  });

  // --- Session status ---
  server.handle(ottoSessionStatusRpc, async (_input, context) => {
    try {
      const result = await context.otto.agents.list({});
      const entries = result.entries ?? [];

      const totalSessions = entries.length;
      const activeSessions = entries.filter((e: any) => e.status === "active" || e.status === "running").length;
      const completedSessions = entries.filter((e: any) => e.lastTurnOutcome === "completed").length;
      const failedSessions = entries.filter((e: any) => e.lastTurnOutcome === "failed").length;

      return {
        totalSessions,
        activeSessions,
        completedSessions,
        failedSessions,
        sessionLimits: {
          maxConcurrent: null,
          maxPerWorkspace: null,
          currentConcurrent: activeSessions,
        },
      };
    } catch (e) {
      return {
        totalSessions: 0,
        activeSessions: 0,
        completedSessions: 0,
        failedSessions: 0,
        sessionLimits: {
          maxConcurrent: null,
          maxPerWorkspace: null,
          currentConcurrent: 0,
        },
      };
    }
  });

  // --- Desktop app link ---
  server.handle(ottoDesktopLinkRpc, async ({ path }: RpcInput<typeof ottoDesktopLinkRpc>) => {
    const url = path ? `otto://${path}` : "otto://";
    return { url };
  });

  // --- Combined summary ---
  server.handle(ottoSummaryRpc, async (_input, context) => {
    const tailscaleOutput = await runCommand("tailscale", ["status", "--json"]);
    const tsStatus = parseTailscaleStatus(tailscaleOutput);
    const tsPeers = tsStatus ? parsePeers(tsStatus) : [];
    const tsOnline = tsPeers.filter(p => p.online);

    const otto = await fetchOttoDaemon("http://127.0.0.1:6868/api/status");
    const system = getSystemUsage();
    const pairedHost = readPairedHost();

    // Get agent/session status via SDK
    let agentStatus: any = { totalAgents: 0, activeAgents: 0, failedAgents: 0 };
    let sessionStatus: any = { totalSessions: 0, activeSessions: 0, completedSessions: 0, failedSessions: 0 };
    try {
      agentStatus = await context.otto.agents.list({});
    } catch {
      // ignore
    }

    const agentEntries = agentStatus.entries ?? [];
    const activeAgentsCount = agentEntries.filter((e: any) => e.status === "active" || e.status === "running").length;
    const failedAgentsCount = agentEntries.filter((e: any) => e.lastTurnOutcome === "failed").length;

    return {
      tailscale: {
        running: tsStatus ? true : false,
        ip: tsStatus?.Self?.TailscaleIPs?.[0] ?? null,
        online: tsStatus ? true : false,
        peerCount: tsPeers.length,
        onlinePeerCount: tsOnline.length,
      },
      otto: {
        running: otto ? true : false,
        version: otto?.version ?? null,
        activeSessions: otto?.activeSessions ?? null,
        activeAgents: otto?.activeAgents ?? null,
        pluginsEnabled: otto?.pluginsEnabled ?? null,
        relayEnabled: otto?.relayEnabled ?? null,
      },
      agents: {
        total: agentEntries.length,
        active: activeAgentsCount,
        failed: failedAgentsCount,
      },
      sessions: {
        total: agentEntries.length,
        active: activeAgentsCount,
        completed: agentEntries.filter((e: any) => e.lastTurnOutcome === "completed").length,
        failed: failedAgentsCount,
      },
      system,
    };

    // Write status file for desktop QML consumption
    try {
      const summary = {
        tailscale: {
          running: tsStatus ? true : false,
          ip: tsStatus?.Self?.TailscaleIPs?.[0] ?? null,
          online: tsStatus ? true : false,
          peerCount: tsPeers.length,
          onlinePeerCount: tsOnline.length,
        },
        otto: {
          running: otto ? true : false,
          version: otto?.version ?? null,
          activeSessions: otto?.activeSessions ?? null,
          activeAgents: otto?.activeAgents ?? null,
        },
        agents: {
          total: agentEntries.length,
          active: activeAgentsCount,
          failed: failedAgentsCount,
        },
        sessions: {
          total: agentEntries.length,
          active: activeAgentsCount,
          completed: agentEntries.filter((e: any) => e.lastTurnOutcome === "completed").length,
          failed: failedAgentsCount,
        },
        system,
        paired: pairedHost !== null,
        pairedHost,
        updatedAt: new Date().toISOString(),
      };
      fs.writeFileSync("/home/otto/.otto/host-pair-summary.json", JSON.stringify(summary, null, 2));
    } catch {
      // ignore
    }
  });
}

export { registerTailscale };
