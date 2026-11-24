import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root
    required property Item di
    Layout.fillWidth: true

    // Reusable card for each AI provider
    Component {
        id: aiProviderCard
        Item {
            property var providerData: modelData
            Layout.fillWidth: true
            implicitHeight: 56

            property bool isOtto: providerData.kind === "otto"
            property bool isCodex: providerData.kind === "codex"
            property bool isClaude: providerData.kind === "claude"
            property bool isOmp: providerData.kind === "omp"

            property var u: providerData.usage
            property bool available: u.available
            property real percentage: u.percentage ?? 0
            property string subtitle: {
                if (isCodex) return available ? Translation.tr("Rate limit usage") : Translation.tr("No usage data yet");
                if (isOmp) return Translation.tr("%1 requests/min of %2").arg(u.requestsLastMinute ?? 0).arg(u.rpmLimit ?? 40);
                if (isOtto) return !available ? Translation.tr("Daemon unreachable") : Translation.tr("%1 running of %2 agents").arg(u.activeSessions ?? 0).arg(u.totalSessions ?? 0);
                if (isClaude) return available ? `${u.tokens ?? 0} / ${Config.options.bar.aiUsage.tokenLimit} tokens` : Translation.tr("Not available");
                return "";
            }

            Rectangle {
                id: card
                anchors.fill: parent
                radius: 12
                color: Appearance.colors.colLayer1
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant

                RowLayout {
                    anchors.fill: parent
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                    spacing: 12

                    // Icon
                    Rectangle {
                        Layout.alignment: Qt.AlignVCenter
                        implicitWidth: 36
                        implicitHeight: 36
                        radius: 18
                        color: providerData.color
                        opacity: 0.15

                        CustomIcon {
                            anchors.centerIn: parent
                            width: 20
                            height: 20
                            source: providerData.icon
                            colorize: true
                            color: providerData.color
                        }
                    }

                    // Name + subtitle
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: -2

                        StyledText {
                            Layout.fillWidth: true
                            text: providerData.name
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: Font.Medium
                            color: Appearance.colors.colOnLayer0
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: subtitle
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colSubtext
                        }
                    }

                    // Progress + percentage
                    ColumnLayout {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        spacing: 4
                        Layout.minimumWidth: 80

                        StyledText {
                            Layout.alignment: Qt.AlignRight
                            text: !available && (isCodex || isOtto) ? "—" : `${Math.round(percentage * 100)}%`
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: Font.Bold
                            color: available ? providerData.color : Appearance.colors.colSubtext
                        }

                        StyledProgressBar {
                            Layout.fillWidth: true
                            valueBarWidth: 100
                            value: available ? percentage : 0
                            color: providerData.color
                        }
                    }
                }
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8

        // Section header
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            spacing: 8

            MaterialSymbol {
                Layout.alignment: Qt.AlignVCenter
                text: "neurology"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("AI Usage")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colSubtext
                text: {
                    const u = AiUsage.available ? AiUsage : null;
                    if (!u) return "";
                    const providers = [];
                    if (Config.options.bar.aiUsage.claudeEnabled && ClaudeUsage.available)
                        providers.push(`${Math.round(ClaudeUsage.percentage * 100)}%`);
                    if (Config.options.bar.aiUsage.codexEnabled && CodexUsage.available)
                        providers.push(`${Math.round(CodexUsage.percentage * 100)}%`);
                    if (Config.options.bar.aiUsage.ompEnabled && OmpUsage.available)
                        providers.push(`${OmpUsage.requestsLastMinute}/${OmpUsage.rpmLimit} req/min`);
                    if (Config.options.bar.aiUsage.ottoEnabled && OttoUsage.available)
                        providers.push(`${OttoUsage.activeSessions}/${OttoUsage.totalSessions} agents`);
                    return providers.join(" • ");
                }
            }
        }

        // Provider cards
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: {
                    const result = [];
                    if (Config.options.bar.aiUsage.claudeEnabled) result.push({ name: "Claude Code", icon: "claude-symbolic", usage: ClaudeUsage, kind: "claude", color: Appearance.colors.colPrimary });
                    if (Config.options.bar.aiUsage.codexEnabled) result.push({ name: "Codex", icon: "openai-symbolic", usage: CodexUsage, kind: "codex", color: Appearance.colors.colSecondary });
                    if (Config.options.bar.aiUsage.ompEnabled) result.push({ name: "Oh My Pi", icon: "omp-symbolic", usage: OmpUsage, kind: "omp", color: Appearance.colors.colTertiary });
                    if (Config.options.bar.aiUsage.ottoEnabled) result.push({ name: "Otto", icon: "otto-symbolic", usage: OttoUsage, kind: "otto", color: Appearance.colors.colError });
                    return result;
                }
                delegate: aiProviderCard
            }
        }
    }
}
