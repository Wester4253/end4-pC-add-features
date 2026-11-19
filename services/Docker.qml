pragma Singleton
import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io

// Docker daemon status and container management
Singleton {
    id: root

    property bool available: false
    property var containers: []
    property var images: []
    property var volumes: []
    property var networks: []
    property string error: ""

    function refresh() {
        if (refreshProc.running) return;
        refreshProc.running = true;
    }

    Timer {
        interval: 30000 // 30 seconds
        repeat: true
        running: Config.ready
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Process {
        id: refreshProc
        command: ["bash", "-c", "docker version >/dev/null 2>&1 && echo 'available' || echo 'unavailable'"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.available = text.trim() === "available";
                if (root.available) {
                    listContainersProc.running = true;
                    listImagesProc.running = true;
                    listVolumesProc.running = true;
                    listNetworksProc.running = true;
                } else {
                    root.containers = [];
                    root.images = [];
                    root.volumes = [];
                    root.networks = [];
                }
            }
        }
    }

    Process {
        id: listContainersProc
        command: ["bash", "-c", "docker ps -a --format '{{json .}}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const lines = text.trim().split("\n").filter(l => l);
                    root.containers = lines.map(l => JSON.parse(l));
                } catch (e) {
                    root.containers = [];
                }
            }
        }
    }

    Process {
        id: listImagesProc
        command: ["bash", "-c", "docker images --format '{{json .}}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const lines = text.trim().split("\n").filter(l => l);
                    root.images = lines.map(l => JSON.parse(l));
                } catch (e) {
                    root.images = [];
                }
            }
        }
    }

    Process {
        id: listVolumesProc
        command: ["bash", "-c", "docker volume ls --format '{{json .}}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const lines = text.trim().split("\n").filter(l => l);
                    root.volumes = lines.map(l => JSON.parse(l));
                } catch (e) {
                    root.volumes = [];
                }
            }
        }
    }

    Process {
        id: listNetworksProc
        command: ["bash", "-c", "docker network ls --format '{{json .}}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const lines = text.trim().split("\n").filter(l => l);
                    root.networks = lines.map(l => JSON.parse(l));
                } catch (e) {
                    root.networks = [];
                }
            }
        }
    }

    function start(containerId) {
        if (actionProc.running) return;
        actionProc.command = ["docker", "start", containerId];
        actionProc.running = true;
    }

    function stop(containerId) {
        if (actionProc.running) return;
        actionProc.command = ["docker", "stop", containerId];
        actionProc.running = true;
    }

    function restart(containerId) {
        if (actionProc.running) return;
        actionProc.command = ["docker", "restart", containerId];
        actionProc.running = true;
    }

    function removeImage(imageId) {
        if (actionProc.running) return;
        actionProc.command = ["docker", "rmi", imageId];
        actionProc.running = true;
    }

    function logs(containerId) {
        // Open logs in terminal
        Quickshell.execDetached(["foot", "-e", "docker", "logs", "-f", containerId]);
    }

    Process {
        id: actionProc
        onExited: {
            // Refresh after action
            listContainersProc.running = true;
            listImagesProc.running = true;
        }
    }
}