# Installation & Testing Guide

## Prerequisites (Already Installed)
- Arch Linux + Hyprland + Quickshell
- Required packages: quickshell, hyprland, hyprlock, hypridle, hyprpaper, waybar, plocate, fd, python, python-requests, cliphist, wl-clipboard, brightnessctl, ddcutil, hyprsunset, wpctl, pavucontrol, ollama
- Fonts: noto-fonts, noto-fonts-emoji, ttf-jetbrains-mono, woff2-font-awesome

## Installation (Already Complete)

### 1. Backup Current Config
```bash
cp -r ~/.config/quickshell ~/.config/quickshell.backup.$(date +%Y%m%d)
cp -r ~/.config/hypr ~/.config/hypr.backup.$(date +%Y%m%d)
```

### 2. Clone & Checkout Stable Version
```bash
cd ~/.config/quickshell
git clone https://github.com/Wester4253/end4-pC-add-features.git end4-pC
cd end4-pC
git checkout v1.0-dynamic-island-overhaul
```

### 3. Set as Default Shell
Edit `~/.config/hypr/hyprland/variables.lua`:
```lua
hl.env("qsConfig", "end4-pC")
```

### 4. Restart Hyprland/Quickshell
```bash
# Option 1: Restart Hyprland
hyprctl dispatch exit

# Option 2: Just reload quickshell
killall qs
qs -c end4-pC > /dev/null 2>&1 & disown
```

## Testing the Installation

### Quick Test
```bash
cd /home/wstr && qs -c end4-pC
```
Should load without syntax errors. Look for:
- `INFO: Configuration Loaded`
- Dynamic Island pill appears on bar
- No "Type X unavailable" or "Syntax error" messages

### Verify Dynamic Island Features
1. **Pill appears** on bar (top/bottom depending on config)
2. **Click pill** → Expanded panel opens with 28 sections
3. **Test sections**:
   - AI Usage: Shows token/RPM usage for 5 providers
   - System Stats: CPU, RAM, Battery, Network
   - Weather: Current + 12h + 7-day forecast
   - Calendar: Interactive month grid
   - World Clock: Multiple timezones
   - Media: MPRIS controls
   - Visualizer: 4 styles (dots/wave/bars/mirror)
   - Notifications: Dismissible list
   - Clipboard: Searchable history + favorites
   - ...and 18 more sections

### Keyboard Shortcuts
- **Super+P**: Project Display flyout (Display/Audio/Brightness)
- **Super+I**: Settings app
- **Super+Shift+Alt+/**: Welcome app
- **Super+Q**: Close window
- **Super+A**: AI Chat sidebar

### Verify AI Providers
Edit `~/.config/illogical-impulse/config.json`:
```json
{
  "bar": {
    "aiUsage": {
      "claudeEnabled": true,
      "codexEnabled": false,
      "ompEnabled": true,
      "ottoEnabled": true,
      "localLLMEnabled": true,
      "ollamaHost": "http://localhost:11434",
      "updateInterval": 60
    }
  }
}
```

### Verify OMP Integration
```bash
# Install OMP
curl -fsSL https://raw.githubusercontent.com/oh-my-pi/omp/main/install.sh | bash
omp login

# Test
omp status
omp agent ls
```

### Verify Local LLMs
```bash
# Ollama
curl -fsSL https://ollama.com/install.sh | sh
ollama serve &
ollama pull llama3.2

# Test
curl http://localhost:11434/api/tags
```

## Troubleshooting

### Dynamic Island Not Showing
```bash
# Check if loaded
qs -c end4-pC --inspect

# Check logs
journalctl -u quickshell -f
# or
qs -c end4-pC 2>&1 | head -50
```

### AI Providers Not Showing
```bash
# Check config
cat ~/.config/illogical-impulse/config.json | jq '.bar.aiUsage'

# Test OMP
omp status
omp agent ls

# Test Ollama
curl http://localhost:11434/api/tags
```

### Dynamic Island Not Expanding
- Check `Config.options.bar.dynamicIsland.enableExpanded` is `true`
- Check `Config.options.bar.cornerStyle` is 2 (Islands) or 3/4 (M3)
- Middle layout must include "dynamicIsland"

### Project Display (Super+P) Not Working
```bash
# Check hyprctl
hyprctl monitors

# Check wpctl
wpctl status

# Check hyprsunset
hyprsunset -h

# Check ddcutil (for external monitors)
sudo ddcutil detect
```

### Syntax Errors During Development
```bash
# Validate QML syntax
qmlimportscanner -importPath /home/wstr/.config/quickshell/end4-pC/modules/ii/bar/ \
  -importPath /home/wstr/.config/quickshell/end4-pC/modules/common/ \
  -importPath /usr/lib/qt6/qml/ \
  /home/wstr/.config/quickshell/end4-pC/modules/ii/bar/DiExpanded.qml
```

## Recovery Procedures

### If Something Breaks
```bash
# 1. Restore from backup
cp -r ~/.config/quickshell.backup.* ~/.config/quickshell
cp -r ~/.config/hypr.backup.* ~/.config/hypr

# 2. Or checkout clean version
cd ~/.config/quickshell/end4-pC
git checkout v1.0-dynamic-island-overhaul

# 3. Restart
killall qs
qs -c end4-pC > /dev/null 2>&1 & disown
```

### Nuclear Option (Complete Reset)
```bash
rm -rf ~/.config/quickshell ~/.config/illogical-impulse
cd ~/.config/quickshell
git clone https://github.com/Wester4253/end4-pC-add-features.git end4-pC
cd end4-pC
git checkout v1.0-dynamic-island-overhaul
```

## Configuration Files
- **Main Config**: `~/.config/illogical-impulse/config.json`
- **Quickshell Config**: `~/.config/quickshell/end4-pC/`
- **Hyprland Config**: `~/.config/hypr/hyprland/`
- **Source Repo**: `/home/wstr/documents/code/end4-pC/`

## Key Configuration Options
```json
{
  "bar": {
    "dynamicIsland": {
      "enableExpanded": true,
      "expandDirection": "auto",
      "showAiUsage": true,
      "showSystemStats": true,
      "showWeather": true,
      "showCalendar": true,
      "showWorldClock": true,
      "showMedia": true,
      "showVisualizer": true,
      "showNotifications": true,
      "showQuickActions": true,
      "showClipboard": true,
      "showActiveWindow": true,
      "showTodo": true,
      "showNotes": true,
      "showTranslator": true,
      "showSongRec": true,
      "showNetwork": true,
      "showBluetooth": true,
      "showTimers": true,
      "showRecording": true,
      "showVPN": true,
      "showDisk": true,
      "showGPU": true,
      "showProcesses": true,
      "showDocker": true,
      "showServices": true,
      "showLogs": true,
      "showShortcuts": true,
      "showUpdates": true,
      "showProfiles": true,
      "showFocus": true,
      "showSystemInfo": true,
      "showFileSearch": true,
      "showCalculator": true
    }
  }
}
```

## Resources
- **Repository**: https://github.com/Wester4253/end4-pC-add-features
- **Upstream (illogical-impulse)**: https://github.com/end-4/dots-hyprland
- **OMP Docs**: https://github.com/oh-my-pi/omp
- **Otto Docs**: https://github.com/otto-code/otto
- **Quickshell Docs**: https://quickshell.org