#!/usr/bin/env bash

# --------------------------------------------------------------
# SDDM Theme Installation
# Deploys the Mochaccino SDDM theme to /usr/share/sddm/themes/mochaccino/
# Can be sourced by install.sh or run standalone.
# --------------------------------------------------------------

# --- Standalone mode ---
if [[ -z "$REPO_DIR" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  REPO_DIR="$(dirname "$SCRIPT_DIR")"
  source "$SCRIPT_DIR/_lib.sh"
fi

# --- Parse arguments ---
THEME="mochaccino"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --theme)
      THEME="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# --- Check dependencies ---
if ! command -v inkscape &>/dev/null; then
  log_error "inkscape is required but not found"
  exit 1
fi

log_info "Installing SDDM theme (${THEME})..."

THEMES_DIR="$REPO_DIR/themes"
MATUGEN_DIR="$REPO_DIR/dotfiles/.config/matugen"

# --- Resolve theme source ---
if [[ "$THEME" == "mochaccino" ]]; then
  # Dynamic theme — matugen-rendered files
  THEME_SRC="$MATUGEN_DIR/themes/mochaccino"
  THEME_CONF="$THEME_SRC/sddm-theme.conf"
  LOGO_SVG="$THEME_SRC/ThemeLogo.svg"
else
  # Baked theme (e.g. monokai-filter-spectrum)
  THEME_SRC="$MATUGEN_DIR/themes/$THEME"
  THEME_CONF="$THEME_SRC/sddm-theme.conf"
  LOGO_SVG=""
fi

if [[ ! -f "$THEME_CONF" ]]; then
  log_error "theme.conf not found at $THEME_CONF"
  log_error "Run matugen first or use --theme monokai-filter-spectrum"
  exit 1
fi

# --- Build staging directory ---
BUILD_DIR="$(mktemp -d)"
trap 'rm -rf "$BUILD_DIR"' EXIT

ASSEMBLED="$BUILD_DIR/mochaccino"
mkdir -p "$ASSEMBLED"

# --- Copy QML files and metadata ---
cp "$THEMES_DIR/sddm/Main.qml" "$ASSEMBLED/"
cp "$THEMES_DIR/sddm/SessionsChoose.qml" "$ASSEMBLED/"
cp "$THEMES_DIR/sddm/UsersChoose.qml" "$ASSEMBLED/"
cp "$THEMES_DIR/sddm/metadata.desktop" "$ASSEMBLED/"
cp "$THEME_CONF" "$ASSEMBLED/theme.conf"

# --- Render logo ---
if [[ -n "$LOGO_SVG" && -f "$LOGO_SVG" ]]; then
  log_info "Rendering logo from SVG..."
  inkscape --export-width=256 --export-height=256 \
           --export-filename="$ASSEMBLED/logo.png" "$LOGO_SVG" >/dev/null
  if command -v optipng &>/dev/null; then
    optipng -strip all -nc "$ASSEMBLED/logo.png" 2>/dev/null
  fi
else
  # For baked themes, check if a pre-rendered logo exists
  if [[ -f "$THEME_SRC/logo.png" ]]; then
    cp "$THEME_SRC/logo.png" "$ASSEMBLED/logo.png"
  fi
fi

# --- Deploy to /usr/share/sddm/themes/ ---
DEST="/usr/share/sddm/themes/mochaccino"
log_info "Deploying to $DEST..."
sudo rm -rf "$DEST"
sudo cp -r "$ASSEMBLED" "$DEST"

# --- Update SDDM config ---
SDDM_CONF="/etc/sddm.conf"
if [[ -f "$SDDM_CONF" ]]; then
  if grep -q '^Current=' "$SDDM_CONF"; then
    sudo sed -i 's|^Current=.*|Current=mochaccino|' "$SDDM_CONF"
  fi
else
  log_warning "/etc/sddm.conf not found — set Current=mochaccino manually"
fi

log_success "SDDM theme installed"
