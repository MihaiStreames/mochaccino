#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/_lib.sh"

# --------------------------------------------------------------
# Header
# --------------------------------------------------------------

clear
echo -e "${MAGENTA}"
cat "$REPO_DIR/logo.txt"
echo -e "${NONE}"
echo -e "${YELLOW}  Dotfiles Uninstaller${NONE}"
echo

# --------------------------------------------------------------
# Config Directories
# --------------------------------------------------------------

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

# --------------------------------------------------------------
# Confirmation
# --------------------------------------------------------------

log_warning "This will remove the following configs from ~/.config/:"
echo
for config in "${configs[@]}"; do
	echo "  - $config"
done
echo

if ! gum confirm "DO YOU WANT TO REMOVE THESE CONFIGS?"; then
	log_info "Uninstall cancelled"
	exit 0
fi

# --------------------------------------------------------------
# Remove Configs
# --------------------------------------------------------------

log_info "Removing configs..."

for config in "${configs[@]}"; do
	target="$HOME/.config/$config"
	if [[ -d "$target" ]]; then
		rm -rf "$target"
		log_success "Removed: $config"
	fi
done

# --------------------------------------------------------------
# Shell Configs
# --------------------------------------------------------------

if gum confirm "Remove shell configs (.bashrc, .bash_profile)?"; then
	[[ -f "$HOME/.bashrc" ]] && rm "$HOME/.bashrc"
	[[ -f "$HOME/.bash_profile" ]] && rm "$HOME/.bash_profile"
	log_success "Shell configs removed"
fi

# --------------------------------------------------------------
# Packages
# --------------------------------------------------------------

echo
log_warning "Packages were NOT removed."
log_info "To manually remove packages:"
echo "  yay -Rns <package-name>"
echo

# --------------------------------------------------------------
# Finish
# --------------------------------------------------------------

log_success "Uninstall complete"
log_info "You may need to reboot your system"
