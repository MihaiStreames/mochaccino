#!/usr/bin/env bash

# --------------------------------------------------------------
# Remove Other Display Managers
# --------------------------------------------------------------

log_info "Setting up SDDM..."

for dm in lightdm gdm lxdm ly; do
	if pacman -Qi "$dm" &>/dev/null; then
		log_info "Removing $dm..."
		sudo dinitctl disable "$dm" 2>/dev/null
		sudo pacman -Rns --noconfirm "$dm" 2>/dev/null
	fi
done

# --------------------------------------------------------------
# Hyprland Session
# --------------------------------------------------------------

log_info "Installing Hyprland startup script..."
sudo tee /usr/local/bin/start-hyprland >/dev/null <<'EOF'
#!/bin/sh

if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval "$(dbus-launch --sh-syntax --exit-with-session)"
fi

exec Hyprland
EOF
sudo chmod +x /usr/local/bin/start-hyprland

log_info "Creating Hyprland session..."
sudo mkdir -p /usr/share/wayland-sessions
sudo tee /usr/share/wayland-sessions/hyprland.desktop >/dev/null <<'EOF'
[Desktop Entry]
Name=Hyprland
Comment=Hyprland Wayland Compositor
Exec=/usr/local/bin/start-hyprland
Type=Application
DesktopNames=Hyprland
EOF

# --------------------------------------------------------------
# SDDM Configuration
# --------------------------------------------------------------

log_info "Configuring SDDM..."
sudo tee /etc/sddm.conf >/dev/null <<'EOF'
[General]
HaltCommand=/usr/bin/loginctl poweroff
RebootCommand=/usr/bin/loginctl reboot
Numlock=none

[Theme]
Current=sddm-astronaut-theme
CursorTheme=Bibata-Modern-Classic

[Users]
MaximumUid=60000
MinimumUid=1000
RememberLastSession=true
RememberLastUser=true

[Wayland]
SessionDir=/usr/share/wayland-sessions
EOF

log_success "SDDM configured"
