#!/bin/bash
# Fresh Install Script for end4-pC Dynamic Island Overhaul
# Run this to completely replace your broken qs config with the working version

set -euo pipefail

REPO_URL="https://github.com/Wester4253/end4-pC-add-features.git"
REPO_DIR="$HOME/.config/quickshell/end4-pC"
STABLE_TAG="v1.0-dynamic-island-overhaul"
QS_CONFIG_NAME="end4-pC"
HYPR_VARS="$HOME/.config/hypr/hyprland/variables.lua"

echo "========================================="
echo "  end4-pC Fresh Install Script"
echo "  Replaces broken qs config with stable version"
echo "========================================="
echo ""

# Check if running as root (should not)
if [[ $EUID -eq 0 ]]; then
    echo "ERROR: Do not run as root. Run as your user."
    exit 1
fi

# Check dependencies
for cmd in git qs hyprctl; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "ERROR: '$cmd' not found. Install required packages first."
        exit 1
    fi
done

echo "Step 1: Backup current configs..."
BACKUP_DIR="$HOME/.config/quickshell.backup.$(date +%Y%m%d_%H%M%S)"
if [[ -d "$HOME/.config/quickshell" ]]; then
    echo "  Backing up ~/.config/quickshell to $BACKUP_DIR"
    cp -r "$HOME/.config/quickshell" "$BACKUP_DIR"
    echo "  Backing up ~/.config/hypr"
    cp -r "$HOME/.config/hypr" "$HOME/.config/hypr.backup.$(date +%Y%m%d_%H%M%S)"
else
    echo "  No existing quickshell config found"
fi

echo ""
echo "Step 2: Clone fresh repository..."
rm -rf "$REPO_DIR"
mkdir -p "$(dirname "$REPO_DIR")"
cd "$(dirname "$REPO_DIR")"
git clone "$REPO_URL" "$(basename "$REPO_DIR")"

cd "$REPO_DIR"

echo ""
echo "Step 3: Checkout stable tag (v1.0-dynamic-island-overhaul)..."
git checkout v1.0-dynamic-island-overhaul

echo ""
echo "Step 4: Set as default quickshell config..."
# Update hyprland variables.lua
if [[ -f "$HYPR_VARS" ]]; then
    # Backup original
    cp "$HYPR_VARS" "$HYPR_VARS.bak.$(date +%Y%m%d_%H%M%S)"
    
    # Update or add qsConfig line
    if grep -q 'qsConfig' "$HYPR_VARS"; then
        sed -i "s|qsConfig.*|qsConfig = \"end4-pC\"|" "$HYPR_VARS"
    else
        echo 'hl.env("qsConfig", "end4-pC")' >> "$HYPR_VARS"
    fi
    echo "  Updated $HYPR_VARS"
else
    echo "WARNING: $HYPR_VARS not found. You may need to manually set qsConfig."
fi

echo ""
echo "Step 5: Kill existing quickshell and restart..."
killall qs 2>/dev/null || true
sleep 1

echo ""
echo "Step 6: Start fresh quickshell..."
# Start in background, detached
qs -c end4-pC > /dev/null 2>&1 & disown

sleep 2

# Verify it's running
if pgrep -f "qs -c end4-pC" > /dev/null; then
    echo ""
    echo "========================================="
    echo "  ✅ INSTALLATION COMPLETE!"
    echo "========================================="
    echo ""
    echo "The stable version (v1.0-dynamic-island-overhaul) is now running."
    echo ""
    echo "If something goes wrong, you can recover with:"
    echo "  cp -r ~/.config/quickshell.backup.* ~/.config/quickshell"
    echo "  cp -r ~/.config/hypr.backup.* ~/.config/hypr"
    echo ""
    echo "Enjoy your fixed Dynamic Island! 🎉"
else
    echo ""
    echo "ERROR: quickshell failed to start. Check logs:"
    echo "  journalctl -u quickshell -f"
    echo "  or run: qs -c end4-pC"
    exit 1
fi