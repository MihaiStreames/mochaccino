#!/usr/bin/env bash

# --------------------------------------------------------------
# Colors
# --------------------------------------------------------------

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
DIM='\033[2m'
NONE='\033[0m'

# --------------------------------------------------------------
# Logging
# --------------------------------------------------------------

log_info() { echo -e "${BLUE}::${NONE} $1"; }
log_success() { echo -e "${GREEN}::${NONE} $1"; }
log_warning() { echo -e "${YELLOW}::${NONE} $1"; }
log_error() { echo -e "${RED}:: ERROR:${NONE} $1"; }

# --------------------------------------------------------------
# Checks
# --------------------------------------------------------------

_checkCommandExists() {
    if ! command -v "$1" &>/dev/null; then
        echo 1
        return
    fi
    echo 0
}

_isInstalled() {
    package="$1"
    check="$(pacman -Qs --color always "${package}" | grep "local" | grep "${package} ")"
    if [ -n "${check}" ]; then
        echo 0
        return
    fi
    echo 1
}

_checkArtix() {
    if [[ ! -f /etc/artix-release ]]; then
        log_error "This installer only works on Artix Linux"
        exit 1
    fi
    log_success "Artix Linux detected"
}

_checkDinit() {
    if [[ $(_checkCommandExists "dinitctl") != 0 ]]; then
        log_error "dinit not found. This installer requires Artix with dinit init system."
        exit 1
    fi
    log_success "dinit init system detected"
}

_checkNotRoot() {
    if [[ $EUID -eq 0 ]]; then
        log_error "Do not run this script as root"
        exit 1
    fi
}

_checkInternet() {
    if ! ping -c 1 archlinux.org &>/dev/null; then
        log_error "No internet connection"
        exit 1
    fi
    log_success "Internet connection OK"
}

_hasNvidia() {
    if lspci | grep -i nvidia &>/dev/null; then
        echo 0
        return
    fi
    echo 1
}

# --------------------------------------------------------------
# Package Installation
# --------------------------------------------------------------

_installPackages() {
    for pkg; do
        if [[ $(_isInstalled "${pkg}") == 0 ]]; then
            log_info "${pkg} is already installed."
            continue
        fi
        yay --noconfirm -S "${pkg}"
    done
}

_installPackagesPacman() {
    for pkg; do
        if [[ $(_isInstalled "${pkg}") == 0 ]]; then
            log_info "${pkg} is already installed."
            continue
        fi
        sudo pacman --noconfirm -S "${pkg}"
    done
}

# --------------------------------------------------------------
# UI
# --------------------------------------------------------------

_writeHeader() {
    clear
    echo -e "${MAGENTA}"
    cat "$REPO_DIR/logo.txt"
    echo -e "${NONE}"
    echo -e "${YELLOW}  Artix Linux + dinit ONLY${NONE}"
    echo
}

_confirmStart() {
    if ! gum confirm "DO YOU WANT TO START THE INSTALLATION?"; then
        log_warning "Installation cancelled"
        exit 0
    fi
    echo
    log_info "Installation started"
    echo
}
