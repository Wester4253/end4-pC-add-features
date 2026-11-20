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

diff --git a/modules/ii/projectDisplay/BrightnessTabContent.qml b/modules/ii/projectDisplay/BrightnessTabContent.qml
new file mode 100644
index 00000000..b4b01fca
--- /dev/null
+++ b/modules/ii/projectDisplay/BrightnessTabContent.qml
@@ -0,0 +1,405 @@
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
+        // Brightness section
+        Rectangle {
+            Layout.fillWidth: true
+            radius: 12
+            color: Appearance.colors.colLayer1
+            border.width: 1
+            border.color: Appearance.colors.colOutlineVariant
+
+            ColumnLayout {
+                anchors.fill: parent
+                Layout.leftMargin: 16
+                Layout.rightMargin: 16
+                Layout.topMargin: 16
+                Layout.bottomMargin: 16
+                spacing: 12
+
+                RowLayout {
+                    Layout.fillWidth: true
+                    spacing: 8
+
+                    MaterialSymbol {
+                        Layout.alignment: Qt.AlignVCenter
+                        text: "brightness_6"
+                        iconSize: 24
+                        fill: 1
+                        color: Appearance.m3colors.m3warning
+                    }
+
+                    StyledText {
+                        Layout.fillWidth: true
+                        Layout.alignment: Qt.AlignVCenter
+                        text: Translation.tr("Brightness")
+                        font.pixelSize: Appearance.font.pixelSize.normal
+                        font.weight: Font.Medium
+                        color: Appearance.colors.colOnLayer0
+                    }
+                }
+
+                // Brightness slider
+                RowLayout {
+                    Layout.fillWidth: true
+                    spacing: 12
+
+                    MaterialSymbol {
+                        Layout.alignment: Qt.AlignVCenter
+                        text: "brightness_low"
+                        iconSize: 20
+                        fill: 1
+                        color: Appearance.m3colors.m3warning
+                    }
+
+                    StyledProgressBar {
+                        Layout.fillWidth: true
+                        valueBarWidth: 300
+                        value: Brightness.brightness
+                        color: Appearance.m3colors.m3warning
+                        onValueChanged: { Brightness.brightness = value; }
+                    }
+
+                    MaterialSymbol {
+                        Layout.alignment: Qt.AlignVCenter
+                        text: "brightness_high"
+                        iconSize: 20
+                        fill: 1
+                        color: Appearance.m3colors.m3warning
+                    }
+
+                    StyledText {
+                        Layout.alignment: Qt.AlignVCenter
+                        Layout.preferredWidth: 48
+                        text: `${Math.round(Brightness.brightness * 100)}%`
+                        font.pixelSize: Appearance.font.pixelSize.normal
+                        font.weight: Font.Bold
+                        font.features: { "tnum": 1 }
+                        color: Appearance.colors.colOnLayer0
+                    }
+                }
+
+                // External monitor brightness (DDC/CI) - placeholder
+                Revealer {
+                    reveal: false // Would show if DDC/CI monitors detected
+                    ColumnLayout {
+                        Layout.fillWidth: true
+                        spacing: 8
+
+                        RowLayout {
+                            Layout.fillWidth: true
+                            StyledText {
+                                text: Translation.tr("External Monitors (DDC/CI)")
+                                font.pixelSize: Appearance.font.pixelSize.smaller
+                                font.weight: Font.Medium
+                                color: Appearance.colors.colSubtext
+                            }
+                        }
+
+                        // Would list external monitors with DDC/CI brightness sliders
+                        Rectangle {
+                            Layout.fillWidth: true
+                            implicitHeight: 48
+                            radius: 8
+                            color: Appearance.colors.colLayer0
+                            border.width: 1
+                            border.color: Appearance.colors.colOutlineVariant
+
+                            StyledText {
+                                anchors.centerIn: parent
+                                text: Translation.tr("Connect external monitors with DDC/CI support to control hardware brightness")
+                                font.pixelSize: Appearance.font.pixelSize.smaller
+                                color: Appearance.colors.colSubtext
+                            }
+                        }
+                    }
+                }
+            }
+        }
+
+        // Night Light / Color Temperature section
+        Rectangle {
+            Layout.fillWidth: true
+            radius: 12
+            color: Appearance.colors.colLayer1
+            border.width: 1
+            border.color: Appearance.colors.colOutlineVariant
+
+            ColumnLayout {
+                anchors.fill: parent
+                Layout.leftMargin: 16
+                Layout.rightMargin: 16
+                Layout.topMargin: 16
+                Layout.bottomMargin: 16
+                spacing: 12
+
+                RowLayout {
+                    Layout.fillWidth: true
+                    spacing: 8
+
+                    MaterialSymbol {
+                        Layout.alignment: Qt.AlignVCenter
+                        text: Hyprsunset.temperatureActive ? "wb_twilight" : "wb_sunny"
+                        iconSize: 24
+                        fill: 1
+                        color: Hyprsunset.temperatureActive ? Appearance.m3colors.m3warning : Appearance.colors.colSubtext
+                    }
+
+                    StyledText {
+                        Layout.fillWidth: true
+                        Layout.alignment: Qt.AlignVCenter
+                        text: Translation.tr("Night Light")
+                        font.pixelSize: Appearance.font.pixelSize.normal
+                        font.weight: Font.Medium
+                        color: Appearance.colors.colOnLayer0
+                    }
+
+                    Switch {
+                        checked: Hyprsunset.temperatureActive
+                        onCheckedChanged: Hyprsunset.temperatureActive = checked
+                    }
+                }
+
+                Revealer {
+                    reveal: Hyprsunset.temperatureActive
+                    ColumnLayout {
+                        Layout.fillWidth: true
+                        spacing: 8
+
+                        // Temperature slider
+                        RowLayout {
+                            Layout.fillWidth: true
+                            spacing: 12
+
+                            MaterialSymbol {
+                                Layout.alignment: Qt.AlignVCenter
+                                text: "thermostat"
+                                iconSize: 20
+                                fill: 1
+                                color: Appearance.m3colors.m3warning
+                            }
+
+                            StyledProgressBar {
+                                Layout.fillWidth: true
+                                valueBarWidth: 300
+                                value: (Hyprsunset.temperature - 1000) / (6500 - 1000)
+                                color: Appearance.m3colors.m3warning
+                                onValueChanged: {
+                                    Hyprsunset.temperature = Math.round(1000 + value * (6500 - 1000));
+                                }
+                            }
+
+                            StyledText {
+                                Layout.alignment: Qt.AlignVCenter
+                                Layout.preferredWidth: 64
+                                text: `${Hyprsunset.temperature}K`
+                                font.pixelSize: Appearance.font.pixelSize.normal
+                                font.weight: Font.Bold
+                                font.features: { "tnum": 1 }
+                                color: Appearance.colors.colOnLayer0
+                            }
+                        }
+
+                        // Preset buttons
+                        RowLayout {
+                            Layout.fillWidth: true
+                            spacing: 8
+
+                            Repeater {
+                                model: [
+                                    { temp: 6500, label: Translation.tr("Daylight") },
+                                    { temp: 5000, label: Translation.tr("Neutral") },
+                                    { temp: 4000, label: Translation.tr("Warm") },
+                                    { temp: 3000, label: Translation.tr("Candle") },
+                                    { temp: 2000, label: Translation.tr("Deep Red") }
+                                ]
+                                delegate: MouseArea {
+                                    cursorShape: Qt.PointingHandCursor
+                                    onClicked: { Hyprsunset.temperature = modelData.temp; }
+                                    Rectangle {
+                                        anchors.fill: parent
+                                        radius: 8
+                                        color: Hyprsunset.temperature === modelData.temp ? Appearance.m3colors.m3warning : Appearance.colors.colLayer1
+                                        border.width: 1
+                                        border.color: Hyprsunset.temperature === modelData.temp ? Appearance.m3colors.m3warning : Appearance.colors.colOutlineVariant
+
+                                        StyledText {
+                                            anchors.centerIn: parent
+                                            Layout.leftMargin: 12
+                                            Layout.rightMargin: 12
+                                            Layout.topMargin: 8
+                                            Layout.bottomMargin: 8
+                                            text: modelData.label
+                                            font.pixelSize: Appearance.font.pixelSize.smaller
+                                            font.weight: Font.Medium
+                                            color: Hyprsunset.temperature === modelData.temp ? Appearance.colors.colOnLayer0 : Appearance.colors.colOnLayer0
+                                        }
+                                    }
+                                }
+                            }
+                        }
+                    }
+                }
+            }
+        }
+
+        // Gamma/Redshift section
+        Rectangle {
+            Layout.fillWidth: true
+            radius: 12
+            color: Appearance.colors.colLayer1
+            border.width: 1
+            border.color: Appearance.colors.colOutlineVariant
+
+            ColumnLayout {
+                anchors.fill: parent
+                Layout.leftMargin: 16
+                Layout.rightMargin: 16
+                Layout.topMargin: 16
+                Layout.bottomMargin: 16
+                spacing: 12
+
+                RowLayout {
+                    Layout.fillWidth: true
+                    spacing: 8
+
+                    MaterialSymbol {
+                        Layout.alignment: Qt.AlignVCenter
+                        text: "color_lens"
+                        iconSize: 24
+                        fill: 1
+                        color: Appearance.colors.colTertiary
+                    }
+
+                    StyledText {
+                        Layout.fillWidth: true
+                        Layout.alignment: Qt.AlignVCenter
+                        text: Translation.tr("Color Profile")
+                        font.pixelSize: Appearance.font.pixelSize.normal
+                        font.weight: Font.Medium
+                        color: Appearance.colors.colOnLayer0
+                    }
+
+                    Switch {
+                        checked: Hyprsunset.gammaEnabled
+                        onCheckedChanged: Hyprsunset.gammaEnabled = checked
+                    }
+                }
+
+                Revealer {
+                    reveal: Hyprsunset.gammaEnabled
+                    ColumnLayout {
+                        Layout.fillWidth: true
+                        spacing: 8
+
+                        // Red gamma
+                        GammaSlider {
+                            label: Translation.tr("Red")
+                            value: Hyprsunset.gammaRed
+                            color: Appearance.colors.colError
+                            onValueChanged: { Hyprsunset.gammaRed = value; }
+                        }
+
+                        // Green gamma
+                        GammaSlider {
+                            label: Translation.tr("Green")
+                            value: Hyprsunset.gammaGreen
+                            color: Appearance.m3colors.m3success
+                            onValueChanged: { Hyprsunset.gammaGreen = value; }
+                        }
+
+                        // Blue gamma
+                        GammaSlider {
+                            label: Translation.tr("Blue")
+                            value: Hyprsunset.gammaBlue
+                            color: Appearance.colors.colPrimary
+                            onValueChanged: { Hyprsunset.gammaBlue = value; }
+                        }
+
+                        // Reset button
+                        MouseArea {
+                            cursorShape: Qt.PointingHandCursor
+                            onClicked: { Hyprsunset.gammaRed = 1.0; Hyprsunset.gammaGreen = 1.0; Hyprsunset.gammaBlue = 1.0; }
+                            Rectangle {
+                                Layout.fillWidth: true
+                                implicitHeight: 36
+                                radius: 8
+                                color: Appearance.colors.colLayer0
+                                border.width: 1
+                                border.color: Appearance.colors.colOutlineVariant
+
+                                StyledText {
+                                    anchors.centerIn: parent
+                                    text: Translation.tr("Reset to Default")
+                                    font.pixelSize: Appearance.font.pixelSize.smaller
+                                    color: Appearance.colors.colSubtext
+                                }
+                            }
+                        }
+                    }
+                }
+            }
+        }
+    }
+}
+
+// Gamma slider component
+Item {
+    id: GammaSlider
+    required property string label
+    required property real value
+    required property color color
+    required property var onValueChanged
+    Layout.fillWidth: true
+    implicitHeight: 48
+
+    RowLayout {
+        anchors.fill: parent
+        Layout.leftMargin: 12
+        Layout.rightMargin: 12
+        spacing: 12
+
+        StyledText {
+            Layout.alignment: Qt.AlignVCenter
+            Layout.preferredWidth: 50
+            text: label
+            font.pixelSize: Appearance.font.pixelSize.smaller
+            color: Appearance.colors.colSubtext
+        }
+
+        StyledProgressBar {
+            Layout.fillWidth: true
+            valueBarWidth: 300
+            value: (value - 0.5) / 1.5 // 0.5 to 2.0 range
+            color: color
+            onValueChanged: {
+                const newVal = 0.5 + value * 1.5;
+                gammaSlider.onValueChanged(newVal);
+            }
+        }
+
+        StyledText {
+            Layout.alignment: Qt.AlignVCenter
+            Layout.preferredWidth: 40
+            text: value.toFixed(2)
+            font.pixelSize: Appearance.font.pixelSize.normal
+            font.weight: Font.Bold
+            font.features: { "tnum": 1 }
+            color: color
+        }
+    }
+}
\ No newline at end of file
