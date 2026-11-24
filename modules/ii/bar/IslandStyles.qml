import QtQuick
import Quickshell
import qs.modules.common
import qs.modules.common.widgets
pragma Singleton
pragma ComponentBehavior: Bound

// Shared design tokens for all Dynamic Island styles
// Provides consistent geometry, colors, and theming across styles
Singleton {
    id: root

    // ===== Style Types =====
    readonly property int STYLE_DEFAULT: 0        // Classic pill (original)
    readonly property int STYLE_SOLID_BLACK: 1    // openagentisland style: pure black, opaque
    readonly property int STYLE_THEMED_PILL: 2    // ChillPill style: themed, translucent
    readonly property int STYLE_GLASS: 3          // Full glass/material
    readonly property int STYLE_NOTCH: 4          // Notch-style with side islands
    readonly property int STYLE_MINIMAL: 5        // Minimal thin line

    // Current active style (synced with config)
    property int activeStyle: Config.options.bar.dynamicIsland.style ?? STYLE_DEFAULT

    // ===== Geometry (shared) =====
    readonly property int margin: 8                  // gap from screen edge
    readonly property int pillHeight: 32             // island height
    readonly property int hPadding: 12               // inner horizontal padding
    readonly property real radius: Appearance.rounding.full
    readonly property real expandedRadius: 20        // panel corner radius
    readonly property int panelWidth: 420
    readonly property int panelHeight: 520

    // ===== Colors (style-specific, resolved at runtime) =====
    // These are computed properties that adapt to the active style and theme
    readonly property color pillColor: root.computePillColor()
    readonly property color pillBorder: root.computePillBorder()
    readonly property int borderWidth: root.computeBorderWidth()
    readonly property color textColor: root.computeTextColor()
    readonly property color subtextColor: root.computeSubtextColor()
    readonly property color accentColor: root.computeAccentColor()
    readonly property real inactiveOpacity: 0.45

    // Panel colors
    readonly property color panelBg: root.computePanelBg()
    readonly property color panelBorder: root.computePanelBorder()
    readonly property int panelBorderWidth: 1
    readonly property color panelShadow: Qt.rgba(0, 0, 0, 0.35)
    readonly property int shadowRadius: 32
    readonly property int shadowOffset: 12

    // ===== Animation timings =====
    readonly property int pillAnimDuration: 350
    readonly property int panelFadeDuration: 180
    readonly property int panelScaleDuration: 200
    readonly property int staggerDelay: 45
    readonly property var pillEasing: Easing.BezierSpline { bezierCurve: Appearance.animationCurves.expressiveDefaultSpatial }
    readonly property var panelEasingOut: Easing.OutCubic
    readonly property var panelEasingIn: Easing.InCubic

    // ===== Style Computation Functions =====
    function computePillColor() {
        switch (activeStyle) {
            case STYLE_SOLID_BLACK:
                return "#000000"  // Pure black, opaque
            case STYLE_THEMED_PILL:
                return Appearance.colors.colUiBackground  // Themed background
            case STYLE_GLASS:
                return Config.options.background.widgets.glass.enable
                    ? Appearance.colors.colUiBackground
                    : Qt.rgba(Appearance.colors.colUiBackground.r, Appearance.colors.colUiBackground.g, Appearance.colors.colUiBackground.b, 0.95)
            case STYLE_NOTCH:
                return "#000000"  // Solid black like openagentisland
            case STYLE_MINIMAL:
                return Qt.rgba(Appearance.colors.colUiBackground.r, Appearance.colors.colUiBackground.g, Appearance.colors.colUiBackground.b, 0.8)
            default: // STYLE_DEFAULT
                return Config.options.bar.followFrameColor
                    ? Appearance.getColorFromName(Config.options.bar.frameColor)
                    : Appearance.colors.colUiBackground
        }
    }

    function computePillBorder() {
        switch (activeStyle) {
            case STYLE_SOLID_BLACK:
            case STYLE_NOTCH:
                return Appearance.colors.colLayer0Border
            case STYLE_THEMED_PILL:
                return Appearance.colors.colOutlineVariant
            case STYLE_GLASS:
                return Config.options.background.widgets.glass.enable
                    ? Appearance.colors.colOutlineVariant
                    : "transparent"
            case STYLE_MINIMAL:
                return "transparent"
            default:
                return Config.options.bar.followFrameColor
                    ? Appearance.getColorFromName(Config.options.bar.frameColor)
                    : Appearance.colors.colUiBackground
        }
    }

    function computeBorderWidth() {
        switch (activeStyle) {
            case STYLE_SOLID_BLACK:
            case STYLE_NOTCH:
                return 1
            case STYLE_GLASS:
                return Config.options.background.widgets.glass.enable ? 1 : 0
            case STYLE_MINIMAL:
                return 0
            default:
                return 0
        }
    }

    function computeTextColor() {
        switch (activeStyle) {
            case STYLE_SOLID_BLACK:
            case STYLE_NOTCH:
                return "#FFFFFF"
            case STYLE_THEMED_PILL:
                return Appearance.colors.colOnLayer0
            case STYLE_GLASS:
                return Appearance.colors.colOnLayer0
            case STYLE_MINIMAL:
                return Appearance.colors.colOnLayer0
            default:
                return Appearance.colors.colOnLayer0
        }
    }

    function computeSubtextColor() {
        switch (activeStyle) {
            case STYLE_SOLID_BLACK:
            case STYLE_NOTCH:
                return "#9AA0AA"
            default:
                return Appearance.colors.colSubtext
        }
    }

    function computeAccentColor() {
        switch (activeStyle) {
            case STYLE_SOLID_BLACK:
            case STYLE_NOTCH:
                return "#8AB4F8"  // Blue accent
            default:
                return Appearance.colors.colPrimary
        }
    }

    function computePanelBg() {
        switch (activeStyle) {
            case STYLE_SOLID_BLACK:
            case STYLE_NOTCH:
                return "#000000"  // Pure black panel
            case STYLE_THEMED_PILL:
                return Appearance.colors.colUiBackground
            case STYLE_GLASS:
                return Config.options.background.widgets.glass.enable
                    ? Appearance.colors.colUiBackground
                    : Qt.rgba(Appearance.colors.colUiBackground.r, Appearance.colors.colUiBackground.g, Appearance.colors.colUiBackground.b, 0.95)
            case STYLE_MINIMAL:
                return Qt.rgba(Appearance.colors.colUiBackground.r, Appearance.colors.colUiBackground.g, Appearance.colors.colUiBackground.b, 0.9)
            default:
                return Config.options.bar.followFrameColor
                    ? Appearance.getColorFromName(Config.options.bar.frameColor)
                    : Appearance.colors.colUiBackground
        }
    }

    function computePanelBorder() {
        switch (activeStyle) {
            case STYLE_SOLID_BLACK:
            case STYLE_NOTCH:
                return Appearance.colors.colLayer0Border
            case STYLE_THEMED_PILL:
                return Appearance.colors.colOutlineVariant
            case STYLE_GLASS:
                return Config.options.background.widgets.glass.enable
                    ? Appearance.colors.colOutlineVariant
                    : "transparent"
            case STYLE_MINIMAL:
                return Appearance.colors.colOutlineVariant
            default:
                return Appearance.colors.colOutlineVariant
        }
    }

    // ===== Style Metadata for Settings =====
    readonly property var styleOptions: [
        {
            id: STYLE_DEFAULT,
            name: Translation.tr("Default (Pill)"),
            icon: "pill",
            description: Translation.tr("Classic themed pill bar")
        },
        {
            id: STYLE_SOLID_BLACK,
            name: Translation.tr("Solid Black"),
            icon: "contrast",
            description: Translation.tr("Pure black opaque island (openagentisland style)")
        },
        {
            id: STYLE_THEMED_PILL,
            name: Translation.tr("Themed Pill"),
            icon: "palette",
            description: Translation.tr("Translucent themed pill (ChillPill style)")
        },
        {
            id: STYLE_GLASS,
            name: Translation.tr("Glass / Material"),
            icon: "water_drop",
            description: Translation.tr("Full glass effect with blur")
        },
        {
            id: STYLE_NOTCH,
            name: Translation.tr("Notch Style"),
            icon: "crop_free",
            description: Translation.tr("Dynamic notch with side islands")
        },
        {
            id: STYLE_MINIMAL,
            name: Translation.tr("Minimal"),
            icon: "minimize",
            description: Translation.tr("Thin minimal line indicator")
        }
    ]

    // ===== Helper: Apply style =====
    function applyStyle(styleId) {
        activeStyle = styleId
        Config.options.bar.dynamicIsland.style = styleId
        GlobalStates.refreshBar()
    }

    // ===== Icon Sizing =====
    readonly property int iconSizeSmall: 14
    readonly property int iconSizeNormal: 18
    readonly property int iconSizeLarge: 24
    readonly property int iconSizeHuge: 28

    // ===== Spacing =====
    readonly property int spacingXS: 4
    readonly property int spacingS: 8
    readonly property int spacingM: 12
    readonly property int spacingL: 16
    readonly property int spacingXL: 24

    // ===== Border Radius =====
    readonly property int radiusXS: 6
    readonly property int radiusS: 8
    readonly property int radiusM: 12
    readonly property int radiusL: 16
    readonly property int radiusXL: 20
    readonly property int radiusFull: 999

    // ===== Font Sizes (scaled) =====
    readonly property int fontSizeXS: Math.round(10 * Config.options.appearance.uiScale)
    readonly property int fontSizeS: Math.round(12 * Config.options.appearance.uiScale)
    readonly property int fontSizeM: Math.round(14 * Config.options.appearance.uiScale)
    readonly property int fontSizeL: Math.round(16 * Config.options.appearance.uiScale)
    readonly property int fontSizeXL: Math.round(18 * Config.options.appearance.uiScale)
    readonly property int fontSizeTitle: Math.round(20 * Config.options.appearance.uiScale)

    // ===== Component Factories =====
    // Reusable component templates for consistent styling

    // Pill background component
    Component {
        id: pillBgComponent
        Rectangle {
            width: root.pillWidth
            height: root.pillHeight
            radius: root.radius
            color: root.pillColor
            border.width: root.borderWidth
            border.color: root.pillBorder
            clip: true
        }
    }

    // Panel background component
    Component {
        id: panelBgComponent
        Rectangle {
            width: root.panelWidth
            height: root.panelHeight
            radius: root.expandedRadius
            color: root.panelBg
            border.width: root.panelBorderWidth
            border.color: root.panelBorder
            clip: true

            // Glass effect
            WindowGlass {
                anchors.fill: parent
                anchors.margins: -4
                glassEnabled: Config.options.background.widgets.glass.enable && (activeStyle === STYLE_GLASS || activeStyle === STYLE_THEMED_PILL)
                cardRadius: root.expandedRadius
            }
        }
    }

    // Panel shadow
    Component {
        id: panelShadowComponent
        Rectangle {
            width: root.panelWidth + 24
            height: root.panelHeight + 24
            radius: root.expandedRadius + 8
            color: "transparent"
            layer.enabled: true
            layer.effect: Qt5Compat.GraphicalEffects.DropShadow {
                verticalOffset: root.shadowOffset
                horizontalOffset: 0
                radius: root.shadowRadius
                samples: 16
                color: root.panelShadow
                transparentBorder: true
            }
        }
    }

    // Styled text component
    Component {
        id: styledTextComponent
        StyledText {
            font.family: Appearance.font.family.main
            color: root.textColor
        }
    }

    // Subtext component
    Component {
        id: subtextComponent
        StyledText {
            font.family: Appearance.font.family.main
            color: root.subtextColor
        }
    }

    // Accent text component
    Component {
        id: accentTextComponent
        StyledText {
            font.family: Appearance.font.family.main
            color: root.accentColor
            font.weight: Font.DemiBold
        }
    }

    // Section header component
    Component {
        id: sectionHeaderComponent
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: root.spacingL
            Layout.rightMargin: root.spacingL
            spacing: root.spacingS

            MaterialSymbol {
                Layout.alignment: Qt.AlignVCenter
                iconSize: root.iconSizeNormal
                fill: 1
                color: root.accentColor
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
                font.pixelSize: root.fontSizeM
                font.weight: Font.Medium
                color: root.textColor
            }
        }
    }

    // Card component (for entries in lists)
    Component {
        id: cardComponent
        Rectangle {
            Layout.fillWidth: true
            radius: root.radiusM
            color: root.computeCardBg()
            border.width: 1
            border.color: root.computeCardBorder()
            implicitHeight: 48

            function computeCardBg() {
                if (activeStyle === STYLE_SOLID_BLACK || activeStyle === STYLE_NOTCH) {
                    return "#111111"
                }
                return Appearance.colors.colLayer1
            }

            function computeCardBorder() {
                if (activeStyle === STYLE_SOLID_BLACK || activeStyle === STYLE_NOTCH) {
                    return "#222222"
                }
                return Appearance.colors.colOutlineVariant
            }
        }
    }

    // Button component (icon buttons in panel)
    Component {
        id: iconButtonComponent
        MouseArea {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true

            Rectangle {
                id: btnBg
                anchors.centerIn: parent
                width: 32
                height: 32
                radius: 16
                color: "transparent"
                border.width: 1
                border.color: "transparent"

                MaterialSymbol {
                    anchors.centerIn: parent
                    iconSize: root.iconSizeNormal
                    fill: 1
                    color: root.textColor
                }
            }

            onEntered: btnBg.color = root.computeButtonHover()
            onExited: btnBg.color = "transparent"
        }
    }

    function computeButtonHover() {
        if (activeStyle === STYLE_SOLID_BLACK || activeStyle === STYLE_NOTCH) {
            return Qt.rgba(1, 1, 1, 0.1)
        }
        return Appearance.colors.colLayer1Hover
    }

    // ===== Animations =====
    // Pill width animation
    Behavior on pillWidth {
        NumberAnimation {
            duration: root.pillAnimDuration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.animationCurves.expressiveDefaultSpatial
        }
    }

    // Panel fade/scale handled by DiExpanded
}