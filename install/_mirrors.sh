#!/usr/bin/env bash

# --------------------------------------------------------------
# Install rate-mirrors
# --------------------------------------------------------------

if [[ $(_checkCommandExists "rate-mirrors") != 0 ]]; then
    log_info "Installing rate-mirrors..."
    sudo pacman -S --noconfirm rate-mirrors
fi

# --------------------------------------------------------------
# Artix Mirrors
# --------------------------------------------------------------

log_info "Ranking Artix mirrors (this may take a moment)..."
rate-mirrors --protocol https artix | head -n 11 | sudo tee /etc/pacman.d/mirrorlist > /dev/null
log_success "Artix mirrors ranked (top 10)"

# --------------------------------------------------------------
# Arch Mirrors
# --------------------------------------------------------------

log_info "Ranking Arch mirrors (this may take a moment)..."
rate-mirrors --protocol https arch | head -n 11 | sudo tee /etc/pacman.d/mirrorlist-arch > /dev/null
log_success "Arch mirrors ranked (top 10)"

# --------------------------------------------------------------
# Refresh
# --------------------------------------------------------------

sudo pacman -Syy
log_success "Package databases refreshed"
