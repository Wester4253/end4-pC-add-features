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
                text: "partly_cloudy_day"
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
        }

        Revealer {
            reveal: Weather.available
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                // Current weather card
                Rectangle {
                    Layout.fillWidth: true
                    radius: 16
                    color: Appearance.colors.colLayer1
                    border.width: 1
                    border.color: Appearance.colors.colOutlineVariant

                    RowLayout {
                        anchors.fill: parent
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16
                        Layout.topMargin: 16
                        Layout.bottomMargin: 16
                        spacing: 16

                        // Weather icon + temp
                        ColumnLayout {
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 4

                            MaterialSymbol {
                                Layout.alignment: Qt.AlignHCenter
                                text: Weather.current?.icon ?? "partly_cloudy_day"
                                iconSize: 48
                                fill: 1
                                color: Appearance.colors.colPrimary
                            }

                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: `${Math.round(Weather.current?.temperature ?? 0)}°`
                                font.pixelSize: 36
                                font.weight: Font.Bold
                                color: Appearance.colors.colOnLayer0
                            }
                        }

                        // Details
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            StyledText {
                                Layout.fillWidth: true
                                text: Weather.current?.condition ?? Translation.tr("Unknown")
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: Font.Medium
                                color: Appearance.colors.colOnLayer0
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: `${Translation.tr("Feels like")} ${Math.round(Weather.current?.feelsLike ?? 0)}°  •  ${Translation.tr("Humidity")} ${Math.round((Weather.current?.humidity ?? 0) * 100)}%`
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colSubtext
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: `${Translation.tr("Wind")} ${Math.round(Weather.current?.windSpeed ?? 0)} ${Weather.unitSystem === "imperial" ? "mph" : "km/h"}  •  ${Translation.tr("UV")} ${Weather.current?.uvIndex ?? 0}`
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colSubtext
                            }

                            // Location
                            RowLayout {
                                spacing: 4
                                StyledText {
                                    text: Weather.current?.location ?? ""
                                    font.pixelSize: Appearance.font.pixelSize.smaller
                                    color: Appearance.colors.colSubtext
                                }
                                MaterialSymbol {
                                    text: "schedule"
                                    iconSize: 14
                                    fill: 1
                                    color: Appearance.colors.colSubtext
                                }
                                StyledText {
                                    text: Weather.current?.lastUpdated ? Qt.formatDateTime(new Date(Weather.current.lastUpdated), "HH:mm") : ""
                                    font.pixelSize: Appearance.font.pixelSize.smaller
                                    color: Appearance.colors.colSubtext
                                }
                            }
                        }
                    }
                }

                // Hourly forecast
                Revealer {
                    reveal: Weather.hourly && Weather.hourly.length > 0
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.leftMargin: 16
                            Layout.rightMargin: 16
                            StyledText {
                                text: Translation.tr("Next 12 Hours")
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.weight: Font.Medium
                                color: Appearance.colors.colSubtext
                            }
                        }

                        Flickable {
                            id: hourlyFlickable
                            Layout.fillWidth: true
                            implicitHeight: 80
                            contentWidth: hourlyContent.implicitWidth
                            boundsBehavior: Flickable.StopAtBounds
                            clip: false

                            RowLayout {
                                id: hourlyContent
                                spacing: 12
                                Layout.leftMargin: 16
                                Layout.rightMargin: 16

                                Repeater {
                                    model: Weather.hourly.slice(0, 12)
                                    delegate: hourlyCard
                                }
                            }
                        }
                    }
                }

                // Daily forecast
                Revealer {
                    reveal: Weather.daily && Weather.daily.length > 0
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.leftMargin: 16
                            Layout.rightMargin: 16
                            StyledText {
                                text: Translation.tr("7-Day Forecast")
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.weight: Font.Medium
                                color: Appearance.colors.colSubtext
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Layout.leftMargin: 16
                            Layout.rightMargin: 16

                            Repeater {
                                model: Weather.daily.slice(0, 7)
                                delegate: dailyCard
                            }
                        }
                    }
                }
            }
        }

        Revealer {
            reveal: !Weather.available
            Layout.fillWidth: true

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 60
                radius: 12
                color: Appearance.colors.colLayer1
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant
                opacity: 0.5

                StyledText {
                    anchors.centerIn: parent
                    text: Translation.tr("Weather unavailable")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colSubtext
                }
            }
        }
    }

    // Hourly forecast card
    Component {
        id: hourlyCard

        Item {
            required property var hourData
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

    // Daily forecast card
    Component {
        id: dailyCard

        Item {
            required property var dayData
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
    }
}
