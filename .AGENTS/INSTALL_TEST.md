# Installation & Testing Guide

## Quick Install
```bash
cd ~/.config/quickshell
git clone https://github.com/Wester4253/end4-pC-add-features.git end4-pC
cd end4-pC
git checkout v1.0-dynamic-island-overhaul
```

## Config
Edit `~/.config/hypr/hyprland/variables.lua`:
```lua
hl.env("qsConfig", "end4-pC")
```

## Run
```bash
export WAYLAND_DISPLAY=wayland-1
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORM=wayland
export HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/1000/hypr/)
qs -c end4-pC
```

## Verify
- `INFO: Configuration Loaded`
- Bar visible at bottom
- `SUPER+Return` opens kitty
- Dynamic Island pill in bar (middle)
- Click → expanded panel with 28 sections
