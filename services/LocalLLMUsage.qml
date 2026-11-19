pragma Singleton
import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io

// Local LLM servers status (Ollama, LM Studio, vLLM, etc.)
Singleton {
    id: root

    property bool available: false
    property var servers: {}
    property int totalRunning: 0
    property int totalModels: 0

    function refresh() {
        if (Config.options.bar.aiUsage.localLLMEnabled && !usageProc.running) usageProc.running = true;
    }

    Timer {
        interval: Config.options.bar.aiUsage.updateInterval * 1000
        repeat: true
        running: Config.ready && Config.options.bar.aiUsage.localLLMEnabled
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Process {
        id: usageProc
        command: ["python3", Quickshell.shellPath("scripts/ai/local-llm-usage.py")]
        environment: ({
            "OLLAMA_HOST": Config.options.bar.aiUsage.ollamaHost ?? "",
            "LMSTUDIO_HOST": Config.options.bar.aiUsage.lmstudioHost ?? "",
            "VLLM_HOST": Config.options.bar.aiUsage.vllmHost ?? "",
            "TEXTGEN_HOST": Config.options.bar.aiUsage.textgenHost ?? "",
        })
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    root.available = data.available === true;
                    root.servers = data.servers ?? {};
                    root.totalRunning = data.totalRunning ?? 0;
                    root.totalModels = data.totalModels ?? 0;
                } catch (e) { root.available = false; }
            }
        }
    }
}