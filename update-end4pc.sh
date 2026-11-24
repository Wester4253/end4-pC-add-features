#!/usr/bin/env bash
# end4-pC Dynamic Island - Update Script
# Run with: curl -fsSL https://raw.githubusercontent.com/Wester4253/end4-pC-add-features/main/update-end4pc.sh | bash
# Or: bash <(curl -fsSL https://raw.githubusercontent.com/Wester4253/end4-pC-add-features/main/update-end4pc.sh)

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Config
REPO_URL="https://github.com/Wester4253/end4-pC-add-features.git"
REPO_BRANCH="main"
CONFIG_DIR="$HOME/.config/quickshell"
REPO_DIR="$CONFIG_DIR/end4-pC"
BACKUP_DIR="$CONFIG_DIR/backups/update-$(date +%Y%m%d-%H%M%S)"

# Helper functions
log() { echo -e "${BLUE}[INFO]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
step() { echo -e "\n${CYAN}▶${NC} $*"; }

# Check not root
if [[ $EUID -eq 0 ]]; then
    error "Do not run as root. Run as your user."
    exit 1
fi

# Detect shell
CURRENT_SHELL=$(basename "$SHELL")
log "Detected shell: $CURRENT_SHELL"

# Check dependencies
step "Checking dependencies..."
for cmd in git qs hyprctl; do
    if ! command -v "$cmd" &> /dev/null; then
        error "'$cmd' not found. Install: git quickshell hyprland"
        exit 1
    fi
done
success "All dependencies found"

# Backup existing config
step "Backing up existing configuration..."
mkdir -p "$BACKUP_DIR"
if [[ -d "$CONFIG_DIR" ]]; then
    cp -r "$CONFIG_DIR" "$BACKUP_DIR/quickshell" 2>/dev/null || true
    log "Backed up quickshell to $BACKUP_DIR/quickshell"
fi
if [[ -d "$HOME/.config/hypr" ]]; then
    cp -r "$HOME/.config/hypr" "$BACKUP_DIR/hypr" 2>/dev/null || true
    log "Backed up hyprland to $BACKUP_DIR/hypr"
fi
success "Backups saved to $BACKUP_DIR"

# Clone/update repository
step "Updating end4-pC repository..."
mkdir -p "$(dirname "$REPO_DIR")"
if [[ -d "$REPO_DIR/.git" ]]; then
    log "Repository exists, pulling latest changes..."
    cd "$REPO_DIR"
    git fetch origin
    git reset --hard "origin/$REPO_BRANCH"
    git clean -fd
else
    log "Cloning fresh repository..."
    rm -rf "$REPO_DIR"
    git clone --branch "$REPO_BRANCH" "$REPO_URL" "$REPO_DIR"
    cd "$REPO_DIR"
fi
success "Repository updated at $REPO_DIR"

# Deploy quickshell config
step "Deploying quickshell configuration..."
# The repo contains the quickshell config directly
rsync -a --delete \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='*.md' \
    --exclude='*.sh' \
    --exclude='LICENSE' \
    --exclude='screenshots' \
    --exclude='.qmlformat.ini' \
    "$REPO_DIR/" "$CONFIG_DIR/"

# Ensure scripts are executable
find "$CONFIG_DIR/scripts" -name "*.py" -exec chmod +x {} \; 2>/dev/null || true
find "$CONFIG_DIR/scripts" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
success "Quickshell config deployed to $CONFIG_DIR"

# Update Hyprland config if needed
step "Checking Hyprland configuration..."
HYPR_DIR="$HOME/.config/hypr"
mkdir -p "$HYPR_DIR/hyprland"

# Create minimal hyprland.conf if missing
if [[ ! -f "$HYPR_DIR/hyprland.conf" ]]; then
    log "Creating minimal hyprland.conf..."
    cat > "$HYPR_DIR/hyprland.conf" << 'HYPRCONF'
# end4-pC Hyprland Config
monitor=,preferred,auto,auto

input {
    kb_layout = us
    follow_mouse = 1
    touchpad { natural_scroll = false; tap_to_click = true; }
}

general {
    gaps_in = 5; gaps_out = 10; border_size = 2
    col.active_border = rgba(898989ee)
    col.inactive_border = rgba(313131ee)
    layout = dwindle
}

decoration {
    rounding = 12
    blur { enabled = true; size = 8; passes = 3; }
    drop_shadow = true; shadow_range = 15
}

animations { enabled = yes; bezier = easeOutExpo; speed = 1; }

env = QT_QPA_PLATFORM,wayland
env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
env = GDK_BACKEND,wayland,x11
env = SDL_VIDEODRIVER,wayland

source = ~/.config/hypr/hyprland/keybinds.conf
source = ~/.config/hypr/hyprland/windowrules.conf
source = ~/.config/hypr/hyprland/monitors.conf
source = ~/.config/hypr/hyprland/autostart.conf
HYPRCONF
fi

# Create keybinds.conf if missing
if [[ ! -f "$HYPR_DIR/hyprland/keybinds.conf" ]]; then
    cat > "$HYPR_DIR/hyprland/keybinds.conf" << 'KEYCONF'
$mainMod = SUPER
bind = $mainMod, Return, exec, foot
bind = $mainMod, space, exec, qs -t overview
bind = $mainMod SHIFT, Q, killactive
bind = $mainMod, h, movefocus, l
bind = $mainMod, j, movefocus, d
bind = $mainMod, k, movefocus, u
bind = $mainMod, l, movefocus, r
bind = $mainMod SHIFT, h, movewindow, l
bind = $mainMod SHIFT, j, movewindow, d
bind = $mainMod SHIFT, k, movewindow, u
bind = $mainMod SHIFT, l, movewindow, r
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10
bind = $mainMod, S, togglespecialworkspace, magic
bind = $mainMod SHIFT, S, movetoworkspace, special:magic
bind = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bind = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bind = , XF86MonBrightnessUp, exec, brightnessctl set 5%+
bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%-
bind = $mainMod SHIFT, R, reload
bind = $mainMod SHIFT, E, exec, hyprctl dispatch exit
KEYCONF
fi

# Create monitors.conf if missing
if [[ ! -f "$HYPR_DIR/hyprland/monitors.conf" ]]; then
    cat > "$HYPR_DIR/hyprland/monitors.conf" << 'MONCONF'
# Monitor configuration - auto-detect
MONCONF
fi

# Create windowrules.conf if missing
if [[ ! -f "$HYPR_DIR/hyprland/windowrules.conf" ]]; then
    cat > "$HYPR_DIR/hyprland/windowrules.conf" << 'WINCONF'
windowrulev2 = float, class:^(pavucontrol|nm-connection-editor|blueman-manager)$
windowrulev2 = float, class:^(org.gnome.Calculator|gnome-calculator)$
windowrulev2 = noblur, class:^(kitty|foot|alacritty)$
WINCONF
fi

# Create autostart.conf with quickshell
if [[ ! -f "$HYPR_DIR/hyprland/autostart.conf" ]]; then
    cat > "$HYPR_DIR/hyprland/autostart.conf" << 'AUTOCONF'
exec-once = waybar &
exec-once = hypridle &
exec-once = hyprpaper &
exec-once = qs -c end4-pC
AUTOCONF
fi

# Create variables.lua for quickshell
cat > "$HYPR_DIR/hyprland/variables.lua" << 'VARS'
hl.env("qsConfig", "end4-pC")
VARS

success "Hyprland config files ready"

# Install Otto Host Pair plugin if not present
step "Installing Otto Host Pair plugin..."
PLUGIN_DIR="$CONFIG_DIR/plugins/otto-host-pair"
if [[ -d "$PLUGIN_DIR" ]]; then
    cd "$PLUGIN_DIR"
    if [[ -f "package.json" ]]; then
        log "Building Otto Host Pair plugin..."
        npm install --production 2>/dev/null || warn "npm install failed, plugin may need manual build"
        npm run build 2>/dev/null || warn "build failed, plugin may need manual build"
    fi
fi

# Restart quickshell
step "Restarting Quickshell..."
log "Stopping existing quickshell..."
killall qs 2>/dev/null || true
sleep 1

log "Starting quickshell with end4-pC config..."
qs -c end4-pC > /dev/null 2>&1 & disown
sleep 2

# Verify
if pgrep -f "qs -c end4-pC" > /dev/null; then
    success "Quickshell is running with end4-pC config"
else
    warn "Quickshell may not have started. Run 'qs -c end4-pC' manually to debug."
fi

# Summary
echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  ✅ UPDATE COMPLETE!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "What was updated:"
echo "  ✅ Quickshell config (Dynamic Island v2 with 6 styles)"
echo "  ✅ Profile Manager (switch between dotfile configs)"
echo "  ✅ Otto Host Pair (one-click Tailscale pairing)"
echo "  ✅ Clipboard Favorites (SQLite-backed)"
echo "  ✅ Visualizer styles: Bars, Dots, Wave, Mirror"
echo "  ✅ All Python backends (AI, clipboard, search, profiles)"
echo "  ✅ Hyprland config (if missing)"
echo ""
echo "New Features:"
echo "  🎨 6 Dynamic Island styles (Default, Solid Black, Themed, Glass, Notch, Minimal)"
echo "  📦 Profile Manager - switch complete dotfile setups from Settings"
echo "  🔗 Otto Host Pair - pair with laptop over Tailscale in one click"
echo "  ⭐ Clipboard Favorites - star entries, filter, search"
echo ""
echo "Next steps:"
echo "  1. Press SUPER+SPACE for overview"
echo "  2. Open Settings → Profiles tab to manage dotfile configs"
echo "  3. Open Settings → Bar → Dynamic Island to choose island style"
echo "  4. Enable Otto Host Pair in Settings → Otto Host Pair"
echo "  5. Click Dynamic Island → Otto Host Pair section to pair devices"
echo ""
echo "Recovery: cp -r $BACKUP_DIR/quickshell $CONFIG_DIR"
echo ""
success "Update complete! 🎉"