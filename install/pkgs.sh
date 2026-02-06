#!/usr/bin/env bash

# --------------------------------------------------------------
# Base
# --------------------------------------------------------------

base=(
    "base-devel"
    "git"
    "wget"
    "curl"
    "htop"
    "btop"
    "fastfetch"
    "unzip"
    "unrar"
    "7zip"
    "flatpak"
    "gum"
)

# --------------------------------------------------------------
# Hyprland
# --------------------------------------------------------------

hyprland=(
    "hyprland"
    "hyprland-qt-support"
    "hyprpaper"
    "hypridle"
    "hyprlock"
    "hyprpicker"
    "hyprcursor"
    "xdg-desktop-portal-hyprland"
    "xdg-desktop-portal-gtk"
    "xdg-utils"
    "xdg-user-dirs"
)

# --------------------------------------------------------------
# Terminal
# --------------------------------------------------------------

terminal=(
    "kitty"
    "kitty-terminfo"
    "kitty-shell-integration"
    "fish"
)

# --------------------------------------------------------------
# UI
# --------------------------------------------------------------

ui=(
    "waybar"
    "rofi"
    "dunst"
    "wlogout"
    "thunar"
    "thunar-volman"
    "thunar-archive-plugin"
    "thunar-vcs-plugin"
    "xarchiver"
    "gvfs"
    "gvfs-mtp"
)

# --------------------------------------------------------------
# Utilities
# --------------------------------------------------------------

utilities=(
    "wl-clipboard"
    "cliphist"
    "grim"
    "slurp"
    "gammastep"
    "pamixer"
    "pavucontrol"
    "playerctl"
    "brightnessctl"
    "blueman"
    "network-manager-applet"
    "gnome-keyring"
    "polkit-gnome"
    "mpv"
    "vlc"
    "imv"
    "ristretto"
    "qbittorrent"
)

# --------------------------------------------------------------
# Theming
# --------------------------------------------------------------

theming=(
    "kvantum"
    "kvantum-qt5"
    "qt5ct"
    "qt6ct"
    "nwg-look"
    "bibata-cursor-git"
    "tela-circle-icon-theme-dracula"
    "kvantum-theme-catppuccin-git"
    "sddm-astronaut-theme"
)

# --------------------------------------------------------------
# Fonts
# --------------------------------------------------------------

fonts=(
    "ttf-jetbrains-mono-nerd"
    "ttf-firacode-nerd"
    "ttf-cascadia-code-nerd"
    "ttf-cascadia-mono-nerd"
    "ttf-iosevka-nerd"
    "ttf-nerd-fonts-symbols"
    "ttf-nerd-fonts-symbols-mono"
    "ttf-nerd-fonts-symbols-common"
    "noto-fonts"
    "noto-fonts-emoji"
)

# --------------------------------------------------------------
# Nvidia
# --------------------------------------------------------------

nvidia=(
    "nvidia-open-dkms"
    "nvidia-utils"
    "lib32-nvidia-utils"
    "nvidia-settings"
    "libva-nvidia-driver"
    "egl-wayland"
    "linux-headers"
)

# --------------------------------------------------------------
# dinit Services
# --------------------------------------------------------------

services_dinit=(
    "networkmanager-dinit"
    "bluez-dinit"
    "sddm-dinit"
    "elogind-dinit"
    "dbus-dinit"
)

# --------------------------------------------------------------
# Optional: Development
# --------------------------------------------------------------

optional_development=(
    "visual-studio-code-bin"
    "sublime-text-4"
    "github-desktop-bin"
)

# --------------------------------------------------------------
# Optional: Creative
# --------------------------------------------------------------

optional_creative=(
    "godot"
    "aseprite"
)

# --------------------------------------------------------------
# Optional: Multimedia
# --------------------------------------------------------------

optional_multimedia=(
    "obs-studio"
    "spicetify-cli"
)

# --------------------------------------------------------------
# Optional: Communication
# --------------------------------------------------------------

optional_communication=(
    "equibop-bin"
    "thunderbird"
    "nicotine+"
)

# --------------------------------------------------------------
# Optional: Browsers
# --------------------------------------------------------------

optional_browsers=(
    "firefox-nightly-bin"
)

# --------------------------------------------------------------
# Optional: Gaming
# --------------------------------------------------------------

optional_gaming=(
    "steam"
    "proton-ge-custom-bin"
    "protonup-qt"
    "mangohud"
    "lib32-mangohud"
    "gamemode"
    "gamescope"
)

# --------------------------------------------------------------
# Optional: Flatpaks
# --------------------------------------------------------------

flatpaks=(
    "com.spotify.Client"
    "tv.strem.Stremio"
)
