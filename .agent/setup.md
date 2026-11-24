# Otto Host Pair Setup — Agent Instructions

This document is the single source of truth for an agent setting up end4-pC features on a user's machine. It covers backup, branch selection, all settings, plugin registration, Quickshell restart, verification, rollback, and context.

## What Gets Installed

### Shared fixes (`main` branch)
- `GlobalStates.qml` — restored from git diff corruption to a valid QML singleton with `projectDisplayOpen`, `dynamicIslandEnabled`, timers, shortcuts
- `modules/common/Config.qml` — adds `ottoHostPair` config block (`enable`, `tailscaleIp`, `paired`, `daemonUrl`)
- `modules/ii/settings/pages/BarConfig.qml` — adds Project Display settings section (8 toggles)
- `services/Cliphist.qml` — reconstructed from git diff corruption into a valid QML singleton with favorites support
- `services/SettingsPages.qml` — registers the "Otto" settings page
- All 28 `DiExpanded*Section.qml` files — converted file-level `Item { id: UppercaseCard }` blocks into `Component { id: lowercaseCard }` inside root `Item`, with lowercase delegate references

### Otto-specific features (`otto-host-pair` branch — everything above PLUS)
- `plugins/otto-host-pair/` — Otto Paseo plugin (API v0.8.0) with RPCs:
  - `tailscale.status` — running, IP, DNS, online
  - `tailscale.fullStatus` — version, exit node, peer list, peer counts
  - `tailscale.peers` — peer array (name, IP, online, last seen)
  - `tailscale.pair` — pair with remote host over Tailscale
  - `otto.daemon.status` — running, version, serverId, hostname, listen
  - `otto.daemon.fullStatus` — uptime, memory, CPU, sessions, agents, providers, feature flags
  - `otto.pair` — link to remote Otto daemon
  - `otto.features` — plugins, relay, voice, brain toggles
  - `otto.system.usage` — CPU%, memory, disk, load, uptime
  - `otto.agent.status` — total/active/failed agents + per-agent details
  - `otto.session.status` — total/active/completed/failed sessions + limits
  - `otto.desktop.link` — returns `otto://` deep link for desktop app
  - `otto.summary` — combined view; writes `/home/otto/.otto/host-pair-summary.json` for QML
- `services/OttoHostPair.qml` — QML singleton reading plugin summary + tailscale/daemon/system data; auto-refreshes every 30s
- `modules/ii/settings/pages/OttoHostPairConfig.qml` — Settings tab: Connection Status, Agent Status, Session Status, Daemon Features, System Usage, Otto Desktop App link (`otto://`)
- `services/SettingsPages.qml` — registers "Otto" settings page (already on main, but ensures otto page)

---

## Prerequisites to Check

Before starting, verify:
- **Otto daemon** v0.9.35+ running with `pluginsEnabled: true` in `/home/otto/.otto/config.json`
- **Tailscale** installed and running (`tailscaled` active, `tailscale status` works)
- **Quickshell** installed (`qs` command available)
- **Git** available with access to `https://github.com/Wester4253/end4-pC-add-features.git`

---

## Step 1: Interactive Questions (Ask Before Doing Anything)

Ask the user these questions and record their answers:

1. **Branch selection:**
   - "(1) main — shared fixes only (settings, gap fixes, Dynamic Island plan)"
   - "(2) otto-host-pair — everything above + Otto Host Pair plugin, agent status, desktop app links"
   - Default: `main`

2. **Repo location:**
   - "Where is your end4-pC Quickshell config? (default: ~/.config/quickshell/end4-pC, or enter custom path)"
   - Default: `~/.config/quickshell/end4-pC`

3. **Otto plugin installation:**
   - "Install the Otto Host Pair plugin into the Otto daemon? (yes/no, default yes)"
   - Only relevant on `otto-host-pair` branch

4. **Otto Desktop App link:**
   - "Add Otto Desktop App (otto://) link to settings? (yes/no, default yes)"
   - Only relevant on `otto-host-pair` branch

5. **Backup confirmation:**
   - "Should I back up your existing Quickshell config first? (yes/no, default yes)"

---

## Step 2: Backup Existing Config

If the user confirmed backup (default yes):

```bash
BACKUP_DIR="$HOME/.config/quickshell.backup.$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r ~/.config/quickshell "$BACKUP_DIR/quickshell" 2>/dev/null || true
cp -r ~/.config/hypr "$BACKUP_DIR/hypr" 2>/dev/null || true
cp -r ~/.config/illogical-impulse "$BACKUP_DIR/illogical-impulse" 2>/dev/null || true
echo "Backup saved to $BACKUP_DIR"
```

If they said no, skip this step but warn them.

---

## Step 3: Prepare the Repo

```bash
REPO_DIR="<user's answer from question 2>"
BRANCH="<user's answer from question 1: main or otto-host-pair>"

# Clone if needed
if [[ ! -d "$REPO_DIR/.git" ]]; then
  mkdir -p "$(dirname "$REPO_DIR")"
  git clone "https://github.com/Wester4253/end4-pC-add-features.git" "$REPO_DIR"
fi

cd "$REPO_DIR"
git fetch --all --prune

# Checkout branch
if git rev-parse --verify "$BRANCH" >/dev/null 2>&1; then
  git checkout "$BRANCH"
else
  git checkout -b "$BRANCH" "origin/$BRANCH" 2>/dev/null || {
    echo "ERROR: Branch $BRANCH not available"
    exit 1
  }
fi

git pull --ff-only
echo "Repo ready on branch $(git branch --show-current)"
```

---

## Step 4: Copy Files into Active Quickshell Config

Copy from the repo into `~/.config/quickshell/` (or wherever the user's active Quickshell config lives):

```bash
DEST="$HOME/.config/quickshell"
mkdir -p "$DEST/modules/common" "$DEST/modules/ii/settings/pages" "$DEST/services"

# Shared fixes (always)
cp "$REPO_DIR/GlobalStates.qml" "$DEST/"
cp "$REPO_DIR/modules/common/Config.qml" "$DEST/modules/common/"
cp "$REPO_DIR/modules/ii/settings/pages/BarConfig.qml" "$DEST/modules/ii/settings/pages/"
cp "$REPO_DIR/services/Cliphist.qml" "$DEST/services/"
cp "$REPO_DIR/services/SettingsPages.qml" "$DEST/services/"

# Otto-specific files (only on otto-host-pair branch)
if [[ "$BRANCH" == "otto-host-pair" ]]; then
  cp "$REPO_DIR/modules/ii/settings/pages/OttoHostPairConfig.qml" "$DEST/modules/ii/settings/pages/"
  cp "$REPO_DIR/services/OttoHostPair.qml" "$DEST/services/"
  cp -r "$REPO_DIR/plugins/otto-host-pair" "$DEST/"
fi
```

---

## Step 5: Register the Otto Plugin

Only if the user said yes to plugin installation AND on `otto-host-pair` branch:

```bash
PLUGIN_DIR="$HOME/.config/quickshell/plugins/otto-host-pair"
mkdir -p "$HOME/.otto/plugins"
cp -r "$PLUGIN_DIR" "$HOME/.otto/plugins/otto-host-pair"

# Try to reload/restart Otto
if command -v otto >/dev/null 2>&1; then
  otto plugin reload otto-host-pair 2>/dev/null || {
    echo "WARNING: otto plugin reload failed; restart Otto manually"
  }
elif systemctl --user is-active --quiet otto 2>/dev/null; then
  systemctl --user restart otto
else
  echo "WARNING: Otto daemon not detected; install plugin manually and restart Otto"
fi
```

---

## Step 6: Restart Quickshell

```bash
export WAYLAND_DISPLAY=wayland-1
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORM=wayland
export HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/1000/hypr/)

pkill -9 qs
sleep 1
qs -c end4-pC > /dev/null 2>&1 & disown
```

Wait a few seconds, then confirm Quickshell started.

---

## Step 7: Verify

Ask the user to confirm each of these:

1. **Settings app opens** without QML syntax errors
2. **Otto tab visible** in settings (icon: device_hub)
3. **Tailscale status** shows in Otto settings → Connection Status
4. **Otto daemon** shows Running or Stopped
5. **Agent Status** shows total/active/failed agent counts
6. **Session Status** shows total/active/completed/failed session counts
7. **Otto Desktop App** has an `otto://` link button (on otto-host-pair branch)

If any fail, proceed to rollback (Step 8).

---

## Step 8: Rollback (If Something Breaks)

```bash
# Restore Quickshell config
cp -r ~/.config/quickshell.backup.* ~/.config/quickshell/

# Remove Otto plugin
rm -rf ~/.otto/plugins/otto-host-pair
systemctl --user restart otto 2>/dev/null || true

# Restart Quickshell
pkill -9 qs
sleep 1
qs -c end4-pC > /dev/null 2>&1 & disown
```

---

## Context for the Agent

- **Repository:** https://github.com/Wester4253/end4-pC-add-features.git
- **Current branch:** `otto-host-pair` (Otto-specific, do NOT push to upstream)
- **Shared branch:** `main` (safe for upstream syncing)
- **Otto daemon config:** `/home/otto/.otto/config.json` (must have `pluginsEnabled: true`)
- **Plugin install location:** `~/.otto/plugins/otto-host-pair/`
- **Pairing state file:** `/home/otto/.otto/host-pair-state.json` (written by plugin)
- **Summary file for QML:** `/home/otto/.otto/host-pair-summary.json` (written by plugin)
- **Runtime environment:** Requires `WAYLAND_DISPLAY`, `XDG_SESSION_TYPE=wayland`, `QT_QPA_PLATFORM=wayland`, `HYPRLAND_INSTANCE_SIGNATURE`
- **Tailscale:** Must be running for pairing features; host IP visible via `tailscale status --json`

## Files Modified by Branch

### `main` (shared):
```
GlobalStates.qml
modules/common/Config.qml
modules/ii/bar/BarContent.qml
modules/ii/bar/DiExpanded.qml
modules/ii/bar/DiExpandedActionsSection.qml
modules/ii/bar/DiExpandedAiSection.qml
modules/ii/bar/DiExpandedBluetoothSection.qml
modules/ii/bar/DiExpandedCalendarSection.qml
modules/ii/bar/DiExpandedFocusSection.qml
modules/ii/bar/DiExpandedNotificationsSection.qml
modules/ii/bar/DiExpandedProcessesSection.qml
modules/ii/bar/DiExpandedProfilesSection.qml
modules/ii/bar/DiExpandedRecordingSection.qml
modules/ii/bar/DiExpandedServicesSection.qml
modules/ii/bar/DiExpandedShortcutsSection.qml
modules/ii/bar/DiExpandedSystemInfoSection.qml
modules/ii/bar/DiExpandedSystemSection.qml
modules/ii/bar/DiExpandedTimerSection.qml
modules/ii/bar/DiExpandedUpdatesSection.qml
modules/ii/bar/DiExpandedVPNSection.qml
modules/ii/bar/DiExpandedWeatherSection.qml
modules/ii/bar/DiExpandedWindowSection.qml
modules/ii/bar/DiExpandedWorldClockSection.qml
modules/ii/settings/pages/BarConfig.qml
services/Cliphist.qml
services/SettingsPages.qml
```

### `otto-host-pair` (Otto-specific, in addition to main):
```
plugins/otto-host-pair/otto-plugin.json
plugins/otto-host-pair/package.json
plugins/otto-host-pair/tsconfig.json
plugins/otto-host-pair/index.server.ts
plugins/otto-host-pair/index.client.tsx
plugins/otto-host-pair/client/web.ts
plugins/otto-host-pair/client/PairSurface.tsx
plugins/otto-host-pair/shared/tailscale.ts
plugins/otto-host-pair/server/tailscale.ts
modules/ii/settings/pages/OttoHostPairConfig.qml
services/OttoHostPair.qml
```

## Rollback Checklist

- [ ] Restore `~/.config/quickshell` from `~/.config/quickshell.backup.*`
- [ ] Remove `~/.otto/plugins/otto-host-pair`
- [ ] Restart Otto daemon: `systemctl --user restart otto`
- [ ] Restart Quickshell: `pkill -9 qs; qs -c end4-pC`
