#!/usr/bin/env bash

# --------------------------------------------------------------
# Pacman Options
# --------------------------------------------------------------

log_info "Configuring pacman..."
PACMAN_CONF="/etc/pacman.conf"

if grep -q "^#Color" "$PACMAN_CONF"; then
    sudo sed -i 's/^#Color/Color/' "$PACMAN_CONF"
    log_success "Enabled: Color"
fi

if grep -q "^#ParallelDownloads" "$PACMAN_CONF"; then
    sudo sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 5/' "$PACMAN_CONF"
    log_success "Enabled: ParallelDownloads = 5"
fi

if grep -q "^#VerbosePkgLists" "$PACMAN_CONF"; then
    sudo sed -i 's/^#VerbosePkgLists/VerbosePkgLists/' "$PACMAN_CONF"
    log_success "Enabled: VerbosePkgLists"
fi

# --------------------------------------------------------------
# Arch Repositories
# --------------------------------------------------------------

if ! grep -q "mirrorlist-arch" "$PACMAN_CONF"; then
    log_info "Adding Arch Linux repositories..."
    sudo tee -a "$PACMAN_CONF" > /dev/null << 'EOF'

[extra]
Include = /etc/pacman.d/mirrorlist-arch

[multilib]
Include = /etc/pacman.d/mirrorlist-arch
EOF
    log_success "Arch repositories added"
fi

# --------------------------------------------------------------
# Keyrings
# --------------------------------------------------------------

log_info "Refreshing keyrings..."
sudo pacman -Sy --noconfirm artix-keyring archlinux-keyring
sudo pacman-key --init
sudo pacman-key --populate artix archlinux
log_success "Keyrings refreshed"

# --------------------------------------------------------------
# Linux Firmware
# --------------------------------------------------------------

log_info "Reinstalling linux-firmware..."
sudo pacman -R --noconfirm linux-firmware
sudo pacman -S --noconfirm linux-firmware
log_success "linux-firmware installed"

# --------------------------------------------------------------
# System Upgrade
# --------------------------------------------------------------

log_info "Upgrading system..."
sudo pacman -Syu --noconfirm
log_success "System upgraded"
