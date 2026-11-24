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

    property string filterText: ""

    // Shortcut row component
    Component {
        id: shortcutRow
        Item {
            property var shortcut: modelData
            Layout.fillWidth: true
            implicitHeight: 36

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

                    // Key combination
                    Rectangle {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.minimumWidth: 140
                        implicitHeight: 28
                        radius: 6
                        color: Appearance.colors.colPrimary
                        opacity: 0.15

                        StyledText {
                            anchors.centerIn: parent
                            Layout.leftMargin: 8
                            Layout.rightMargin: 8
                            text: shortcut.key
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            font.weight: Font.Bold
                            font.family: "monospace"
                            color: Appearance.colors.colPrimary
                        }
                    }

                    // Action description
                    StyledText {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        text: shortcut.action
                        font.pixelSize: Appearance.font.pixelSize.normal
                        color: Appearance.colors.colOnLayer0
                    }
                }
            }
        }
    }

    // Shortcut category component
    Component {
        id: shortcutCategory
        Item {
            property var categoryData: modelData
            property string filterText: root.filterText
            Layout.fillWidth: true

            property var filteredShortcuts: {
                if (!categoryData.shortcuts) return [];
                if (!filterText) return categoryData.shortcuts;
                var f = filterText.toLowerCase();
                return categoryData.shortcuts.filter(s =>
                    s.key.toLowerCase().includes(f) || s.action.toLowerCase().includes(f)
                );
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Revealer {
                    reveal: root.filteredShortcuts.length > 0

                    // Category header
                    Rectangle {
                        Layout.fillWidth: true
                        radius: 10
                        color: Appearance.colors.colPrimary
                        opacity: 0.1

                        RowLayout {
                            anchors.fill: parent
                            Layout.leftMargin: 12
                            Layout.rightMargin: 12
                            Layout.topMargin: 8
                            Layout.bottomMargin: 8
                            spacing: 8

                            MaterialSymbol {
                                Layout.alignment: Qt.AlignVCenter
                                text: categoryData.icon
                                iconSize: 20
                                fill: 1
                                color: Appearance.colors.colPrimary
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: categoryData.name
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: Font.Medium
                                color: Appearance.colors.colPrimary
                            }

                            StyledText {
                                Layout.alignment: Qt.AlignVCenter
                                text: `${root.filteredShortcuts.length} ${Translation.tr("shortcuts")}`
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colSubtext
                            }
                        }
                    }
                }

                // Shortcuts list
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Repeater {
                        model: root.filteredShortcuts
                        delegate: shortcutRow
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
                text: "keyboard"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Shortcuts")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }
        }

        Revealer {
            reveal: true
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                spacing: 4

                Repeater {
                    model: root.shortcutCategories ?? []
                    delegate: shortcutCategory
                }
            }
        }
    }
}
