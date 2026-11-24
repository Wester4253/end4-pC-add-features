# Dynamic Island Implementation Plan

**Source of Truth:** PR #1 — "Dynamic island + AI bar full overhaul (V1)"
**URL:** https://github.com/Wester4253/end4-pC-add-features/pull/1
**Branch:** `feat/dynamic-island-overhaul`
**Head SHA:** `b1fd183f905aeea531765b24ed47eb10ecf86c7e`
**Merge SHA:** `d7c67217f7982731e37d0a3cf0569fdef209635b`
**Status:** Merged (not yet built into current `main`)

---

## What PR #1 Implements

PR #1 transforms the Dynamic Island from a simple pill widget into a full-screen "control center" overlay with 25 toggleable sections, 5 AI provider integrations, and deep settings integration.

### Dynamic Island — 25 Sections
| Category | Sections |
|----------|----------|
| AI Usage | Claude, Codex, OMP, Otto, Local LLMs |
| System Stats | CPU w/ temp, Memory, Battery, Network |
| Weather | Current + 12hr + 7-day forecast |
| Calendar | Interactive month grid |
| World Clock | UTC offsets, DST |
| Media | Album art, full controls |
| Visualizer | 5 styles: bars/dots/wave/mirror/none |
| Notifications | With Cliphist integration |
| Clipboard | With favorites |
| Active Window | Title, class, PID, controls |
| Timers | Pomodoro, Countdown, Stopwatch |
| Network | WiFi, status |
| Bluetooth | Device list, pairing |
| Screen Recording | Start/stop controls |
| Quick Actions | 12 buttons |
| VPN | Connections, add/remove |
| Disk/Storage | Mount list, usage |
| GPU | Stats |
| Processes | Process list |
| Docker | Containers, images |
| Services | System services |
| Debug Logs | Log viewer |
| Keybindings | 8 categories, 40+ shortcuts |
| System Updates | Pacman, AUR, Flatpak |
| Profiles | Save/load/export |
| Focus Mode | DND/gaming presets |
| System Info | 12 cards |

### AI Integrations (5 Providers)
- Claude Code
- Codex
- Oh My Pi (OMP)
- Otto (WebSocket JSON-RPC)
- Local LLMs (Ollama/LM Studio/vLLM/text-gen-webui)

### Settings Integration
- `BarConfig.qml` — 25 section toggles
- `DashboardSettingsCatalog.qml` — settings catalog entries
- `Config.qml` — all `bar.dynamicIsland.*` and `bar.aiUsage.*` options

### New Services (QML Singletons)
- `OttoUsage.qml`
- `LocalLLMUsage.qml`
- `FocusMode.qml`
- `Profiles.qml`
- `Docker.qml`
- `ProjectDisplay.qml`

### Python Scripts
- `scripts/ai/omp-usage.py` — fixed parser
- `scripts/ai/otto-usage.py` — WebSocket JSON-RPC
- `scripts/ai/local-llm-usage.py` — HTTP to Ollama/LM Studio/vLLM/textgen
- `scripts/clipboard/cliphist-favorites.py` — SQLite favorites
- `scripts/presets/profile_manager.py`
- `scripts/search/everything-query.py`

### Animation & UX Polish
- 180ms opacity + 200ms scale (OutCubic) panel animation
- 350ms pill-width BezierSpline
- Staggered revealers
- 32px-radius drop shadow at 12px offset
- Auto-position: up when bar at bottom, down when at top
- Flickable scrolling
- Glass/material styling

---

## Files Changed in PR #1 (72 files: 15 modified + 57 added)

### Modified (15)
1. `GlobalStates.qml` — +`projectDisplayOpen` + `CompositorGlobalShortcut` (Super+P)
2. `modules/common/Config.qml` — Otto/Local LLM config, 26 `dynamicIsland` toggles, `projectDisplay` block
3. `modules/common/widgets/StyledPopup.qml` — focus-grab persistence + 100ms close-delay
4. `modules/ii/bar/AiUsage.qml` — Otto + Local LLM providers
5. `modules/ii/bar/AiUsagePopup.qml` — subtitle/status helpers, Otto agent rows
6. `modules/ii/bar/Bluetooth.qml` — `_adapterEnabled` guard
7. `modules/ii/bar/ClockWidget.qml` — click-to-toggle calendar
8. `modules/ii/bar/ClockWidgetPopup.qml` — full month calendar grid
9. `modules/ii/bar/DynamicIsland.qml` — AI chip width, recording width, pill/panel sizing
10. `modules/ii/bar/HyprlandXkbIndicator.qml` — layout code fallback
11. `modules/ii/settings/DashboardSettingsCatalog.qml` — Otto + AI provider entries
12. `modules/ii/settings/pages/BarConfig.qml` — visualizer option, expanded toggles
13. `scripts/ai/omp-usage.py` — fixed parser
14. `services/Cliphist.qml` — favorites support
15. `services/Network.qml` — cached AP list, coalesced events

### Added (57)
**QML sections (`modules/ii/bar/`):** `DiAiChip.qml`, `DiExpanded.qml`, `DiExpandedActionsSection.qml`, `DiExpandedAiSection.qml`, `DiExpandedBluetoothSection.qml`, `DiExpandedCalculatorSection.qml`, `DiExpandedCalendarSection.qml`, `DiExpandedClipboardSection.qml`, `DiExpandedDiskSection.qml`, `DiExpandedDockerSection.qml`, `DiExpandedFileSearchSection.qml`, `DiExpandedFocusSection.qml`, `DiExpandedGPUSection.qml`, `DiExpandedLogsSection.qml`, `DiExpandedMediaSection.qml`, `DiExpandedNetworkSection.qml`, `DiExpandedNotesSection.qml`, `DiExpandedNotificationsSection.qml`, `DiExpandedProcessesSection.qml`, `DiExpandedProfilesSection.qml`, `DiExpandedRecordingSection.qml`, `DiExpandedServicesSection.qml`, `DiExpandedShortcutsSection.qml`, `DiExpandedSongRecSection.qml`, `DiExpandedSystemInfoSection.qml`, `DiExpandedSystemSection.qml`, `DiExpandedTimerSection.qml`, `DiExpandedTodoSection.qml`, `DiExpandedTranslatorSection.qml`, `DiExpandedUpdatesSection.qml`, `DiExpandedVPNSection.qml`, `DiExpandedVisualizerSection.qml`, `DiExpandedWeatherSection.qml`, `DiExpandedWindowSection.qml`, `DiExpandedWorldClockSection.qml`, `DiVisualizerWidget.qml`

**Project Display (`modules/ii/projectDisplay/`):** `AudioTabContent.qml`, `BrightnessTabContent.qml`, `ProjectDisplay.qml`

**Sidebar (`modules/ii/sidebarLeft/`):** `AIChatSidebar.qml`

**Python scripts:** `scripts/ai/local-llm-chat.py`, `ai/local-llm-usage.py`, `ai/otto-usage.py`, `clipboard/cliphist-favorites.py`, `presets/profile_manager.py`, `search/everything-query.py`

**QML services:** `Docker.qml`, `FocusMode.qml`, `LocalLLMUsage.qml`, `OttoUsage.qml`, `Profiles.qml`, `ProjectDisplay.qml`

---

## Implementation Plan (DO NOT BUILD YET — PLAN ONLY)

### Phase 1: Foundation
1. Add `projectDisplayOpen` property + Super+P shortcut to `GlobalStates.qml` (already done in current main)
2. Add `projectDisplay` config block to `Config.qml` (already done)
3. Add `ProjectDisplay.qml` service singleton
4. Create `modules/ii/projectDisplay/` directory with tab contents

### Phase 2: Core Dynamic Island Components
1. Create `DiExpanded.qml` — main expanded panel container (glass, 420×520, 20px radius, 32px shadow)
2. Create `DiAiChip.qml` — AI usage chip for collapsed pill
3. Create `DynamicIsland.qml` — pill widget with width animation (350ms BezierSpline)
4. Create section components one at a time following the `DiExpanded*Section.qml` pattern:
   - Each section: root `Item` with `required property Item di`, `ColumnLayout` content
   - Each reusable sub-component: `Component { id: lowercaseName }` inside root Item
   - Delegate references use lowercase component ID (no braces)

### Phase 3: AI Provider Integrations
1. Create `services/OttoUsage.qml` — WebSocket JSON-RPC to Otto daemon
2. Create `services/LocalLLMUsage.qml` — HTTP to Ollama/LM Studio/vLLM/textgen
3. Create Python backends: `scripts/ai/otto-usage.py`, `scripts/ai/local-llm-usage.py`
4. Integrate into `DiExpandedAiSection.qml`

### Phase 4: Settings Integration
1. Add all 25 `dynamicIsland.show*` toggles to `BarConfig.qml`
2. Add all `projectDisplay.*` entries to `DashboardSettingsCatalog.qml`
3. Add all `bar.aiUsage.*` options to `Config.qml`

### Phase 5: Remaining Sections
Build sections in priority order:
1. System Stats (CPU, Memory, Battery, Network)
2. Weather (current + forecast)
3. Calendar (month grid)
4. World Clock
5. Media
6. Notifications + Clipboard
7. Quick Actions
8. Remaining sections (VPN, Disk, GPU, Processes, Docker, Services, etc.)

### Phase 6: Python Scripts
1. `scripts/ai/omp-usage.py` — fixed parser
2. `scripts/clipboard/cliphist-favorites.py` — SQLite favorites
3. `scripts/presets/profile_manager.py`
4. `scripts/search/everything-query.py`

### Phase 7: Polish
- 180ms opacity + 200ms scale panel animation
- Staggered revealers
- Auto-positioning (up/down based on bar position)
- Glass/material styling

---

## Key Design Patterns to Follow

1. **Component structure:** All reusable sub-components must be `Component { id: lowercaseName }` inside the root `Item`, defined before use. Delegate references use lowercase ID (no braces).

2. **StyledProgressBar:** Use `highlightColor`/`trackColor`, NOT `color`/`background`. Remove `maximumHorizontalAdvance`.

3. **DropShadow:** Use `Qt5Compat.GraphicalEffects.DropShadow` with `import QtQuick.Effects` + `import Qt5Compat.GraphicalEffects`.

4. **Mirrored property:** Wrap all `item.mirrored` assignments in try-catch.

5. **Tailscale/Otto pairing:** Already implemented in `plugins/otto-host-pair/` — can be referenced from Dynamic Island settings.

---

## Verification Checklist

- [ ] `qs -c end4-pC` loads without "Syntax error" or "Type X unavailable"
- [ ] `INFO: Configuration Loaded` appears
- [ ] Bar visible at bottom (`hyprctl layers` shows `quickshell:bar`)
- [ ] Dynamic Island pill visible in bar
- [ ] Click pill → expanded panel opens
- [ ] All 25 sections toggleable via settings
- [ ] AI providers show usage data
- [ ] Panel animation smooth (180ms/200ms)
- [ ] Auto-position works (up/down based on bar position)
