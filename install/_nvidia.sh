#!/usr/bin/env bash

# --------------------------------------------------------------
# Nvidia Drivers
# --------------------------------------------------------------

log_info "Installing Nvidia drivers..."
_installPackages "${nvidia[@]}"

# --------------------------------------------------------------
# GRUB Configuration
# --------------------------------------------------------------

log_info "Configuring GRUB for Nvidia..."
if ! grep -q "nvidia-drm.modeset=1" /etc/default/grub; then
	sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\([^"]*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 nvidia-drm.modeset=1"/' /etc/default/grub
	log_success "Added nvidia-drm.modeset=1 to GRUB"
fi
sudo grub-mkconfig -o /boot/grub/grub.cfg
log_success "GRUB configuration updated"

# --------------------------------------------------------------
# Initramfs Configuration
# --------------------------------------------------------------

log_info "Configuring mkinitcpio..."
if ! grep -q "nvidia nvidia_modeset nvidia_uvm nvidia_drm" /etc/mkinitcpio.conf; then
	if grep -q '^MODULES=()' /etc/mkinitcpio.conf; then
		sudo sed -i 's/^MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
	else
		sudo sed -i 's/^MODULES=(\([^)]*\))/MODULES=(\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
	fi
	log_success "Added Nvidia modules to mkinitcpio"
fi
sudo mkinitcpio -P
log_success "initramfs regenerated"

# --------------------------------------------------------------
# Hyprland Environment Variables
# --------------------------------------------------------------

env_conf="$DOTFILES_DIR/.config/hypr/conf/env.conf"
if [[ -f "$env_conf" ]]; then
	sed -i 's/^# *\(env = LIBVA_DRIVER_NAME,nvidia\)/\1/' "$env_conf"
	sed -i 's/^# *\(env = __GLX_VENDOR_LIBRARY_NAME,nvidia\)/\1/' "$env_conf"
	sed -i 's/^# *\(env = GBM_BACKEND,nvidia-drm\)/\1/' "$env_conf"
	sed -i 's/^# *\(env = __GL_GSYNC_ALLOWED,1\)/\1/' "$env_conf"
	sed -i 's/^# *\(env = WLR_NO_HARDWARE_CURSORS,1\)/\1/' "$env_conf"
	sed -i 's/^# *\(env = NVD_BACKEND,direct\)/\1/' "$env_conf"
	log_success "Nvidia environment variables enabled"
fi

log_success "Nvidia setup complete"
log_warning "A reboot is required for Nvidia drivers to take effect"
