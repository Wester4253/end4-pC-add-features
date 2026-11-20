commit b1fd183f905aeea531765b24ed47eb10ecf86c7e
Author: OttoAgent <noah.butterfeild@gmail.com>
Date:   Thu Nov 19 14:57:21 2026 +0000

    feat: Add 4 new Dynamic Island sections (Todo, Notes, Translator, SongRec)
    
    - DiExpandedTodoSection.qml: Full todo/task manager with add/edit/delete/mark done
    - DiExpandedNotesSection.qml: Notes manager with add/edit/delete, timestamps
    - DiExpandedTranslatorSection.qml: Full translator with multi-engine, language selector, swap
    - DiExpandedSongRecSection.qml: Music recognition with monitor/input source, settings
    - Config: Added showTodo, showNotes, showTranslator, showSongRec options
    - BarConfig: Added toggles for all 4 sections in Panel Sections
    - DashboardSettingsCatalog: Added searchable settings for all 4
    - Config: Added showTodo, showNotes, showTranslator, showSongRec to dynamicIsland

diff --git a/modules/ii/bar/DiExpandedSongRecSection.qml b/modules/ii/bar/DiExpandedSongRecSection.qml
new file mode 100644
index 00000000..90b4c959
--- /dev/null
+++ b/modules/ii/bar/DiExpandedSongRecSection.qml
@@ -0,0 +1,339 @@
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
+        spacing: 8
+
+        // Section header
+        RowLayout {
+            Layout.fillWidth: true
+            Layout.leftMargin: 16
+            Layout.rightMargin: 16
+            spacing: 8
+
+            MaterialSymbol {
+                Layout.alignment: Qt.AlignVCenter
+                text: "music_note"
+                iconSize: 20
+                fill: 1
+                color: Appearance.colors.colPrimary
+            }
+
+            StyledText {
+                Layout.alignment: Qt.AlignVCenter
+                text: Translation.tr("Music Recognition")
+                font.pixelSize: Appearance.font.pixelSize.normal
+                font.weight: Font.Medium
+                color: Appearance.colors.colOnLayer0
+            }
+
+            Item { Layout.fillWidth: true }
+
+            // Monitor source toggle
+            Switch {
+                checked: SongRec.monitorSource === SongRec.MonitorSource.Monitor
+                onCheckedChanged: SongRec.toggleMonitorSource(checked)
+            }
+
+            StyledText {
+                Layout.alignment: Qt.AlignVCenter
+                text: SongRec.monitorSourceString
+                font.pixelSize: Appearance.font.pixelSize.smaller
+                color: Appearance.colors.colSubtext
+            }
+        }
+
+        // Status / Current track
+        Revealer {
+            reveal: SongRec.recognizedTrack && SongRec.recognizedTrack.title
+            Layout.fillWidth: true
+            Layout.leftMargin: 16
+            Layout.rightMargin: 16
+
+            Rectangle {
+                Layout.fillWidth: true
+                radius: 16
+                color: Appearance.colors.colPrimary
+                opacity: 0.15
+
+                ColumnLayout {
+                    anchors.fill: parent
+                    Layout.leftMargin: 16
+                    Layout.rightMargin: 16
+                    Layout.topMargin: 16
+                    Layout.bottomMargin: 16
+                    spacing: 8
+
+                    RowLayout {
+                        Layout.fillWidth: true
+                        spacing: 12
+
+                        MaterialSymbol {
+                            Layout.alignment: Qt.AlignVCenter
+                            text: "music_note"
+                            iconSize: 32
+                            fill: 1
+                            color: Appearance.colors.colPrimary
+                        }
+
+                        ColumnLayout {
+                            Layout.fillWidth: true
+                            spacing: 2
+
+                            StyledText {
+                                Layout.fillWidth: true
+                                text: SongRec.recognizedTrack.title
+                                font.pixelSize: Appearance.font.pixelSize.normal
+                                font.weight: Font.Medium
+                                color: Appearance.colors.colOnLayer0
+                                elide: Text.ElideRight
+                            }
+
+                            StyledText {
+                                Layout.fillWidth: true
+                                text: SongRec.recognizedTrack.subtitle
+                                font.pixelSize: Appearance.font.pixelSize.smaller
+                                color: Appearance.colors.colSubtext
+                                elide: Text.ElideRight
+                            }
+                        }
+
+                        // Open link
+                        Revealer {
+                            reveal: SongRec.recognizedTrack.url
+                            MouseArea {
+                                cursorShape: Qt.PointingHandCursor
+                                onClicked: { Quickshell.execDetached(["xdg-open", SongRec.recognizedTrack.url]); }
+                                MaterialSymbol {
+                                    Layout.alignment: Qt.AlignVCenter
+                                    text: "open_in_new"
+                                    iconSize: 20
+                                    fill: 1
+                                    color: Appearance.colors.colPrimary
+                                }
+                            }
+                        }
+                    }
+                }
+            }
+        }
+
+        // Currently listening
+        Revealer {
+            reveal: SongRec.running && (!SongRec.recognizedTrack || !SongRec.recognizedTrack.title)
+            Layout.fillWidth: true
+            Layout.leftMargin: 16
+            Layout.rightMargin: 16
+
+            Rectangle {
+                Layout.fillWidth: true
+                radius: 12
+                color: Appearance.colors.colPrimary
+                opacity: 0.1
+
+                ColumnLayout {
+                    anchors.centerIn: parent
+                    Layout.fillWidth: true
+                    Layout.leftMargin: 16
+                    Layout.rightMargin: 16
+                    Layout.topMargin: 16
+                    Layout.bottomMargin: 16
+                    spacing: 12
+
+                    RowLayout {
+                        Layout.fillWidth: true
+                        spacing: 8
+
+                        BusySpinner {
+                            Layout.alignment: Qt.AlignVCenter
+                            size: 32
+                        }
+
+                        ColumnLayout {
+                            Layout.fillWidth: true
+                            spacing: 4
+
+                            StyledText {
+                                Layout.fillWidth: true
+                                text: Translation.tr("Listening...")
+                                font.pixelSize: Appearance.font.pixelSize.normal
+                                font.weight: Font.Medium
+                                color: Appearance.colors.colPrimary
+                            }
+
+                            StyledText {
+                                Layout.fillWidth: true
+                                text: Translation.tr("Playing audio from %1").arg(SongRec.monitorSourceString)
+                                font.pixelSize: Appearance.font.pixelSize.smaller
+                                color: Appearance.colors.colSubtext
+                            }
+                        }
+                    }
+
+                    // Stop button
+                    MouseArea {
+                        cursorShape: Qt.PointingHandCursor
+                        onClicked: SongRec.toggleRunning(false)
+                        MaterialSymbol {
+                            Layout.alignment: Qt.AlignVCenter
+                            text: "stop_circle"
+                            iconSize: 24
+                            fill: 1
+                            color: Appearance.colors.colError
+                        }
+                    }
+                }
+            }
+        }
+
+        // Start button (when not running)
+        Revealer {
+            reveal: !SongRec.running
+            Layout.fillWidth: true
+            Layout.leftMargin: 16
+            Layout.rightMargin: 16
+
+            MouseArea {
+                cursorShape: Qt.PointingHandCursor
+                onClicked: SongRec.toggleRunning(true)
+
+                Rectangle {
+                    Layout.fillWidth: true
+                    implicitHeight: 56
+                    radius: 12
+                    color: Appearance.colors.colPrimary
+
+                    RowLayout {
+                        anchors.centerIn: parent
+                        spacing: 8
+
+                        MaterialSymbol {
+                            Layout.alignment: Qt.AlignVCenter
+                            text: "music_note"
+                            iconSize: 24
+                            fill: 1
+                            color: Appearance.colors.colOnPrimary
+                        }
+
+                        StyledText {
+                            Layout.alignment: Qt.AlignVCenter
+                            text: Translation.tr("Identify Music")
+                            font.pixelSize: Appearance.font.pixelSize.normal
+                            font.weight: Font.Medium
+                            color: Appearance.colors.colOnPrimary
+                        }
+                    }
+                }
+            }
+        }
+
+        // Settings
+        Revealer {
+            reveal: !SongRec.running
+            Layout.fillWidth: true
+            Layout.leftMargin: 16
+            Layout.rightMargin: 16
+
+            ColumnLayout {
+                Layout.fillWidth: true
+                spacing: 8
+
+                // Timeout interval
+                RowLayout {
+                    Layout.fillWidth: true
+                    spacing: 8
+
+                    StyledText {
+                        Layout.alignment: Qt.AlignVCenter
+                        text: Translation.tr("Check Interval")
+                        font.pixelSize: Appearance.font.pixelSize.smaller
+                        color: Appearance.colors.colSubtext
+                        Layout.preferredWidth: 100
+                    }
+
+                    ConfigSpinBox {
+                        Layout.fillWidth: true
+                        from: 1
+                        to: 30
+                        stepSize: 1
+                        value: Config.options.musicRecognition.interval
+                        onValueChanged: Config.options.musicRecognition.interval = value
+                    }
+
+                    StyledText {
+                        Layout.alignment: Qt.AlignVCenter
+                        text: "s"
+                        font.pixelSize: Appearance.font.pixelSize.smaller
+                        color: Appearance.colors.colSubtext
+                    }
+                }
+
+                // Timeout duration
+                RowLayout {
+                    Layout.fillWidth: true
+                    spacing: 8
+
+                    StyledText {
+                        Layout.alignment: Qt.AlignVCenter
+                        text: Translation.tr("Timeout")
+                        font.pixelSize: Appearance.font.pixelSize.smaller
+                        color: Appearance.colors.colSubtext
+                        Layout.preferredWidth: 100
+                    }
+
+                    ConfigSpinBox {
+                        Layout.fillWidth: true
+                        from: 5
+                        to: 60
+                        stepSize: 5
+                        value: Config.options.musicRecognition.timeout
+                        onValueChanged: Config.options.musicRecognition.timeout = value
+                    }
+
+                    StyledText {
+                        Layout.alignment: Qt.AlignVCenter
+                        text: "s"
+                        font.pixelSize: Appearance.font.pixelSize.smaller
+                        color: Appearance.colors.colSubtext
+                    }
+                }
+
+                // Monitor source
+                RowLayout {
+                    Layout.fillWidth: true
+                    spacing: 8
+
+                    StyledText {
+                        Layout.alignment: Qt.AlignVCenter
+                        text: Translation.tr("Monitor Source")
+                        font.pixelSize: Appearance.font.pixelSize.smaller
+                        color: Appearance.colors.colSubtext
+                        Layout.preferredWidth: 100
+                    }
+
+                    ConfigComboBox {
+                        currentValue: SongRec.monitorSourceString
+                        onSelected: newValue => {
+                            SongRec.toggleMonitorSource(newValue === "monitor" ? SongRec.MonitorSource.Monitor : SongRec.MonitorSource.Input);
+                        }
+                        options: [
+                            { displayName: Translation.tr("Monitor (Output)"), icon: "tv", value: "monitor" },
+                            { displayName: Translation.tr("Input (Microphone)"), icon: "mic", value: "input" }
+                        ]
+                    }
+                }
+            }
+        }
+    }
+}
\ No newline at end of file
