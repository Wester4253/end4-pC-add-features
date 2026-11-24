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

    // Hourly forecast card component
    Component {
        id: hourlyCard
        Item {
            property var hourData: modelData
            implicitWidth: 56
            Layout.preferredHeight: 72

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 4

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: hourData?.time ? Qt.formatDateTime(new Date(hourData.time), "HH:mm") : ""
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }

                MaterialSymbol {
                    Layout.alignment: Qt.AlignHCenter
                    text: hourData?.icon ?? "partly_cloudy_day"
                    iconSize: 24
                    fill: 1
                    color: Appearance.colors.colPrimary
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: `${Math.round(hourData?.temperature ?? 0)}°`
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Medium
                    color: Appearance.colors.colOnLayer0
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: `${Math.round((hourData?.precipitation ?? 0) * 100)}%`
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }
            }
        }
    }

    // Daily forecast card component
    Component {
        id: dailyCard
        property var dayData: modelData
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

                // Day name
                StyledText {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: 80
                    text: dayData?.date ? Qt.formatDateTime(new Date(dayData.date), "EEE") : ""
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.weight: Font.Medium
                    color: Appearance.colors.colOnLayer0
                }

                // Icon
                MaterialSymbol {
                    Layout.alignment: Qt.AlignVCenter
                    text: dayData?.icon ?? "partly_cloudy_day"
                    iconSize: 20
                    fill: 1
                    color: Appearance.colors.colPrimary
                }

                // Condition
                StyledText {
                    Layout.fillWidth: true
                    text: dayData?.condition ?? ""
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }

                // High/Low
                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 8

                    StyledText {
                        text: `${Math.round(dayData?.high ?? 0)}°`
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: Font.Medium
                        color: Appearance.colors.colOnLayer0
                    }

                    StyledText {
                        text: `${Math.round(dayData?.low ?? 0)}°`
                        font.pixelSize: Appearance.font.pixelSize.normal
                        color: Appearance.colors.colSubtext
                    }
                }

                // Precipitation
                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 4

                    MaterialSymbol {
                        text: "water_drop"
                        iconSize: 14
                        fill: 1
                        color: Appearance.colors.colPrimary
                    }
                    StyledText {
                        text: `${Math.round((dayData?.precipitation ?? 0) * 100)}%`
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colSubtext
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
                text: "wB_sunny"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Weather")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colSubtext
                text: Weather.available ? `${Math.round(Weather.temperature * 100)}°` : Translation.tr("No data")
            }
        }

        // Current conditions
        Revealer {
            reveal: Weather.available
            Layout.fillWidth: true

            Rectangle {
                Layout.fillWidth: true
                radius: 12
                color: Appearance.colors.colLayer1
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant

                RowLayout {
                    anchors.fill: parent
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.topMargin: 12
                    Layout.bottomMargin: 12
                    spacing: 16

                    MaterialSymbol {
                        Layout.alignment: Qt.AlignVCenter
                        text: Weather.icon ?? "partly_cloudy_day"
                        iconSize: 48
                        fill: 1
                        color: Appearance.colors.colPrimary
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        StyledText {
                            Layout.fillWidth: true
                            text: Weather.location ?? Translation.tr("Unknown location")
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: Font.Medium
                            color: Appearance.colors.colOnLayer0
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: `${Math.round(Weather.temperature * 100)}°  •  ${Weather.condition ?? ""}`
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colSubtext
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: Translation.tr("Humidity %1%").arg(Math.round(Weather.humidity * 100))
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colSubtext
                        }
                    }
                }
            }
        }

        // Hourly forecast
        Revealer {
            reveal: Weather.available && Weather.hourly.length > 0
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                spacing: 8

                StyledText {
                    text: Translation.tr("Hourly Forecast")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.weight: Font.Medium
                    color: Appearance.colors.colSubtext
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Repeater {
                        model: Weather.hourly.slice(0, 6)
                        delegate: hourlyCard
                    }
                }
            }
        }

        // Daily forecast
        Revealer {
            reveal: Weather.available && Weather.daily.length > 0
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                spacing: 8

                StyledText {
                    text: Translation.tr("Daily Forecast")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.weight: Font.Medium
                    color: Appearance.colors.colSubtext
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Repeater {
                        model: Weather.daily.slice(0, 5)
                        delegate: dailyCard
                    }
                }
            }
        }
    }
}
