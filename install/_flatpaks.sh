#!/usr/bin/env bash

# --------------------------------------------------------------
# Flathub Repository
# --------------------------------------------------------------

log_info "Setting up Flatpak..."

if ! flatpak remote-list 2>/dev/null | grep -q flathub; then
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    log_success "Flathub repository added"
fi

# --------------------------------------------------------------
# Install Flatpaks
# --------------------------------------------------------------

for app in "${flatpaks[@]}"; do
    log_info "Installing: $app"
    flatpak install -y flathub "$app" 2>/dev/null
done

# --------------------------------------------------------------
# Spicetify Configuration
# --------------------------------------------------------------

if flatpak list 2>/dev/null | grep -q "com.spotify.Client" && command -v spicetify &>/dev/null; then
    spotify_path="$HOME/.var/app/com.spotify.Client/config/spotify"
    if [[ -d "$spotify_path" ]]; then
        log_info "Configuring Spicetify for Flatpak Spotify..."
        spicetify config spotify_path "$spotify_path"
        spicetify config prefs_path "$spotify_path/prefs"
        sudo chmod a+wr "$spotify_path"
        sudo chmod a+wr -R "$spotify_path/Apps" 2>/dev/null
        spicetify backup apply 2>/dev/null
        log_success "Spicetify configured"
    else
        log_info "Run Spotify once, then run 'spicetify backup apply'"
    fi
fi

log_success "Flatpaks installed"
