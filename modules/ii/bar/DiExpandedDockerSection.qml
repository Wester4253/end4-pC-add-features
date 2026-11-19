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
                text: "whatshot"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Docker")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                onClicked: { Docker.refresh(); }
                MaterialSymbol {
                    Layout.alignment: Qt.AlignVCenter
                    text: "refresh"
                    iconSize: 20
                    fill: 1
                    color: Appearance.colors.colSubtext
                }
            }
        }

        Revealer {
            reveal: Docker.available
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

                    DockerStatCard {
                        title: Translation.tr("Containers")
                        value: `${Docker.containers.filter(c => c.running).length} / ${Docker.containers.length}`
                        icon: "widgets"
                        color: Appearance.colors.colPrimary
                    }

                    DockerStatCard {
                        title: Translation.tr("Images")
                        value: `${Docker.images.length}`
                        icon: "image"
                        color: Appearance.colors.colSecondary
                    }

                    DockerStatCard {
                        title: Translation.tr("Volumes")
                        value: `${Docker.volumes.length}`
                        icon: "storage"
                        color: Appearance.colors.colTertiary
                    }

                    DockerStatCard {
                        title: Translation.tr("Networks")
                        value: `${Docker.networks.length}`
                        icon: "hub"
                        color: Appearance.m3colors.m3warning
                    }
                }

                // Containers list
                Revealer {
                    reveal: Docker.containers.length > 0
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            StyledText {
                                text: Translation.tr("Containers")
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.weight: Font.Medium
                                color: Appearance.colors.colSubtext
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Repeater {
                                model: Docker.containers
                                delegate: DockerContainerCard {
                                    Layout.fillWidth: true
                                    container: modelData
                                }
                            }
                        }
                    }
                }

                // Images
                Revealer {
                    reveal: Docker.images.length > 0
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            StyledText {
                                text: Translation.tr("Images")
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.weight: Font.Medium
                                color: Appearance.colors.colSubtext
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Repeater {
                                model: Docker.images.slice(0, 10)
                                delegate: DockerImageCard {
                                    Layout.fillWidth: true
                                    image: modelData
                                }
                            }
                        }
                    }
                }
            }
        }

        Revealer {
            reveal: !Docker.available
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
                        text: Translation.tr("Docker unavailable")
                        font.pixelSize: Appearance.font.pixelSize.normal
                        color: Appearance.colors.colSubtext
                    }

                    StyledText {
                        text: Translation.tr("Docker daemon not running or not installed")
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colSubtext
                    }

                    MouseArea {
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { Docker.refresh(); }
                        StyledText {
                            text: Translation.tr("Retry")
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colPrimary
                        }
                    }
                }
            }
        }
    }
}

// Docker stat card
Item {
    id: DockerStatCard
    required property string title
    required property string value
    required property string icon
    required property color color
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
                color: Appearance.colors.colOnLayer0
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

// Docker container card
Item {
    id: DockerContainerCard
    required property var container
    Layout.fillWidth: true
    implicitHeight: 56

    property bool running: container.running === true

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Appearance.colors.colLayer1
        border.width: 1
        border.color: running ? Appearance.m3colors.m3success : Appearance.colors.colOutlineVariant

        RowLayout {
            anchors.fill: parent
            Layout.leftMargin: 12
            Layout.rightMargin: 12
            spacing: 12

            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 40
                implicitHeight: 40
                radius: 20
                color: running ? Appearance.m3colors.m3success : Appearance.colors.colPrimary
                opacity: 0.15

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: running ? "play_circle" : "stop_circle"
                    iconSize: 20
                    fill: 1
                    color: running ? Appearance.m3colors.m3success : Appearance.colors.colPrimary
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: -2

                StyledText {
                    Layout.fillWidth: true
                    text: container.name ?? container.id?.slice(0, 12) ?? Translation.tr("Unknown")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Medium
                    color: Appearance.colors.colOnLayer0
                }

                StyledText {
                    Layout.fillWidth: true
                    text: `${container.image ?? ""}  •  ${container.status ?? ""}  ${running ? "• " + Translation.tr("Up") + " " + (container.uptime ?? "") : ""}`
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }
            }

            RowLayout {
                spacing: 4

                MouseArea {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    cursorShape: Qt.PointingHandCursor
                    enabled: running
                    onClicked: Docker.stop(container.id)
                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "stop"
                        iconSize: 18
                        fill: 1
                        color: running ? Appearance.colors.colError : Appearance.colors.colSubtext
                    }
                }

                MouseArea {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    cursorShape: Qt.PointingHandCursor
                    enabled: !running
                    onClicked: Docker.start(container.id)
                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "play_arrow"
                        iconSize: 18
                        fill: 1
                        color: !running ? Appearance.m3colors.m3success : Appearance.colors.colSubtext
                    }
                }

                MouseArea {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Docker.restart(container.id)
                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "restart_alt"
                        iconSize: 18
                        fill: 1
                        color: Appearance.colors.colSubtext
                    }
                }

                MouseArea {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Docker.logs(container.id)
                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "terminal"
                        iconSize: 18
                        fill: 1
                        color: Appearance.colors.colSubtext
                    }
                }
            }
        }
    }
}

// Docker image card
Item {
    id: DockerImageCard
    required property var image
    Layout.fillWidth: true
    implicitHeight: 48

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: Appearance.colors.colLayer1
        border.width: 1
        border.color: Appearance.colors.colOutlineVariant

        RowLayout {
            anchors.fill: parent
            Layout.leftMargin: 12
            Layout.rightMargin: 12
            spacing: 12

            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 36
                implicitHeight: 36
                radius: 18
                color: Appearance.colors.colSecondary
                opacity: 0.15

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: "image"
                    iconSize: 18
                    fill: 1
                    color: Appearance.colors.colSecondary
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: -2

                StyledText {
                    Layout.fillWidth: true
                    text: image.repository ?? "<none>"
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Medium
                    color: Appearance.colors.colOnLayer0
                }

                StyledText {
                    Layout.fillWidth: true
                    text: `${image.tag ?? "latest"}  •  ${FileUtils.formatBytes(image.size)}  •  ${image.id?.slice(0, 12) ?? ""}`
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }
            }

            MouseArea {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                cursorShape: Qt.PointingHandCursor
                onClicked: Docker.removeImage(image.id)
                MaterialSymbol {
                    anchors.centerIn: parent
                    text: "delete"
                    iconSize: 18
                    fill: 1
                    color: Appearance.colors.colSubtext
                }
            }
        }
    }
}