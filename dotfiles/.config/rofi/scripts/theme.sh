#!/usr/bin/env bash
# Theme picker: swap pre-made color themes

MATUGEN_DIR="$HOME/.config/matugen"
THEMES_DIR="$MATUGEN_DIR/themes"

THEME=$(find "$THEMES_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" 2>/dev/null \
    | sort \
    | rofi -dmenu -i -p "󰏘" -theme "$HOME/.config/rofi/launcher.rasi")

[[ -z "$THEME" ]] && exit 0

theme_dir="$THEMES_DIR/$THEME"
[[ ! -d "$theme_dir" ]] && exit 1

cp "$theme_dir/kitty-theme.conf" "$HOME/.config/kitty/theme.conf"
cp "$theme_dir/hyprland-colors.conf" "$HOME/.config/hypr/conf/colors.conf"
cp "$theme_dir/rofi-colors.rasi" "$HOME/.config/rofi/shared/colors.rasi"
cp "$theme_dir/waybar-colors.css" "$HOME/.config/waybar/colors.css"
cp "$theme_dir/fish-colors.fish" "$HOME/.config/fish/conf.d/02-colors.fish"
mkdir -p "$HOME/.config/dunst/dunstrc.d"
cp "$theme_dir/dunst-colors.conf" "$HOME/.config/dunst/dunstrc.d/colors.conf"

kill -SIGUSR1 $(pidof kitty) 2>/dev/null
hyprctl reload 2>/dev/null
pkill waybar 2>/dev/null; sleep 0.3; waybar &
pkill dunst 2>/dev/null
