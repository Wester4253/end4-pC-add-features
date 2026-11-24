# Install New Features — end4-pC

Practical guide for merging the new features (Otto Host Pair plugin, improved settings, gap fixes) over an existing end4-pC installation. Designed to be read by an OMP agent.

## Prerequisites

- Repo cloned at `~/.config/quickshell/end4-pC` (or your Quickshell config dir)
- **`main` branch** — shared fixes (settings, gap fixes, Dynamic Island planning)
- **`otto-host-pair` branch** — Otto-specific features (plugin, agent status, desktop service)
- Otto daemon running (`otto` v0.9.35+, `pluginsEnabled: true`)
- Tailscale installed and running (`tailscaled` active)


---

## Option 1: Merge Over Existing Dots (Recommended)

Apply the changed QML files on top of your existing config without nuking everything.

### 1. Sync the repo

```bash
cd ~/.config/quickshell/end4-pC
git checkout main
git pull --all --prune
```

### 2. Copy changed QML files into your active Quickshell config

If your active config is a separate clone/symlink, copy the modified files:

```bash
# From the repo root
cp GlobalStates.qml \
   modules/common/Config.qml \
   modules/ii/settings/pages/BarConfig.qml \
   modules/ii/settings/pages/OttoHostPairConfig.qml \
   services/Cliphist.qml \
   services/SettingsPages.qml \
   <your-active-quickshell-config>/
```

Copy the entire `plugins/` directory:

```bash
cp -r plugins/ <your-active-quickshell-config>/
```

If your active config **is** this repo (no separate path), you're done — the files are already in place.

### 3. Register the Otto plugin

```bash
cd plugins/otto-host-pair
otto plugin install .
```

Or if the plugin needs to be installed into the Otto daemon's plugin directory:

```bash
# Otto plugins typically live in ~/.otto/plugins/
mkdir -p ~/.otto/plugins
cp -r plugins/otto-host-pair ~/.otto/plugins/
```

Then reload the daemon:

```bash
systemctl --user restart otto
# or
otto plugin reload otto-host-pair
```

### 4. Restart Quickshell

```bash
export WAYLAND_DISPLAY=wayland-1
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORM=wayland
export HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/1000/hypr/)

pkill -9 qs
sleep 1
qs -c end4-pC > /dev/null 2>&1 & disown
```

---

## Option 2: Fresh Clone (Nuclear)

Wipe and re-clone. Only use if your existing config is broken.

```bash
# Backup first
cp -r ~/.config/quickshell ~/.config/quickshell.backup.$(date +%Y%m%d)
cp -r ~/.config/hypr ~/.config/hypr.backup.$(date +%Y%m%d)

# Clean
rm -rf ~/.config/quickshell/end4-pC

# Re-clone
cd ~/.config/quickshell
git clone https://github.com/Wester4253/end4-pC-add-features.git end4-pC
cd end4-pC
git checkout main

# Install plugin
cd plugins/otto-host-pair
otto plugin install .

# Restart
export WAYLAND_DISPLAY=wayland-1
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORM=wayland
export HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/1000/hypr/)
qs -c end4-pC
```

---

## Option 3: OMP Agent Install (What You'd Tell an Agent)

If you're delegating to an OMP agent, give them this:

```
Install the end4-pC new features on this machine:

1. cd ~/.config/quickshell/end4-pC && git checkout main && git pull --all --prune
2. Copy the modified QML files (GlobalStates.qml, modules/common/Config.qml,
   modules/ii/settings/pages/BarConfig.qml, modules/ii/settings/pages/OttoHostPairConfig.qml,
   services/Cliphist.qml, services/SettingsPages.qml) into the active Quickshell config.
3. Copy plugins/otto-host-pair into ~/.otto/plugins/ and run 'otto plugin install otto-host-pair'.
4. Restart Quickshell: pkill -9 qs; qs -c end4-pc
5. Verify: the settings app should have a new "Otto" page, and the Otto Host Pair
   plugin should appear in the Otto web app sidebar.
```

---

## What Gets Installed

| Feature | Where it lives | How to access |
|---------|---------------|---------------|
| Otto Host Pair plugin | `plugins/otto-host-pair/` | Otto web app sidebar → "Otto Host Pair" |
| Otto settings page | `modules/ii/settings/pages/OttoHostPairConfig.qml` | Settings app → "Otto" tab |
| Project Display settings | `modules/ii/settings/pages/BarConfig.qml` | Settings → Bar → Project Display |
| Cliphist fix | `services/Cliphist.qml` | Automatic (clipboard refresh) |
| GlobalStates restore | `GlobalStates.qml` | Automatic |
| Config additions | `modules/common/Config.qml` | Automatic (`ottoHostPair` block) |

---

## Verification

After install:

1. **Settings app opens** without QML syntax errors
2. **Otto tab visible** in settings (icon: device_hub)
3. **Tailscale status** shows in Otto settings → Connection Status
- **Desktop App link** opens `otto://` (Otto desktop app, not web UI)

---

## Rollback

If something breaks:

```bash
# Restore Quickshell config
cp -r ~/.config/quickshell.backup.* ~/.config/quickshell/

# Remove Otto plugin
rm -rf ~/.otto/plugins/otto-host-pair
systemctl --user restart otto

# Restart Quickshell
pkill -9 qs
qs -c end4-pC
```
