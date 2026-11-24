import type { PluginSurfaceProps } from "@otto-code/plugin/client";
import { useRpc } from "@otto-code/plugin/client";
import { useMutation, useQuery, useState } from "@tanstack/react-query";
import { useMemo } from "react";
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
  // --- Queries ---
  const tailscaleStatus = useQuery({
    queryKey: ["tailscale-status"],
    queryFn: useRpc(tailscaleStatusRpc),
  });

  const tailscaleFull = useQuery({
    queryKey: ["tailscale-full"],
    queryFn: useRpc(tailscaleFullStatusRpc),
  });

  const tailscalePeers = useQuery({
    queryKey: ["tailscale-peers"],
    queryFn: useRpc(tailscalePeersRpc),
  });

  const ottoStatus = useQuery({
    queryKey: ["otto-status"],
    queryFn: useRpc(ottoDaemonStatusRpc),
  });

  const ottoFull = useQuery({
    queryKey: ["otto-full"],
    queryFn: useRpc(ottoDaemonFullStatusRpc),
  });

  const ottoFeatures = useQuery({
    queryKey: ["otto-features"],
    queryFn: useRpc(ottoFeaturesRpc),
  });

  const systemUsage = useQuery({
    queryKey: ["system-usage"],
    queryFn: useRpc(ottoSystemUsageRpc),
  });

  const agentStatus = useQuery({
    queryKey: ["agent-status"],
    queryFn: useRpc(ottoAgentStatusRpc),
  });

  const sessionStatus = useQuery({
    queryKey: ["session-status"],
    queryFn: useRpc(ottoSessionStatusRpc),
  });

  const summary = useQuery({
    queryKey: ["otto-summary"],
    queryFn: useRpc(ottoSummaryRpc),
  });

  // --- Mutations ---
  const pairTailscale = useMutation({
    mutationFn: useRpc(tailscalePairRpc),
  });

  const pairOtto = useMutation({
    mutationFn: useRpc(ottoPairRpc),
  });

  const openDesktop = useMutation({
    mutationFn: useRpc(ottoDesktopLinkRpc),
  });

  // --- Local state ---
  const [hostIp, setHostIp] = useState("");
  const [showDetails, setShowDetails] = useState(false);
  const [desktopUrl, setDesktopUrl] = useState<string | null>(null);

  const styles = useMemo(
    () => ({
      screen: {
        flex: 1,
        padding: layout.compact ? 12 : 20,
        backgroundColor: theme.colors.surface0,
      },
      card: {
        backgroundColor: theme.colors.surface1,
        borderRadius: 12,
        padding: layout.compact ? 16 : 20,
        marginBottom: 16,
      },
      title: {
        fontSize: layout.compact ? 18 : 20,
        fontWeight: "600" as const,
        color: theme.colors.foreground,
        marginBottom: 8,
      },
      subtitle: {
        fontSize: 14,
        color: theme.colors.subtext,
        marginBottom: 16,
      },
      statusRow: {
        flexDirection: "row",
        alignItems: "center",
        gap: 8,
        marginBottom: 8,
      },
      statusRowCompact: {
        flexDirection: "row",
        alignItems: "center",
        gap: 6,
        marginBottom: 6,
      },
      statusLabel: {
        fontSize: 13,
        color: theme.colors.subtext,
        flex: 1,
      },
      statusValue: {
        fontSize: 13,
        fontWeight: "500" as const,
        color: theme.colors.foreground,
      },
      statusValueOk: {
        fontSize: 13,
        fontWeight: "500" as const,
        color: theme.colors.success,
      },
      statusValueWarn: {
        fontSize: 13,
        fontWeight: "500" as const,
        color: theme.colors.warning,
      },
      statusValueError: {
        fontSize: 13,
        fontWeight: "500" as const,
        color: theme.colors.error,
      },
      divider: {
        height: 1,
        backgroundColor: theme.colors.outlineVariant,
        marginVertical: 10,
      },
      input: {
        backgroundColor: theme.colors.surface2,
        borderColor: theme.colors.outline,
        borderWidth: 1,
        borderRadius: 8,
        paddingHorizontal: 12,
        paddingVertical: 10,
        color: theme.colors.foreground,
        fontSize: 14,
        marginBottom: 12,
      },
      button: {
        backgroundColor: theme.colors.primary,
        borderRadius: 8,
        paddingVertical: 12,
        paddingHorizontal: 16,
        alignItems: "center" as const,
        marginBottom: 8,
      },
      buttonText: {
        color: theme.colors.onPrimary,
        fontWeight: "600" as const,
        fontSize: 14,
      },
      buttonDisabled: {
        backgroundColor: theme.colors.surface2,
      },
      link: {
        color: theme.colors.primary,
        fontSize: 14,
        textDecorationLine: "underline" as const,
      },
      error: {
        color: theme.colors.error,
        fontSize: 12,
        marginTop: 8,
      },
      success: {
        color: theme.colors.success,
        fontSize: 12,
        marginTop: 8,
      },
      peerItem: {
        flexDirection: "row",
        alignItems: "center",
        justifyContent: "space-between",
        paddingVertical: 6,
        paddingHorizontal: 4,
        borderBottomWidth: 1,
        borderBottomColor: theme.colors.outlineVariant,
      },
      peerName: {
        fontSize: 13,
        color: theme.colors.foreground,
        fontWeight: "500" as const,
      },
      peerIp: {
        fontSize: 12,
        color: theme.colors.colSubtext,
      },
      toggleButton: {
        backgroundColor: theme.colors.surface2,
        borderRadius: 8,
        paddingVertical: 10,
        paddingHorizontal: 16,
        marginBottom: 8,
        flexDirection: "row" as const,
        justifyContent: "space-between" as const,
        alignItems: "center" as const,
      },
      agentItem: {
        flexDirection: "row",
        alignItems: "center",
        justifyContent: "space-between",
        paddingVertical: 6,
        paddingHorizontal: 4,
        borderBottomWidth: 1,
        borderBottomColor: theme.colors.outlineVariant,
      },
      agentName: {
        fontSize: 13,
        color: theme.colors.foreground,
        fontWeight: "500" as const,
      },
      agentMeta: {
        fontSize: 11,
        color: theme.colors.colSubtext,
      },
    }),
    [theme, layout.compact],
  );

  // --- Derived data ---
  const ts = tailscaleFull.data;
  const tsPeers = tailscalePeers.data ?? [];
  const ot = ottoFull.data;
  const su = systemUsage.data;
  const ag = agentStatus.data;
  const se = sessionStatus.data;
  const summ = summary.data;
  const tsBasic = tailscaleStatus.data;
  const otBasic = ottoStatus.data;

  const tsRunning = tsBasic?.running ?? false;
  const tsIp = tsBasic?.ip ?? "";
  const tsDns = tsBasic?.dns ?? "";
  const ottoRunning = otBasic?.running ?? false;
  const paired = summ?.paired ?? false;
  const pairedHost = summ?.pairedHost ?? null;

  const statusColor = (ok: boolean) =>
    ok ? styles.statusValueOk : styles.statusValueError;

  const handleOpenDesktop = async () => {
    const result = await openDesktop.mutateAsync({ path: undefined });
    setDesktopUrl(result.url);
  };

  return (
    <ScrollView style={styles.screen}>
      {/* --- SUMMARY CARD --- */}
      <View style={styles.card}>
        <Text style={styles.title}>Otto Host Pair</Text>
        <Text style={styles.subtitle}>
          Full status, usage, agent/session info, and desktop app links.
        </Text>

        <View style={styles.statusRow}>
          <Text style={styles.statusLabel}>Tailscale</Text>
          <Text style={statusColor(tsRunning)}>{tsRunning ? "Online" : "Offline"}</Text>
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
                <Text style={styles.statusValueError}>{ag.failedAgents}</Text>
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
                <Text style={styles.statusValueError}>{se.failedSessions}</Text>
              </View>
            )}
          </>
        )}
      </View>

      {/* --- DESKTOP APP LINK --- */}
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
        {openDesktop.isError && (
          <Text style={styles.error}>
            {String(openDesktop.error?.message ?? openDesktop.error)}
          </Text>
        )}
      </View>

      {/* --- TAILSCALE DETAILS --- */}
      <Pressable
        style={styles.toggleButton}
        onPressed={() => setShowDetails(!showDetails)}
      >
        <Text style={{ ...styles.buttonText, color: theme.colors.primary }}>
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
                <View key={peer.ip ?? peer.name} style={styles.peerItem}>
                  <View>
                    <Text style={styles.peerName}>{peer.name}</Text>
                    <Text style={styles.peerIp}>
                      {peer.ip ?? "—"} • {peer.online ? "Online" : "Offline"}
                    </Text>
                  </View>
                  <Text
                    style={{
                      fontSize: 11,
                      color: peer.online ? theme.colors.success : theme.colors.error,
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

      {/* --- OTTO DAEMON DETAILS --- */}
      <Pressable
        style={styles.toggleButton}
        onPressed={() => setShowDetails(!showDetails)}
      >
        <Text style={{ ...styles.buttonText, color: theme.colors.primary }}>
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

      {/* --- AGENT STATUS --- */}
      <Pressable
        style={styles.toggleButton}
        onPressed={() => setShowDetails(!showDetails)}
      >
        <Text style={{ ...styles.buttonText, color: theme.colors.primary }}>
          {showDetails ? "Hide" : "Show"} Agent Status
        </Text>
      </Pressable>

      {showDetails && ag && ag.agents.length > 0 && (
        <View style={styles.card}>
          <Text style={styles.title}>Agents</Text>
          {ag.agents.map((agent: any) => (
            <View key={agent.id} style={styles.agentItem}>
              <View>
                <Text style={styles.agentName}>{agent.title ?? "Untitled"}</Text>
                <Text style={styles.agentMeta}>
                  {agent.provider} • {agent.status}
                </Text>
              </View>
              <Text
                style={{
                  fontSize: 11,
                  color:
                    agent.lastTurnOutcome === "failed"
                      ? theme.colors.error
                    : agent.status === "active" || agent.status === "running"
                      ? theme.colors.success
                      : theme.colors.colSubtext,
                }}
              >
                {agent.lastTurnOutcome ?? "—"}
              </Text>
            </View>
          ))}
        </View>
      )}

      {/* --- PAIRING SECTION --- */}
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
          onPress={() => {
            pairTailscale.mutate({ hostIp });
          }}
        >
          <Text style={styles.buttonText}>
            {pairTailscale.isPending ? "Pairing…" : "Pair Tailscale Host"}
          </Text>
        </Pressable>

        {pairTailscale.isError && (
          <Text style={styles.error}>
            {String(pairTailscale.error?.message ?? pairTailscale.error)}
          </Text>
        )}

        {pairTailscale.isSuccess && (
          <Text style={styles.success}>Paired with {hostIp}</Text>
        )}

        <View style={styles.divider} />

        <Pressable
          style={[styles.button, !tsRunning || !hostIp ? styles.buttonDisabled : {}]}
          disabled={!tsRunning || !hostIp}
          onPress={() => {
            pairOtto.mutate({ tailscaleIp: hostIp });
          }}
        >
          <Text style={styles.buttonText}>
            {pairOtto.isPending ? "Linking daemon…" : "Link Otto Daemon"}
          </Text>
        </Pressable>

        {pairOtto.isError && (
          <Text style={styles.error}>
            {String(pairOtto.error?.message ?? pairOtto.error)}
          </Text>
        )}

        {pairOtto.isSuccess && (
          <Text style={styles.success}>Otto daemon linked at {hostIp}</Text>
        )}
      </View>

      {/* --- DAEMON FEATURES --- */}
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

      {/* --- DESKTOP APP INSTRUCTIONS --- */}
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
