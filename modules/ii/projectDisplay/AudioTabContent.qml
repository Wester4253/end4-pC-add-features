commit d6f717e2ceb1fca02c1dccf191a39efa26965db6
Author: OttoAgent <noah.butterfeild@gmail.com>
Date:   Thu Nov 19 07:27:42 2026 +0000

    feat: Add Project Display & Audio Flyout (Super+P)
    
    - Added ProjectDisplay.qml with 3 tabs: Display, Audio, Brightness/Color
    - Display tab: 4 projection modes (PC only, Mirror, Extend, Second screen), monitor list with resolution/scale/rotation/VRR/DPMS controls
    - Audio tab: Output/input device cards with volume sliders, mute toggle, default device selection
    - Brightness/Color tab: Brightness slider, Night Light with presets, Color profile with gamma sliders
    - Service: ProjectDisplay.qml with monitor/audio refresh, Super+P global shortcut
    - GlobalStates: projectDisplayOpen property + CompositorGlobalShortcut (Super+P)
    - Settings: BarConfig + DashboardSettingsCatalog with full toggle controls
    - Config: projectDisplay.* options for all features

diff --git a/modules/ii/projectDisplay/AudioTabContent.qml b/modules/ii/projectDisplay/AudioTabContent.qml
new file mode 100644
index 00000000..ae0af362
--- /dev/null
+++ b/modules/ii/projectDisplay/AudioTabContent.qml
@@ -0,0 +1,237 @@
+import QtQuick
+import QtQuick.Layouts
+import Quickshell
+import qs
+import qs.services
+import qs.modules.common
+import qs.modules.common.widgets
+
+Item {
+    id: root
+    required property Item di
+    Layout.fillWidth: true
+
+    ColumnLayout {
+        Layout.fillWidth: true
+        spacing: 12
+
+        // Output devices
+        Revealer {
+            reveal: di.audioOutputs && di.audioOutputs.length > 0
+            Layout.fillWidth: true
+
+            ColumnLayout {
+                Layout.fillWidth: true
+                spacing: 8
+
+                RowLayout {
+                    Layout.fillWidth: true
+                    StyledText {
+                        text: Translation.tr("Output Devices (%1)").arg(di.audioOutputs.length)
+                        font.pixelSize: Appearance.font.pixelSize.smaller
+                        font.weight: Font.Medium
+                        color: Appearance.colors.colSubtext
+                    }
+                }
+
+                ColumnLayout {
+                    Layout.fillWidth: true
+                    spacing: 4
+
+                    Repeater {
+                        model: di.audioOutputs
+                        delegate: AudioDeviceCard {
+                            Layout.fillWidth: true
+                            device: modelData
+                            isOutput: true
+                        }
+                    }
+                }
+            }
+        }
+
+        // Input devices
+        Revealer {
+            reveal: di.audioInputs && di.audioInputs.length > 0
+            Layout.fillWidth: true
+
+            ColumnLayout {
+                Layout.fillWidth: true
+                spacing: 8
+
+                RowLayout {
+                    Layout.fillWidth: true
+                    StyledText {
+                        text: Translation.tr("Input Devices (%1)").arg(di.audioInputs.length)
+                        font.pixelSize: Appearance.font.pixelSize.smaller
+                        font.weight: Font.Medium
+                        color: Appearance.colors.colSubtext
+                    }
+                }
+
+                ColumnLayout {
+                    Layout.fillWidth: true
+                    spacing: 4
+
+                    Repeater {
+                        model: di.audioInputs
+                        delegate: AudioDeviceCard {
+                            Layout.fillWidth: true
+                            device: modelData
+                            isOutput: false
+                        }
+                    }
+                }
+            }
+        }
+
+        Revealer {
+            reveal: (!di.audioOutputs || di.audioOutputs.length === 0) && (!di.audioInputs || di.audioInputs.length === 0)
+            Layout.fillWidth: true
+
+            Rectangle {
+                Layout.fillWidth: true
+                implicitHeight: 80
+                radius: 12
+                color: Appearance.colors.colLayer1
+                border.width: 1
+                border.color: Appearance.colors.colOutlineVariant
+                opacity: 0.5
+
+                StyledText {
+                    anchors.centerIn: parent
+                    text: Translation.tr("No audio devices detected")
+                    font.pixelSize: Appearance.font.pixelSize.normal
+                    color: Appearance.colors.colSubtext
+                }
+            }
+        }
+    }
+}
+
+// Audio Device Card
+Item {
+    id: AudioDeviceCard
+    required property var device
+    required property bool isOutput
+    Layout.fillWidth: true
+    implicitHeight: 56
+
+    property string displayName: device.description || device.name || Translation.tr("Unknown Device")
+    property string icon: isOutput ? (device.port?.includes("hdmi") ? "tv" : device.port?.includes("headphone") ? "headphones" : "speaker") : "mic"
+    property string volumeStr: device.volume !== undefined ? `${Math.round(device.volume * 100)}%` : ""
+    property color volumeColor: device.muted ? Appearance.colors.colError : Appearance.colors.colPrimary
+
+    Rectangle {
+        anchors.fill: parent
+        radius: 12
+        color: Appearance.colors.colLayer1
+        border.width: 1
+        border.color: device === Audio.defaultSink || device === Audio.defaultSource
+            ? Appearance.colors.colPrimary
+            : Appearance.colors.colOutlineVariant
+
+        RowLayout {
+            anchors.fill: parent
+            Layout.leftMargin: 12
+            Layout.rightMargin: 12
+            spacing: 12
+
+            // Device icon
+            Rectangle {
+                Layout.alignment: Qt.AlignVCenter
+                implicitWidth: 40
+                implicitHeight: 40
+                radius: 20
+                color: Appearance.colors.colPrimary
+                opacity: 0.15
+
+                MaterialSymbol {
+                    anchors.centerIn: parent
+                    text: icon
+                    iconSize: 20
+                    fill: 1
+                    color: Appearance.colors.colPrimary
+                }
+            }
+
+            // Device info
+            ColumnLayout {
+                Layout.fillWidth: true
+                spacing: -2
+
+                StyledText {
+                    Layout.fillWidth: true
+                    text: displayName
+                    font.pixelSize: Appearance.font.pixelSize.normal
+                    font.weight: Font.Medium
+                    color: Appearance.colors.colOnLayer0
+                }
+
+                StyledText {
+                    Layout.fillWidth: true
+                    text: `${device.port || ""}  ${device.api || ""}`
+                    font.pixelSize: Appearance.font.pixelSize.smaller
+                    color: Appearance.colors.colSubtext
+                }
+            }
+
+            // Volume + actions
+            RowLayout {
+                spacing: 4
+
+                // Mute toggle
+                MouseArea {
+                    Layout.preferredWidth: 36
+                    Layout.preferredHeight: 36
+                    cursorShape: Qt.PointingHandCursor
+                    onClicked: {
+                        if (isOutput) device.muted = !device.muted;
+                        else device.muted = !device.muted;
+                    }
+                    hoverEnabled: true
+                    MaterialSymbol {
+                        anchors.centerIn: parent
+                        text: device.muted ? (isOutput ? "volume_off" : "mic_off") : (isOutput ? "volume_up" : "mic")
+                        iconSize: 20
+                        fill: 1
+                        color: device.muted ? Appearance.colors.colError : Appearance.colors.colSubtext
+                    }
+                }
+
+                // Volume slider
+                Revealer {
+                    reveal: !device.muted
+                    StyledProgressBar {
+                        Layout.fillWidth: true
+                        valueBarWidth: 100
+                        value: device.volume || 0.5
+                        color: volumeColor
+                        onValueChanged: {
+                            if (isOutput) device.volume = value;
+                            else device.volume = value;
+                        }
+                    }
+                }
+
+                // Set as default
+                MouseArea {
+                    Layout.preferredWidth: 36
+                    Layout.preferredHeight: 36
+                    cursorShape: Qt.PointingHandCursor
+                    onClicked: {
+                        if (isOutput) Audio.defaultSink = device.id;
+                        else Audio.defaultSource = device.id;
+                    }
+                    MaterialSymbol {
+                        anchors.centerIn: parent
+                        text: (isOutput ? (device === Audio.defaultSink ? "check_circle" : "check_circle_outline") : (device === Audio.defaultSource ? "check_circle" : "check_circle_outline"))
+                        iconSize: 20
+                        fill: 1
+                        color: isOutput ? (device === Audio.defaultSink ? Appearance.colors.colPrimary : Appearance.colors.colSubtext) : (device === Audio.defaultSource ? Appearance.colors.colPrimary : Appearance.colors.colSubtext)
+                    }
+                }
+            }
+        }
+    }
+}
\ No newline at end of file
