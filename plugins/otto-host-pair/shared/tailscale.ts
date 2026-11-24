import { defineRpc } from "@otto-code/plugin";
import { z } from "zod";

// --- Tailscale ---

export const tailscaleStatusRpc = defineRpc({
  name: "tailscale.status",
  input: z.object({}),
  output: z.object({
    running: z.boolean(),
    ip: z.string().nullable(),
    dns: z.string().nullable(),
    online: z.boolean(),
  }),
});

export const tailscaleFullStatusRpc = defineRpc({
  name: "tailscale.fullStatus",
  input: z.object({}),
  output: z.object({
    running: z.boolean(),
    ip: z.string().nullable(),
    dns: z.string().nullable(),
    online: z.boolean(),
    version: z.string().nullable(),
    exitNodeStatus: z.string().nullable(),
    exitNodeIP: z.string().nullable(),
    peers: z.array(
      z.object({
        name: z.string(),
        ip: z.string(),
        online: z.boolean(),
        lastSeen: z.string().nullable(),
        exitNode: z.boolean().optional(),
        relay: z.boolean().optional(),
      })
    ),
    peerCount: z.number(),
    onlinePeerCount: z.number(),
  }),
});

export const tailscalePeersRpc = defineRpc({
  name: "tailscale.peers",
  input: z.object({}),
  output: z.array(
    z.object({
      name: z.string(),
      ip: z.string(),
      online: z.boolean(),
      lastSeen: z.string().nullable(),
      location: z.string().nullable(),
    })
  ),
});

export const tailscalePairRpc = defineRpc({
  name: "tailscale.pair",
  input: z.object({
    hostIp: z.string(),
    port: z.number().optional(),
  }),
  output: z.object({
    paired: z.boolean(),
    error: z.string().optional(),
  }),
});

// --- Otto Daemon ---

export const ottoDaemonStatusRpc = defineRpc({
  name: "otto.daemon.status",
  input: z.object({}),
  output: z.object({
    running: z.boolean(),
    version: z.string().nullable(),
    serverId: z.string().nullable(),
    hostname: z.string().nullable(),
    listen: z.string().nullable(),
  }),
});

export const ottoDaemonFullStatusRpc = defineRpc({
  name: "otto.daemon.fullStatus",
  input: z.object({}),
  output: z.object({
    running: z.boolean(),
    version: z.string().nullable(),
    serverId: z.string().nullable(),
    hostname: z.string().nullable(),
    listen: z.string().nullable(),
    uptimeSeconds: z.number().nullable(),
    memoryUsageMB: z.number().nullable(),
    cpuPercent: z.number().nullable(),
    activeSessions: z.number().nullable(),
    activeAgents: z.number().nullable(),
    providers: z.array(z.string()).nullable(),
    pluginsEnabled: z.boolean().nullable(),
    relayEnabled: z.boolean().nullable(),
    voiceEnabled: z.boolean().nullable(),
    brainEnabled: z.boolean().nullable(),
  }),
});

export const ottoPairRpc = defineRpc({
  name: "otto.pair",
  input: z.object({
    tailscaleIp: z.string(),
  }),
  output: z.object({
    paired: z.boolean(),
    error: z.string().optional(),
  }),
});

export const ottoFeaturesRpc = defineRpc({
  name: "otto.features",
  input: z.object({}),
  output: z.object({
    pluginsEnabled: z.boolean(),
    relayEnabled: z.boolean(),
    voiceEnabled: z.boolean(),
    brainEnabled: z.boolean(),
  }),
});

// --- System Usage ---

export const ottoSystemUsageRpc = defineRpc({
  name: "otto.system.usage",
  input: z.object({}),
  output: z.object({
    cpuPercent: z.number(),
    memoryTotalMB: z.number(),
    memoryUsedMB: z.number(),
    memoryPercent: z.number(),
    diskTotalGB: z.number(),
    diskUsedGB: z.number(),
    diskPercent: z.number(),
    load1: z.number(),
    load5: z.number(),
    load15: z.number(),
    uptimeSeconds: z.number(),
  }),
});

// --- Agent / Session Status ---

export const ottoAgentStatusRpc = defineRpc({
  name: "otto.agent.status",
  input: z.object({}),
  output: z.object({
    totalAgents: z.number(),
    activeAgents: z.number(),
    failedAgents: z.number(),
    agents: z.array(
      z.object({
        id: z.string(),
        title: z.string().nullable(),
        provider: z.string(),
        status: z.string(),
        workspaceId: z.string().nullable(),
        cwd: z.string(),
        lastTurnOutcome: z.string().nullable(),
        lastTurnError: z.string().nullable(),
        lastTurnCompletedAt: z.string().nullable(),
      })
    ),
  }),
});

export const ottoSessionStatusRpc = defineRpc({
  name: "otto.session.status",
  input: z.object({}),
  output: z.object({
    totalSessions: z.number(),
    activeSessions: z.number(),
    completedSessions: z.number(),
    failedSessions: z.number(),
    sessionLimits: z.object({
      maxConcurrent: z.number().nullable(),
      maxPerWorkspace: z.number().nullable(),
      currentConcurrent: z.number().nullable(),
    }),
  }),
});

// --- Desktop App Link ---

export const ottoDesktopLinkRpc = defineRpc({
  name: "otto.desktop.link",
  input: z.object({
    path: z.string().optional(),
  }),
  output: z.object({
    url: z.string(),
  }),
});

// --- Summary ---

export const ottoSummaryRpc = defineRpc({
  name: "otto.summary",
  input: z.object({}),
  output: z.object({
    tailscale: z.object({
      running: z.boolean(),
      ip: z.string().nullable(),
      online: z.boolean(),
      peerCount: z.number(),
      onlinePeerCount: z.number(),
    }),
    otto: z.object({
      running: z.boolean(),
      version: z.string().nullable(),
      activeSessions: z.number().nullable(),
      activeAgents: z.number().nullable(),
      pluginsEnabled: z.boolean().nullable(),
      relayEnabled: z.boolean().nullable(),
    }),
    agents: z.object({
      total: z.number(),
      active: z.number(),
      failed: z.number(),
    }),
    sessions: z.object({
      total: z.number(),
      active: z.number(),
      completed: z.number(),
      failed: z.number(),
    }),
    system: z.object({
      cpuPercent: z.number(),
      memoryPercent: z.number(),
      diskPercent: z.number(),
    }),
    paired: z.boolean(),
    pairedHost: z.string().nullable(),
  }),
});
