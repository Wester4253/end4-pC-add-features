import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root
    required property Item di
    Layout.fillWidth: true

    // Update stat card component
    Component {
        id: updateStatCard
        Item {
            property string title
            property string value
            property string icon
            property color color
            Layout.fillWidth: true
            Layout.preferredHeight: 64

            Rectangle {
                anchors.fill: parent
                radius: 12
                color: Appearance.colors.colLayer1
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 4

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        implicitWidth: 44
                        implicitHeight: 44
                        radius: 22
                        color: color
                        opacity: 0.15

                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: icon
                            iconSize: 22
                            fill: 1
                            color: color
                        }
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: value
                        font.pixelSize: Appearance.font.pixelSize.larger
                        font.weight: Font.Bold
                        font.features: { "tnum": 1 }
                        color: color
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: title
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colSubtext
                    }
                }
            }
        }
    }

    // Update package card component
    Component {
        id: updatePackageCard
        property var package: modelData
        property string source
        Layout.fillWidth: true
        implicitHeight: 40

        property string displayName: package.name ?? package.pkgName ?? "Unknown"
        property string oldVersion: package.oldVersion ?? package.version ?? ""
        property string newVersion: package.newVersion ?? ""

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: Appearance.colors.colLayer1
            border.width: 1
            border.color: Appearance.colors.colOutlineVariant

            RowLayout {
                anchors.fill: parent
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                spacing: 12

                // Source icon
                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    implicitWidth: 32
                    implicitHeight: 32
                    radius: 16
                    color: {
                        switch (source) {
                            case "pacman": return Appearance.colors.colPrimary;
                            case "aur": return Appearance.colors.colSecondary;
                            case "flatpak": return Appearance.colors.colTertiary;
                            default: return Appearance.colors.colPrimary;
                        }
                    }
                    opacity: 0.15

                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: {
                            switch (source) {
                                case "pacman": return "archive";
                                case "aur": return "cloud_download";
                                case "flatpak": return "grid_view";
                                default: return "archive";
                            }
                        }
                        iconSize: 16
                        fill: 1
                        color: {
                            switch (source) {
                                case "pacman": return Appearance.colors.colPrimary;
                                case "aur": return Appearance.colors.colSecondary;
                                case "flatpak": return Appearance.colors.colTertiary;
                                default: return Appearance.colors.colPrimary;
                            }
                        }
                    }
                }

                // Package info
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
                        text: oldVersion && newVersion ? `${oldVersion} → ${newVersion}` : (newVersion ?? oldVersion ?? "")
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        font.family: "monospace"
                        color: Appearance.colors.colSubtext
                    }
                }

                // Source badge
                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    implicitHeight: 20
                    radius: 10
                    color: {
                        switch (source) {
                            case "pacman": return Appearance.colors.colPrimary;
                            case "aur": return Appearance.colors.colSecondary;
                            case "flatpak": return Appearance.colors.colTertiary;
                            default: return Appearance.colors.colPrimary;
                        }
                    }
                    opacity: 0.2

                    StyledText {
                        anchors.centerIn: parent
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        text: source.toUpperCase()
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        font.weight: Font.Bold
                        color: {
                            switch (source) {
                                case "pacman": return Appearance.colors.colPrimary;
                                case "aur": return Appearance.colors.colSecondary;
                                case "flatpak": return Appearance.colors.colTertiary;
                                default: return Appearance.colors.colPrimary;
                            }
                        }
                    }
                }
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8

        // Section header
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            spacing: 8

            MaterialSymbol {
                Layout.alignment: Qt.AlignVCenter
                text: "system_update"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("System Updates")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }

            // Refresh button
            MouseArea {
                cursorShape: Qt.PointingHandCursor
                onClicked: Updates.check()
                MaterialSymbol {
                    Layout.alignment: Qt.AlignVCenter
                    text: "refresh"
                    iconSize: 20
                    fill: 1
                    color: Appearance.colors.colSubtext
                }
            }

            // Auto-check toggle
            Switch {
                checked: Updates.autoCheckEnabled
                onCheckedChanged: Updates.autoCheckEnabled = checked
            }
        }

        Revealer {
            reveal: Updates.available
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                spacing: 8

                // Summary stats
                GridLayout {
                    Layout.fillWidth: true
                    columns: 4
                    columnSpacing: 12
                    rowSpacing: 12

                    Loader {
                        sourceComponent: updateStatCard
                        Binding { target: item; property: "title"; value: Translation.tr("Pacman") }
                        Binding { target: item; property: "value"; value: `${Updates.pacmanUpdates ?? 0}` }
                        Binding { target: item; property: "icon"; value: "archive" }
                        Binding { target: item; property: "color"; value: Updates.pacmanUpdates > 0 ? Appearance.colors.colPrimary : Appearance.m3colors.m3success }
                    }

                    Loader {
                        sourceComponent: updateStatCard
                        Binding { target: item; property: "title"; value: Translation.tr("AUR") }
                        Binding { target: item; property: "value"; value: `${Updates.aurUpdates ?? 0}` }
                        Binding { target: item; property: "icon"; value: "cloud_download" }
                        Binding { target: item; property: "color"; value: Updates.aurUpdates > 0 ? Appearance.colors.colSecondary : Appearance.m3colors.m3success }
                    }

                    Loader {
                        sourceComponent: updateStatCard
                        Binding { target: item; property: "title"; value: Translation.tr("Flatpak") }
                        Binding { target: item; property: "value"; value: `${Updates.flatpakUpdates ?? 0}` }
                        Binding { target: item; property: "icon"; value: "grid_view" }
                        Binding { target: item; property: "color"; value: Updates.flatpakUpdates > 0 ? Appearance.colors.colTertiary : Appearance.m3colors.m3success }
                    }

                    Loader {
                        sourceComponent: updateStatCard
                        Binding { target: item; property: "title"; value: Translation.tr("Total") }
                        Binding { target: item; property: "value"; value: `${(Updates.pacmanUpdates ?? 0) + (Updates.aurUpdates ?? 0) + (Updates.flatpakUpdates ?? 0)}` }
                        Binding { target: item; property: "icon"; value: "system_update" }
                        Binding { target: item; property: "color"; value: Updates.totalUpdates > 0 ? Appearance.colors.colError : Appearance.m3colors.m3success }
                    }
                }

                // Last check
                Revealer {
                    reveal: Updates.lastCheck !== undefined && Updates.lastCheck > 0
                    Rectangle {
                        Layout.fillWidth: true
                        radius: 10
                        color: Appearance.colors.colLayer1
                        border.width: 1
                        border.color: Appearance.colors.colOutlineVariant
                        opacity: 0.5

                        RowLayout {
                            anchors.fill: parent
                            Layout.leftMargin: 12
                            Layout.rightMargin: 12
                            Layout.topMargin: 8
                            Layout.bottomMargin: 8
                            spacing: 8

                            MaterialSymbol {
                                Layout.alignment: Qt.AlignVCenter
                                text: "schedule"
                                iconSize: 18
                                fill: 1
                                color: Appearance.colors.colSubtext
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: Translation.tr("Last checked: %1").arg(Qt.formatDateTime(new Date(Updates.lastCheck), "MMM d, HH:mm"))
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colSubtext
                            }
                        }
                    }
                }

                // Pacman updates
                Revealer {
                    reveal: Updates.pacmanUpdates > 0 && Updates.pacmanPackages.length > 0
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            StyledText {
                                text: Translation.tr("Pacman Updates (%1)").arg(Updates.pacmanPackages.length)
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.weight: Font.Medium
                                color: Appearance.colors.colSubtext
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Repeater {
                                model: Updates.pacmanPackages.slice(0, 15)
                                delegate: updatePackageCard
                                Layout.fillWidth: true
                                package: modelData
                                source: "pacman"
                            }
                        }
                    }
                }

                // AUR updates
                Revealer {
                    reveal: Updates.aurUpdates > 0 && Updates.aurPackages.length > 0
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            StyledText {
                                text: Translation.tr("AUR Updates (%1)").arg(Updates.aurPackages.length)
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.weight: Font.Medium
                                color: Appearance.colors.colSubtext
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Repeater {
                                model: Updates.aurPackages.slice(0, 15)
                                delegate: updatePackageCard
                                Layout.fillWidth: true
                                package: modelData
                                source: "aur"
                            }
                        }
                    }
                }

                // Flatpak updates
                Revealer {
                    reveal: Updates.flatpakUpdates > 0 && Updates.flatpakPackages.length > 0
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            StyledText {
                                text: Translation.tr("Flatpak Updates (%1)").arg(Updates.flatpakPackages.length)
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.weight: Font.Medium
                                color: Appearance.colors.colSubtext
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Repeater {
                                model: Updates.flatpakPackages.slice(0, 15)
                                delegate: updatePackageCard
                                Layout.fillWidth: true
                                package: modelData
                                source: "flatpak"
                            }
                        }
                    }
                }

                // Apply all button
                Revealer {
                    reveal: Updates.totalUpdates > 0
                    Layout.fillWidth: true

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 50
                        radius: 12
                        color: Appearance.colors.colPrimary

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Updates.applyAll()
                            hoverEnabled: true

                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                radius: 12

                                MouseArea {
                                    anchors.fill: parent
                                    onEntered: parent.color = Qt.lighter(Appearance.colors.colPrimary, 1.1)
                                    onExited: parent.color = "transparent"
                                }

                                StyledText {
                                    anchors.centerIn: parent
                                    text: Translation.tr("Apply All Updates")
                                    font.pixelSize: Appearance.font.pixelSize.normal
                                    font.weight: Font.Medium
                                    color: Appearance.colors.colOnPrimary
                                }
                            }
                        }
                    }
                }
            }
        }

        Revealer {
            reveal: !Updates.available
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 80
                radius: 12
                color: Appearance.colors.colLayer1
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant
                opacity: 0.5

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    StyledText {
                        text: Translation.tr("Update service unavailable")
                        font.pixelSize: Appearance.font.pixelSize.normal
                        color: Appearance.colors.colSubtext
                    }

                    StyledText {
                        text: Translation.tr("Checking for updates...")
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colSubtext
                    }

                    BusySpinner {
                        size: 20
                    }
                }
            }
        }
    }
}
