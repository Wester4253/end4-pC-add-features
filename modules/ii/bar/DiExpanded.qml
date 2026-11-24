import QtQuick
import QtQuick.Layouts
import Quickshell
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell.Hyprland
import Quickshell.Services.UPower
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.ii.bar

Item {
    id: root
    required property Item di
    property bool mirrored: di.mirrored

    // Style system
    readonly property var islandStyle: IslandStyles
    readonly property int activeStyle: Config.options.bar.dynamicIsland.style ?? 0

    readonly property real panelWidth: islandStyle.panelWidth
    readonly property real panelHeight: islandStyle.panelHeight
    readonly property real cornerRadius: islandStyle.expandedRadius

    // Animation for panel appearance
    property real panelOpacity: 0
    property real panelScale: 0.95
    property bool panelVisible: false

    Behavior on panelOpacity {
        NumberAnimation { duration: islandStyle.panelFadeDuration; easing.type: islandStyle.panelEasingOut }
    }
    Behavior on panelScale {
        NumberAnimation { duration: islandStyle.panelScaleDuration; easing.type: islandStyle.panelEasingOut }
    }

    // Determine expand direction
    readonly property bool barAtBottom: Config.options.bar.bottom
    readonly property string expandDirection: Config.options.bar.dynamicIsland.expandDirection
    readonly property bool expandUp: {
        if (expandDirection === "up") return true;
        if (expandDirection === "down") return false;
        return barAtBottom; // auto: expand up if bar at bottom, down if bar at top
    }

    // Position relative to the dynamic island pill
    anchors.horizontalCenter: di.pill.horizontalCenter
    anchors.bottom: expandUp ? di.pill.top : undefined
    anchors.top: expandUp ? undefined : di.pill.bottom
    anchors.verticalCenterOffset: expandUp ? -8 : 8
    width: root.panelWidth
    height: root.panelHeight
    transformOrigin: expandUp ? Item.Bottom : Item.Top
    scale: root.panelScale
    opacity: root.panelOpacity
    clip: false

    // Trigger animations when loaded
    Component.onCompleted: {
        root.panelVisible = true
        root.panelOpacity = 1
        root.panelScale = 1
    }

    // Background with glass effect
    Rectangle {
        id: panelBg
        anchors.fill: parent
        radius: root.cornerRadius
        color: root.islandStyle.panelBg
        border.width: root.islandStyle.panelBorderWidth
        border.color: root.islandStyle.panelBorder
        clip: true

        WindowGlass {
            anchors.fill: parent
            anchors.margins: -4
            glassEnabled: Config.options.background.widgets.glass.enable && (root.activeStyle === 3 || root.activeStyle === 2)
            cardRadius: root.cornerRadius
            flareLeft: 0
            flareRight: 0
        }
    }

    // Shadow
    Rectangle {
        anchors.fill: panelBg
        anchors.margins: -12
        radius: root.cornerRadius + 8
        color: "transparent"
        layer.enabled: true
        layer.effect: Qt5Compat.GraphicalEffects.DropShadow {
            verticalOffset: root.islandStyle.shadowOffset
            horizontalOffset: 0
            radius: root.islandStyle.shadowRadius
            samples: 16
            color: root.islandStyle.panelShadow
            transparentBorder: true
        }
        visible: root.panelVisible
        opacity: root.panelOpacity
    }

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 56
            color: "transparent"
            border.width: root.islandStyle.panelBorderWidth
            border.color: root.islandStyle.panelBorder

            RowLayout {
                anchors.fill: parent
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                spacing: 12

                MaterialSymbol {
                    Layout.alignment: Qt.AlignVCenter
                    text: "nest_wifi_pro"
                    iconSize: 24
                    fill: 1
                    color: root.islandStyle.accentColor
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("Dynamic Island")
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: Font.Medium
                        color: root.islandStyle.textColor
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("Control Panel")
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: root.islandStyle.subtextColor
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.di.expanded = false
                    hoverEnabled: true
                }
            }
        }

        // Scrollable content
        Flickable {
            id: flickable
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentHeight: contentColumnInner.implicitHeight
            boundsBehavior: Flickable.StopAtBounds
            interactive: contentHeight > height

            ColumnLayout {
                id: contentColumnInner
                Layout.fillWidth: true
                spacing: 12

                // AI Usage Section
                Revealer {
                    reveal: Config.options.bar.dynamicIsland.showAiUsage
                    Layout.fillWidth: true
                    DiExpandedAiSection { di: root.di }
                }

                // System Stats Section
                Revealer {
                    reveal: Config.options.bar.dynamicIsland.showSystemStats
                    Layout.fillWidth: true
                    DiExpandedSystemSection { di: root.di }
                }

                // Weather Section
                Revealer {
                    reveal: Config.options.bar.dynamicIsland.showWeather && Weather.available
                    Layout.fillWidth: true
                    DiExpandedWeatherSection { di: root.di }
                }

                // Calendar Section
                Revealer {
                    reveal: Config.options.bar.dynamicIsland.showCalendar
                    Layout.fillWidth: true
                    DiExpandedCalendarSection { di: root.di }
                }

                // World Clock Section
                Revealer {
                    reveal: Config.options.bar.dynamicIsland.showWorldClock && WorldClock.clocks.length > 0
                    Layout.fillWidth: true
                    DiExpandedWorldClockSection { di: root.di }
                }

                // Media Section (if playing)
                Revealer {
                    reveal: Config.options.bar.dynamicIsland.showMedia && root.di.hasMedia
                    Layout.fillWidth: true
                    DiExpandedMediaSection { di: root.di }
                }

                // Visualizer Section
                Revealer {
                    reveal: Config.options.bar.dynamicIsland.showVisualizer
                    Layout.fillWidth: true
                    DiExpandedVisualizerSection { di: root.di }
                }

                // Notifications Section
                Revealer {
                    reveal: Config.options.bar.dynamicIsland.showNotifications
                    Layout.fillWidth: true
                    DiExpandedNotificationsSection { di: root.di }
                }

                // Clipboard Section
                Revealer {
                    reveal: Config.options.bar.dynamicIsland.showClipboard
                    Layout.fillWidth: true
                    DiExpandedClipboardSection { di: root.di }
                }

                // Active Window Section
                Revealer {
                    reveal: Config.options.bar.dynamicIsland.showActiveWindow
                    Layout.fillWidth: true
                    DiExpandedWindowSection { di: root.di }
                }

                // Recording Section
                Revealer {
                    reveal: Config.options.bar.dynamicIsland.showRecording
                    Layout.fillWidth: true
                    DiExpandedRecordingSection { di: root.di }
                }

                // Timers Section
                Revealer {
                    reveal: Config.options.bar.dynamicIsland.showTimers
                    Layout.fillWidth: true
                    DiExpandedTimerSection { di: root.di }
                }

                // Network Section
                Revealer {
                    reveal: Config.options.bar.dynamicIsland.showNetwork
                    Layout.fillWidth: true
                    DiExpandedNetworkSection { di: root.di }
                }

                // Bluetooth Section
                Revealer {
                    reveal: Config.options.bar.dynamicIsland.showBluetooth
                    Layout.fillWidth: true
                    DiExpandedBluetoothSection { di: root.di }
                }

                // Otto Host Pair Section
                Revealer {
                    reveal: Config.options.bar.dynamicIsland.showOttoHostPair
                    Layout.fillWidth: true
                    DiExpandedOttoHostPairSection { di: root.di }
                }

                // Quick Actions Section
                Revealer {
                    reveal: Config.options.bar.dynamicIsland.showQuickActions
                    Layout.fillWidth: true
                    DiExpandedActionsSection { di: root.di }
                }

                // VPN Section
                Revealer {
                    reveal: Config.options.bar.dynamicIsland.showVPN
                    Layout.fillWidth: true
                    DiExpandedVPNSection { di: root.di }
                }

                // Disk/Storage Section
                Revealer {
                    reveal: Config.options.bar.dynamicIsland.showDisk
                    Layout.fillWidth: true
                    DiExpandedDiskSection { di: root.di }
                }

                // GPU Section
                Revealer {
                    reveal: Config.options.bar.dynamicIsland.showGPU
                    Layout.fillWidth: true
                    DiExpandedGPUSection { di: root.di }
                }

                // Processes Section
                Revealer {
                    reveal: Config.options.bar.dynamicIsland.showProcesses
                    Layout.fillWidth: true
                    DiExpandedProcessesSection { di: root.di }
                }

                // Docker Section
                Revealer {
                    reveal: Config.options.bar.dynamicIsland.showDocker
                    Layout.fillWidth: true
                    DiExpandedDockerSection { di: root.di }
                }

                // Services Section
                Revealer {
                    reveal: Config.options.bar.dynamicIsland.showServices
                    Layout.fillWidth: true
                    DiExpandedServicesSection { di: root.di }
                }

                // Logs Section
                Revealer {
                    reveal: Config.options.bar.dynamicIsland.showLogs
                    Layout.fillWidth: true
                    DiExpandedLogsSection { di: root.di }
                }

                // Shortcuts Section
                Revealer {
                    reveal: Config.options.bar.dynamicIsland.showShortcuts
                    Layout.fillWidth: true
                    DiExpandedShortcutsSection { di: root.di }
                }

                // Updates Section
                Revealer {
                    reveal: Config.options.bar.dynamicIsland.showUpdates
                    Layout.fillWidth: true
                    DiExpandedUpdatesSection { di: root.di }
                }

                // Profiles Section
                Revealer {
                    reveal: Config.options.bar.dynamicIsland.showProfiles
                    Layout.fillWidth: true
                    DiExpandedProfilesSection { di: root.di }
                }

                // Focus Mode Section
                Revealer {
                    reveal: Config.options.bar.dynamicIsland.showFocus
                    Layout.fillWidth: true
                    DiExpandedFocusSection { di: root.di }
                }

                // System Info Section
                Revealer {
                    reveal: Config.options.bar.dynamicIsland.showSystemInfo
                    Layout.fillWidth: true
                    DiExpandedSystemInfoSection { di: root.di }
                }

                Item { Layout.fillWidth: true; implicitHeight: 16 }
            }
        }
    }

    // Close on outside click
    MouseArea {
        anchors.fill: parent
        enabled: root.panelVisible
        onClicked: {
            root.di.expanded = false
        }
    }
}