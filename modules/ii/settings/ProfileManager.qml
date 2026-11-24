import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions as CF

ContentPage {
    id: page
    forceWidth: true
    bottomContentPadding: 35

    property var currentProfile: ""
    property var profiles: []
    property bool loading: false
    property string statusMessage: ""
    property string statusType: "" // "info", "success", "error"

    // Default profile sources
    readonly property var defaultSources: [
        {
            id: "upstream",
            name: "Illogical Impulse (Upstream)",
            description: "Original end-4 dots-hyprland configuration",
            repo: "https://github.com/end-4/dots-hyprland.git",
            branch: "main",
            path: "quickshell",
            official: true
        },
        {
            id: "illogical-impulse",
            name: "Illogical Impulse II",
            description: "end-4's illogical-impulse panel family",
            repo: "https://github.com/end-4/illogical-impulse.git",
            branch: "main",
            path: "",
            official: true
        },
        {
            id: "wester4253",
            name: "Wester4253's Fork (Current)",
            description: "This fork with Dynamic Island overhaul",
            repo: "https://github.com/Wester4253/end4-pC-add-features.git",
            branch: "main",
            path: "",
            official: true
        },
        {
            id: "chillpill",
            name: "ChillPill Shell",
            description: "Waybar-style custom pill bar with theming",
            repo: "https://github.com/LUCKYS1NGHH/ChillPill-Shell.git",
            branch: "main",
            path: "qml",
            official: false
        },
        {
            id: "openagentisland",
            name: "OpenAgentIsland",
            description: "Agent-focused dynamic island with notch style",
            repo: "https://github.com/patheonsceo/openagentisland.git",
            branch: "main",
            path: "quickshell",
            official: false
        }
    ]

    Component.onCompleted: {
        loadProfiles()
    }

    function loadProfiles() {
        loading = true
        statusMessage = Translation.tr("Loading profiles...")
        statusType = "info"
        
        // Load from config
        const saved = Config.options.profileManager.profiles ?? []
        const custom = Config.options.profileManager.customSources ?? []
        
        // Merge default sources with custom
        var all = []
        defaultSources.forEach(ds => {
            const customMatch = custom.find(c => c.id === ds.id)
            all.push({
                ...ds,
                installed: checkInstalled(ds.id),
                current: ds.id === Config.options.profileManager.activeProfile,
                custom: customMatch ? customMatch : null
            })
        })
        
        // Add purely custom sources
        custom.forEach(c => {
            if (!defaultSources.find(ds => ds.id === c.id)) {
                all.push({
                    ...c,
                    installed: checkInstalled(c.id),
                    current: c.id === Config.options.profileManager.activeProfile,
                    custom: c
                })
            }
        })
        
        profiles = all
        loading = false
        statusMessage = ""
    }

    function checkInstalled(profileId) {
        const profileDir = getProfileDir(profileId)
        return Qt.fileExists(profileDir + "/shell.qml")
    }

    function getProfileDir(profileId) {
        return Directories.configPath + "/profiles/" + profileId
    }

    function installProfile(profile) {
        loading = true
        statusMessage = Translation.tr("Installing %1...").arg(profile.name)
        statusType = "info"
        
        const script = `
            set -euo pipefail
            PROFILE_DIR="${Directories.configPath}/profiles/${profile.id}"
            mkdir -p "$PROFILE_DIR"
            
            # Clone or update
            if [ -d "$PROFILE_DIR/.git" ]; then
                cd "$PROFILE_DIR"
                git fetch origin
                git reset --hard origin/${profile.branch}
            else
                git clone --branch ${profile.branch} --depth 1 ${profile.repo} "$PROFILE_DIR" 2>/dev/null || git clone ${profile.repo} "$PROFILE_DIR"
                cd "$PROFILE_DIR"
                git checkout ${profile.branch}
            fi
            
            # If path specified, copy from subdirectory
            if [ -n "${profile.path}" ] && [ -d "$PROFILE_DIR/${profile.path}" ]; then
                rsync -a --delete "$PROFILE_DIR/${profile.path}/" "$PROFILE_DIR/"
            fi
            
            echo "INSTALLED:${profile.id}"
        `
        
        installProcess.command = ["sh", "-c", script]
        installProcess.running = true
    }

    function applyProfile(profile) {
        loading = true
        statusMessage = Translation.tr("Applying %1...").arg(profile.name)
        statusType = "info"
        
        const script = `
            set -euo pipefail
            PROFILE_DIR="${Directories.configPath}/profiles/${profile.id}"
            QS_DIR="${Directories.configPath}/quickshell"
            
            # Backup current
            BACKUP_DIR="${Directories.configPath}/backups/profile-switch-$(date +%Y%m%d-%H%M%S)"
            mkdir -p "$BACKUP_DIR"
            [ -d "$QS_DIR" ] && cp -r "$QS_DIR" "$BACKUP_DIR/quickshell"
            
            # Apply new profile
            rsync -a --delete "$PROFILE_DIR/" "$QS_DIR/"
            
            # Update active profile in config
            python3 -c "
import json
import os
config_path = os.path.expanduser('~/.config/quickshell/config.jsonc')
if os.path.exists(config_path):
    with open(config_path) as f:
        content = f.read()
    # Simple JSONC update - in reality use proper parser
    import re
    content = re.sub(r'\\\"activeProfile\\\"\\s*:\\s*\\\"[^\\\"]*\\\"', '\\\"activeProfile\\\": \\\"${profile.id}\\\"', content)
    with open(config_path, 'w') as f:
        f.write(content)
"
            
            echo "APPLIED:${profile.id}"
        `
        
        applyProcess.command = ["sh", "-c", script]
        applyProcess.running = true
    }

    function addCustomSource() {
        // Open dialog to add custom GitHub repo
        customDialog.open()
    }

    function saveCustomSource(data) {
        const custom = (Config.options.profileManager.customSources ?? []).slice()
        const existing = custom.findIndex(c => c.id === data.id)
        if (existing >= 0) {
            custom[existing] = data
        } else {
            custom.push(data)
        }
        Config.options.profileManager.customSources = custom
        loadProfiles()
    }

    function removeCustomSource(id) {
        const custom = (Config.options.profileManager.customSources ?? []).filter(c => c.id !== id)
        Config.options.profileManager.customSources = custom
        loadProfiles()
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 20

        // Header
        ContentSection {
            icon: "folder_git"
            shape: MaterialShape.Shape.Gem
            title: Translation.tr("Profile Manager")
            hint: Translation.tr("Switch between complete dotfile configurations. Each profile is a full quickshell setup.")

            GroupedList {
                ConfigRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    spacing: 10

                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("Manage and switch between complete dotfile profiles from GitHub")
                        color: Appearance.colors.colOnSecondaryContainer
                    }
                }

                ConfigRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    spacing: 10

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: page.addCustomSource()
                    }
                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("Add Custom Repository")
                        color: Appearance.colors.colPrimary
                        font.weight: Font.Medium
                    }
                    MaterialSymbol {
                        text: "add"
                        iconSize: 20
                        color: Appearance.colors.colPrimary
                    }
                }

                ConfigRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    spacing: 10

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            loadProfiles()
                        }
                    }
                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("Refresh Profiles")
                        color: Appearance.colors.colPrimary
                        font.weight: Font.Medium
                    }
                    MaterialSymbol {
                        text: "refresh"
                        iconSize: 20
                        color: Appearance.colors.colPrimary
                    }
                }
            }
        }

        // Status banner
        Revealer {
            reveal: page.statusMessage !== ""
            Layout.fillWidth: true

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                radius: 12
                color: page.statusType === "error" ? Appearance.colors.colErrorContainer :
                       page.statusType === "success" ? Appearance.colors.colSuccessContainer :
                       Appearance.colors.colPrimaryContainer
                border.width: 1
                border.color: page.statusType === "error" ? Appearance.colors.colError :
                              page.statusType === "success" ? Appearance.colors.colSuccess :
                              Appearance.colors.colPrimary
                implicitHeight: 48

                RowLayout {
                    anchors.fill: parent
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    spacing: 12

                    MaterialSymbol {
                        Layout.alignment: Qt.AlignVCenter
                        text: page.statusType === "error" ? "error" :
                              page.statusType === "success" ? "check_circle" : "info"
                        iconSize: 20
                        fill: 1
                        color: page.statusType === "error" ? Appearance.colors.colError :
                               page.statusType === "success" ? Appearance.colors.colSuccess :
                               Appearance.colors.colPrimary
                    }

                    StyledText {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        text: page.statusMessage
                        font.pixelSize: Appearance.font.pixelSize.normal
                        color: page.statusType === "error" ? Appearance.colors.colOnErrorContainer :
                               page.statusType === "success" ? Appearance.colors.colOnSuccessContainer :
                               Appearance.colors.colOnPrimaryContainer
                    }
                }
            }
        }

        // Profile list
        ContentSection {
            icon: "grid_view"
            shape: MaterialShape.Shape.Cookie4Sided
            title: Translation.tr("Available Profiles")

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                contentHeight: profileColumn.implicitHeight
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: profileColumn
                    Layout.fillWidth: true
                    spacing: 12

                    Repeater {
                        model: page.profiles
                        delegate: ProfileCard {
                            Layout.fillWidth: true
                            profile: modelData
                            onInstallClicked: page.installProfile(modelData)
                            onApplyClicked: page.applyProfile(modelData)
                            onRemoveClicked: page.removeCustomSource(modelData.id)
                        }
                    }
                }
            }
        }

        // Custom source dialog
        CustomSourceDialog {
            id: customDialog
            onSave: page.saveCustomSource(data)
        }

        // Install process
        Process {
            id: installProcess
            running: false
            stdout: StdioCollector {
                onStreamFinished: {
                    page.loading = false
                    if (text.includes("INSTALLED:")) {
                        page.statusMessage = Translation.tr("Profile installed successfully")
                        page.statusType = "success"
                        page.loadProfiles()
                    } else {
                        page.statusMessage = Translation.tr("Install failed: %1").arg(text)
                        page.statusType = "error"
                    }
                }
            }
            stderr: StdioCollector {
                onStreamFinished: {
                    page.loading = false
                    if (text) {
                        page.statusMessage = Translation.tr("Error: %1").arg(text)
                        page.statusType = "error"
                    }
                }
            }
        }

        // Apply process
        Process {
            id: applyProcess
            running: false
            stdout: StdioCollector {
                onStreamFinished: {
                    page.loading = false
                    if (text.includes("APPLIED:")) {
                        page.statusMessage = Translation.tr("Profile applied! Restart Quickshell to see changes.")
                        page.statusType = "success"
                        Config.options.profileManager.activeProfile = text.split(":")[1]
                        page.loadProfiles()
                    } else {
                        page.statusMessage = Translation.tr("Apply failed: %1").arg(text)
                        page.statusType = "error"
                    }
                }
            }
            stderr: StdioCollector {
                onStreamFinished: {
                    page.loading = false
                    if (text) {
                        page.statusMessage = Translation.tr("Error: %1").arg(text)
                        page.statusType = "error"
                    }
                }
            }
        }
    }
}

// Profile Card Component
Item {
    id: ProfileCard
    required property var profile
    signal installClicked(var profile)
    signal applyClicked(var profile)
    signal removeClicked(string profileId)
    Layout.fillWidth: true
    implicitHeight: 120

    property bool isCustom: profile.custom !== null && !profile.official
    property bool canRemove: isCustom

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: Appearance.colors.colLayer1
        border.width: profile.current ? 2 : 1
        border.color: profile.current ? Appearance.colors.colPrimary : Appearance.colors.colOutlineVariant

        RowLayout {
            anchors.fill: parent
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            spacing: 16

            // Icon/Logo
            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                width: 64
                height: 64
                radius: 16
                color: profile.current ? Appearance.colors.colPrimaryContainer : Appearance.colors.colLayer0
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: profile.official ? "cloud" : "folder_git"
                    iconSize: 28
                    fill: 1
                    color: profile.current ? Appearance.colors.colPrimary : Appearance.colors.colSubtext
                }
            }

            // Info
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    StyledText {
                        Layout.fillWidth: true
                        text: profile.name
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: Font.Medium
                        color: Appearance.colors.colOnLayer0
                        elide: Text.ElideRight
                    }

                    // Status badges
                    RowLayout {
                        spacing: 4

                        Rectangle {
                            visible: profile.current
                            radius: 8
                            color: Appearance.colors.colPrimaryContainer
                            implicitHeight: 20
                            implicitWidth: currentText.implicitWidth + 10

                            StyledText {
                                id: currentText
                                anchors.centerIn: parent
                                text: Translation.tr("Current")
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                color: Appearance.colors.colPrimary
                            }
                        }

                        Rectangle {
                            visible: profile.installed && !profile.current
                            radius: 8
                            color: Appearance.colors.colSuccessContainer
                            implicitHeight: 20
                            implicitWidth: installedText.implicitWidth + 10

                            StyledText {
                                id: installedText
                                anchors.centerIn: parent
                                text: Translation.tr("Installed")
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                color: Appearance.colors.colSuccess
                            }
                        }

                        Rectangle {
                            visible: !profile.installed
                            radius: 8
                            color: Appearance.colors.colLayer0
                            implicitHeight: 20
                            implicitWidth: notInstalledText.implicitWidth + 10

                            StyledText {
                                id: notInstalledText
                                anchors.centerIn: parent
                                text: Translation.tr("Not Installed")
                                font.pixelSize: 10
                                color: Appearance.colors.colSubtext
                            }
                        }

                        Rectangle {
                            visible: profile.custom && !profile.official
                            radius: 8
                            color: Appearance.colors.colSecondaryContainer
                            implicitHeight: 20
                            implicitWidth: customText.implicitWidth + 10

                            StyledText {
                                id: customText
                                anchors.centerIn: parent
                                text: Translation.tr("Custom")
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                color: Appearance.colors.colOnSecondaryContainer
                            }
                        }
                    }
                }

                StyledText {
                    Layout.fillWidth: true
                    text: profile.description
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: profile.repo
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.family: "monospace"
                    color: Appearance.colors.colSubtext
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    visible: profile.path !== ""
                    text: Translation.tr("Path: %1").arg(profile.path)
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }
            }

            // Actions
            ColumnLayout {
                spacing: 8

                // Install button
                RippleButton {
                    visible: !profile.installed
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 36
                    buttonRadius: 18
                    text: Translation.tr("Install")
                    icon: "download"
                    onClicked: installClicked(profile)
                    colBackground: Appearance.colors.colPrimary
                    colBackgroundHover: Appearance.colors.colPrimaryHover
                    colRipple: Appearance.colors.colPrimaryActive
                }

                // Apply button
                RippleButton {
                    visible: profile.installed && !profile.current
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 36
                    buttonRadius: 18
                    text: Translation.tr("Apply")
                    icon: "check"
                    onClicked: applyClicked(profile)
                    colBackground: Appearance.colors.colSuccess
                    colBackgroundHover: Appearance.colors.colSuccessHover
                    colRipple: Appearance.colors.colSuccessActive
                }

                // Current indicator
                Rectangle {
                    visible: profile.current
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 36
                    radius: 18
                    color: Appearance.colors.colPrimaryContainer

                    StyledText {
                        anchors.centerIn: parent
                        text: Translation.tr("Active")
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        font.weight: Font.Medium
                        color: Appearance.colors.colPrimary
                    }
                }

                // Remove button (for custom)
                RippleButton {
                    visible: canRemove
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 36
                    buttonRadius: 18
                    text: Translation.tr("Remove")
                    icon: "delete"
                    onClicked: removeClicked(profile.id)
                    colBackground: Appearance.colors.colErrorContainer
                    colBackgroundHover: Appearance.colors.colErrorContainerHover
                    colRipple: Appearance.colors.colErrorContainerActive
                    contentItem: RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        MaterialSymbol {
                            text: "delete"
                            iconSize: 16
                            fill: 1
                            color: Appearance.colors.colError
                        }
                        StyledText {
                            text: Translation.tr("Remove")
                            font.weight: Font.Medium
                            color: Appearance.colors.colError
                        }
                    }
                }
            }
        }
    }
}

// Custom Source Dialog
Item {
    id: CustomSourceDialog
    signal save(var data)
    property bool open: false

    function open() {
        customDialog.visible = true
        customDialog.opacity = 1
        formIdField.text = ""
        formNameField.text = ""
        formDescField.text = ""
        formRepoField.text = ""
        formBranchField.text = "main"
        formPathField.text = ""
        editingId = ""
    }

    property string editingId: ""

    Rectangle {
        id: customDialog
        visible: false
        opacity: 0
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.9, 500)
        height: 520
        radius: 20
        color: Appearance.colors.colUiBackground
        border.width: 1
        border.color: Appearance.colors.colOutlineVariant
        z: 100

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            StyledText {
                Layout.fillWidth: true
                text: editingId ? Translation.tr("Edit Custom Source") : Translation.tr("Add Custom Repository")
                font.pixelSize: Appearance.font.pixelSize.larger
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            StyledText {
                Layout.fillWidth: true
                text: Translation.tr("Enter a GitHub repository URL to add as a profile source")
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colSubtext
            }

            // ID field
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                StyledText {
                    text: Translation.tr("Profile ID (unique, no spaces)")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }
                TextField {
                    id: formIdField
                    Layout.fillWidth: true
                    placeholderText: "my-custom-profile"
                    background: Rectangle {
                        radius: 8
                        color: Appearance.colors.colLayer1
                        border.width: 1
                        border.color: Appearance.colors.colOutlineVariant
                    }
                    color: Appearance.colors.colOnLayer0
                    font.pixelSize: Appearance.font.pixelSize.normal
                }
            }

            // Name field
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                StyledText {
                    text: Translation.tr("Display Name")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }
                TextField {
                    id: formNameField
                    Layout.fillWidth: true
                    placeholderText: "My Custom Profile"
                    background: Rectangle {
                        radius: 8
                        color: Appearance.colors.colLayer1
                        border.width: 1
                        border.color: Appearance.colors.colOutlineVariant
                    }
                    color: Appearance.colors.colOnLayer0
                    font.pixelSize: Appearance.font.pixelSize.normal
                }
            }

            // Description field
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                StyledText {
                    text: Translation.tr("Description")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }
                TextField {
                    id: formDescField
                    Layout.fillWidth: true
                    placeholderText: "Custom dotfiles from my fork"
                    background: Rectangle {
                        radius: 8
                        color: Appearance.colors.colLayer1
                        border.width: 1
                        border.color: Appearance.colors.colOutlineVariant
                    }
                    color: Appearance.colors.colOnLayer0
                    font.pixelSize: Appearance.font.pixelSize.normal
                }
            }

            // Repo URL field
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                StyledText {
                    text: Translation.tr("GitHub Repository URL")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }
                TextField {
                    id: formRepoField
                    Layout.fillWidth: true
                    placeholderText: "https://github.com/user/repo.git"
                    background: Rectangle {
                        radius: 8
                        color: Appearance.colors.colLayer1
                        border.width: 1
                        border.color: Appearance.colors.colOutlineVariant
                    }
                    color: Appearance.colors.colOnLayer0
                    font.pixelSize: Appearance.font.pixelSize.normal
                }
            }

            // Branch and Path row
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    StyledText {
                        text: Translation.tr("Branch")
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colSubtext
                    }
                    TextField {
                        id: formBranchField
                        Layout.fillWidth: true
                        placeholderText: "main"
                        background: Rectangle {
                            radius: 8
                            color: Appearance.colors.colLayer1
                            border.width: 1
                            border.color: Appearance.colors.colOutlineVariant
                        }
                        color: Appearance.colors.colOnLayer0
                        font.pixelSize: Appearance.font.pixelSize.normal
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    StyledText {
                        text: Translation.tr("Subdirectory Path (optional)")
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colSubtext
                    }
                    TextField {
                        id: formPathField
                        Layout.fillWidth: true
                        placeholderText: "quickshell"
                        background: Rectangle {
                            radius: 8
                            color: Appearance.colors.colLayer1
                            border.width: 1
                            border.color: Appearance.colors.colOutlineVariant
                        }
                        color: Appearance.colors.colOnLayer0
                        font.pixelSize: Appearance.font.pixelSize.normal
                    }
                }
            }

            // Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Item { Layout.fillWidth: true }

                RippleButton {
                    text: Translation.tr("Cancel")
                    onClicked: {
                        customDialog.visible = false
                        customDialog.opacity = 0
                    }
                    colBackground: Appearance.colors.colLayer1
                    colBackgroundHover: Appearance.colors.colLayer1Hover
                }

                RippleButton {
                    text: editingId ? Translation.tr("Save") : Translation.tr("Add")
                    onClicked: {
                        const data = {
                            id: formIdField.text.trim(),
                            name: formNameField.text.trim(),
                            description: formDescField.text.trim(),
                            repo: formRepoField.text.trim(),
                            branch: formBranchField.text.trim() || "main",
                            path: formPathField.text.trim(),
                            official: false,
                            custom: true
                        }
                        if (!data.id || !data.name || !data.repo) {
                            // Show error
                            return
                        }
                        save(data)
                        customDialog.visible = false
                        customDialog.opacity = 0
                    }
                    colBackground: Appearance.colors.colPrimary
                    colBackgroundHover: Appearance.colors.colPrimaryHover
                    colRipple: Appearance.colors.colPrimaryActive
                }
            }
        }
    }
}