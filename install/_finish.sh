#!/usr/bin/env bash

# --------------------------------------------------------------
# Script Permissions
# --------------------------------------------------------------

log_info "Running post-install tasks..."

for dir in "$HOME/.config/hypr/scripts" "$HOME/.config/rofi/scripts" "$HOME/.config/waybar/scripts"; do
	if [[ -d "$dir" ]]; then
		chmod +x "$dir"/*.sh 2>/dev/null
	fi
done
log_success "Scripts made executable"

# --------------------------------------------------------------
# XDG Directories
# --------------------------------------------------------------

if command -v xdg-user-dirs-update &>/dev/null; then
	xdg-user-dirs-update
	log_success "XDG directories created"
fi

# --------------------------------------------------------------
# Summary
# --------------------------------------------------------------

echo
echo "============================================"
echo "           Installation Summary"
echo "============================================"
echo
echo "  Keyboard Layout: $KEYBOARD_LAYOUT"
echo "  Nvidia GPU: $HAS_NVIDIA"
echo "  Optional: ${OPTIONAL_SELECTED:-None}"
echo
echo "============================================"
echo
log_warning "Please reboot your system!"
echo
echo "After reboot:"
echo "  1. Select 'Hyprland' from SDDM"
echo "  2. Super + Space  -> App launcher"
echo "  3. Super + Enter  -> Terminal"
echo "  4. Super + L      -> Lock screen"
echo "  5. Super + Q      -> Close window"
echo
