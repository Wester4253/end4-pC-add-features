import type { PluginSurfaceProps } from "@otto-code/plugin/client";
import { useRpc } from "@otto-code/plugin/client";
import { useQuery } from "@tanstack/react-query";
import { useMemo, useState } from "react";
import { Pressable, Text, TextInput, View, ScrollView, ActivityIndicator } from "react-native";
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
import { openExternal } from "./web";

export function PairSurface({ theme, layout }: PluginSurfaceProps) {
  const c = theme.colors;

  // --- RPCs ---
  const rpcTailscaleStatus = useRpc(tailscaleStatusRpc);
  const rpcTailscaleFull = useRpc(tailscaleFullStatusRpc);
  const rpcTailscalePeers = useRpc(tailscalePeersRpc);
  const rpcOttoStatus = useRpc(ottoDaemonStatusRpc);
  const rpcOttoFull = useRpc(ottoDaemonFullStatusRpc);
  const rpcOttoFeatures = useRpc(ottoFeaturesRpc);
  const rpcSystemUsage = useRpc(ottoSystemUsageRpc);
  const rpcAgentStatus = useRpc(ottoAgentStatusRpc);
  const rpcSessionStatus = useRpc(ottoSessionStatusRpc);
  const rpcSummary = useRpc(ottoSummaryRpc);
  const rpcOpenDesktop = useRpc(ottoDesktopLinkRpc);

  // --- Queries ---
  const tailscaleStatus = useQuery({
    queryKey: ["tailscale-status"],
    queryFn: async () => rpcTailscaleStatus({}),
  });
  const tailscaleFull = useQuery({
    queryKey: ["tailscale-full"],
    queryFn: async () => rpcTailscaleFull({}),
  });
  const tailscalePeers = useQuery({
    queryKey: ["tailscale-peers"],
    queryFn: async () => rpcTailscalePeers({}),
  });
  const ottoStatus = useQuery({
    queryKey: ["otto-status"],
    queryFn: async () => rpcOttoStatus({}),
  });
  const ottoFull = useQuery({
    queryKey: ["otto-full"],
    queryFn: async () => rpcOttoFull({}),
  });
  const ottoFeatures = useQuery({
    queryKey: ["otto-features"],
    queryFn: async () => rpcOttoFeatures({}),
  });
  const systemUsage = useQuery({
    queryKey: ["system-usage"],
    queryFn: async () => rpcSystemUsage({}),
  });
  const agentStatus = useQuery({
    queryKey: ["agent-status"],
    queryFn: async () => rpcAgentStatus({}),
  });
  const sessionStatus = useQuery({
    queryKey: ["session-status"],
    queryFn: async () => rpcSessionStatus({}),
  });
  const summary = useQuery({
    queryKey: ["otto-summary"],
    queryFn: async () => rpcSummary({}),
  });

  const [hostIp, setHostIp] = useState("");
  const [showDetails, setShowDetails] = useState(false);
  const [desktopUrl, setDesktopUrl] = useState<string | null>(null);

  const styles = useMemo(
    () => ({
      screen: {
        flex: 1,
        padding: layout.compact ? 12 : 20,
        backgroundColor: c.surface0,
      },
      card: {
        backgroundColor: c.surface1,
        borderRadius: 12,
        padding: layout.compact ? 16 : 20,
        marginBottom: 16,
      },
      title: {
        fontSize: layout.compact ? 18 : 20,
        fontWeight: "600" as const,
        color: c.foreground,
        marginBottom: 8,
      },
      subtitle: {
        fontSize: 14,
        color: c.foregroundMuted,
        marginBottom: 16,
      },
      statusRow: {
        flexDirection: "row",
        alignItems: "center" as const,
        gap: 8,
        marginBottom: 8,
      },
      statusRowCompact: {
        flexDirection: "row",
        alignItems: "center" as const,
        gap: 6,
        marginBottom: 6,
      },
      statusLabel: {
        fontSize: 13,
        color: c.foregroundMuted,
        flex: 1,
      },
      statusValue: {
        fontSize: 13,
        fontWeight: "500" as const,
        color: c.foreground,
      },
      statusValueOk: {
        fontSize: 13,
        fontWeight: "500" as const,
        color: c.statusSuccess,
      },
      statusValueWarn: {
        fontSize: 13,
        fontWeight: "500" as const,
        color: c.statusWarning,
      },
      statusValueError: {
        fontSize: 13,
        fontWeight: "500" as const,
        color: c.statusDanger,
      },
      divider: {
        height: 1,
        backgroundColor: c.border,
        marginVertical: 10,
      },
      input: {
        backgroundColor: c.surface2,
        borderColor: c.border,
        borderWidth: 1,
        borderRadius: 8,
        paddingHorizontal: 12,
        paddingVertical: 10,
        color: c.foreground,
        fontSize: 14,
        marginBottom: 12,
      },
      button: {
        backgroundColor: c.accent,
        borderRadius: 8,
        paddingVertical: 12,
        paddingHorizontal: 16,
        alignItems: "center" as const,
        marginBottom: 8,
      },
      buttonText: {
        color: c.accentForeground,
        fontWeight: "600" as const,
        fontSize: 14,
      },
      buttonDisabled: {
        backgroundColor: c.surface2,
      },
      link: {
        color: c.accent,
        fontSize: 14,
        textDecorationLine: "underline" as const,
      },
      error: {
        color: c.statusDanger,
        fontSize: 12,
        marginTop: 8,
      },
      success: {
        color: c.statusSuccess,
        fontSize: 12,
        marginTop: 8,
      },
      peerItem: {
        flexDirection: "row",
        alignItems: "center" as const,
        justifyContent: "space-between" as const,
        paddingVertical: 6,
        paddingHorizontal: 4,
        borderBottomWidth: 1,
        borderBottomColor: c.border,
      },
      peerName: {
        fontSize: 13,
        color: c.foreground,
        fontWeight: "500" as const,
      },
      peerIp: {
        fontSize: 12,
        color: c.foregroundMuted,
      },
      toggleButton: {
        backgroundColor: c.surface2,
        borderRadius: 8,
        paddingVertical: 10,
        paddingHorizontal: 16,
        marginBottom: 8,
        flexDirection: "row",
        justifyContent: "space-between" as const,
        alignItems: "center" as const,
      },
      agentItem: {
        flexDirection: "row",
        alignItems: "center" as const,
        justifyContent: "space-between" as const,
        paddingVertical: 6,
        paddingHorizontal: 4,
        borderBottomWidth: 1,
        borderBottomColor: c.border,
      },
      agentName: {
        fontSize: 13,
        color: c.foreground,
        fontWeight: "500" as const,
      },
      agentMeta: {
        fontSize: 11,
        color: c.foregroundMuted,
      },
    }) as any,
    [theme, layout.compact],

  const ts = tailscaleFull.data;
  const tsPeers = tailscalePeers.data ?? [];
  const ot = ottoFull.data;
  const su = systemUsage.data;
  const ag = agentStatus.data;
  const se = sessionStatus.data;
  const summ = summary.data;
  const tsBasic = tailscaleStatus.data;
  const tsIp = tsBasic?.ip ?? "";
  const tsDns = tsBasic?.dns ?? "";
  const ottoRunning = otBasic?.running ?? false;
  const paired = summ?.paired ?? false;
  const pairedHost = summ?.pairedHost ?? null;

  const statusColor = (ok: boolean) =>
    ok ? styles.statusValueOk : styles.statusValueError;

  const handleOpenDesktop = async () => {
    const result = await rpcOpenDesktop({});
    setDesktopUrl(result.url);
  };

  return (
    <ScrollView style={styles.screen}>
      <View style={styles.card}>
        <Text style={styles.title}>Otto Host Pair</Text>
        <Text style={styles.subtitle}>
          Full status, usage, agent/session info, and desktop app links.
        </Text>

        <View style={styles.statusRow}>
          <Text style={styles.statusLabel}>Tailscale</Text>
          <Text style={statusColor(tsRunning)}>
            {tsRunning ? "Online" : "Offline"}
          </Text>
        </View>
        {tsIp && (
          <View style={styles.statusRowCompact}>
            <Text style={styles.statusLabel}>IP</Text>
            <Text style={styles.statusValue}>{tsIp}</Text>
          </View>
        )}
        {tsDns && (
          <View style={styles.statusRowCompact}>
            <Text style={styles.statusLabel}>DNS</Text>
            <Text style={styles.statusValue}>{tsDns}</Text>
          </View>
        )}

        <View style={styles.statusRow}>
          <Text style={styles.statusLabel}>Otto Daemon</Text>
          <Text style={statusColor(ottoRunning)}>
            {ottoRunning ? "Running" : "Stopped"}
          </Text>
        </View>

        <View style={styles.statusRow}>
          <Text style={styles.statusLabel}>Paired</Text>
          <Text style={statusColor(paired)}>
            {paired ? "Yes" : "No"}
          </Text>
        </View>
        {pairedHost && (
          <View style={styles.statusRowCompact}>
            <Text style={styles.statusLabel}>Host</Text>
            <Text style={styles.statusValue}>{pairedHost}</Text>
          </View>
        )}

        <View style={styles.divider} />

        {su && (
          <>
            <View style={styles.statusRowCompact}>
              <Text style={styles.statusLabel}>CPU</Text>
              <Text style={styles.statusValue}>{su.cpuPercent}%</Text>
            </View>
            <View style={styles.statusRowCompact}>
              <Text style={styles.statusLabel}>Memory</Text>
              <Text style={styles.statusValue}>
                {su.memoryUsedMB} MB / {su.memoryTotalMB} MB ({su.memoryPercent}%)
              </Text>
            </View>
            <View style={styles.statusRowCompact}>
              <Text style={styles.statusLabel}>Disk</Text>
              <Text style={styles.statusValue}>
                {su.diskUsedGB} GB / {su.diskTotalGB} GB ({su.diskPercent}%)
              </Text>
            </View>
            <View style={styles.statusRowCompact}>
              <Text style={styles.statusLabel}>Load</Text>
              <Text style={styles.statusValue}>
                {su.load1.toFixed(2)} / {su.load5.toFixed(2)} / {su.load15.toFixed(2)}
              </Text>
            </View>
            <View style={styles.statusRowCompact}>
              <Text style={styles.statusLabel}>Uptime</Text>
              <Text style={styles.statusValue}>
                {Math.floor(su.uptimeSeconds / 3600)}h
                {Math.floor((su.uptimeSeconds % 3600) / 60)}m
              </Text>
            </View>
          </>
        )}

        {ag && (
          <>
            <View style={styles.statusRowCompact}>
              <Text style={styles.statusLabel}>Agents</Text>
              <Text style={styles.statusValue}>
                {ag.activeAgents} active / {ag.totalAgents} total
              </Text>
            </View>
            {ag.failedAgents > 0 && (
              <View style={styles.statusRowCompact}>
                <Text style={styles.statusLabel}>Failed</Text>
                <Text style={styles.statusValueError}>
                  {ag.failedAgents}
                </Text>
              </View>
            )}
          </>
        )}

        {se && (
          <>
            <View style={styles.statusRowCompact}>
              <Text style={styles.statusLabel}>Sessions</Text>
              <Text style={styles.statusValue}>
                {se.activeSessions} active / {se.totalSessions} total
              </Text>
            </View>
            {se.failedSessions > 0 && (
              <View style={styles.statusRowCompact}>
                <Text style={styles.statusLabel}>Failed</Text>
                <Text style={styles.statusValueError}>
                  {se.failedSessions}
                </Text>
              </View>
            )}
          </>
        )}
      </View>

      <View style={styles.card}>
        <Text style={styles.title}>Open in Otto Desktop</Text>
        <Text style={styles.subtitle}>
          Launch the Otto desktop app directly from this surface.
        </Text>
        <Pressable style={styles.button} onPress={handleOpenDesktop}>
          <Text style={styles.buttonText}>
            {openDesktop.isPending ? "Opening…" : "Open Otto Desktop App"}
          </Text>
        </Pressable>
        {desktopUrl && (
          <View style={styles.statusRowCompact}>
            <Text style={styles.statusLabel}>Deep link</Text>
            <Text style={styles.statusValue}>{desktopUrl}</Text>
          </View>
        )}
      </View>

      <Pressable
        style={styles.toggleButton}
        onPressed={() => setShowDetails(!showDetails)}
      >
        <Text style={{ ...styles.buttonText, color: c.accent }}>
          {showDetails ? "Hide" : "Show"} Tailscale Details
        </Text>
      </Pressable>

      {showDetails && ts && (
        <View style={styles.card}>
          <Text style={styles.title}>Tailscale Network</Text>

          <View style={styles.statusRowCompact}>
            <Text style={styles.statusLabel}>Version</Text>
            <Text style={styles.statusValue}>{ts.version ?? "unknown"}</Text>
          </View>
          <View style={styles.statusRowCompact}>
            <Text style={styles.statusLabel}>Exit Node</Text>
            <Text style={styles.statusValue}>
              {ts.exitNodeStatus ?? "none"}
            </Text>
          </View>
          <View style={styles.statusRowCompact}>
            <Text style={styles.statusLabel}>Peers</Text>
            <Text style={styles.statusValue}>
              {ts.onlinePeerCount} online / {ts.peerCount} total
            </Text>
          </View>

          {tsPeers.length > 0 && (
            <>
              <Text style={styles.subtitle} style={{ marginTop: 10 }}>
                Peers
              </Text>
              {tsPeers.map((peer) => (
                <View
                  key={peer.ip ?? peer.name}
                  style={styles.peerItem}
                >
                  <View>
                    <Text style={styles.peerName}>{peer.name}</Text>
                    <Text style={styles.peerIp}>
                      {peer.ip ?? "—"} • {peer.online ? "Online" : "Offline"}
                    </Text>
                  </View>
                  <Text
                    style={{
                      fontSize: 11,
                      color: peer.online ? c.statusSuccess : c.statusDanger,
                    }}
                  >
                    {peer.exitNode ? "EXIT" : ""}
                  </Text>
                </View>
              ))}
            </>
          )}
        </View>
      )}

      <Pressable
        style={styles.toggleButton}
        onPressed={() => setShowDetails(!showDetails)}
      >
        <Text style={{ ...styles.buttonText, color: c.accent }}>
          {showDetails ? "Hide" : "Show"} Otto Daemon Details
        </Text>
      </Pressable>

      {showDetails && ot && (
        <View style={styles.card}>
          <Text style={styles.title}>Otto Daemon</Text>

          <View style={styles.statusRowCompact}>
            <Text style={styles.statusLabel}>Version</Text>
            <Text style={styles.statusValue}>{ot.version ?? "unknown"}</Text>
          </View>
          <View style={styles.statusRowCompact}>
            <Text style={styles.statusLabel}>Server ID</Text>
            <Text style={styles.statusValue}>{ot.serverId ?? "—"}</Text>
          </View>
          <View style={styles.statusRowCompact}>
            <Text style={styles.statusLabel}>Hostname</Text>
            <Text style={styles.statusValue}>{ot.hostname ?? "—"}</Text>
          </View>
          <View style={styles.statusRowCompact}>
            <Text style={styles.statusLabel}>Listen</Text>
            <Text style={styles.statusValue}>{ot.listen ?? "—"}</Text>
          </View>
          <View style={styles.statusRowCompact}>
            <Text style={styles.statusLabel}>Sessions</Text>
            <Text style={styles.statusValue}>
              {ot.activeSessions ?? "—"}
            </Text>
          </View>
          <View style={styles.statusRowCompact}>
            <Text style={styles.statusLabel}>Agents</Text>
            <Text style={styles.statusValue}>
              {ot.activeAgents ?? "—"}
            </Text>
          </View>
        </View>
      )}

      <Pressable
        style={styles.toggleButton}
        onPressed={() => setShowDetails(!showDetails)}
      >
        <Text style={{ ...styles.buttonText, color: c.accent }}>
          {showDetails ? "Hide" : "Show"} Agent Status
        </Text>
      </Pressable>

      {showDetails && ag && ag.agents.length > 0 && (
        <View style={styles.card}>
          <Text style={styles.title}>Agents</Text>
          {ag.agents.map((agent: any) => (
            <View key={agent.id} style={styles.agentItem}>
              <View>
                <Text style={styles.agentName}>
                  {agent.title ?? "Untitled"}
                </Text>
                <Text style={styles.agentMeta}>
                  {agent.provider} • {agent.status}
                </Text>
              </View>
              <Text
                style={{
                  fontSize: 11,
                  color:
                    agent.lastTurnOutcome === "failed"
                      ? c.statusDanger
                    : agent.status === "active" ||
                      agent.status === "running"
                      ? c.statusSuccess
                      : c.foregroundMuted,
                }}
              >
                {agent.lastTurnOutcome ?? "—"}
              </Text>
            </View>
          ))}
        </View>
      )}

      <View style={styles.card}>
        <Text style={styles.title}>Pair New Host</Text>
        <Text style={styles.subtitle}>
          Connect to a remote Otto daemon over Tailscale.
        </Text>

        <TextInput
          style={styles.input}
          placeholder="Remote Tailscale IP (e.g. 100.x.y.z)"
          value={hostIp}
          onChangeText={setHostIp}
          autoCapitalize="none"
        />

        <Pressable
          style={[styles.button, !tsRunning || !hostIp ? styles.buttonDisabled : {}]}
          disabled={!tsRunning || !hostIp}
          onPress={async () => {
            try {
              await rpcTailscalePairRpc({ hostIp });
              setHostIp("");
            } catch (e) {
              console.error("Pair failed:", e);
            }
          }}
        >
          <Text style={styles.buttonText}>
            {tsRunning ? "Pair Tailscale Host" : "Tailscale Offline"}
          </Text>
        </Pressable>

        <View style={styles.divider} />

        <Pressable
          style={[styles.button, !tsRunning || !hostIp ? styles.buttonDisabled : {}]}
          disabled={!tsRunning || !hostIp}
          onPress={async () => {
            try {
              await rpcOttoPairRpc({ tailscaleIp: hostIp });
              setHostIp("");
            } catch (e) {
              console.error("Link failed:", e);
            }
          }}
        >
          <Text style={styles.buttonText}>
            {tsRunning ? "Link Otto Daemon" : "Tailscale Offline"}
          </Text>
        </Pressable>
      </View>

      <View style={styles.card}>
        <Text style={styles.title}>Daemon Features</Text>
        {ottoFeatures.isPending ? (
          <ActivityIndicator size="small" />
        ) : (
          <>
            <View style={styles.statusRowCompact}>
              <Text style={styles.statusLabel}>Plugins</Text>
              <Text style={statusColor(ottoFeatures.data?.pluginsEnabled ?? false)}>
                {ottoFeatures.data?.pluginsEnabled ? "On" : "Off"}
              </Text>
            </View>
            <View style={styles.statusRowCompact}>
              <Text style={styles.statusLabel}>Relay</Text>
              <Text style={statusColor(ottoFeatures.data?.relayEnabled ?? false)}>
                {ottoFeatures.data?.relayEnabled ? "On" : "Off"}
              </Text>
            </View>
            <View style={styles.statusRowCompact}>
              <Text style={styles.statusLabel}>Voice</Text>
              <Text style={statusColor(ottoFeatures.data?.voiceEnabled ?? false)}>
                {ottoFeatures.data?.voiceEnabled ? "On" : "Off"}
              </Text>
            </View>
            <View style={styles.statusRowCompact}>
              <Text style={styles.statusLabel}>Brain</Text>
              <Text style={statusColor(ottoFeatures.data?.brainEnabled ?? false)}>
                {ottoFeatures.data?.brainEnabled ? "On" : "Off"}
              </Text>
            </View>
          </>
        )}
      </View>

      <View style={styles.card}>
        <Text style={styles.title}>Otto Desktop App</Text>
        <Text style={styles.subtitle}>
          Use the Otto desktop app (not the web UI) to manage agents, plugins,
          and settings locally.
        </Text>
      </View>
    </ScrollView>
  );
}
