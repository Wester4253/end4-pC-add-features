#!/usr/bin/env bash
###############################################################################
# Otto Host Pair — Interactive Setup
# Copy-paste this into any agent terminal. It asks what you want and does it.
###############################################################################
set -uo pipefail

# --- Colors ---
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; NC='\033[0m'
info()  { printf "${BLUE}[INFO]${NC} %s\n" "$*"; }
ok()    { printf "${GREEN}[OK]${NC} %s\n" "$*"; }
warn()  { printf "${YELLOW}[WARN]${NC} %s\n" "$*"; }
err()   { printf "${RED}[ERR]${NC} %s\n" "$*" >&2; }

###############################################################################
# Interactive prompts
###############################################################################
echo ""
echo "============================================================"
echo "  Otto Host Pair — Interactive Setup"
echo "============================================================"
echo ""

# Branch choice
echo "Which branch do you want to install from?"
echo "  1) main        — Shared fixes only (settings, gap fixes, Dynamic Island plan)"
echo "  2) otto-host-pair — Everything above + Otto Host Pair plugin & agent status"
echo ""
read -rp "Choice [1-2]: " BRANCH_CHOICE
case "$BRANCH_CHOICE" in
  1) BRANCH="main" ;;
  2) BRANCH="otto-host-pair" ;;
  *) BRANCH="main" ; echo "Invalid choice, defaulting to main." ;;
esac
info "Selected branch: $BRANCH"

# Install location
echo ""
echo "Where is your end4-pC Quickshell config?"
echo "  1) ~/.config/quickshell/end4-pC  (default)"
echo "  2) Custom path"
echo ""
read -rp "Choice [1-2]: " LOC_CHOICE
if [[ "$LOC_CHOICE" == "2" ]]; then
  read -rp "Full path to end4-pC repo: " REPO_DIR
else
  REPO_DIR="$HOME/.config/quickshell/end4-pC"
fi
info "Repo directory: $REPO_DIR"

# Otto plugin install
echo ""
echo "Install the Otto Host Pair plugin into the Otto daemon?"
echo "  1) Yes — copy to ~/.otto/plugins/ and reload daemon (default)"
echo "  2) No — just copy files, skip plugin registration"
echo ""
read -rp "Choice [1-2]: " PLUGIN_CHOICE
INSTALL_PLUGIN=true
[[ "$PLUGIN_CHOICE" == "2" ]] && INSTALL_PLUGIN=false

# Desktop app link
echo ""
echo "Add Otto Desktop App (otto://) link to settings?"
echo "  1) Yes (default)"
echo "  2) No"
echo ""
read -rp "Choice [1-2]: " DESKTOP_CHOICE
INSTALL_DESKTOP=true
[[ "$DESKTOP_CHOICE" == "2" ]] && INSTALL_DESKTOP=false

echo ""
echo "============================================================"
echo "  Summary"
echo "============================================================"
echo "  Branch:        $BRANCH"
echo "  Repo:          $REPO_DIR"
echo "  Install plugin: $INSTALL_PLUGIN"
echo "  Desktop link:   $INSTALL_DESKTOP"
echo ""
read -rp "Proceed with install? [y/N]: " CONFIRM
[[ "$CONFIRM" =~ ^[Yy]$ ]] || { info "Aborted."; exit 0; }

###############################################################################
# Helper: ensure we're on the right branch
###############################################################################
ensure_repo() {
  if [[ ! -d "$REPO_DIR/.git" ]]; then
    err "Not a git repo: $REPO_DIR"
    info "Cloning from GitHub..."
    git clone "https://github.com/Wester4253/end4-pC-add-features.git" "$REPO_DIR" || {
      err "Clone failed"; exit 1
    }
  fi

  cd "$REPO_DIR" || { err "Cannot cd to $REPO_DIR"; exit 1; }
  git fetch --all --prune >/dev/null 2>&1 || true

  # Checkout the requested branch
  if git rev-parse --verify "$BRANCH" >/dev/null 2>&1; then
    git checkout "$BRANCH" >/dev/null 2>&1 || git checkout -b "$BRANCH" origin/"$BRANCH" 2>/dev/null || true
  else
    warn "Branch $BRANCH not found locally, trying remote..."
    git checkout -b "$BRANCH" "origin/$BRANCH" 2>/dev/null || {
      err "Branch $BRANCH not available"; exit 1
    }
  fi
  git pull --ff-only >/dev/null 2>&1 || true
  ok "Repo ready on branch $(git branch --show-current)"
}

###############################################################################
# Helper: copy files
###############################################################################
copy_files() {
  local dest="$1"
  mkdir -p "$dest"

  info "Copying QML files..."
  cp -v "$REPO_DIR/GlobalStates.qml" "$dest/" 2>/dev/null || true
  cp -v "$REPO_DIR/modules/common/Config.qml" "$dest/modules/common/" 2>/dev/null || true
  cp -v "$REPO_DIR/modules/ii/settings/pages/BarConfig.qml" "$dest/modules/ii/settings/pages/" 2>/dev/null || true
  cp -v "$REPO_DIR/modules/ii/settings/pages/OttoHostPairConfig.qml" "$dest/modules/ii/settings/pages/" 2>/dev/null || true
  cp -v "$REPO_DIR/services/Cliphist.qml" "$dest/services/" 2>/dev/null || true
  cp -v "$REPO_DIR/services/SettingsPages.qml" "$dest/services/" 2>/dev/null || true
  cp -v "$REPO_DIR/services/OttoHostPair.qml" "$dest/services/" 2>/dev/null || true

  info "Copying plugin..."
  cp -rv "$REPO_DIR/plugins/otto-host-pair" "$dest/" 2>/dev/null || true

  ok "Files copied to $dest"
}

###############################################################################
# Helper: register Otto plugin
###############################################################################
register_plugin() {
  local plugin_dir="$1"
  if [[ "$INSTALL_PLUGIN" != "true" ]]; then
    warn "Skipping plugin registration."
    return 0
  fi

  info "Installing Otto Host Pair plugin..."
  mkdir -p "$HOME/.otto/plugins"
  cp -rv "$plugin_dir" "$HOME/.otto/plugins/otto-host-pair" || {
    err "Plugin copy failed"; return 1
  }

  # Try to reload the Otto daemon
  if command -v otto >/dev/null 2>&1; then
    info "Reloading Otto daemon plugins..."
    otto plugin reload otto-host-pair 2>/dev/null || {
      warn "Plugin reload failed — you may need to restart Otto manually: systemctl --user restart otto"
    }
  elif systemctl --user is-active --quiet otto 2>/dev/null; then
    info "Restarting Otto service..."
    systemctl --user restart otto 2>/dev/null || warn "Could not restart otto service"
  else
    warn "Otto daemon not detected — install plugin manually and restart Otto"
  fi
  ok "Plugin installed at ~/.otto/plugins/otto-host-pair"
}

###############################################################################
# Main
###############################################################################
main() {
  ensure_repo
  copy_files "$HOME/.config/quickshell"

  if [[ "$INSTALL_PLUGIN" == "true" ]]; then
    register_plugin "$REPO_DIR/plugins/otto-host-pair"
  fi

  echo ""
  echo "============================================================"
  echo "  Install complete!"
  echo "============================================================"
  echo ""
  echo "Next steps:"
  echo "  1. Restart Quickshell:"
  echo "     export WAYLAND_DISPLAY=wayland-1"
  echo "     export XDG_SESSION_TYPE=wayland"
  echo "     export QT_QPA_PLATFORM=wayland"
  echo "     export HYPRLAND_INSTANCE_SIGNATURE=\$(ls /run/user/1000/hypr/)"
  echo "     pkill -9 qs; sleep 1; qs -c end4-pC > /dev/null 2>&1 & disown"
  echo ""
  echo "  2. Open Settings → Otto tab to see agent/session status"
  echo "  3. Pair a remote host via the Otto desktop app surface"
  echo ""
  echo "Branch: $BRANCH | Repo: $REPO_DIR"
  echo ""
}

main "$@"
