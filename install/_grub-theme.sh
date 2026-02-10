#!/usr/bin/env bash

# --------------------------------------------------------------
# GRUB Theme Installation
# Deploys the Mochaccino GRUB theme to /boot/grub/themes/mochaccino/
# Can be sourced by install.sh or run standalone.
# --------------------------------------------------------------

# --------------------------------------------------------------
# Standalone mode
# --------------------------------------------------------------
if [[ -z "$REPO_DIR" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  REPO_DIR="$(dirname "$SCRIPT_DIR")"
  source "$SCRIPT_DIR/_lib.sh"
fi

# --------------------------------------------------------------
# Parse arguments
# --------------------------------------------------------------
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

# --------------------------------------------------------------
# Check dependencies
# --------------------------------------------------------------
for cmd in inkscape optipng magick; do
  if ! command -v "$cmd" &>/dev/null; then
    log_error "$cmd is required but not found"
    exit 1
  fi
done

log_info "Installing GRUB theme (${THEME})..."

THEMES_DIR="$REPO_DIR/themes"
RENDER_DIR="$THEMES_DIR/grub/render"
MATUGEN_DIR="$REPO_DIR/dotfiles/.config/matugen"

# --------------------------------------------------------------
# Resolve theme source
# --------------------------------------------------------------
if [[ "$THEME" == "mochaccino" ]]; then
  # Dynamic theme — matugen-rendered files
  THEME_SRC="$MATUGEN_DIR/themes/mochaccino"
  COLORS_CFG="$THEME_SRC/colors.cfg"
  THEME_TXT="$THEME_SRC/grub-theme.txt"
  BG_SVG="$THEME_SRC/grub-background.svg"
  LOGO_SVG="$THEME_SRC/ThemeLogo.svg"
else
  # Baked theme (e.g. monokai-filter-spectrum)
  THEME_SRC="$MATUGEN_DIR/themes/$THEME"
  COLORS_CFG="$THEME_SRC/colors.cfg"
  THEME_TXT="$THEME_SRC/grub-theme.txt"
  BG_SVG=""
  LOGO_SVG=""
fi

if [[ ! -f "$COLORS_CFG" ]]; then
  log_error "colors.cfg not found at $COLORS_CFG"
  log_error "Run matugen first or use --theme monokai-filter-spectrum"
  exit 1
fi

if [[ ! -f "$THEME_TXT" ]]; then
  log_error "theme.txt not found at $THEME_TXT"
  exit 1
fi

# --------------------------------------------------------------
# Build staging directory
# --------------------------------------------------------------
BUILD_DIR="$(mktemp -d)"
trap 'rm -rf "$BUILD_DIR"' EXIT

log_info "Rendering GRUB assets..."
cd "$BUILD_DIR"
"$RENDER_DIR/render.sh" --colors "$COLORS_CFG"

# --------------------------------------------------------------
# Render background from SVG if available, otherwise use generated
# --------------------------------------------------------------
if [[ -n "$BG_SVG" && -f "$BG_SVG" ]]; then
  log_info "Rendering background from SVG..."
  inkscape --export-width=640 --export-height=480 \
           --export-filename="$BUILD_DIR/background.png" "$BG_SVG" >/dev/null
  optipng -strip all -nc "$BUILD_DIR/background.png" 2>/dev/null
else
  cp "$BUILD_DIR/background/background-640x480/background.png" "$BUILD_DIR/background.png"
fi

# --------------------------------------------------------------
# Render logo from SVG if available, otherwise use generated
# --------------------------------------------------------------
if [[ -n "$LOGO_SVG" && -f "$LOGO_SVG" ]]; then
  log_info "Rendering logo from SVG..."
  inkscape --export-width=100 --export-height=100 \
           --export-filename="$BUILD_DIR/logo.png" "$LOGO_SVG" >/dev/null
  optipng -strip all -nc "$BUILD_DIR/logo.png" 2>/dev/null
else
  cp "$BUILD_DIR/logo/logo-100/logo.png" "$BUILD_DIR/logo.png"
fi

# --------------------------------------------------------------
# Assemble theme directory
# --------------------------------------------------------------
ASSEMBLED="$BUILD_DIR/mochaccino"
mkdir -p "$ASSEMBLED/icons"

cp "$THEME_TXT" "$ASSEMBLED/theme.txt"
cp "$THEMES_DIR/grub/font.pf2" "$ASSEMBLED/font.pf2"
cp "$BUILD_DIR/background.png" "$ASSEMBLED/background.png"
cp "$BUILD_DIR/logo.png" "$ASSEMBLED/logo.png"
cp "$BUILD_DIR/select/select-1080p"/select_*.png "$ASSEMBLED/"
cp "$BUILD_DIR/icons/icons-1080p"/*.png "$ASSEMBLED/icons/"

# --------------------------------------------------------------
# Deploy to /boot/grub/themes/
# --------------------------------------------------------------
DEST="/boot/grub/themes/mochaccino"
log_info "Deploying to $DEST..."
sudo rm -rf "$DEST"
sudo cp -r "$ASSEMBLED" "$DEST"

# --------------------------------------------------------------
# Update GRUB config
# --------------------------------------------------------------
GRUB_DEFAULT="/etc/default/grub"
if [[ -f "$GRUB_DEFAULT" ]]; then
  if grep -q '^GRUB_THEME=' "$GRUB_DEFAULT"; then
    sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"$DEST/theme.txt\"|" "$GRUB_DEFAULT"
  else
    echo "GRUB_THEME=\"$DEST/theme.txt\"" | sudo tee -a "$GRUB_DEFAULT" >/dev/null
  fi
  log_info "Regenerating GRUB config..."
  sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

log_success "GRUB theme installed"
