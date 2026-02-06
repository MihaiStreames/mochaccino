#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
DOTFILES_DIR="$REPO_DIR/dotfiles"

source "$SCRIPT_DIR/_lib.sh"
source "$SCRIPT_DIR/pkgs.sh"

# --------------------------------------------------------------
# Install gum
# --------------------------------------------------------------

if [[ $(_checkCommandExists "gum") != 0 ]]; then
    echo ":: Installing gum for interactive menus..."
    sudo pacman --noconfirm -S gum
fi

# --------------------------------------------------------------
# Header
# --------------------------------------------------------------

_writeHeader

# --------------------------------------------------------------
# Preflight Checks
# --------------------------------------------------------------

_checkNotRoot
_checkArtix
_checkDinit
_checkInternet

if [[ $(_hasNvidia) == 0 ]]; then
    log_success "Nvidia GPU detected"
    HAS_NVIDIA="true"
else
    log_info "No Nvidia GPU detected"
    HAS_NVIDIA="false"
fi

echo

# --------------------------------------------------------------
# User Configuration
# --------------------------------------------------------------

log_info "Select your keyboard layout"
KEYBOARD_LAYOUT=$(gum choose "us" "fr" "de" "es" "uk" "other")
if [[ "$KEYBOARD_LAYOUT" == "other" ]]; then
    KEYBOARD_LAYOUT=$(gum input --placeholder "Enter layout (e.g. us)")
fi
log_success "Keyboard layout: $KEYBOARD_LAYOUT"

echo

log_info "Select optional packages to install (space to select, enter to confirm)"
OPTIONAL_SELECTED=$(gum choose --no-limit \
    "Development (VSCode, Sublime, GitHub Desktop)" \
    "Creative (Godot, Aseprite)" \
    "Multimedia (OBS, Spicetify)" \
    "Communication (Discord, Thunderbird)" \
    "Browsers (Firefox Nightly)" \
    "Gaming (Steam, Proton, MangoHUD)")

echo

_confirmStart

# --------------------------------------------------------------
# Mirrors and Pacman
# --------------------------------------------------------------

source "$SCRIPT_DIR/_mirrors.sh"
source "$SCRIPT_DIR/_system.sh"

# --------------------------------------------------------------
# Yay
# --------------------------------------------------------------

source "$SCRIPT_DIR/_yay.sh"

# --------------------------------------------------------------
# Packages
# --------------------------------------------------------------

log_info "Installing base packages..."
_installPackages "${base[@]}"

log_info "Installing Hyprland..."
_installPackages "${hyprland[@]}"

log_info "Installing terminal..."
_installPackages "${terminal[@]}"

log_info "Installing UI components..."
_installPackages "${ui[@]}"

log_info "Installing utilities..."
_installPackages "${utilities[@]}"

log_info "Installing fonts..."
_installPackages "${fonts[@]}"

log_info "Installing theming packages..."
_installPackages "${theming[@]}"

log_info "Installing dinit services..."
_installPackages "${services_dinit[@]}"

# --------------------------------------------------------------
# Nvidia
# --------------------------------------------------------------

if [[ "$HAS_NVIDIA" == "true" ]]; then
    source "$SCRIPT_DIR/_nvidia.sh"
fi

# --------------------------------------------------------------
# Services
# --------------------------------------------------------------

source "$SCRIPT_DIR/_services.sh"

# --------------------------------------------------------------
# SDDM
# --------------------------------------------------------------

source "$SCRIPT_DIR/_sddm.sh"

# --------------------------------------------------------------
# Dotfiles
# --------------------------------------------------------------

source "$SCRIPT_DIR/_dotfiles.sh"

# --------------------------------------------------------------
# Optional
# --------------------------------------------------------------

if [[ -n "$OPTIONAL_SELECTED" ]]; then
    source "$SCRIPT_DIR/_optional.sh"
fi

# --------------------------------------------------------------
# Flatpaks
# --------------------------------------------------------------

source "$SCRIPT_DIR/_flatpaks.sh"

# --------------------------------------------------------------
# Finish
# --------------------------------------------------------------

source "$SCRIPT_DIR/_finish.sh"
