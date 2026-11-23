#!/bin/bash
# Complete Fresh Install for end4-pC Dynamic Island
# Run this on a fresh system to get a fully working end4-pC setup
# Works in fish, bash, zsh

set -euo pipefail

REPO_URL="https://github.com/Wester4253/end4-pC-add-features.git"
REPO_DIR="$HOME/.config/quickshell/end4-pC"
STABLE_TAG="v1.0-dynamic-island-overhaul"
QS_CONFIG_NAME="end4-pC"
HYPR_DIR="$HOME/.config/hypr"
QS_DIR="$HOME/.config/quickshell"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }

# Check not root
if [[ $EUID -eq 0 ]]; then
    error "Do not run as root. Run as your user."
    exit 1
fi

# Check shell
CURRENT_SHELL=$(basename "$SHELL")
log "Detected shell: $CURRENT_SHELL"

# Check dependencies
for cmd in git qs hyprctl; do
    if ! command -v "$cmd" &> /dev/null; then
        error "'$cmd' not found. Install: git quickshell hyprland"
        exit 1
    fi
done

success "All dependencies found"

# Step 1: Backup existing configs
log "Backing up existing configs..."
BACKUP_DIR="$HOME/.config/backup.$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
[[ -d "$HOME/.config/quickshell" ]] && cp -r "$HOME/.config/quickshell" "$BACKUP_DIR/quickshell" && log "Backed up quickshell"
[[ -d "$HOME/.config/hypr" ]] && cp -r "$HOME/.config/hypr" "$BACKUP_DIR/hypr" && log "Backed up hyprland"
success "Backups saved to $BACKUP_DIR"

# Step 2: Clone fresh repo
log "Cloning end4-pC repository..."
rm -rf "$REPO_DIR"
mkdir -p "$(dirname "$REPO_DIR")"
cd "$(dirname "$REPO_DIR")"
git clone "https://github.com/Wester4253/end4-pC-add-features.git" "$(basename "$REPO_DIR")"
cd "$REPO_DIR"
git checkout v1.0-dynamic-island-overhaul
success "Repository ready at $REPO_DIR"

# Step 3: Deploy quickshell config
log "Deploying quickshell config (end4-pC)..."
rm -rf "$QS_DIR"
mkdir -p "$QS_DIR"
cp -r "$REPO_DIR"/* "$QS_DIR/"
success "Quickshell config deployed to $QS_DIR"

# Step 4: Create minimal hyprland config if missing
log "Setting up Hyprland config..."
mkdir -p "$HYPR_DIR"

# Create minimal hyprland.conf if missing
if [[ ! -f "$HYPR_DIR/hyprland.conf" ]]; then
    cat > "$HYPR_DIR/hyprland.conf" << 'HYPRCONF'
# end4-pC Hyprland Config - Minimal working config
# Source: https://github.com/end-4/dots-hyprland (illogical-impulse)

# Monitor - will be auto-detected, but provide fallback
monitor=,preferred,auto,auto

# Input
input {
    kb_layout = us
    kb_variant = 
    kb_options = grp:alt_shift_toggle
    kb_model = 
    follow_mouse = 1
    touchpad {
        natural_scroll = false
        tap_to_click = true
    }
}

# General
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(898989ee)
    col.inactive_border = rgba(313131ee)
    resize_on_border = true
    allow_tearing = false
    layout = dwindle
}

# Decoration
decoration {
    rounding = 12
    blur {
        enabled = true
        size = 8
        passes = 3
    }
    drop_shadow = true
    shadow_range = 15
    shadow_render_power = 3
    shadow_offset = 0 3
}

# Animations
animations {
    enabled = yes
    bezier = easeOutExpo
    speed = 1
}

# Input
input {
    sensitivity = 0.5
    accel_profile = flat
}

# Misc
misc {
    vfr = true
    cursor_inactive_timeout = 0
}

# Environment variables
env = XCURSOR_SIZE,24
env = XCURSOR_THEME,bibata-modern-ice
env = QT_QPA_PLATFORM,wayland
env = QT_QPA_PLATFORMTHEME,qt6ct
env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
env = QT_AUTO_SCREEN_SCALE_FACTOR,1
env = GDK_BACKEND,wayland,x11
env = SDL_VIDEODRIVER,wayland
env = MOZ_ENABLE_WAYLAND,1
env = CLUTTER_BACKEND,wayland
env = ELECTRON_OZONE_PLATFORM_HINT,auto
env = _JAVA_AWT_WM_NONREPARENTING,1

# NVIDIA
env = LIBVA_DRIVER_NAME,nvidia
env = VDPAU_DRIVER,nvidia
env = NVD_BACKEND,direct
env = __GL_GSYNC_ALLOWED,1
env = __GL_VRR_ALLOWED,1
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia

# Source additional configs
source = ~/.config/hypr/hyprland/keybinds.conf
source = ~/.config/hypr/hyprland/windowrules.conf
source = ~/.config/hypr/hyprland/monitors.conf
source = ~/.config/hypr/hyprland/autostart.conf

# Keybinds placeholder - will be created below
HYPRCONF
    success "Created minimal hyprland.conf"
fi

# Create minimal keybinds.conf if missing
if [[ ! -f "$HOME/.config/hypr/hyprland/keybinds.conf" ]]; then
    mkdir -p "$HOME/.config/hypr/hyprland"
    cat > "$HOME/.config/hypr/hyprland/keybinds.conf" << 'KEYCONF'
# Minimal keybinds for end4-pC
$mainMod = SUPER

# Terminal
bind = $mainMod, Return, exec, foot
bind = $mainMod SHIFT, Return, exec, foot -e tmux

# App launcher
bind = $mainMod, space, exec, qs -t overview

# Close window
bind = $mainMod SHIFT, Q, killactive

# Move focus
bind = $mainMod, h, movefocus, l
bind = $mainMod, j, movefocus, d
bind = $mainMod, k, movefocus, u
bind = $mainMod, l, movefocus, r

# Move windows
bind = $mainMod SHIFT, h, movewindow, l
bind = $mainMod SHIFT, j, movewindow, d
bind = $mainMod SHIFT, k, movewindow, u
bind = $mainMod SHIFT, l, movewindow, r

# Workspaces
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Move to workspace
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 3
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# Special workspace (scratchpad)
bind = $mainMod, S, togglespecialworkspace, magic
bind = $mainMod SHIFT, S, movetoworkspace, special:magic

# Screenshots
bind = PRINT, exec, grim -g "$(slurp)" - | wl-copy
bind = SHIFT, PRINT, exec, grim - | wl-copy

# Volume
bind = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bind = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

# Brightness
bind = , XF86MonBrightnessUp, exec, brightnessctl set 5%+
bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%-

# Reload
bind = $mainMod SHIFT, R, reload

# Exit
bind = $mainMod SHIFT, E, exec, hyprctl dispatch exit
KEYCONF
    success "Created keybinds.conf"
fi

# Create minimal monitors.conf if missing
if [[ ! -f "$HOME/.config/hypr/hyprland/monitors.conf" ]]; then
    cat > "$HOME/.config/hypr/hyprland/monitors.conf" << 'MONCONF'
# Monitor configuration - auto-detect
# This will be overridden by hyprland's auto-detection
# Add manual configs here if needed
# monitor=HDMI-A-1,preferred,auto,1
# monitor=eDP-1,preferred,auto,1
MONCONF
fi

# Create minimal windowrules.conf if missing
if [[ ! -f "$HOME/.config/hypr/hyprland/windowrules.conf" ]]; then
    cat > "$HOME/.config/hypr/hyprland/windowrules.conf" << 'WINCONF'
# Window rules
windowrulev2 = float, class:^(pavucontrol|nm-connection-editor|blueman-manager)$
windowrulev2 = float, class:^(org.gnome.Calculator|gnome-calculator)$
windowrulev2 = float, title:^(Picture-in-Picture)$
windowrulev2 = noblur, class:^(kitty|foot|alacritty)$
WINCONF
fi

# Create minimal autostart.conf if missing
if [[ ! -f "$HOME/.config/hypr/hyprland/autostart.conf" ]]; then
    cat > "$HOME/.config/hypr/hyprland/autostart.conf" << 'AUTOCONF'
# Autostart applications
exec-once = waybar &
exec-once = hypridle &
exec-once = hyprpaper &
# Start quickshell with end4-pC config
exec-once = qs -c end4-pC
AUTOCONF
fi

success "Hyprland config files created"

# Step: Create variables.lua for quickshell
log "Setting up variables.lua for quickshell..."
HYPR_VARS="$HOME/.config/hypr/hyprland/variables.lua"
mkdir -p "$(dirname "$HYPR_VARS")"

cat > "$HYPR_VARS" << 'VARS'
--[[
	Variables file for end4-pC configuration
	This file is managed by the install script - do not edit manually unless you know what you're doing
]]

-- Quickshell configuration name
hl.env("qsConfig", "end4-pC")

-- Hyprland general settings
hl.config({
	monitor = {
		preferred = "auto",
		fallback = "1920x1080@60",
	},
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_options = "grp:alt_shift_toggle",
		kb_model = "",
		follow_mouse = 1,
		touchpad = {
			natural_scroll = false,
			tap_to_click = true,
			drag_lock = false,
			disable_while_typing = true,
		},
	},
	general = {
		gaps_in = 5,
		gaps_out = 10,
		border_size = 2,
		col_active_border = "rgba(898989ee)",
		col_inactive_border = "rgba(313131ee)",
		resize_on_border = true,
		allow_tearing = false,
		layout = "dwindle",
		no_focus_fallback = true,
		focus_on_activate = true,
	},
	decoration = {
		rounding = 12,
		blur = { enabled = true, size = 8, passes = 3, new_optimizations = true },
		drop_shadow = true,
		shadow_range = 15,
		shadow_render_power = 3,
		shadow_offset = { 0, 3 },
	},
	animations = { enabled = true, bezier = "easeOutExpo", speed = 1.0 },
	gestures = { enabled = true, workspace_swipe = true, fingers = 3 },
	input = { sensitivity = 0.5, accel_profile = "flat" },
	misc = { vfr = true, cursor_inactive_timeout = 0, allow_session_lock_restore = true },
})
VARS

success "Created variables.lua"

# Step: Deploy quickshell config
log "Deploying quickshell config (end4-pC)..."
QS_DIR="$HOME/.config/quickshell"
REPO_DIR="$HOME/.config/quickshell/end4-pC"
rm -rf "$REPO_DIR"
mkdir -p "$(dirname "$REPO_DIR")"
cd "$(dirname "$REPO_DIR")"
git clone "https://github.com/Wester4253/end4-pC-add-features.git" "end4-pC"
cd "$HOME/.config/quickshell/end4-pC"
git checkout v1.0-dynamic-island-overhaul 2>/dev/null || git checkout feat/dynamic-island-overhaul

# Copy to quickshell config dir
rm -rf "$QS_DIR/end4-pC"
cp -r "$HOME/.config/quickshell/end4-pC" "$QS_DIR/"
success "Quickshell config deployed"

# Create variables.lua for quickshell
mkdir -p "$HOME/.config/hypr/hyprland"
cat > "$HOME/.config/hypr/hyprland/variables.lua" << 'VARS'
hl.env("qsConfig", "end4-pC")
VARS

# Step: Kill and restart quickshell
log "Restarting quickshell..."
killall qs 2>/dev/null || true
sleep 1
qs -c end4-pC > /dev/null 2>&1 & disown
sleep 2

# Verify
if pgrep -f "qs -c end4-pC" > /dev/null; then
    success "quickshell is running with end4-pC config"
else
    warn "quickshell may not have started. Run 'qs -c end4-pC' manually to debug."
fi

echo ""
echo "========================================="
echo "  ✅ INSTALLATION COMPLETE!"
echo "========================================="
echo ""
echo "What was installed:"
echo "  ✅ Hyprland config (~/.config/hypr/hyprland/)"
echo "  ✅ Quickshell end4-pC config (~/.config/quickshell/end4-pC/)"
echo "  ✅ Variables.lua pointing to end4-pC"
echo "  ✅ Autostart configured"
echo ""
echo "Next steps:"
echo "  1. Log out and back in (or reboot) to start Hyprland"
echo "  2. Press SUPER+SPACE for overview"
echo "  3. Press SUPER+P for Project Display"
echo "  4. Check ~/.config/hypr/hyprland/ for customization"
echo ""
echo "Recovery: cp -r ~/.config/quickshell.backup.* ~/.config/quickshell"
echo ""
success "Installation complete! 🎉"