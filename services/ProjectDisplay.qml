pragma Singleton
import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

/**
 * Project Display & Audio Flyout Service
 * Provides display configuration, audio routing, and brightness/color control
 * Triggered via Super+P or GlobalStates.projectDisplayOpen
 */
Singleton {
    id: root

    property bool active: GlobalStates.projectDisplayOpen

    // Monitors
    property var monitors: []
    property var audioOutputs: []
    property var audioInputs: []

    // Auto-refresh when active
    Timer {
        interval: 2000
        running: root.active
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            refreshMonitors();
            refreshAudio();
        }
    }

    function refreshMonitors() {
        Hyprland.sendMessage("j/monitors")
            .then(result => {
                if (result) {
                    root.monitors = result;
                }
            })
            .catch(() => {});
    }

    function refreshAudio() {
        root.audioOutputs = Audio.sources.values.slice();
        root.audioInputs = Audio.sinks.values.slice();
    }

    // Display actions
    function setMonitorMode(mode, monitorId) {
        // mode: "only", "mirror", "extend", "second"
        // Implementation would use hyprctl
        console.log("Set monitor mode:", mode, monitorId);
    }

    function setAudioOutput(deviceId) {
        Audio.defaultSink = deviceId;
    }

    function setAudioInput(deviceId) {
        Audio.defaultSource = deviceId;
    }

    // Brightness/Color
    function setBrightness(device, value) {
        // Would use brightnessctl or ddcutil
    }

    function setNightLight(value) {
        Hyprsunset.temperature = value;
    }

    // Global shortcut handler
    CompositorGlobalShortcut {
        name: "projectDisplay"
        description: "Toggle Project Display & Audio flyout"
        onPressed: {
            GlobalStates.projectDisplayOpen = !GlobalStates.projectDisplayOpen;
        }
    }
}