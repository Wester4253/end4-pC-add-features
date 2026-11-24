import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

MouseArea {
    id: root
    property color contentColor: Appearance.colors.colOnLayer1
    property bool contentColorOverridden: false
    property bool vertical: false
    readonly property var providers: {
        const result = [];
        if (Config.options.bar.aiUsage.claudeEnabled)
            result.push({ name: "Claude Code", icon: "claude-symbolic", usage: ClaudeUsage, codex: false });
        if (Config.options.bar.aiUsage.codexEnabled)
            result.push({ name: "Codex", icon: "openai-symbolic", usage: CodexUsage, kind: "codex" });
        if (Config.options.bar.aiUsage.ompEnabled)
            result.push({ name: "Oh My Pi", icon: "omp-symbolic", usage: OmpUsage, kind: "omp" });
        if (Config.options.bar.aiUsage.ottoEnabled)
            result.push({ name: "Otto", icon: "otto-symbolic", usage: OttoUsage, kind: "otto" });
        if (Config.options.bar.aiUsage.localLLMEnabled)
            result.push({ name: "Local LLMs", icon: "memory", usage: LocalLLMUsage, kind: "local" });
        // Add paired remote host
        if (OttoHostPair.paired && OttoHostPair.pairedHostOnline)
            result.push({ name: "Otto @ " + (OttoHostPair.pairedHostName !== "" ? OttoHostPair.pairedHostName : OttoHostPair.pairedHost), icon: "device_hub", usage: OttoHostPair, kind: "otto-paired" });
        return result;
    }

    // Hide entirely when every enabled provider says there is nothing to show
    // (e.g. Otto enabled but the daemon is unreachable or has no agents).
    visible: providers.some(provider => {
        if (provider.kind === "otto" || provider.kind === "otto-paired") return provider.usage.pairedHostActiveAgents > 0 || provider.usage.ottoActiveAgents > 0;
        if (provider.kind === "local") return provider.usage.available;
        return true;
    })
    implicitWidth: providers.length === 0 ? 0 : (vertical ? Appearance.sizes.verticalBarWidth : content.implicitWidth + 12)
    implicitHeight: providers.length === 0 ? 0 : (vertical ? content.implicitHeight + 10 : Appearance.sizes.barHeight)
    hoverEnabled: !Config.options.bar.tooltips.clickToShow

    GridLayout {
        id: content
        anchors.centerIn: parent
        columns: root.vertical ? 1 : root.providers.length
        columnSpacing: 10
        rowSpacing: 5

        Repeater {
            model: root.providers
            delegate: GridLayout {
                id: delegateRoot

                required property var modelData
                readonly property bool needsData: modelData.kind === "codex" || (modelData.kind === "otto" && !modelData.usage.ottoRunning) || (modelData.kind === "otto-paired" && !modelData.usage.pairedHostOnline) || (modelData.kind === "local" && !modelData.usage.available)
                readonly property bool active: needsData ? (modelData.kind === "otto-paired" ? modelData.usage.pairedHostOnline : modelData.usage.available) : (modelData.kind === "local" ? modelData.usage.totalRunning > 0 : (modelData.kind === "otto-paired" ? modelData.usage.pairedHostActiveAgents > 0 : modelData.usage.activeSessions > 0))
                readonly property color providerColor: active ? root.contentColor : (root.contentColorOverridden ? Qt.alpha(root.contentColor, 0.6) : Appearance.colors.colSubtext)
                columns: root.vertical ? 1 : 2
                columnSpacing: 5
                rowSpacing: 2

                CustomIcon {
                    Layout.alignment: Qt.AlignCenter
                    width: 15
                    height: 15
                    source: modelData.icon
                    colorize: true
                    color: providerColor
                }
                StyledText {
                    Layout.alignment: Qt.AlignCenter
                    text: {
                        const u = modelData.usage;
                        if (delegateRoot.needsData) {
                            if (modelData.kind === "otto-paired") return u.pairedHostOnline ? "online" : "offline";
                            return "—";
                        }
                        if (modelData.kind === "local") return u.totalRunning > 0 ? u.totalRunning + " running" : "idle";
                        if (modelData.kind === "otto-paired") return u.pairedHostActiveAgents + " active";
                        return Math.round(u.percentage * 100) + "%";
                    }
                    font.pixelSize: root.vertical ? Appearance.font.pixelSize.smaller : Appearance.font.pixelSize.small
                    color: providerColor
                }
            }
        }
    }

    AiUsagePopup {
        hoverTarget: root
        providers: root.providers
    }
}