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

diff --git a/modules/ii/bar/DiExpandedTranslatorSection.qml b/modules/ii/bar/DiExpandedTranslatorSection.qml
new file mode 100644
index 00000000..4297b510
--- /dev/null
+++ b/modules/ii/bar/DiExpandedTranslatorSection.qml
@@ -0,0 +1,515 @@
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
+    property string translatedText: ""
+    property bool failed: false
+    property bool showLanguageSelector: false
+    property bool languageSelectorTarget: false // false = target, true = source
+
+    // Translation engine
+    readonly property string engine: {
+        const configured = Config.options.language.translator.engine ?? "auto";
+        return configured === "auto" ? "bing" : configured;
+    }
+
+    // Languages
+    readonly property var availableLanguages: Translation.availableLanguages
+    readonly property var generatedLanguages: Translation.generatedTranslations
+    readonly property var allLanguages: {
+        const combined = new Set([...root.availableLanguages, ...root.generatedLanguages]);
+        return Array.from(combined).sort();
+    }
+
+    // Current languages
+    property string targetLanguage: Config.options.language.translator.targetLanguage
+    property string sourceLanguage: Config.options.language.translator.sourceLanguage
+
+    // Input text
+    property string inputText: ""
+
+    // Debounce timer
+    Timer {
+        id: translateTimer
+        interval: Config.options.sidebar.translator.delay ?? 500
+        repeat: false
+        onTriggered: root.startTranslation()
+    }
+
+    function startTranslation() {
+        const text = root.inputText.trim();
+        if (text.length === 0) {
+            root.translatedText = "";
+            root.failed = false;
+            return;
+        }
+        translateProc.buffer = "";
+        translateProc.command = ["timeout", "12", "trans", "-e", root.engine, "-4", "-brief", "-no-bidi", "-source", root.sourceLanguage, "-target", root.targetLanguage, text];
+        translateProc.running = true;
+    }
+
+    function swapLanguages() {
+        const temp = root.targetLanguage;
+        root.targetLanguage = root.sourceLanguage;
+        root.sourceLanguage = temp;
+        Config.options.language.translator.targetLanguage = root.targetLanguage;
+        Config.options.language.translator.sourceLanguage = root.sourceLanguage;
+        translateTimer.restart();
+    }
+
+    function showLanguageSelectorDialog(isTargetLang) {
+        root.languageSelectorTarget = isTargetLang;
+        root.showLanguageSelector = true;
+    }
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
+                text: "translate"
+                iconSize: 20
+                fill: 1
+                color: Appearance.colors.colPrimary
+            }
+
+            StyledText {
+                Layout.alignment: Qt.AlignVCenter
+                text: Translation.tr("Translator")
+                font.pixelSize: Appearance.font.pixelSize.normal
+                font.weight: Font.Medium
+                color: Appearance.colors.colOnLayer0
+            }
+
+            Item { Layout.fillWidth: true }
+
+            // Engine selector
+            ConfigComboBox {
+                currentValue: root.engine
+                onSelected: newValue => {
+                    Config.options.language.translator.engine = newValue;
+                    if (root.inputText) translateTimer.restart();
+                }
+                options: [
+                    { displayName: Translation.tr("Bing"), icon: "microsoft", value: "bing" },
+                    { displayName: Translation.tr("Google"), icon: "google", value: "google" },
+                    { displayName: Translation.tr("Yandex"), icon: "yandex", value: "yandex" },
+                    { displayName: Translation.tr("DeepL"), icon: "cloud", value: "deepl" },
+                    { displayName: Translation.tr("Libre"), icon: "library_books", value: "libre" },
+                    { displayName: Translation.tr("Libre (no key)"), icon: "lock_open", value: "libre_free" }
+                ]
+            }
+        }
+
+        // Language selector row
+        Rectangle {
+            Layout.fillWidth: true
+            Layout.leftMargin: 16
+            Layout.rightMargin: 16
+            implicitHeight: 48
+            radius: 10
+            color: Appearance.colors.colLayer1
+            border.width: 1
+            border.color: Appearance.colors.colOutlineVariant
+
+            RowLayout {
+                anchors.fill: parent
+                Layout.leftMargin: 12
+                Layout.rightMargin: 12
+                spacing: 8
+
+                // Source language
+                MouseArea {
+                    Layout.fillWidth: true
+                    cursorShape: Qt.PointingHandCursor
+                    onClicked: showLanguageSelectorDialog(true)
+                    hoverEnabled: true
+
+                    RowLayout {
+                        Layout.fillWidth: true
+                        spacing: 8
+
+                        MaterialSymbol {
+                            Layout.alignment: Qt.AlignVCenter
+                            text: "arrow_upward"
+                            iconSize: 18
+                            fill: 1
+                            color: Appearance.colors.colSubtext
+                        }
+
+                        StyledText {
+                            Layout.fillWidth: true
+                            text: root.sourceLanguage
+                            font.pixelSize: Appearance.font.pixelSize.normal
+                            color: Appearance.colors.colOnLayer0
+                        }
+
+                        MaterialSymbol {
+                            Layout.alignment: Qt.AlignVCenter
+                            text: "swap_horiz"
+                            iconSize: 20
+                            fill: 1
+                            color: Appearance.colors.colPrimary
+                        }
+                    }
+                }
+
+                // Swap button
+                MouseArea {
+                    cursorShape: Qt.PointingHandCursor
+                    onClicked: swapLanguages()
+                    hoverEnabled: true
+
+                    Rectangle {
+                        Layout.alignment: Qt.AlignVCenter
+                        implicitWidth: 40
+                        implicitHeight: 40
+                        radius: 20
+                        color: Appearance.colors.colPrimary
+                        opacity: 0.15
+
+                        MaterialSymbol {
+                            anchors.centerIn: parent
+                            text: "swap_horiz"
+                            iconSize: 20
+                            fill: 1
+                            color: Appearance.colors.colPrimary
+                        }
+                    }
+                }
+
+                // Target language
+                MouseArea {
+                    Layout.fillWidth: true
+                    cursorShape: Qt.PointingHandCursor
+                    onClicked: showLanguageSelectorDialog(false)
+                    hoverEnabled: true
+
+                    RowLayout {
+                        Layout.fillWidth: true
+                        spacing: 8
+
+                        MaterialSymbol {
+                            Layout.alignment: Qt.AlignVCenter
+                            text: "arrow_downward"
+                            iconSize: 18
+                            fill: 1
+                            color: Appearance.colors.colSubtext
+                        }
+
+                        StyledText {
+                            Layout.fillWidth: true
+                            text: root.targetLanguage
+                            font.pixelSize: Appearance.font.pixelSize.normal
+                            color: Appearance.colors.colOnLayer0
+                        }
+                    }
+                }
+            }
+        }
+
+        // Input field
+        Rectangle {
+            Layout.fillWidth: true
+            Layout.leftMargin: 16
+            Layout.rightMargin: 16
+            implicitHeight: 44
+            radius: 10
+            color: Appearance.colors.colLayer1
+            border.width: 1
+            border.color: root.failed ? Appearance.colors.colError : Appearance.colors.colOutlineVariant
+
+            RowLayout {
+                anchors.fill: parent
+                Layout.leftMargin: 12
+                Layout.rightMargin: 12
+                spacing: 8
+
+                MaterialSymbol {
+                    Layout.alignment: Qt.AlignVCenter
+                    text: "translate"
+                    iconSize: 20
+                    fill: 1
+                    color: root.failed ? Appearance.colors.colError : Appearance.colors.colPrimary
+                }
+
+                TextField {
+                    id: inputField
+                    Layout.fillWidth: true
+                    background: null
+                    font.pixelSize: Appearance.font.pixelSize.normal
+                    color: Appearance.colors.colOnLayer0
+                    placeholderText: Translation.tr("Enter text to translate...")
+                    text: root.inputText
+                    onTextChanged: {
+                        root.inputText = text;
+                        translateTimer.restart();
+                    }
+                }
+            }
+        }
+
+        // Translation result
+        Revealer {
+            reveal: root.translatedText.length > 0 || root.failed
+            Layout.fillWidth: true
+            Layout.leftMargin: 16
+            Layout.rightMargin: 16
+
+            Rectangle {
+                Layout.fillWidth: true
+                radius: 12
+                color: root.failed ? Appearance.colors.colError : Appearance.colors.colPrimary
+                opacity: 0.1
+                border.width: 1
+                border.color: root.failed ? Appearance.colors.colError : Appearance.colors.colPrimary
+
+                ColumnLayout {
+                    anchors.fill: parent
+                    Layout.leftMargin: 12
+                    Layout.rightMargin: 12
+                    Layout.topMargin: 12
+                    Layout.bottomMargin: 12
+                    spacing: 8
+
+                    RowLayout {
+                        Layout.fillWidth: true
+                        spacing: 8
+
+                        MaterialSymbol {
+                            Layout.alignment: Qt.AlignVCenter
+                            text: root.failed ? "error" : "check_circle"
+                            iconSize: 20
+                            fill: 1
+                            color: root.failed ? Appearance.colors.colError : Appearance.colors.colPrimary
+                        }
+
+                        StyledText {
+                            Layout.fillWidth: true
+                            Layout.alignment: Qt.AlignVCenter
+                            text: root.failed ? Translation.tr("Translation failed") : root.translatedText
+                            font.pixelSize: Appearance.font.pixelSize.normal
+                            font.weight: Font.Medium
+                            color: root.failed ? Appearance.colors.colError : Appearance.colors.colOnLayer0
+                            elide: Text.ElideRight
+                        }
+
+                        // Copy button
+                        Revealer {
+                            reveal: !root.failed
+                            MouseArea {
+                                cursorShape: Qt.PointingHandCursor
+                                onClicked: { Quickshell.copyToClipboard(root.translatedText); }
+                                MaterialSymbol {
+                                    Layout.alignment: Qt.AlignVCenter
+                                    text: "content_copy"
+                                    iconSize: 18
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
+        // Language selector dialog
+        Revealer {
+            reveal: root.showLanguageSelector
+            Layout.fillWidth: true
+
+            Rectangle {
+                Layout.fillWidth: true
+                radius: 12
+                color: Appearance.colors.colLayer1
+                border.width: 1
+                border.color: Appearance.colors.colOutlineVariant
+
+                ColumnLayout {
+                    anchors.fill: parent
+                    Layout.leftMargin: 16
+                    Layout.rightMargin: 16
+                    Layout.topMargin: 12
+                    Layout.bottomMargin: 12
+                    spacing: 8
+
+                    RowLayout {
+                        Layout.fillWidth: true
+                        spacing: 8
+
+                        StyledText {
+                            Layout.alignment: Qt.AlignVCenter
+                            text: root.languageSelectorTarget ? Translation.tr("Target Language") : Translation.tr("Source Language")
+                            font.pixelSize: Appearance.font.pixelSize.normal
+                            font.weight: Font.Medium
+                            color: Appearance.colors.colOnLayer0
+                        }
+
+                        MouseArea {
+                            cursorShape: Qt.PointingHandCursor
+                            onClicked: root.showLanguageSelector = false
+                            MaterialSymbol {
+                                Layout.alignment: Qt.AlignVCenter
+                                text: "close"
+                                iconSize: 20
+                                fill: 1
+                                color: Appearance.colors.colSubtext
+                            }
+                        }
+                    }
+
+                    // Search
+                    Rectangle {
+                        Layout.fillWidth: true
+                        implicitHeight: 40
+                        radius: 10
+                        color: Appearance.colors.colLayer0
+                        border.width: 1
+                        border.color: Appearance.colors.colOutlineVariant
+
+                        RowLayout {
+                            anchors.fill: parent
+                            Layout.leftMargin: 12
+                            Layout.rightMargin: 12
+                            spacing: 8
+
+                            MaterialSymbol {
+                                Layout.alignment: Qt.AlignVCenter
+                                text: "search"
+                                iconSize: 20
+                                fill: 1
+                                color: Appearance.colors.colSubtext
+                            }
+
+                            TextField {
+                                id: langSearchField
+                                Layout.fillWidth: true
+                                background: null
+                                font.pixelSize: Appearance.font.pixelSize.normal
+                                color: Appearance.colors.colOnLayer0
+                                placeholderText: Translation.tr("Search languages...")
+                                onTextChanged: {
+                                    // Filter logic handled by model
+                                }
+                            }
+                        }
+                    }
+
+                    // Language list
+                    Flickable {
+                        Layout.fillWidth: true
+                        Layout.fillHeight: true
+                        clip: true
+                        contentHeight: langColumn.implicitHeight
+                        boundsBehavior: Flickable.StopAtBounds
+
+                        ColumnLayout {
+                            id: langColumn
+                            Layout.fillWidth: true
+                            spacing: 2
+
+                            Repeater {
+                                model: {
+                                    const filter = root.langSearchField ? root.langSearchField.text.toLowerCase() : "";
+                                    return root.allLanguages.filter(lang => lang.toLowerCase().includes(filter));
+                                }
+                                delegate: LanguageItem {
+                                    Layout.fillWidth: true
+                                    langCode: modelData
+                                    isTarget: !root.languageSelectorTarget
+                                    currentTarget: root.targetLanguage
+                                    currentSource: root.sourceLanguage
+                                }
+                            }
+                        }
+                    }
+                }
+            }
+        }
+
+        // Close on outside click
+        MouseArea {
+            anchors.fill: parent
+            enabled: root.showLanguageSelector
+            onClicked: root.showLanguageSelector = false
+        }
+    }
+}
+
+// Language item
+Item {
+    id: LanguageItem
+    required property string langCode
+    required property bool isTarget
+    required property string currentTarget
+    required property string currentSource
+
+    property bool isSelected: root.isTarget ? (langCode === root.currentTarget) : (langCode === root.currentSource)
+
+    Layout.fillWidth: true
+    implicitHeight: 44
+
+    MouseArea {
+        anchors.fill: parent
+        cursorShape: Qt.PointingHandCursor
+        onClicked: {
+            if (root.isTarget) {
+                root.targetLanguage = langCode;
+            } else {
+                root.sourceLanguage = langCode;
+            }
+            root.showLanguageSelector = false;
+        }
+        hoverEnabled: true
+        onEntered: parent.color = Qt.lighter(Appearance.colors.colLayer1, 1.1)
+        onExited: parent.color = root.isSelected ? Appearance.colors.colPrimaryContainer : "transparent"
+
+        Rectangle {
+            anchors.fill: parent
+            radius: 8
+            color: root.isSelected ? Appearance.colors.colPrimaryContainer : "transparent"
+            border.width: root.isSelected ? 1 : 0
+            border.color: Appearance.colors.colPrimary
+
+            RowLayout {
+                anchors.fill: parent
+                Layout.leftMargin: 12
+                Layout.rightMargin: 12
+                spacing: 8
+
+                MaterialSymbol {
+                    Layout.alignment: Qt.AlignVCenter
+                    text: root.isSelected ? "check_circle" : "radio_button_unchecked"
+                    iconSize: 20
+                    fill: 1
+                    color: root.isSelected ? Appearance.colors.colPrimary : Appearance.colors.colSubtext
+                }
+
+                StyledText {
+                    Layout.fillWidth: true
+                    text: langCode
+                    font.pixelSize: Appearance.font.pixelSize.normal
+                    color: root.isSelected ? Appearance.colors.colPrimary : Appearance.colors.colOnLayer0
+                }
+            }
+        }
+    }
+}
\ No newline at end of file
