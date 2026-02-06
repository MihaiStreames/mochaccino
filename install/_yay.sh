#!/usr/bin/env bash

# --------------------------------------------------------------
# Yay AUR Helper
# --------------------------------------------------------------

if [[ $(_checkCommandExists "yay") == 0 ]]; then
    log_info "yay is already installed"
else
    log_info "Installing yay AUR helper..."
    sudo pacman -S --needed --noconfirm base-devel git

    temp_dir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay-bin.git "$temp_dir/yay-bin"
    cd "$temp_dir/yay-bin"
    makepkg -si --noconfirm
    cd -
    rm -rf "$temp_dir"

    log_success "yay installed"
fi
