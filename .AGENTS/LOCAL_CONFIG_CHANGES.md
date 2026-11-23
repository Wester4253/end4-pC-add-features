# Local Config Changes Summary

## Files Modified (10 core fixes)

### 1. DiAiChip.qml - StyledProgressBar Properties
- `color`/`background` → `highlightColor`/`trackColor` for 4 providers
- Removed invalid `maximumHorizontalAdvance: 120`

### 2. HyprlandXkbIndicator.qml - IPC Replacement
- `Hyprland.sendMessage("j/devices")` → Process with `hyprctl devices -j`

### 3. DiExpanded.qml - DropShadow
- Added `import QtQuick.Effects` + `Qt5Compat.GraphicalEffects`
- `layer.effect: DropShadow` → `layer.effect: Qt5Compat.GraphicalEffects.DropShadow`

### 4. BarConfig.qml - ConfigComboBox
- `options: [...]` → `model: [...]`

### 5-9. DiExpanded*Section.qml - Component Restructuring
- Components moved inside root Item, lowercase IDs
- Components defined BEFORE use
- Delegates use lowercase ID without braces

### 10. BarContent.qml - Mirrored Property
- Wrapped all 9 `item.mirrored` assignments in try-catch

### Config Fixes
- `dynamicIsland` added to `leftLayout` in config.json
- GlobalStates.qml restored from backup
