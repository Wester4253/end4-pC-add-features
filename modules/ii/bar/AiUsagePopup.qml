import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

StyledPopup {
    id: root

    property var providers: []

    function formatTokens(count) {
        if (count >= 1000000) return `${(count / 1000000).toFixed(1)}M`;
        if (count >= 1000) return `${Math.round(count / 1000)}k`;
        return `${count}`;
    }

    function formatReset(usage) {
        if (usage.resetsAt <= 0) return Translation.tr("No usage in this window");
        const seconds = Math.max(0, usage.resetsAt - Date.now() / 1000);
        const h = Math.floor(seconds / 3600);
        const m = Math.floor((seconds % 3600) / 60);
        return Translation.tr("Resets in %1").arg(h > 0 ? `${h}h ${m}m` : `${m}m`);
    }

    function subtitleFor(provider) {
        const usage = provider.modelData.usage;
        switch (provider.modelData.kind) {
            case "codex":
                return usage.available ? root.formatReset(usage) : Translation.tr("No usage data yet");
            case "omp":
                return Translation.tr("%1 requests/min of %2").arg(usage.requestsLastMinute ?? 0).arg(usage.rpmLimit ?? 40);
            case "otto":
                if (!usage.available) return Translation.tr("Daemon unreachable%1").arg(usage.host ? ` (${usage.host})` : "");
                if (usage.totalSessions === 0) return Translation.tr("No agents");
                return Translation.tr("%1 running of %2 agents").arg(usage.activeSessions).arg(usage.totalSessions);
            case "local":
                if (!usage.available) return Translation.tr("No servers running");
                return Translation.tr("%1 running, %2 models").arg(usage.totalRunning).arg(usage.totalModels);
            default:
                return root.formatReset(usage);
        }
    }

    function statusIcon(agent) {
        if (agent.requiresAttention) return "notification_important";
        if (agent.pendingPermissions > 0) return "shield";
        return agent.status === "running" ? "progress_activity" : "schedule";
    }

    function statusLabel(agent) {
        if (agent.requiresAttention) return Translation.tr("Attention");
        if (agent.pendingPermissions > 0) return Translation.tr("Permission needed");
        return agent.status === "running" ? Translation.tr("Working") : Translation.tr("Idle");
    }

    ColumnLayout {
        spacing: 10

        Repeater {
            model: root.providers
            delegate: ColumnLayout {
                id: provider
                required property var modelData
                spacing: 10
                Layout.fillWidth: true
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 3
                    spacing: 7

                    Rectangle {
                        implicitWidth: 36
                        implicitHeight: 36
                        radius: Appearance.rounding.full
                        color: Appearance.colors.colPrimaryContainer

                        CustomIcon {
                            anchors.centerIn: parent
                            width: 20
                            height: 20
                            source: provider.modelData.icon
                            colorize: true
                            color: Appearance.colors.colPrimary
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: -3

                        StyledText {
                            text: provider.modelData.name
                            font {
                                weight: Font.Medium
                                pixelSize: Appearance.font.pixelSize.normal
                            }
                            color: Appearance.colors.colOnSurfaceVariant
                        }

                        StyledText {
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colOnSurfaceVariant
                            opacity: 0.6
                            text: root.subtitleFor(provider)
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    StyledText {
                        Layout.rightMargin: 8
                        font.pixelSize: Appearance.font.pixelSize.huge
                        font.weight: Font.Bold
                        color: Appearance.colors.colPrimary
                        text: {
                            const u = provider.modelData.usage;
                            const needsData = provider.modelData.kind === "codex" || provider.modelData.kind === "otto" || provider.modelData.kind === "local";
                            if (needsData && !u.available) return "—";
                            if (provider.modelData.kind === "local") return u.totalRunning > 0 ? `${u.totalRunning}` : "0";
                            return `${Math.round(u.percentage * 100)}%`;
                        }
                    }
                }

                StyledProgressBar {
                    Layout.fillWidth: true
                    valueBarWidth: 260
                    value: provider.modelData.usage.percentage
                }

                StyledPopupValueRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    icon: "token"
                    // Claude is the only provider without a kind marker.
                    visible: !provider.modelData.kind
                    label: Translation.tr("Tokens (estimate)")
                    value: `${root.formatTokens(provider.modelData.usage.tokens)} / ${root.formatTokens(provider.modelData.usage.tokenLimit)}`
                }

                // Local LLM servers
                StyledPopupValueRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    visible: provider.modelData.kind === "local" && provider.modelData.usage.available
                    icon: "memory"
                    label: Translation.tr("Running models")
                    value: `${provider.modelData.usage.totalRunning} / ${provider.modelData.usage.totalModels}`
                }

                StyledPopupValueRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    visible: {
                        if (provider.modelData.kind === "codex") return false;
                        if (provider.modelData.kind === "otto" && !provider.modelData.usage.available) return false;
                        return provider.modelData.usage.activeSessions === 0;
                    }
                    icon: "bedtime"
                    label: Translation.tr("No active sessions")
                    value: ""
                }

                Repeater {
                    // Session/agent rows: Claude and OMP report "sessions",
                    // Otto reports its managed agents.
                    // Local LLMs report running models.
                    model: {
                        const u = provider.modelData.usage;
                        if (provider.modelData.kind === "codex") return [];
                        if (provider.modelData.kind === "otto") return u.agents ?? [];
                        if (provider.modelData.kind === "local") return u.servers ? Object.entries(u.servers).filter(([,v]) => v.available).map(([k,v]) => ({name: k, status: v.running_models > 0 ? "running" : "idle", models: v.models?.length ?? 0})) : [];
                        return u.sessions ?? [];
                    }
                    delegate: StyledPopupValueRow {
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        icon: {
                            if (provider.modelData.kind === "otto") return root.statusIcon(modelData);
                            if (provider.modelData.kind === "local") return modelData.status === "running" ? "memory" : "memory_off";
                            return modelData.status === "busy" ? "progress_activity" : "terminal";
                        }
                        label: modelData.name
                        value: {
                            if (provider.modelData.kind === "otto") return root.statusLabel(modelData);
                            if (provider.modelData.kind === "local") return modelData.status === "running" ? Translation.tr("%1 models").arg(modelData.models) : Translation.tr("Stopped");
                            return modelData.status === "busy" ? Translation.tr("Working") : Translation.tr("Idle");
                        }
                    }
                }
                StyledPopupValueRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    visible: provider.modelData.kind === "codex" && provider.modelData.usage.weeklyResetsAt > 0
                    icon: "date_range"
                    label: Translation.tr("Weekly usage")
                    value: provider.modelData.kind === "codex" ? `${Math.round(provider.modelData.usage.weeklyPercentage * 100)}%` : ""
                }

                // 5h token total (Oh My Pi)
                StyledPopupValueRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    visible: provider.modelData.kind === "omp" && provider.modelData.usage.tokens > 0
                    icon: "token"
                    label: Translation.tr("Tokens (5h window)")
                    value: root.formatTokens(provider.modelData.usage.tokens)
                }

                // Token total across all agents (Otto)
                StyledPopupValueRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    visible: provider.modelData.kind === "otto" && provider.modelData.usage.available && provider.modelData.usage.tokens > 0
                    icon: "token"
                    label: Translation.tr("Tokens (all agents)")
                    value: root.formatTokens(provider.modelData.usage.tokens)
                }

                // Most loaded agent's context window (Otto)
                StyledPopupValueRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    visible: {
                        if (provider.modelData.kind !== "otto" || !provider.modelData.usage.available) return false;
                        return (provider.modelData.usage.agents ?? []).some(a => (a.contextPercent ?? 0) > 0);
                    }
                    icon: "data_usage"
                    label: Translation.tr("Highest context use")
                    value: {
                        const agents = provider.modelData.usage.agents ?? [];
                        const max = agents.reduce((m, a) => Math.max(m, a.contextPercent ?? 0), 0);
                        return `${Math.round(max * 100)}%`;
                    }
                }

                // Top models (Oh My Pi)
                Repeater {
                    model: provider.modelData.kind === "omp" ? (provider.modelData.usage.models ?? []).slice(0, 3) : []
                    delegate: StyledPopupValueRow {
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        icon: "token"
                        label: modelData[0]
                        value: root.formatTokens(modelData[1])
                    }
                }
            }
        }
    }
}