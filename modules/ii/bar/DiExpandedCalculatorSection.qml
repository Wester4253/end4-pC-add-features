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

    property string expression: ""
    property string result: ""
    property bool hasError: false

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
                text: "calculate"
                iconSize: 20
                fill: 1
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Calculator")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }

            Item { Layout.fillWidth: true }

            // Clear button
            Revealer {
                reveal: root.expression.length > 0
                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { root.expression = ""; root.result = ""; root.hasError = false; }
                    MaterialSymbol {
                        Layout.alignment: Qt.AlignVCenter
                        text: "clear"
                        iconSize: 20
                        fill: 1
                        color: Appearance.colors.colSubtext
                    }
                }
            }
        }

        // Expression display
        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            implicitHeight: 56
            radius: 12
            color: Appearance.colors.colLayer1
            border.width: 1
            border.color: root.hasError ? Appearance.colors.colError : Appearance.colors.colOutlineVariant

            RowLayout {
                anchors.fill: parent
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                spacing: 8

                MaterialSymbol {
                    Layout.alignment: Qt.AlignVCenter
                    text: "calculate"
                    iconSize: 20
                    fill: 1
                    color: root.hasError ? Appearance.colors.colError : Appearance.colors.colPrimary
                }

                TextField {
                    id: calcField
                    Layout.fillWidth: true
                    background: null
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.family: "monospace"
                    color: Appearance.colors.colOnLayer0
                    placeholderText: Translation.tr("Enter expression (e.g., 2 + 2 * 3)")
                    text: root.expression
                    onTextChanged: {
                        root.expression = text;
                        debounceTimer.restart();
                    }
                }
            }
        }

        // Result display
        Revealer {
            reveal: root.result !== ""
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 48
                radius: 12
                color: root.hasError ? Appearance.colors.colError : Appearance.colors.colPrimary
                opacity: 0.1
                border.width: 1
                border.color: root.hasError ? Appearance.colors.colError : Appearance.colors.colPrimary

                RowLayout {
                    anchors.fill: parent
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                    spacing: 8

                    MaterialSymbol {
                        Layout.alignment: Qt.AlignVCenter
                        text: root.hasError ? "error" : "check_circle"
                        iconSize: 20
                        fill: 1
                        color: root.hasError ? Appearance.colors.colError : Appearance.colors.colPrimary
                    }

                    StyledText {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        text: root.result
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: Font.Medium
                        font.family: "monospace"
                        color: root.hasError ? Appearance.colors.colError : Appearance.colors.colPrimary
                    }

                    // Copy result
                    Revealer {
                        reveal: !root.hasError
                        MouseArea {
                            cursorShape: Qt.PointingHandCursor
                            onClicked: { Quickshell.copyToClipboard(root.result); }
                            MaterialSymbol {
                                Layout.alignment: Qt.AlignVCenter
                                text: "content_copy"
                                iconSize: 18
                                fill: 1
                                color: root.hasError ? Appearance.colors.colError : Appearance.colors.colPrimary
                            }
                        }
                    }
                }
            }
        }

        // Quick buttons
        Revealer {
            reveal: root.expression === ""
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    StyledText {
                        text: Translation.tr("Quick expressions:")
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colSubtext
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 4
                    columnSpacing: 8
                    rowSpacing: 8

                    Repeater {
                        model: [
                            { expr: "2 + 2", desc: "Simple" },
                            { expr: "10 * 5", desc: "Multiply" },
                            { expr: "100 / 4", desc: "Divide" },
                            { expr: "2 ^ 10", desc: "Power" },
                            { expr: "sqrt(16)", desc: "Square root" },
                            { expr: "sin(pi/2)", desc: "Sine" },
                            { expr: "log(100)", desc: "Log" },
                            { expr: "10%", desc: "Percent" },
                            { expr: "5! + 3!", desc: "Factorial" },
                            { expr: "2 * pi * 10", desc: "Circumference" },
                            { expr: "pi * 5^2", desc: "Circle area" },
                            { expr: "cbrt(27)", desc: "Cube root" },
                            { expr: "max(1,5,3)", desc: "Max" },
                            { expr: "min(1,5,3)", desc: "Min" },
                            { expr: "round(3.14159, 2)", desc: "Round" },
                            { expr: "random()", desc: "Random" }
                        ]
                        delegate: QuickExprButton {
                            Layout.fillWidth: true
                            expression: modelData.expr
                            label: modelData.desc
                            onClicked: { root.expression = expression; debounceTimer.restart(); }
                        }
                    }
                }
            }
        }
    }

    // Debounce timer for expression evaluation
    Timer {
        id: debounceTimer
        interval: 300
        repeat: false
        onTriggered: evaluateExpression()
    }

    function evaluateExpression() {
        if (root.expression.trim() === "") {
            root.result = "";
            root.hasError = false;
            return;
        }

        try {
            // Use python for safe evaluation
            evalProc.running = true;
        } catch (e) {
            root.result = Translation.tr("Error");
            root.hasError = true;
        }
    }

    Process {
        id: evalProc
        command: ["python3", "-c", "import math; import sys; expr = sys.argv[1]; try: result = eval(expr, {'__builtins__': {}}, {k: getattr(math, k) for k in dir(math) if not k.startswith('_')}); print(result) except Exception as e: print('ERROR:', e)", root.expression]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.startsWith("ERROR:")) {
                    root.result = text.slice(7).trim();
                    root.hasError = true;
                } else {
                    root.result = text.trim();
                    root.hasError = false;
                }
            }
        }
    }
}

// Quick expression button
Item {
    id: QuickExprButton
    required property string expression
    required property string label
    required property var onClicked
    Layout.fillWidth: true
    implicitHeight: 36

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: Appearance.colors.colLayer1
        border.width: 1
        border.color: Appearance.colors.colOutlineVariant

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: quickExprButton.onClicked()
            onEntered: parent.color = Qt.lighter(Appearance.colors.colLayer1, 1.05)
            onExited: parent.color = Appearance.colors.colLayer1

            StyledText {
                anchors.centerIn: parent
                text: quickExprButton.label
                font.pixelSize: Appearance.font.pixelSize.smaller
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
            }
        }
    }
}