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

    readonly property VisualizerEngine engine: VisualizerEngine
    readonly property var visualizerStyle: Config.options.bar.dynamicIsland.visualizerStyle

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
                text: "graphic_eq"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Audio Visualizer")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }

            // Style selector
            ConfigComboBox {
                currentValue: visualizerStyle
                onSelected: newValue => { Config.options.bar.dynamicIsland.visualizerStyle = newValue; }
                options: [
                    { displayName: Translation.tr("None"), icon: "block", value: "none" },
                    { displayName: Translation.tr("Bars"), icon: "equalizer", value: "bars" },
                    { displayName: Translation.tr("Dots"), icon: "more_horiz", value: "dots" },
                    { displayName: Translation.tr("Wave"), icon: "ssid_chart", value: "wave" },
                    { displayName: Translation.tr("Mirror"), icon: "flip", value: "mirror" }
                ]
            }
        }

        Revealer {
            reveal: visualizerStyle !== "none" && MprisController.activePlayer !== null
            Layout.fillWidth: true

            // Visualizer display
            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                implicitHeight: 120
                radius: 16
                color: Appearance.colors.colLayer1
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant
                clip: true

                DiVisualizerWidget {
                    anchors.fill: parent
                    anchors.margins: 8
                    engine: root.engine
                    style: visualizerStyle
                    barCount: visualizerStyle === "wave" ? 64 : 32
                    color: Appearance.colors.colPrimary
                    mirror: visualizerStyle === "mirror"
                }
            }
        }

        Revealer {
            reveal: visualizerStyle !== "none" && MprisController.activePlayer === null
            Layout.fillWidth: true

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                implicitHeight: 80
                radius: 12
                color: Appearance.colors.colLayer1
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant
                opacity: 0.5

                StyledText {
                    anchors.centerIn: parent
                    text: Translation.tr("No media playing")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colSubtext
                }
            }
        }

        Revealer {
            reveal: visualizerStyle === "none"
            Layout.fillWidth: true

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                implicitHeight: 60
                radius: 12
                color: Appearance.colors.colLayer1
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant
                opacity: 0.5

                StyledText {
                    anchors.centerIn: parent
                    text: Translation.tr("Visualizer disabled — select a style above")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colSubtext
                }
            }
        }
    }
}