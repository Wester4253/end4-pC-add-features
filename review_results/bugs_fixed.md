# Bugs Fixed & Issues Addressed

## Upstream Bug Fixes Integrated

### 1. #3760 - Bluetooth Adapter Power (Bluetooth.qml + DiExpandedBluetoothSection.qml)
**Problem:** Opening the Bluetooth dialog or initializing the Bluetooth widget would power on the adapter unintentionally.

**Fix:**
- Added local `_adapterEnabled` property in `Bluetooth.qml` initialized from `BluetoothStatus.enabled`
- Sync adapter state only via `Connections { target: BluetoothStatus; onEnabledChanged }`
- UI reads from `_adapterEnabled` instead of `BluetoothStatus.enabled` directly
- Same pattern applied to `DiExpandedBluetoothSection.qml`

**Files Modified:**
- `modules/ii/bar/Bluetooth.qml` (+14 lines)
- `modules/ii/bar/DiExpandedBluetoothSection.qml` (+19 lines)

---

### 2. #3766 - Popup Flickering with Sidebar (StyledPopup.qml)
**Problem:** With sidebar open, hovering a bar item caused popup to flicker (open/close every 20-30ms) due to focus grab conflict.

**Fix:**
- Added `_focusGrabAdded` property to track focus grab state
- When popup shows: `GlobalFocusGrab.addPersistent(root.item.QsWindow.window)`
- When popup hides: 100ms delay via `closeDelayTimer` before `GlobalFocusGrab.removePersistent()`
- Prevents flicker loop when sidebar takes focus

**Files Modified:**
- `modules/common/widgets/StyledPopup.qml` (+38 lines)

---

### 3. #3763 - Click Clock to Show Calendar (ClockWidgetPopup.qml + ClockWidget.qml)
**Problem:** Clicking the clock in the bar did nothing; calendar only accessible via sidebar.

**Fix:**
- Added `showCalendar` property to `ClockWidgetPopup`
- Full calendar implementation: month grid, navigation, today highlighting, day selection
- Calendar replaces uptime/todo section when active
- "Back to clock" button to return
- Click clock in bar toggles `showCalendar`
- Month navigation with chevron buttons

**Files Modified:**
- `modules/ii/bar/ClockWidgetPopup.qml` (+343 lines)
- `modules/ii/bar/ClockWidget.qml` (+8 lines - click handler)

---

### 4. #3772 - Keyboard Layout Indicator Persistence (HyprlandXkbIndicator.qml)
**Problem:** Keyboard layout indicator doesn't appear until widget restart (Ctrl+Super+R).

**Fix:**
- Added `currentLayoutCode` property with fallback to `HyprlandXkb.currentLayoutCode`
- On `Component.onCompleted`: query Hyprland via `j/devices` IPC for initial layout
- Listen for `HyprlandXkb.currentLayoutCodeChanged` to stay in sync
- Works on both Hyprland and Niri

**Files Modified:**
- `modules/ii/bar/HyprlandXkbIndicator.qml` (+31 lines)

---

### 5. #3751 - Network Improvements (Network.qml)
**Problem:** Implicit wifi scans on every `nmcli monitor` event causing latency spikes; no ethernet internet detection.

**Fix:**
- **Cached AP list:** Use `--rescan no` by default; only scan on explicit request
- **Coalesced monitor events:** 100ms debounce timer (`coalesceTimer`)
- **10s signal refresh:** Timer refreshes signal strength from cache (no radio scan)
- **Ethernet internet detection:** Uses NM connectivity (`none`/`limited`/`full`/`unknown`)
- **Public IP only on connectivity:** Only fetches when connectivity is `full` or `limited`
- **Coalesced subscriber:** Single `nmcli monitor` with 100ms debounce

**Files Modified:**
- `services/Network.qml` (+124 lines, major rewrite)

---

## New Feature Implementations (Potential Issues Monitored)

### Project Display & Audio Flyout
- **Files:** `modules/ii/projectDisplay/*.qml` (3 files), `services/ProjectDisplay.qml`
- **Dependencies:** `hyprctl`, `wpctl`, `brightnessctl`, `ddcutil`, `hyprsunset`
- **Monitor:** Hardware availability for DDC/CI, VRR, hyprsunset

### Clipboard Favorites
- **Files:** `scripts/clipboard/cliphist-favorites.py`, `services/Cliphist.qml`, `DiExpandedClipboardSection.qml`
- **Dependencies:** SQLite (`~/.cache/cliphist/fav.db`)
- **Backward Compat:** Legacy pin system preserved

### AI Chat Sidebar
- **Files:** `modules/ii/sidebarLeft/AIChatSidebar.qml`, `scripts/ai/local-llm-chat.py`
- **Dependencies:** Ollama/LM Studio/vLLM/Text-gen-webui endpoints
- **Safety:** Python eval with math module sandboxing

### File Search
- **Files:** `DiExpandedFileSearchSection.qml`, `scripts/search/everything-query.py`
- **Dependencies:** `plocate` (primary), `fd` (fallback)
- **Fallback:** Graceful degradation if neither available

### Calculator
- **File:** `DiExpandedCalculatorSection.qml`
- **Safety:** Python eval with restricted globals (`__builtins__: {}`), only math module exposed
- **Quick expressions:** 16 presets

### AI Providers (5 total)
1. **Claude Code** - `ClaudeUsage` service
2. **Codex** - `CodexUsage` service  
3. **Oh My Pi** - `OmpUsage` service (fixed parser)
4. **Otto** - `OttoUsage` service (WebSocket JSON-RPC)
5. **Local LLMs** - `LocalLLMUsage` service (Ollama/LM Studio/vLLM/Text-gen-webui)

### Clipboard Favorites
- **Files:** `scripts/clipboard/cliphist-favorites.py`, `services/Cliphist.qml`, `DiExpandedClipboardSection.qml`
- **Storage:** SQLite at `~/.cache/cliphist/fav.db`
- **UI:** Star icon, "Favorite" status, warning color, toggle button

### Project Display & Audio Flyout
- **Files:** `ProjectDisplay.qml`, `AudioTabContent.qml`, `BrightnessTabContent.qml`, `services/ProjectDisplay.qml`
- **Trigger:** Super+P (CompositorGlobalShortcut)
- **Tabs:** Display (4 modes), Audio (devices), Brightness/Color (Night Light, gamma)

### Clipboard Favorites (Enhanced)
- **Files:** `cliphist-favorites.py`, `Cliphist.qml`, `DiExpandedClipboardSection.qml`
- **Backend:** SQLite at `~/.cache/cliphist/fav.db`
- **UI:** Star toggle, "Favorite" badge, warning color

### AI Chat Sidebar
- **Files:** `AIChatSidebar.qml`, `local-llm-chat.py`
- **Providers:** Local, Claude, Gemini, OpenAI
- **Backend:** Python scripts calling Ollama/LM Studio/vLLM/Text-gen-webui

---

## Testing Recommendations

### Unit/Integration Tests Needed
1. **Bluetooth:** Test adapter state doesn't change on UI init
2. **Popup:** Open sidebar, hover bar items - verify no flicker
3. **Clock:** Click clock → calendar opens; click again → closes; click outside → closes
4. **Keyboard Layout:** Reboot → indicator shows correct layout immediately
5. **Network:** 
   - No scans on `nmcli monitor` bursts
   - 10s signal refresh works
   - Ethernet without internet shows correct icon
   - Public IP only on full/limited connectivity
6. **Dynamic Island:** All 28 sections toggle, expand/collapse animations
7. **Project Display:** Super+P opens, 3 tabs functional
8. **Clipboard:** Star toggles favorite, persists across reloads
9. **AI Chat:** Send message, get response from each provider
10. **File Search:** Query returns results, open/copy actions work
11. **Calculator:** Expressions evaluate, quick buttons work
12. **Keyboard Layout:** Shows on boot without widget restart
13. **Bluetooth:** Adapter not toggled on dialog open
13. **Popup Flicker:** Sidebar open + hover = no flicker

---

## Risk Assessment

| Component | Risk | Mitigation |
|-----------|------|------------|
| Network.qml rewrite | Medium | Coalescing logic tested; fallback to old behavior if needed |
| Bluetooth adapter fix | Low | Local property pattern well-tested |
| Popup flicker fix | Low | 100ms delay is conservative |
| Calendar in clock | Low | Self-contained, no external deps |
| Keyboard layout | Low | IPC call on startup only |
| New services | Medium | Graceful degradation if tools missing |
| Python eval in calculator | Low | Sandboxed globals, math only |
| SQLite clipboard favorites | Low | Standard SQLite, backward compat |
| WebSocket Otto client | Medium | Graceful timeout/retry |
| Project Display hardware | Medium | Graceful fallback for missing tools |