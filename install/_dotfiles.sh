#!/usr/bin/env bash

# --------------------------------------------------------------
# Config Directories
# --------------------------------------------------------------

log_info "Deploying dotfiles..."

configs=(
    "hypr"
    "kitty"
    "fish"
    "waybar"
    "rofi"
    "dunst"
    "wlogout"
    "gtk-3.0"
    "gtk-4.0"
    "qt5ct"
    "qt6ct"
    "Kvantum"
    "fastfetch"
    "Thunar"
)

for config in "${configs[@]}"; do
    source="$DOTFILES_DIR/.config/$config"
    target="$HOME/.config/$config"
    if [[ -d "$source" ]]; then
        mkdir -p "$(dirname "$target")"
        cp -r "$source" "$target"
        log_success "Copied: $config"
    fi
done

# --------------------------------------------------------------
# Keyboard Layout
# --------------------------------------------------------------

input_conf="$HOME/.config/hypr/conf/input.conf"
if [[ -f "$input_conf" ]]; then
    sed -i "s/kb_layout = .*/kb_layout = $KEYBOARD_LAYOUT/" "$input_conf"
    log_success "Keyboard layout set to: $KEYBOARD_LAYOUT"
fi

# --------------------------------------------------------------
# Shell Configs
# --------------------------------------------------------------

[[ -f "$DOTFILES_DIR/.bashrc" ]] && cp "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
[[ -f "$DOTFILES_DIR/.bash_profile" ]] && cp "$DOTFILES_DIR/.bash_profile" "$HOME/.bash_profile"

# --------------------------------------------------------------
# GTK Bookmarks
# --------------------------------------------------------------

mkdir -p "$HOME/.config/gtk-3.0"
cat > "$HOME/.config/gtk-3.0/bookmarks" << EOF
file://$HOME/Documents
file://$HOME/Downloads
file://$HOME/Music
file://$HOME/Pictures
file://$HOME/Videos
EOF
log_success "GTK bookmarks created"

# --------------------------------------------------------------
# Default Shell
# --------------------------------------------------------------

if command -v fish &>/dev/null; then
    fish_path=$(which fish)
    if [[ "$SHELL" != "$fish_path" ]]; then
        log_info "Setting fish as default shell..."
        chsh -s "$fish_path"
        log_success "Default shell set to fish"
    fi
fi

log_success "Dotfiles deployed"
