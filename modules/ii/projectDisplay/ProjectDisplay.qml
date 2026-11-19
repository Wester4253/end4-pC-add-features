import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root
    property bool active: false

    // State
    property var monitors: []
    property var audioOutputs: []
    property var audioInputs: []
    property int activeTab: 0 // 0 = Display, 1 = Audio, 2 = Brightness/Color

    // Monitors
    Timer {
        interval: 2000
        running: root.active
        repeat: true
        triggeredOnStart: true
        onTriggered: refreshMonitors()
    }

    // Audio
    Connections {
        target: Audio
        function onSourceListChanged() { if (root.active) refreshAudio(); }
        function onSinkListChanged() { if (root.active) refreshAudio(); }
    }

    Timer {
        interval: 2000
        running: root.active
        repeat: true
        triggeredOnStart: true
        onTriggered: refreshAudio()
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

                // Position at center of screen
                x: (Window.screen.width - width) / 2
                y: (Window.screen.height - height) / 2
                width: 560
                height: 480

                // Close on outside click
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.active = false
                    }
                }

                // Main panel
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

                        // Header with tabs
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
                                spacing: 4

                                // Tab buttons
                                Repeater {
                                    model: [
                                        { id: 0, icon: "monitor", label: Translation.tr("Display") },
                                        { id: 1, icon: "volume_up", label: Translation.tr("Audio") },
                                        { id: 2, icon: "brightness_6", label: Translation.tr("Brightness") }
                                    ]
                                    delegate: TabButton {
                                        Layout.fillWidth: true
                                        tabData: modelData
                                        active: root.activeTab === modelData.id
                                        onClicked: root.activeTab = modelData.id
                                    }
                                }
                            }
                        }
                    }

                    // Content
                    Flickable {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        contentHeight: contentColumn.implicitHeight
                        boundsBehavior: Flickable.StopAtBounds

                        ColumnLayout {
                            id: contentColumn
                            Layout.fillWidth: true
                            spacing: 12
                            Layout.leftMargin: 16
                            Layout.rightMargin: 16
                            Layout.topMargin: 12
                            Layout.bottomMargin: 16

                            // Display Tab
                            Revealer {
                                reveal: root.activeTab === 0
                                Layout.fillWidth: true
                                DisplayTabContent { di: root }
                            }

                            // Audio Tab
                            Revealer {
                                reveal: root.activeTab === 1
                                Layout.fillWidth: true
                                AudioTabContent { di: root }
                            }

                            // Brightness/Color Tab
                            Revealer {
                                reveal: root.activeTab === 2
                                Layout.fillWidth: true
                                BrightnessTabContent { di: root }
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

// Tab Button
Item {
    id: TabButton
    required property var tabData
    required property bool active
    required property var onClicked
    Layout.fillWidth: true
    implicitHeight: 40

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: root.active ? Appearance.colors.colPrimary : "transparent"
        border.width: 1
        border.color: root.active ? "transparent" : Appearance.colors.colOutlineVariant

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: tabButton.onClicked()
            hoverEnabled: true
            onEntered: parent.color = root.active ? Appearance.colors.colPrimary : Qt.lighter(Appearance.colors.colLayer1, 1.1)
            onExited: parent.color = root.active ? Appearance.colors.colPrimary : "transparent"

            RowLayout {
                anchors.centerIn: parent
                spacing: 8

                MaterialSymbol {
                    Layout.alignment: Qt.AlignVCenter
                    text: tabButton.tabData.icon
                    iconSize: 20
                    fill: 1
                    color: root.active ? Appearance.colors.colOnPrimary : Appearance.colors.colOnLayer0
                }

                StyledText {
                    Layout.alignment: Qt.AlignVCenter
                    text: tabButton.tabData.label
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Medium
                    color: root.active ? Appearance.colors.colOnPrimary : Appearance.colors.colOnLayer0
                }
            }
        }
    }
}

// Display Tab Content
Item {
    id: DisplayTabContent
    required property Item di
    Layout.fillWidth: true

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 12

        // Quick projection modes
        Rectangle {
            Layout.fillWidth: true
            radius: 12
            color: Appearance.colors.colLayer1
            border.width: 1
            border.color: Appearance.colors.colOutlineVariant

            ColumnLayout {
                anchors.fill: parent
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.topMargin: 16
                Layout.bottomMargin: 16
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    StyledText {
                        text: Translation.tr("Projection Mode")
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: Font.Medium
                        color: Appearance.colors.colOnLayer0
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 4
                    columnSpacing: 8
                    rowSpacing: 8

                    Repeater {
                        model: [
                            { id: "only", icon: "laptop_mac", label: Translation.tr("PC Screen Only"), shortcut: "1" },
                            { id: "mirror", icon: "screen_mirror", label: Translation.tr("Duplicate"), shortcut: "2" },
                            { id: "extend", icon: "screen_share", label: Translation.tr("Extend"), shortcut: "3" },
                            { id: "second", icon: "monitor", label: Translation.tr("Second Screen Only"), shortcut: "4" }
                        ]
                        delegate: ModeButton {
                            Layout.fillWidth: true
                            modeData: modelData
                        }
                    }
                }
            }
        }

        // Monitors list
        Revealer {
            reveal: di.monitors && di.monitors.length > 0
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    StyledText {
                        text: Translation.tr("Connected Displays (%1)").arg(di.monitors.length)
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        font.weight: Font.Medium
                        color: Appearance.colors.colSubtext
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Repeater {
                        model: di.monitors
                        delegate: MonitorCard {
                            Layout.fillWidth: true
                            monitor: modelData
                        }
                    }
                }
            }
        }

        Revealer {
            reveal: !di.monitors || di.monitors.length === 0
            Layout.fillWidth: true

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 80
                radius: 12
                color: Appearance.colors.colLayer1
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant
                opacity: 0.5

                StyledText {
                    anchors.centerIn: parent
                    text: Translation.tr("No displays detected")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colSubtext
                }
            }
        }
    }
}

// Mode Button
Item {
    id: ModeButton
    required property var modeData
    Layout.fillWidth: true
    Layout.preferredHeight: 56

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: Appearance.colors.colLayer1
        border.width: 1
        border.color: Appearance.colors.colOutlineVariant

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: di.setMonitorMode(modeData.id)
            onEntered: parent.color = Qt.lighter(Appearance.colors.colLayer1, 1.05)
            onExited: parent.color = Appearance.colors.colLayer1

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 4

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    implicitWidth: 48
                    implicitHeight: 48
                    radius: 24
                    color: Appearance.colors.colPrimary
                    opacity: 0.15

                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: modeData.icon
                        iconSize: 24
                        fill: 1
                        color: Appearance.colors.colPrimary
                    }
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: modeData.label
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Medium
                    color: Appearance.colors.colOnLayer0
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: modeData.shortcut
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.weight: Font.Bold
                    color: Appearance.colors.colSubtext
                }
            }
        }
    }
}

// Monitor Card
Item {
    id: MonitorCard
    required property var monitor
    Layout.fillWidth: true
    implicitHeight: 72

    property string displayName: monitor.name || Translation.tr("Unknown")
    property string resolution: `${monitor.width || 0}x${monitor.height || 0}@${monitor.refreshRate || 60}Hz`
    property string scale: monitor.scale ? `x${monitor.scale}` : ""
    property bool isPrimary: monitor.id === 0

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Appearance.colors.colLayer1
        border.width: 1
        border.color: root.isPrimary ? Appearance.colors.colPrimary : Appearance.colors.colOutlineVariant

        RowLayout {
            anchors.fill: parent
            Layout.leftMargin: 12
            Layout.rightMargin: 12
            spacing: 12

            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 48
                implicitHeight: 48
                radius: 24
                color: root.isPrimary ? Appearance.colors.colPrimary : Appearance.colors.colPrimary
                opacity: 0.15

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: root.isPrimary ? "laptop_mac" : "monitor"
                    iconSize: 24
                    fill: 1
                    color: root.isPrimary ? Appearance.colors.colPrimary : Appearance.colors.colPrimary
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: -2

                StyledText {
                    Layout.fillWidth: true
                    text: displayName
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Medium
                    color: Appearance.colors.colOnLayer0
                }

                StyledText {
                    Layout.fillWidth: true
                    text: `${resolution}  ${scale}  ${monitor.transform || 0}°`
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }
            }

            RowLayout {
                spacing: 4

                // Resolution selector
                ConfigComboBox {
                    currentValue: `${monitor.width || 1920}x${monitor.height || 1080}@${monitor.refreshRate || 60}`
                    onSelected: newValue => { /* Would apply resolution */ }
                    options: [
                        { displayName: "1920x1080@60", value: "1920x1080@60" },
                        { displayName: "1920x1080@144", value: "1920x1080@144" },
                        { displayName: "2560x1440@60", value: "2560x1440@60" },
                        { displayName: "2560x1440@144", value: "2560x1440@144" },
                        { displayName: "3840x2160@60", value: "3840x2160@60" }
                    ]
                }

                // Scale
                ConfigComboBox {
                    currentValue: monitor.scale || "1"
                    onSelected: newValue => { /* Would apply scale */ }
                    options: [
                        { displayName: "100%", value: "1" },
                        { displayName: "125%", value: "1.25" },
                        { displayName: "150%", value: "1.5" },
                        { displayName: "200%", value: "2" }
                    ]
                }

                // Transform (rotation)
                ConfigComboBox {
                    currentValue: monitor.transform || "0"
                    onSelected: newValue => { /* Would apply transform */ }
                    options: [
                        { displayName: "0°", value: "0" },
                        { displayName: "90°", value: "1" },
                        { displayName: "180°", value: "2" },
                        { displayName: "270°", value: "3" }
                    ]
                }

                // VRR toggle
                Revealer {
                    reveal: monitor.vrrAvailable === true
                    Switch {
                        checked: monitor.vrrEnabled || false
                        onCheckedChanged: { /* Would toggle VRR */ }
                    }
                }

                // DPMS sleep
                MouseArea {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { /* Would call DPMS off */ }
                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "bedtime"
                        iconSize: 20
                        fill: 1
                        color: Appearance.colors.colSubtext
                    }
                }
            }
        }
    }
}