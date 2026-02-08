#!/usr/bin/env bash

# --------------------------------------------------------------
# Optional Packages
# --------------------------------------------------------------

log_info "Installing optional packages..."

if [[ "$OPTIONAL_SELECTED" == *"Development"* ]]; then
	log_info "Installing development tools..."
	_installPackages "${optional_development[@]}"
fi

if [[ "$OPTIONAL_SELECTED" == *"Creative"* ]]; then
	log_info "Installing creative software..."
	_installPackages "${optional_creative[@]}"
fi

if [[ "$OPTIONAL_SELECTED" == *"Multimedia"* ]]; then
	log_info "Installing multimedia tools..."
	_installPackages "${optional_multimedia[@]}"
fi

if [[ "$OPTIONAL_SELECTED" == *"Communication"* ]]; then
	log_info "Installing communication apps..."
	_installPackages "${optional_communication[@]}"
fi

if [[ "$OPTIONAL_SELECTED" == *"Browsers"* ]]; then
	log_info "Installing browsers..."
	_installPackages "${optional_browsers[@]}"
fi

if [[ "$OPTIONAL_SELECTED" == *"Gaming"* ]]; then
	log_info "Installing gaming packages..."
	_installPackages "${optional_gaming[@]}"
fi

log_success "Optional packages installed"
