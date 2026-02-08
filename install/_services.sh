#!/usr/bin/env bash

# --------------------------------------------------------------
# Enable dinit Services
# --------------------------------------------------------------

log_info "Enabling dinit services..."

for service in NetworkManager bluetoothd sddm dbus elogind; do
	if sudo dinitctl list 2>/dev/null | grep -q "^\[{+}.*\] $service"; then
		log_info "$service is already enabled"
	else
		if sudo dinitctl enable "$service" 2>/dev/null; then
			log_success "Enabled: $service"
		else
			log_warning "Could not enable $service"
		fi
	fi
done

log_success "dinit services configured"
