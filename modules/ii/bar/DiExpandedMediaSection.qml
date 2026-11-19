import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root
    required property Item di
    Layout.fillWidth: true

    readonly property MprisPlayer player: root.di.activePlayer

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
                text: "music_note"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Media")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }
        }

        // Media card
        Rectangle {
            Layout.fillWidth: true
            radius: 16
            color: Appearance.colors.colLayer1
            border.width: 1
            border.color: Appearance.colors.colOutlineVariant

            RowLayout {
                anchors.fill: parent
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                Layout.topMargin: 12
                Layout.bottomMargin: 12
                spacing: 16

                // Album art
                Rectangle {
                    id: artRect
                    Layout.alignment: Qt.AlignTop
                    implicitWidth: 64
                    implicitHeight: 64
                    radius: 8
                    color: Appearance.colors.colLayer0
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: player?.artUrl ?? ""
                        sourceSize: Qt.size(128, 128)
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        visible: player?.artUrl && player.artUrl.length > 0
                    }

                    Revealer {
                        anchors.fill: parent
                        reveal: !player?.artUrl || player.artUrl.length === 0
                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "music_note"
                            iconSize: 28
                            fill: 1
                            color: Appearance.colors.colSubtext
                        }
                    }
                }

                // Track info + controls
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    StyledText {
                        Layout.fillWidth: true
                        text: player?.trackTitle ?? Translation.tr("Unknown")
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: Font.Medium
                        color: Appearance.colors.colOnLayer0
                        elide: Text.ElideRight
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: player?.trackArtist ?? ""
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colSubtext
                        elide: Text.ElideRight
                    }

                    // Progress bar
                    Revealer {
                        reveal: player?.position !== undefined && player?.length !== undefined && player.length > 0
                        Layout.fillWidth: true
                        StyledProgressBar {
                            Layout.fillWidth: true
                            valueBarWidth: 200
                            value: player.position / player.length
                            color: Appearance.colors.colPrimary
                        }
                    }

                    // Controls
                    RowLayout {
                        spacing: 16
                        Layout.fillWidth: true

                        MaterialSymbolButton {
                            text: "shuffle"
                            iconSize: 20
                            color: player?.shuffle ? Appearance.colors.colPrimary : Appearance.colors.colSubtext
                            onClicked: { if (player) player.shuffle = !player.shuffle; }
                        }

                        MaterialSymbolButton {
                            text: "skip_previous"
                            iconSize: 28
                            color: Appearance.colors.colOnLayer0
                            onClicked: { if (player) player.previous(); }
                        }

                        MaterialSymbolButton {
                            text: player?.isPlaying ? "pause_circle" : "play_circle"
                            iconSize: 36
                            fill: 1
                            color: Appearance.colors.colPrimary
                            onClicked: { if (player) player.playPause(); }
                        }

                        MaterialSymbolButton {
                            text: "skip_next"
                            iconSize: 28
                            color: Appearance.colors.colOnLayer0
                            onClicked: { if (player) player.next(); }
                        }

                        MaterialSymbolButton {
                            text: "repeat"
                            iconSize: 20
                            color: (player?.loop === "Track" || player?.loop === "Playlist") ? Appearance.colors.colPrimary : Appearance.colors.colSubtext
                            onClicked: {
                                if (player) {
                                    if (player.loop === "Track") player.loop = "Playlist";
                                    else if (player.loop === "Playlist") player.loop = "None";
                                    else player.loop = "Track";
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Volume
                        RowLayout {
                            spacing: 8
                            Layout.alignment: Qt.AlignVCenter

                            MaterialSymbol {
                                text: player?.volume === 0 || player?.muted ? "volume_off" : "volume_up"
                                iconSize: 20
                                fill: 1
                                color: Appearance.colors.colSubtext
                            }

                            StyledProgressBar {
                                implicitWidth: 80
                                valueBarWidth: 80
                                value: player?.muted ? 0 : (player?.volume ?? 0.5)
                                color: Appearance.colors.colPrimary
                                onValueChanged: { if (player) player.volume = value; }
                            }
                        }
                    }
                }
            }
        }
    }
}