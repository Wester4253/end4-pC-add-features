pragma Singleton
import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io

// Focus Mode / Do Not Disturb - suppresses notifications and visual distractions
Singleton {
    id: root

    property bool enabled: Persistent.states.focusMode.enabled ?? false
    property int duration: 0 // 0 = indefinite, otherwise minutes
    property int endTime: 0
    property string mode: "focus" // "focus", "dnd", "gaming"

    Timer {
        id: expiryTimer
        interval: 60000 // check every minute
        repeat: true
        running: root.enabled && root.duration > 0
        onTriggered: {
            if (Date.now() >= root.endTime) {
                root.disable();
            }
        }
    }

    function enable(minutes, modeName) {
        root.enabled = true;
        root.mode = modeName ?? "focus";
        root.duration = minutes ?? 0;
        if (minutes > 0) {
            root.endTime = Date.now() + minutes * 60000;
        }
        Persistent.states.focusMode.enabled = true;
        Persistent.states.focusMode.mode = root.mode;
        Persistent.states.focusMode.duration = root.duration;
        Persistent.states.focusMode.endTime = root.endTime;

        // Suppress notifications
        Notifications.dnd = true;

        // Disable visual distractions
        if (root.mode === "gaming") {
            // Could disable animations, reduce quality, etc.
        }
    }

    function disable() {
        root.enabled = false;
        root.duration = 0;
        root.endTime = 0;
        Persistent.states.focusMode.enabled = false;

        // Restore notifications
        Notifications.dnd = false;
    }

    function toggle() {
        if (root.enabled) {
            root.disable();
        } else {
            root.enable(0, "focus");
        }
    }

    function setMode(modeName) {
        root.mode = modeName;
        Persistent.states.focusMode.mode = modeName;
    }

    // Quick presets
    function focus25() { root.enable(25, "focus"); }
    function focus50() { root.enable(50, "focus"); }
    function dnd1h() { root.enable(60, "dnd"); }
    function gaming4h() { root.enable(240, "gaming"); }

    Component.onCompleted: {
        if (Persistent.states.focusMode.enabled) {
            root.enabled = true;
            root.mode = Persistent.states.focusMode.mode ?? "focus";
            root.duration = Persistent.states.focusMode.duration ?? 0;
            root.endTime = Persistent.states.focusMode.endTime ?? 0;
            if (root.duration > 0 && Date.now() >= root.endTime) {
                root.disable();
            } else if (root.duration > 0) {
                Notifications.dnd = true;
            }
        }
    }
}