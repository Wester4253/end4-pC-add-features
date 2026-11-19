# Testing Checklist

## Pre-requisites
- [ ] Hyprland running
- [ ] Quickshell running with end4-pC config
- [ ] `plocate` installed (for file search)
- [ ] `fd` installed (file search fallback)
- [ ] `python3` with `requests` module (AI chat)
- [ ] Ollama/LM Studio/vLLM running (for local LLM)
- [ ] Otto daemon running (for Otto integration)
- [ ] `ddcutil` (for external monitor brightness)
- [ ] `hyprsunset` (for night light)
- [ ] `wpctl` (for audio routing)
- [ ] `hyprctl` (for display management)

---

## Dynamic Island Core

### Pill (AI Chip)
- [ ] Pill renders correctly
- [ ] AI chip shows 5 providers when enabled
- [ ] Percentages update correctly
- [ ] Badges appear for background providers
- [ ] Wheel scroll toggles idle state
- [ ] Tap expands panel (when no priority content)

### Expanded Panel
- [ ] Opens below pill (bar at top) / above pill (bar at bottom)
- [ ] Auto-direction works (bar position detection)
- [ ] Smooth scale/opacity animation (180ms/200ms)
- [ ] Glass effect matches theme
- [ ] Drop shadow renders correctly
- [ ] Click outside closes panel
- [ ] All 28 sections toggle independently in settings

### Section Toggles (Settings → Bar → Dynamic Island → Panel Sections)
- [ ] AI Usage
- [ ] System Stats
- [ ] Weather
- [ ] Calendar
- [ ] World Clock
- [ ] Media
- [ ] Visualizer
- [ ] Notifications
- [ ] Clipboard
- [ ] Active Window
- [ ] Timers
- [ ] Network
- [ ] Bluetooth
- [ ] VPN
- [ ] Disk/Storage
- [ ] GPU
- [ ] Processes
- [ ] Docker
- [ ] Services
- [ ] Debug Logs
- [ ] Shortcuts
- [ ] Updates
- [ ] Profiles
- [ ] Focus Mode
- [ ] System Info
- [ ] File Search
- [ ] Calculator

---

## AI Integration

### Bar AI Chip
- [ ] Shows 5 providers (Claude, Codex, OMP, Otto, Local)
- [ ] Mini progress bars animate
- [ ] Summary text updates
- [ ] Hides when all disabled/no data

### AI Usage Popup
- [ ] Opens on hover
- [ ] All 5 providers listed
- [ ] Progress bars correct
- [ ] Session/agent rows display
- [ ] Tokens/reset info shown
- [ ] Local LLM shows running/total models

### Provider: Oh My Pi (Fixed)
- [ ] Scans `~/.omp` and `~/.pi` sessions
- [ ] 5h rolling window
- [ ] Busy/idle from transcript (not /proc)
- [ ] Per-model token breakdown

### Provider: Otto
- [ ] WebSocket connects to daemon
- [ ] Shows running/total agents
- [ ] Per-agent: status, attention, permissions, context%
- [ ] Total tokens across agents

### Provider: Local LLMs
- [ ] Queries Ollama (11434)
- [ ] Queries LM Studio (1234)
- [ ] Queries vLLM (8000)
- [ ] Queries text-gen-webui (5000)
- [ ] Shows running/total models per server

---

## Project Display & Audio Flyout (Super+P)

### Trigger
- [ ] Super+P toggles flyout
- [ ] GlobalStates.projectDisplayOpen toggles
- [ ] Flyout centers on pill

### Display Tab
- [ ] 4 projection mode buttons (1-4 shortcuts)
- [ ] Monitor list shows all connected
- [ ] Per-monitor: resolution selector
- [ ] Per-monitor: scale selector (100/125/150/200%)
- [ ] Per-monitor: rotation (0/90/180/270)
- [ ] Per-monitor: VRR toggle (if available)
- [ ] Per-monitor: DPMS sleep button
- [ ] Primary monitor highlighted

### Audio Tab
- [ ] Output devices listed
- [ ] Input devices listed
- [ ] Volume sliders work
- [ ] Mute toggle works
- [ ] Default device selection (check icon)
- [ ] Current device highlighted

### Brightness/Color Tab
- [ ] Brightness slider works
- [ ] Night Light toggle
- [ ] Night Light presets (5)
- [ ] Color profile toggle
- [ ] RGB gamma sliders (0.5-2.0)
- [ ] Reset button works
- [ ] Preset buttons (Daylight/Neutral/Warm/Candle/Deep Red)

### Settings Integration
- [ ] Enable/disable flyout
- [ ] All 20 sub-options toggleable
- [ ] Hotkey configurable (SUPER+P)

---

## Clipboard Favorites

### Clipboard Panel
- [ ] Star button toggles favorite
- [ ] Star icon fills when favorited
- [ ] "Favorite" status text
- [ ] Warning color for favorites
- [ ] Star button in icon area
- [ ] Pin toggle still works (legacy)
- [ ] Paste button works
- [ ] Search filters entries
- [ ] Empty state shows correctly

### Favorites Persistence
- [ ] Add favorite → persists after reload
- [ ] Remove favorite → persists after reload
- [ ] `~/.cache/cliphist/fav.db` created
- [ ] SQLite schema correct
- [ ] Legacy pins still work

---

## AI Chat Sidebar

### UI
- [ ] Opens from sidebar (Intelligence tab)
- [ ] Provider selector works
- [ ] Message bubbles render
- [ ] User/assistant distinction
- [ ] Timestamps show
- [ ] Input field accepts text
- [ ] Enter sends, Shift+Enter = newline
- [ ] Send button works
- [ ] Loading spinner during request
- [ ] Scroll to bottom on new message
- [ ] Close button works
- [ ] Click outside closes

### Providers
- [ ] Local LLM selector works
- [ ] Claude Code option (if available)
- [ ] Gemini option (if configured)
- [ ] OpenAI option (if configured)
- [ ] Switching providers clears chat

### Local LLM Backend
- [ ] Ollama query works
- [ ] LM Studio query works
- [ ] vLLM query works
- [ ] text-gen-webui query works
- [ ] Fallback chain works
- [ ] Error handling shows message

---

## File Search

### Search UI
- [ ] Search field accepts input
- [ ] Prefix hints: `#` everything, `@` content, `!` type
- [ ] Sort dropdown (Relevance/Name/Size/Type/Modified)
- [ ] Sort direction toggle (↑/↓)
- [ ] Filter dropdown (All/Folders/Files/Images/Video/Audio/Docs/Archives/Apps/Code)
- [ ] Search mode dropdown (Name/Content/Type)

### Results
- [ ] Results appear in real-time
- [ ] File icon by type
- [ ] Path shown truncated
- [ ] Size displayed
- [ ] Modified date shown
- [ ] Click opens file
- [ ] Folder button opens parent
- [ ] Copy path button works
- [ ] No results state shows

### Backend
- [ ] plocate query works
- [ ] fd fallback works
- [ ] Results limited to 100
- [ ] Sort applies correctly
- [ ] Filter applies correctly
- [ ] Search mode applies correctly

---

## Calculator

### Expression Evaluation
- [ ] Basic math: `2+2`, `10*5`, `100/4`
- [ ] Power: `2^10`
- [ ] Parentheses: `(2+3)*4`
- [ ] Functions: `sqrt(16)`, `sin(pi/2)`, `log(100)`
- [ ] Constants: `pi`, `e`
- [ ] Factorial: `5!`
- [ ] Percent: `10%`
- [ ] Max/min: `max(1,5,3)`, `min(1,5,3)`
- [ ] Round: `round(3.14159, 2)`
- [ ] Random: `random()`
- [ ] Error handling shows "Error: ..."

### Quick Expressions
- [ ] 16 preset buttons
- [ ] Click inserts expression
- [ ] Auto-evaluates on insert
- [ ] Result shows below

### Result Display
- [ ] Shows result below input
- [ ] Error shows in red
- [ ] Copy button copies result
- [ ] Clear button resets

---

## Clipboard Favorites

- [ ] Star button toggles favorite
- [ ] Star icon fills (bookmark)
- [ ] "Favorite" status text
- [ ] Warning color for favorites
- [ ] Star icon in entry header
- [ ] Favorite entries sorted first? (check)
- [ ] Persistence across reloads
- [ ] `~/.cache/cliphist/fav.db` created
- [ ] Legacy pin still works

---

## File Search

- [ ] Search field accepts input
- [ ] Prefix hints shown
- [ ] Sort/filter/mode controls work
- [ ] Results display correctly
- [ ] File actions work
- [ ] Backend queries plocate/fd
- [ ] Results limited to 100
- [ ] Sort applies
- [ ] Filter applies
- [ ] Mode applies

---

## Calculator

- [ ] Expressions evaluate
- [ ] Math functions work
- [ ] Constants work
- [ ] Quick buttons insert & evaluate
- [ ] Result displays
- [ ] Copy result works
- [ ] Error handling

---

## Keyboard Layout Indicator

- [ ] Shows on boot without restart
- [ ] Updates on layout change
- [ ] Works on Hyprland
- [ ] Works on Niri

---

## Network

- [ ] No implicit scans on `nmcli monitor`
- [ ] 10s signal refresh from cache
- [ ] Coalesced monitor events (100ms)
- [ ] Ethernet without internet detected
- [ ] Public IP only on full/limited
- [ ] Wifi panel still scans explicitly
- [ ] Wifi connect/disconnect works

---

## Bluetooth

- [ ] Adapter not powered on at init
- [ ] UI shows correct state
- [ ] Toggle works
- [ ] Dialog opens correctly
- [ ] Device connect/disconnect
- [ ] Device remove works
- [ ] Scan works
- [ ] Pair works
- [ ] Battery shows

---

## Popup Flickering

- [ ] Open right sidebar
- [ ] Hover bar items
- [ ] No flicker (open/close loop)
- [ ] Popups stay open
- [ ] Close delay 100ms works

---

## Clock Calendar

- [ ] Click clock toggles calendar
- [ ] Calendar shows current month
- [ ] Month navigation works
- [ ] Today highlighted
- [ ] Day selection updates popup date
- [ ] "Back to clock" works
- [ ] Uptime/todo hidden when calendar open

---

## Keyboard Layout

- [ ] Shows on boot (no widget restart needed)
- [ ] Updates on layout switch
- [ ] Works on Hyprland
- [ ] Works on Niri

---

## Profiles

- [ ] Save current config as profile
- [ ] Load profile applies config
- [ ] Export profile to file
- [ ] Import profile from file
- [ ] Delete profile
- [ ] Profile list in Dynamic Island
- [ ] Profile switch triggers reload

---

## Focus Mode

- [ ] Toggle enables/disables
- [ ] 25min Focus preset
- [ ] 50min Focus preset
- [ ] 1hr DND preset
- [ ] 4hr Gaming preset
- [ ] Custom duration works
- [ ] Mode selector (Focus/DND/Gaming)
- [ ] Auto-expiry works
- [ ] Notifications suppressed in DND

---

## File Search

- [ ] Search field works
- [ ] Prefix hints: `#` `@` `!`
- [ ] Sort options work
- [ [ ] Filter options work
- [ ] Mode selector works
- [ ] Results display
- [ ] Actions work
- [ ] Backend queries plocate/fd

---

## Calculator

- [ ] Expressions evaluate
- [ ] Math functions
- [ ] Constants
- [ ] Quick buttons
- [ ] Result display
- [ ] Copy result
- [ ] Error handling

---

## Profiles

- [ ] Save profile
- [ ] Load profile
- [ ] Export profile
- [ ] Import profile
- [ ] Delete profile
- [ ] List in Dynamic Island

---

## Focus Mode

- [ ] Enable/disable
- [ ] Presets work
- [ ] Custom duration
- [ ] Mode selector
- [ ] Auto-expiry
- [ ] DND suppresses notifications

---

## Project Display

- [ ] Super+P toggles
- [ ] Display tab: 4 modes
- [ ] Monitor controls
- [ ] Audio tab: devices
- [ ] Brightness tab: slider
- [ ] Night Light
- [ ] Gamma sliders

---

## Clipboard Favorites

- [ ] Star toggle
- [ ] Favorite badge
- [ ] Persistence
- [ ] Legacy pins work

---

## AI Chat

- [ ] Sidebar opens
- [ ] Provider select
- [ ] Send message
- [ ] Response renders
- [ ] Local LLM works
- [ ] Multi-provider

---

## Final Validation

- [ ] All syntax checks pass
- [ ] No brace mismatches
- [ ] All imports valid
- [ ] Python scripts compile
- [ ] Settings persist
- [ ] No regressions in existing features
- [ ] Performance acceptable
- [ ] Memory usage reasonable