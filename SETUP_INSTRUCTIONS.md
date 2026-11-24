# Otto Host Pair Setup — Agent Instructions

You are setting up end4-pC features on the user's machine. Follow these instructions interactively: ask the user the questions below, then execute the steps based on their answers.

## Overview

Two branches exist:
- **`main`** — Shared fixes: restored `GlobalStates.qml`, `Config.qml` additions (`ottoHostPair` block), `BarConfig.qml` Project Display settings, `Cliphist.qml` reconstruction, all 28 DiExpanded QML section component fixes.
- **`otto-host-pair`** — Everything on `main` **plus** Otto-specific features:
  - `plugins/otto-host-pair/` — Otto plugin (Paseo API v0.8.0) with RPCs for Tailscale status/pairing, Otto daemon status, agent/session status, system usage, desktop app links (`otto://`)
  - `services/OttoHostPair.qml` — QML singleton reading plugin summary + tailscale/daemon/system data
  - `modules/ii/settings/pages/OttoHostPairConfig.qml` — Settings tab showing agent/session status, system usage, connection status, desktop app link
  - `services/SettingsPages.qml` — registers the "Otto" settings page

## Step 1: Ask the user these questions

Ask all of these before doing anything:

1. **Branch:** "Which branch do you want to install from? (1) main — shared fixes only, (2) otto-host-pair — everything including Otto Host Pair plugin and agent status"
2. **Repo location:** "Where is your end4-pC Quickshell config? (default: ~/.config/quickshell/end4-pC, or enter a custom path)"
3. **Otto plugin:** "Install the Otto Host Pair plugin into the Otto daemon? (yes/no, default yes)"
4. **Desktop app link:** "Add Otto Desktop App (otto://) link to settings? (yes/no, default yes)"

## Step 2: Execute based on answers

### A. Prepare the repo
1. If the repo directory doesn't exist or isn't a git repo:
   - `git clone https://github.com/Wester4253/end4-pC-add-features.git <path>`
2. `cd <path>`
3. `git fetch --all --prune`
4. Checkout the chosen branch:
   - `git checkout <branch>` (if it exists locally)
   - or `git checkout -b <branch> origin/<branch>` (if remote only)
5. `git pull --ff-only`

### B. Copy files into the active Quickshell config
Copy these from the repo into `~/.config/quickshell/` (or the user's active Quickshell config path):

- `GlobalStates.qml`
- `modules/common/Config.qml`
- `modules/ii/settings/pages/BarConfig.qml`
- `modules/ii/settings/pages/OttoHostPairConfig.qml` (only if otto-host-pair branch)
- `services/Cliphist.qml`
- `services/SettingsPages.qml`
- `services/OttoHostPair.qml` (only if otto-host-pair branch)
- `plugins/otto-host-pair/` (entire directory, only if otto-host-pair branch)

### C. Register the Otto plugin (only if user said yes)
1. `mkdir -p ~/.otto/plugins`
2. `cp -r <repo>/plugins/otto-host-pair ~/.otto/plugins/otto-host-pair`
3. Try to reload Otto: `otto plugin reload otto-host-pair` or `systemctl --user restart otto`
4. If neither works, warn the user to restart Otto manually

### D. Restart Quickshell
```
export WAYLAND_DISPLAY=wayland-1
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORM=wayland
export HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/1000/hypr/)
pkill -9 qs
sleep 1
qs -c end4-pC > /dev/null 2>&1 & disown
```

## Step 3: Verify
Ask the user to confirm:
1. Settings app opens without QML syntax errors
2. Settings app has an "Otto" tab (icon: device_hub)
3. Otto settings → Connection Status shows Tailscale and Otto daemon state
4. Otto settings → Agent Status shows agent counts
5. Otto settings → Otto Desktop App has an `otto://` link button

## Step 4: Rollback (if something breaks)
```
cp -r ~/.config/quickshell.backup.* ~/.config/quickshell/
rm -rf ~/.otto/plugins/otto-host-pair
systemctl --user restart otto
pkill -9 qs
qs -c end4-pC
```

## Important notes
- The plugin requires Otto daemon v0.9.35+ with `pluginsEnabled: true`
- Tailscale must be installed and running for pairing features
- The `otto-host-pair` branch is Otto-specific and should NOT be pushed to the upstream repo
- The `main` branch is safe for upstream syncing
