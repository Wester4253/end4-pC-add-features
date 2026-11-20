import QtQuick
import QtQuick.Layouts
import qs
import qs.services

Item {
    id: root
    property VisualizerEngine engine
    property string style: "bars" // "bars", "dots", "wave", "mirror"
    property int barCount: 32
    property color color: Appearance.colors.colPrimary
    property bool mirror: false
    property real sensitivity: 1.0

    readonly property bool isBars: style === "bars"
    readonly property bool isDots: style === "dots"
    readonly property bool isWave: style === "wave"
    readonly property bool isMirror: style === "mirror" || mirror

    // Start engine when visible
    onVisibleChanged: {
        if (visible) {
            engine.active = true;
            engine.sensitivity = root.sensitivity;
        } else {
            engine.active = false;
        }
    }

    // Bar visualizer
    Revealer {
        reveal: isBars || isMirror
        anchors.fill: parent

        Row {
            id: barsRow
            anchors.fill: parent
            spacing: 2

            Repeater {
                model: root.barCount
                delegate: BarDelegate {
                    required property int index
                    required property VisualizerEngine engine
                    required property color barColor
                    required property int barCount
                    required property bool mirror
                    width: root.width / root.barCount
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    // Dots visualizer
    Revealer {
        reveal: isDots
        anchors.fill: parent

        Item {
            id: dotsContainer
            anchors.fill: parent

            Repeater {
                model: root.barCount
                delegate: DotDelegate {
                    required property int index
                    required property VisualizerEngine engine
                    required property color dotColor
                    required property int dotCount
                    x: (root.width / root.dotCount) * index + (root.width / root.dotCount) / 2
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    // Wave visualizer
    Revealer {
        reveal: isWave
        anchors.fill: parent

        Canvas {
            id: waveCanvas
            anchors.fill: parent
            renderStrategy: Canvas.Cooperative
            renderTarget: Canvas.FramebufferObject

            onPaint: {
                var ctx = waveCanvas.getContext("2d");
                ctx.clearRect(0, 0, waveCanvas.width, waveCanvas.height);

                if (!engine.data || engine.data.length === 0) return;

                var barCount = Math.min(root.barCount * 2, engine.data.length);
                var barWidth = waveCanvas.width / barCount;
                var centerY = waveCanvas.height / 2;
                var maxHeight = waveCanvas.height * 0.8;

                var gradient = ctx.createLinearGradient(0, 0, 0, waveCanvas.height);
                var c = Qt.color(root.color);
                gradient.addColorStop(0, Qt.rgba(c.r, c.g, c.b, 0.8));
                gradient.addColorStop(1, Qt.rgba(c.r, c.g, c.b, 0.1));

                ctx.fillStyle = gradient;
                ctx.strokeStyle = Qt.rgba(c.r, c.g, c.b, 0.6);
                ctx.lineWidth = 2;
                ctx.lineCap = "round";
                ctx.lineJoin = "round";

                ctx.beginPath();
                ctx.moveTo(0, centerY);

                for (var i = 0; i < barCount; i++) {
                    var value = engine.data[i] || 0;
                    var x = i * barWidth;
                    var y = centerY - value * maxHeight / 2;

                    if (i === 0) {
                        ctx.moveTo(x, y);
                    } else {
                        var prevX = (i - 1) * barWidth;
                        var prevY = centerY - (engine.data[i - 1] || 0) * maxHeight / 2;
                        var cpX = (prevX + x) / 2;
                        ctx.bezierCurveTo(cpX, prevY, cpX, y, x, y);
                    }
                }

                ctx.lineTo(waveCanvas.width, centerY);
                ctx.lineTo(waveCanvas.width, waveCanvas.height);
                ctx.lineTo(0, waveCanvas.height);
                ctx.closePath();
                ctx.fill();

                // Mirror wave if enabled
                if (root.isMirror) {
                    ctx.beginPath();
                    ctx.moveTo(0, centerY);

                    for (var i = 0; i < barCount; i++) {
                        var value = engine.data[i] || 0;
                        var x = i * barWidth;
                        var y = centerY + value * maxHeight / 2;

                        if (i === 0) {
                            ctx.moveTo(x, y);
                        } else {
                            var prevX = (i - 1) * barWidth;
                            var prevY = centerY + (engine.data[i - 1] || 0) * maxHeight / 2;
                            var cpX = (prevX + x) / 2;
                            ctx.bezierCurveTo(cpX, prevY, cpX, y, x, y);
                        }
                    }

                    ctx.lineTo(waveCanvas.width, centerY);
                    ctx.closePath();
                    ctx.fill();
                }
            }

            Connections {
                target: engine
                function onDataChanged() {
                    waveCanvas.requestPaint();
                }
            }
        }
    }
}

// Bar delegate for bars visualizer
Item {
    id: BarDelegate
    required property int index
    required property VisualizerEngine engine
    required property color barColor
    required property int barCount
    required property bool mirror

    property real barWidth: parent ? parent.width / barCount : 10
    property real value: engine.data && index < engine.data.length ? engine.data[index] : 0

    Rectangle {
        anchors.bottom: parent.bottom
        width: Math.max(2, barWidth - 2)
        height: Math.max(1, value * parent.height * 0.8)
        color: barColor
        radius: 1
    }

    // Mirror bar
    Revealer {
        reveal: mirror
        Rectangle {
            anchors.top: parent.top
            width: Math.max(2, barWidth - 2)
            height: Math.max(1, value * parent.height * 0.8)
            color: barColor
            radius: 1
        }
    }
}

// Dot delegate for dots visualizer
Item {
    id: DotDelegate
    required property int index
    required property VisualizerEngine engine
    required property color dotColor
    required property int dotCount

    property real value: engine.data && index < engine.data.length ? engine.data[index] : 0
    property real maxRadius: 8
    property real minRadius: 2

    Circle {
        id: dot
        x: -width / 2
        y: -height / 2
        width: minRadius + value * (maxRadius - minRadius)
        height: minRadius + value * (maxRadius - minRadius)
        radius: width / 2
        color: dotColor
        opacity: 0.6 + value * 0.4

        Behavior on width {
            NumberAnimation { duration: 50; easing.type: Easing.OutQuad }
        }
        Behavior on height {
            NumberAnimation { duration: 50; easing.type: Easing.OutQuad }
        }
    }
}