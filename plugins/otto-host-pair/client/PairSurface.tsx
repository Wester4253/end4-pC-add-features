import React, { useMemo, useState } from "react";
import { StyleSheet } from "react-native";
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  ScrollView,
  ActivityIndicator,
  Switch,
  Alert,
} from "react-native";
import { useRpc } from "@otto-code/plugin/client";
import {
  tailscaleFullStatusRpc,
  tailscalePeersRpc,
  ottoDaemonFullStatusRpc,
  ottoAgentStatusRpc,
  ottoSessionStatusRpc,
  ottoSummaryRpc,
  systemUsageRpc,
  openSurfaceRpc,
  openDesktopLinkRpc,
  tailscaleStatusRpc,
  ottoDaemonStatusRpc,
} from "../shared/tailscale";
import { useTheme } from "@otto-code/plugin/client";
import { useLayout } from "@otto-code/plugin/client";

export default function PairSurface() {
  const theme = useTheme();
  const layout = useLayout();
  const c = theme.colors;

  const tailscaleFull = useRpc(tailscaleFullStatusRpc, { pollInterval: 10000 });
  const tailscalePeers = useRpc(tailscalePeersRpc, { pollInterval: 10000 });
  const otBasic = useRpc(ottoDaemonStatusRpc, { pollInterval: 10000 });
  const ottoFull = useRpc(ottoDaemonFullStatusRpc, { pollInterval: 10000 });
  const agentStatus = useRpc(ottoAgentStatusRpc, { pollInterval: 10000 });
  const sessionStatus = useRpc(ottoSessionStatusRpc, { pollInterval: 10000 });
  const summary = useRpc(ottoSummaryRpc, { pollInterval: 10000 });
  const systemUsage = useRpc(systemUsageRpc, { pollInterval: 10000 });
  const tailscaleStatus = useRpc(tailscaleStatusRpc, { pollInterval: 10000 });
  const rpcOpenSurface = useRpc(openSurfaceRpc);
  const rpcOpenDesktop = useRpc(openDesktopLinkRpc);

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
    }),
    [theme, layout.compact],
  );

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
    <View style={styles.screen}>
      <ScrollView showsVerticalScrollIndicator={false}>
        {/* Connection Status */}
        <View style={styles.card}>
          <Text style={styles.title}>Connection Status</Text>

          <View style={styles.statusRow}>
            <View style={{ width: 10, height: 10, borderRadius: 5, backgroundColor: tsBasic?.online ? c.statusSuccess : c.statusDanger }} />
            <Text style={styles.statusLabel}>Tailscale</Text>
            <Text style={[styles.statusValue, { color: tsBasic?.online ? c.statusSuccess : c.statusDanger }]}>
              {tsBasic?.online ? "Online" : "Offline"}
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
            <View style={{ width: 10, height: 10, borderRadius: 5, backgroundColor: ottoRunning ? c.statusSuccess : c.statusDanger }} />
            <Text style={styles.statusLabel}>Otto Daemon (Local)</Text>
            <Text style={[styles.statusValue, { color: ottoRunning ? c.statusSuccess : c.statusDanger }]}>
              {ottoRunning ? "Running" : "Stopped"}
            </Text>
          </View>

          {ot?.version && (
            <View style={styles.statusRowCompact}>
              <Text style={styles.statusLabel}>Version</Text>
              <Text style={styles.statusValue}>{ot.version}</Text>
            </View>
          )}

          <View style={styles.statusRow}>
            <View style={{ width: 10, height: 10, borderRadius: 5, backgroundColor: paired ? c.statusSuccess : c.statusDanger }} />
            <Text style={styles.statusLabel}>Paired Host</Text>
            <Text style={[styles.statusValue, { color: paired ? c.statusSuccess : c.statusDanger }]}>
              {paired ? pairedHost ?? "Connected" : "Not paired"}
            </Text>
          </View>

          <View style={{ flexDirection: "row", gap: 8, marginTop: 12 }}>
            <TouchableOpacity
              style={[styles.button, { flex: 1 }]}
              onPress={() => {
                if (paired) {
                  // Unpair logic would go here
                } else {
                  rpcOpenSurface({});
                }
              }}
            >
              <Text style={styles.buttonText}>
                {paired ? "Unpair" : "Open Pairing"}
              </Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={[styles.button, styles.buttonDisabled, { flex: 1 }]}
              onPress={handleOpenDesktop}
            >
              <Text style={[styles.buttonText, { color: c.foregroundMuted }]}>Open Desktop</Text>
            </TouchableOpacity>
          </View>
        </View>

        {/* Tailnet Peers */}
        <View style={styles.card}>
          <Text style={styles.title}>Tailnet Devices ({tsPeers.length})</Text>
          {tsPeers.length === 0 ? (
            <Text style={styles.subtitle}>No other devices on tailnet</Text>
          ) : (
            tsPeers.map((peer) => (
              <View key={peer.name} style={styles.peerItem}>
                <View>
                  <Text style={styles.peerName}>{peer.name}</Text>
                  <Text style={styles.peerIp}>{peer.ip} · {peer.online ? "Online" : "Offline"}</Text>
                </View>
                <TouchableOpacity
                  style={{ backgroundColor: c.accent, borderRadius: 6, paddingHorizontal: 12, paddingVertical: 6 }}
                  onPress={() => {
                    // Pair with this peer
                    // This would call the pair RPC
                  }}
                  disabled={!peer.online}
                >
                  <Text style={{ color: c.accentForeground, fontWeight: "600" }}>
                    {paired && pairedHost === peer.name ? "Paired" : "Pair"}
                  </Text>
                </TouchableOpacity>
              </View>
            ))
          )}
        </View>

        {/* Local Otto Daemon */}
        <View style={styles.card}>
          <Text style={styles.title}>Local Otto Daemon</Text>
          <View style={styles.statusRowCompact}>
            <Text style={styles.statusLabel}>Active Agents</Text>
            <Text style={styles.statusValue}>{ot?.activeAgents ?? 0}</Text>
          </View>
          <View style={styles.statusRowCompact}>
            <Text style={styles.statusLabel}>Active Sessions</Text>
            <Text style={styles.statusValue}>{ot?.activeSessions ?? 0}</Text>
          </View>
          <View style={styles.statusRowCompact}>
            <Text style={styles.statusLabel}>Uptime</Text>
            <Text style={styles.statusValue}>
              {ot?.uptimeSeconds ? `${Math.floor(ot.uptimeSeconds / 3600)}h ${Math.floor((ot.uptimeSeconds % 3600) / 60)}m` : "—"}
            </Text>
          </View>
          <View style={styles.statusRowCompact}>
            <Text style={styles.statusLabel}>Memory</Text>
            <Text style={styles.statusValue}>{ot?.memoryUsageMB ?? 0} MB</Text>
          </View>
          <View style={styles.statusRowCompact}>
            <Text style={styles.statusLabel}>CPU</Text>
            <Text style={styles.statusValue}>{ot?.cpuPercent ?? 0}%</Text>
          </View>
        </View>

        {/* Remote Host (if paired) */}
        {paired && (
          <View style={styles.card}>
            <Text style={styles.title}>Paired Host: {pairedHost}</Text>
            <View style={styles.statusRowCompact}>
              <Text style={styles.statusLabel}>Active Agents</Text>
              <Text style={styles.statusValue}>{ag?.activeAgents ?? 0}</Text>
            </View>
            <View style={styles.statusRowCompact}>
              <Text style={styles.statusLabel}>Active Sessions</Text>
              <Text style={styles.statusValue}>{se?.activeSessions ?? 0}</Text>
            </View>
            <View style={styles.statusRowCompact}>
              <Text style={styles.statusLabel}>Agent Limit</Text>
              <Text style={styles.statusValue}>
                {ag?.agentLimit ? `${ag.agentUsed} / ${ag.agentLimit}` : "—"}
              </Text>
            </View>
            <View style={styles.statusRowCompact}>
              <Text style={styles.statusLabel}>Session Limit</Text>
              <Text style={styles.statusValue}>
                {se?.sessionLimit ? `${se.sessionUsed} / ${se.sessionLimit}` : "—"}
              </Text>
            </View>

            {/* Remote Agents List */}
            {ag?.agents && ag.agents.length > 0 && (
              <>
                <View style={styles.divider} />
                <Text style={{ ...styles.subtitle, marginTop: 8 }}>Remote Agents</Text>
                {ag.agents.map((agent: any) => (
                  <View key={agent.id} style={styles.agentItem}>
                    <View>
                      <Text style={styles.agentName}>{agent.title ?? agent.id}</Text>
                      <Text style={styles.agentMeta}>{agent.provider} · {agent.status}</Text>
                    </View>
                    <View
                      style={{
                        width: 8,
                        height: 8,
                        borderRadius: 4,
                        backgroundColor: agent.status === "active" || agent.status === "running" ? c.statusSuccess : c.foregroundMuted,
                      }}
                    />
                  </View>
                ))}
              </>
            )}
          </View>
        )}

        {/* System Usage */}
        <View style={styles.card}>
          <Text style={styles.title}>System</Text>
          <View style={styles.statusRowCompact}>
            <Text style={styles.statusLabel}>CPU</Text>
            <Text style={styles.statusValue}>{su?.cpuPercent ?? 0}%</Text>
          </View>
          <View style={styles.statusRowCompact}>
            <Text style={styles.statusLabel}>Memory</Text>
            <Text style={styles.statusValue}>
              {su?.memoryUsedMB ?? 0} / {su?.memoryTotalMB ?? 0} MB ({su?.memoryPercent ?? 0}%)
            </Text>
          </View>
          <View style={styles.statusRowCompact}>
            <Text style={styles.statusLabel}>Disk</Text>
            <Text style={styles.statusValue}>
              {su?.diskUsedGB ?? 0} / {su?.diskTotalGB ?? 0} GB ({su?.diskPercent ?? 0}%)
            </Text>
          </View>
          <View style={styles.statusRowCompact}>
            <Text style={styles.statusLabel}>Load</Text>
            <Text style={styles.statusValue}>
              {su?.load1?.toFixed(2) ?? 0} / {su?.load5?.toFixed(2) ?? 0} / {su?.load15?.toFixed(2) ?? 0}
            </Text>
          </View>
          <View style={styles.statusRowCompact}>
            <Text style={styles.statusLabel}>Uptime</Text>
            <Text style={styles.statusValue}>
              {su?.uptimeSeconds ? `${Math.floor(su.uptimeSeconds / 3600)}h ${Math.floor((su.uptimeSeconds % 3600) / 60)}m` : "—"}
            </Text>
          </View>
        </View>
      </ScrollView>
    </View>
  );
}