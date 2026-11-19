import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root
    required property bool active
    property string currentProvider: "local" // "local", "claude", "gemini", "openai"
    property var messages: []
    property string inputText: ""
    property bool isLoading: false
    property var selectedSession: null

    // Providers
    readonly property var providers: [
        { id: "local", name: "Local LLM", icon: "memory", models: LocalLLMUsage.available ? (LocalLLMUsage.servers || {}) : {} },
        { id: "claude", name: "Claude Code", icon: "claude-symbolic", available: Config.options.ai.claudeEnabled && ClaudeUsage.available },
        { id: "gemini", name: "Gemini", icon: "google-gemini-symbolic", available: Config.options.ai.geminiEnabled },
        { id: "openai", name: "OpenAI", icon: "openai-symbolic", available: Config.options.ai.openaiEnabled }
    ]

    function sendMessage() {
        if (!root.inputText.trim() || root.isLoading) return;
        
        const userMessage = {
            role: "user",
            content: root.inputText,
            timestamp: Date.now()
        };
        
        root.messages.push(userMessage);
        const prompt = root.inputText;
        root.inputText = "";
        root.isLoading = true;
        
        // Call AI service based on provider
        switch (root.currentProvider) {
            case "local":
                localAIService.sendPrompt(prompt).then(response => {
                    root.messages.push({ role: "assistant", content: response, timestamp: Date.now() });
                    root.isLoading = false;
                }).catch(err => {
                    root.messages.push({ role: "assistant", content: `Error: ${err}`, timestamp: Date.now() });
                    root.isLoading = false;
                });
                break;
            case "claude":
                // Would call Claude service
                root.isLoading = false;
                break;
            case "gemini":
                // Would call Gemini service
                root.isLoading = false;
                break;
            case "openai":
                // Would call OpenAI service
                root.isLoading = false;
                break;
        }
    }

    // Local AI service
    property var localAIService: {
        sendPrompt: (prompt) => {
            return new Promise((resolve, reject) => {
                // Use the existing AI service or call Python script
                const proc = new Process();
                proc.command = ["python3", Quickshell.shellPath("scripts/ai/local-llm-chat.py"), prompt, root.currentProvider];
                proc.onFinished = (exitCode, output) => {
                    if (exitCode === 0) {
                        resolve(output.trim());
                    } else {
                        reject(output);
                    }
                };
                proc.running = true;
            });
        }
    }

    // UI
    Loader {
        active: root.active
        sourceComponent: panelComponent

        Component {
            id: panelComponent
            PanelWindow {
                id: window
                flags: Qt.FramelessWindowHint | Qt.Window | Qt.WindowStaysOnTopHint
                color: "transparent"
                x: (Window.screen.width - width) / 2
                y: (Window.screen.height - height) / 2
                width: 480
                height: 600

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.active = false
                    }
                }

                Rectangle {
                    id: panel
                    anchors.fill: parent
                    anchors.margins: 16
                    radius: 20
                    color: Config.options.background.widgets.glass.enable
                        ? Appearance.colors.colUiBackground
                        : Qt.rgba(Appearance.colors.colUiBackground.r, Appearance.colors.colUiBackground.g, Appearance.colors.colUiBackground.b, 0.95)
                    border.width: Config.options.background.widgets.glass.enable ? 1 : 0
                    border.color: Appearance.colors.colOutlineVariant
                    clip: true

                    WindowGlass {
                        anchors.fill: parent
                        anchors.margins: -4
                        glassEnabled: Config.options.background.widgets.glass.enable
                        cardRadius: 20
                    }

                    // Shadow
                    Rectangle {
                        anchors.fill: panel
                        anchors.margins: -16
                        radius: 36
                        color: "transparent"
                        layer.enabled: true
                        layer.effect: Qt5Compat.GraphicalEffects.DropShadow {
                            verticalOffset: 16
                            horizontalOffset: 0
                            radius: 40
                            samples: 16
                            color: Qt.rgba(0, 0, 0, 0.4)
                            transparentBorder: true
                        }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        // Header
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 56
                            color: "transparent"
                            border.width: Config.options.background.widgets.glass.enable ? 1 : 0
                            border.color: Appearance.colors.colOutlineVariant

                            RowLayout {
                                anchors.fill: parent
                                Layout.leftMargin: 16
                                Layout.rightMargin: 16
                                spacing: 12

                                MaterialSymbol {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: "smart_toy"
                                    iconSize: 24
                                    fill: 1
                                    color: Appearance.colors.colPrimary
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0

                                    StyledText {
                                        Layout.fillWidth: true
                                        text: Translation.tr("AI Chat")
                                        font.pixelSize: Appearance.font.pixelSize.normal
                                        font.weight: Font.Medium
                                        color: Appearance.colors.colOnLayer0
                                    }

                                    StyledText {
                                        Layout.fillWidth: true
                                        text: root.currentProvider === "local" ? Translation.tr("Local LLM") : Translation.tr("Cloud AI")
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colSubtext
                                    }
                                }

                                // Provider selector
                                ConfigComboBox {
                                    currentValue: root.currentProvider
                                    onSelected: newValue => { root.currentProvider = newValue; }
                                    options: [
                                        { displayName: Translation.tr("Local LLM"), icon: "memory", value: "local" },
                                        { displayName: Translation.tr("Claude Code"), icon: "claude-symbolic", value: "claude" },
                                        { displayName: Translation.tr("Gemini"), icon: "google-gemini-symbolic", value: "gemini" },
                                        { displayName: Translation.tr("OpenAI"), icon: "openai-symbolic", value: "openai" }
                                    ]
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.active = false
                                }
                            }
                        }

                        // Messages
                        Flickable {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            contentHeight: messagesColumn.implicitHeight
                            boundsBehavior: Flickable.StopAtBounds

                            ColumnLayout {
                                id: messagesColumn
                                Layout.fillWidth: true
                                spacing: 8
                                Layout.leftMargin: 16
                                Layout.rightMargin: 16
                                Layout.topMargin: 12
                                Layout.bottomMargin: 12

                                Repeater {
                                    model: root.messages
                                    delegate: MessageBubble {
                                        Layout.fillWidth: true
                                        message: modelData
                                    }
                                }

                                // Loading indicator
                                Revealer {
                                    reveal: root.isLoading
                                    Layout.fillWidth: true
                                    implicitHeight: 48

                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 8

                                        BusySpinner { size: 20 }

                                        StyledText {
                                            Layout.alignment: Qt.AlignVCenter
                                            text: Translation.tr("Thinking...")
                                            font.pixelSize: Appearance.font.pixelSize.normal
                                            color: Appearance.colors.colSubtext
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Input area
                    Rectangle {
                        Layout.fillWidth: true
                        color: "transparent"
                        border.width: Config.options.background.widgets.glass.enable ? 1 : 0
                        border.color: Appearance.colors.colOutlineVariant

                        RowLayout {
                            anchors.fill: parent
                            Layout.leftMargin: 12
                            Layout.rightMargin: 12
                            Layout.topMargin: 8
                            Layout.bottomMargin: 8
                            spacing: 8

                            TextField {
                                id: inputField
                                Layout.fillWidth: true
                                background: null
                                font.pixelSize: Appearance.font.pixelSize.normal
                                color: Appearance.colors.colOnLayer0
                                placeholderText: Translation.tr("Ask anything...")
                                text: root.inputText
                                onTextChanged: root.inputText = text
                                onAccepted: root.sendMessage()
                            }

                            MouseArea {
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.sendMessage()
                                MaterialSymbol {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: "send"
                                    iconSize: 24
                                    fill: 1
                                    color: root.isLoading ? Appearance.colors.colSubtext : Appearance.colors.colPrimary
                                }
                            }
                        }
                    }
                }

                // Close on outside click
                MouseArea {
                    anchors.fill: parent
                    onClicked: root.active = false
                }
            }
        }
    }
}

// Message bubble component
Item {
    id: MessageBubble
    required property var message
    Layout.fillWidth: true

    property bool isUser: message.role === "user"
    property string content: message.content || ""
    property string timestamp: message.timestamp ? Qt.formatDateTime(new Date(message.timestamp), "HH:mm") : ""

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4

        // Message content
        Rectangle {
            Layout.fillWidth: true
            radius: 16
            color: root.isUser ? Appearance.colors.colPrimary : Appearance.colors.colLayer1
            border.width: root.isUser ? 0 : 1
            border.color: Appearance.colors.colOutlineVariant

            ColumnLayout {
                anchors.fill: parent
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.topMargin: 10
                Layout.bottomMargin: 10
                spacing: 4

                StyledText {
                    Layout.fillWidth: true
                    text: root.content
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: root.isUser ? Appearance.colors.colOnPrimary : Appearance.colors.colOnLayer0
                    wrapMode: Text.WordWrap
                }

                StyledText {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                    text: root.timestamp
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: root.isUser ? Qt.lighter(Appearance.colors.colOnPrimary, 1.3) : Appearance.colors.colSubtext
                }
            }
        }

        // Sender label
        StyledText {
            Layout.alignment: root.isUser ? Qt.AlignRight : Qt.AlignLeft
            text: root.isUser ? Translation.tr("You") : Translation.tr("Assistant")
            font.pixelSize: Appearance.font.pixelSize.smaller
            font.weight: Font.Medium
            color: root.isUser ? Appearance.colors.colPrimary : Appearance.colors.colSubtext
        }
    }
}