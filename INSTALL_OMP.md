# end4-pC Dynamic Island Overhaul - OMP Agent Installation Guide

**Version:** v1.0-dynamic-island-overhaul  
**Tag:** `v1.0-dynamic-island-overhaul`  
**Branch:** `feat/dynamic-island-overhaul`  
**Repository:** https://github.com/Wester4253/end4-pC-add-features

---

## ⚠️ IMPORTANT: Recovery Instructions

If anything breaks during installation, you can recover to this exact state:

```bash
# Clone the repo
git clone https://github.com/Wester4253/end4-pC-add-features.git
cd end4-pC-add-features

# Checkout the stable tag
git checkout v1.0-dynamic-island-overhaul

# Or checkout the branch
git checkout feat/dynamic-island-overhaul
```

The tag `v1.0-dynamic-island-overhaul` is immutable and will always point to this working state.

---

## 📋 Prerequisites

### System Requirements
- **OS:** Arch Linux (or Arch-based: CachyOS, EndeavourOS, Garuda, etc.)
- **Window Manager:** Hyprland (v0.40+) or Niri
- **Shell:** Quickshell (qs) installed and working
- **GPU:** NVIDIA/AMD/Intel (NVIDIA requires proprietary drivers)

### Required Packages (Arch/CachyOS)
```bash
# Core
sudo pacman -S quickshell hyprland hyprlock hypridle hyprpaper waybar

# Dynamic Island dependencies
sudo pacman -S plocate fd python python-requests cliphist wl-clipboard

# Optional but recommended
sudo pacman -S brightnessctl ddcutil hyprsunset wpctl pavucontrol

# For AI features
sudo pacman -S ollama  # or install LM Studio / vLLM / text-generation-webui manually

# Fonts
sudo pacman -S noto-fonts noto-fonts-emoji ttf-jetbrains-mono ttf-font-awesome
```

### AUR Packages (if needed)
```bash
yay -S quickshell-git hyprland-git cliphist stash
```

---

## 🚀 Installation Steps

### 1. Backup Your Current Config
```bash
# Backup your current quickshell config
cp -r ~/.config/quickshell ~/.config/quickshell.backup.$(date +%Y%m%d)

# Backup hyprland config
cp -r ~/.config/hypr ~/.config/hypr.backup.$(date +%Y%m%d)
```

### 2. Clone This Repository
```bash
cd ~/.config/quickshell
git clone https://github.com/Wester4253/end4-pC-add-features.git end4-pC
cd end4-pC
```

### 3. Checkout Stable Version (RECOMMENDED)
```bash
# Use the stable tag (immutable, always works)
git checkout v1.0-dynamic-island-overhaul

# OR use the branch (gets updates)
git checkout feat/dynamic-island-overhaul
```

### 4. Set as Default Shell
Edit `~/.config/hypr/hyprland/variables.lua`:
```lua
hl.env("qsConfig", "end4-pC")
```

### 5. Restart Hyprland/Quickshell
```bash
# Option 1: Restart Hyprland (logs you out)
hyprctl dispatch exit

# Option 2: Just reload quickshell
killall qs
qs -c end4-pC > /dev/null 2>&1 & disown
```

---

## ⚙️ Post-Install Configuration

### 1. First Run - Run Setup Wizard
The first launch will trigger the First Run Experience. Follow the on-screen prompts.

### 2. Configure AI Providers (Optional but Recommended)
Edit `~/.config/illogical-impulse/config.json` or use Settings → Bar → AI Usage:

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
      "lmstudioHost": "http://localhost:1234",
      "vllmHost": "http://localhost:8000",
      "textgenHost": "http://localhost:5000",
      "updateInterval": 60
    }
  }
}
```

#### AI Provider Setup:

**Oh My Pi (omp):**
```bash
# Install omp
curl -fsSL https://raw.githubusercontent.com/oh-my-pi/omp/main/install.sh | bash
omp login  # Follow prompts
```

**Otto (for Otto agent):**
```bash
npm install -g @otto-code/cli
otto onboard  # Follow prompts, starts daemon on localhost:6868
```

**Local LLMs:**
```bash
# Ollama
curl -fsSL https://ollama.com/install.sh | sh
ollama serve &
ollama pull llama3.2

# LM Studio - Download from https://lmstudio.ai

# vLLM
pip install vllm
vllm serve meta-llama/Llama-3.2-3B-Instruct
```

### 3. Enable Dynamic Island
Settings → Bar → Layout → Middle Layout → Add "dynamicIsland"

Or edit config:
```json
"bar": {
  "layouts": {
    "middleLayout": ["dynamicIsland"]
  }
}
```

### 4. Configure Project Display (Super+P)
Settings → Bar → Project Display → Enable

Configure:
- Display: Mirror/Extend/Resolution/Scale/Rotation/VRR/DPMS
- Audio: Output/Input devices, volume, default device
- Brightness: Slider, Night Light (5 presets), Gamma sliders

---

## 🎯 Key Features Overview

### Dynamic Island (32 Sections)
| Section | Config Key | Description |
|---------|------------|-------------|
| AI Usage | `showAiUsage` | 5 providers: Claude, Codex, OMP, Otto, Local LLMs |
| System Stats | `showSystemStats` | CPU, RAM, Battery, Network |
| Weather | `showWeather` | Current + 12h + 7-day |
| Calendar | `showCalendar` | Interactive month grid |
| World Clock | `showWorldClock` | Timezone clocks |
| Media | `showMedia` | Full MPRIS controls |
| Visualizer | `showVisualizer` | 4 styles (bars/dots/wave/mirror) |
| Notifications | `showNotifications` | Dismissible list |
| Clipboard | `showClipboard` | Searchable + favorites (star) |
| Active Window | `showActiveWindow` | Title, controls, info |
| Todo | `showTodo` | Tasks with done/pending |
| Notes | `showNotes` | Persistent notes |
| Translator | `showTranslator` | 6 engines, 100+ languages |
| SongRec | `showSongRec` | Music recognition (Super+P) |
| ...and 18 more | | |

### Project Display Flyout (Super+P)
- **Display Tab:** 4 modes (PC Only, Mirror, Extend, Second Screen)
- **Audio Tab:** Output/Input devices, volume, default device
- **Brightness/Color:** Slider, Night Light (5 presets), Gamma sliders

### AI Providers (5 Total)
| Provider | Config | Data Source |
|----------|--------|-------------|
| Claude Code | `claudeEnabled` | `~/.claude` transcripts |
| Codex | `codexEnabled` | `~/.codex` API |
| Oh My Pi | `ompEnabled` | `~/.omp` + `~/.pi` transcripts |
| Otto | `ottoEnabled` | WebSocket to daemon (localhost:6868) |
| Local LLMs | `localLLMEnabled` | Ollama/LM Studio/vLLM/Text-gen-webui |

### Clipboard Favorites
- Star icon to favorite entries
- Persists in `~/.cache/cliphist/fav.db` (SQLite)
- Legacy pin system preserved

### Project Display (Super+P)
- **Display Tab:** PC Only / Mirror / Extend / Second Screen
- **Audio Tab:** Output/Input devices, volume, default device
- **Brightness/Color:** Slider, Night Light (5 presets), Gamma sliders

---

## 🔧 Troubleshooting

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

# Test Otto
curl http://localhost:6868/health

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

### AI Providers Not Updating
```bash
# Check OMP
omp agent ls --json

# Check Otto daemon
curl -s http://localhost:6868/health

# Check Ollama
curl http://localhost:11434/api/tags | jq '.models[].name'
```

### Clipboard Favorites Not Working
```bash
# Check database
sqlite3 ~/.cache/cliphist/fav.db "SELECT * FROM favorites;"

# Re-initialize
rm ~/.cache/cliphist/fav.db
# Restart quickshell
```

---

## 🔄 Recovery Procedures

### If Something Breaks Badly
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
# Remove all configs
rm -rf ~/.config/quickshell ~/.config/illogical-impulse

# Re-clone
cd ~/.config/quickshell
git clone https://github.com/Wester4253/end4-pC-add-features.git end4-pC
cd end4-pC
git checkout v1.0-dynamic-island-overhaul
```

### OMP-Specific Recovery
```bash
# If OMP update broke things
omp doctor
omp update --force

# Or reinstall OMP
curl -fsSL https://raw.githubusercontent.com/oh-my-pi/omp/main/install.sh | bash
omp login
```

---

## 📝 Configuration Reference

### Main Config File
`~/.config/illogical-impulse/config.json`

Key sections:
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
    },
    "aiUsage": {
      "claudeEnabled": true,
      "codexEnabled": false,
      "ompEnabled": true,
      "ottoEnabled": true,
      "localLLMEnabled": true,
      "ollamaHost": "",
      "lmstudioHost": "",
      "vllmHost": "",
      "textgenHost": "",
      "ottoHost": "",
      "ottoPassword": "",
      "updateInterval": 60
    }
  }
}
```

---

## 🔐 Security Notes

- **Otto Password:** Never commit `ottoPassword` to git. Set via Settings UI only.
- **API Keys:** Never commit API keys. Use `/key YOUR_KEY` in AI chat.
- **Otto Daemon:** Only expose port 6868 on trusted networks (LAN/VPN).
- **Ollama/LM Studio:** Bind to localhost only unless on trusted network.

---

## 📚 Additional Resources

- **Repository:** https://github.com/Wester4253/end4-pC-add-features
- **Upstream (illogical-impulse):** https://github.com/end-4/dots-hyprland
- **OMP Docs:** https://github.com/oh-my-pi/omp
- **Otto Docs:** https://github.com/otto-code/otto
- **Quickshell Docs:** https://quickshell.org

---

## 📞 Support

If you encounter issues:
1. Check this guide's troubleshooting section
2. Check the repo issues: https://github.com/Wester4253/end4-pC-add-features/issues
3. Check upstream: https://github.com/end-4/dots-hyprland/issues
4. Create an issue with logs and steps to reproduce

---

**Last Updated:** 2025-11-18  
**Compatible With:** end4-pC-add-features `v1.0-dynamic-island-overhaul`  
**Tested On:** Arch Linux + Hyprland + Quickshell + NVIDIA RTX 3080