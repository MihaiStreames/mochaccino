#!/usr/bin/env bash
# Wallpaper picker: set wallpaper + generate Material You theme

MATUGEN_DIR="$HOME/.config/matugen"
WALLPAPER_DIR="$HOME/Pictures/Wallpaper"
HYPRPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"

WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.webp" \) \
    | sed "s|$WALLPAPER_DIR/||" \
    | sort \
    | rofi -dmenu -i -p "󰸉" -theme "$HOME/.config/rofi/launcher.rasi")

[[ -z "$WALLPAPER" ]] && exit 0

WALLPAPER_PATH="$WALLPAPER_DIR/$WALLPAPER"
MONITORS=$(hyprctl monitors -j | jq -r '.[].name')

{
    for mon in $MONITORS; do
        printf 'wallpaper {\n    monitor = %s\n    path = %s\n    fit_mode = contain\n}\n\n' "$mon" "$WALLPAPER_PATH"
    done
} > "$HYPRPAPER_CONF"

killall hyprpaper 2>/dev/null
hyprpaper &

python3 "$MATUGEN_DIR/mochaccino.py" "$WALLPAPER_PATH"

kill -SIGUSR1 $(pidof kitty) 2>/dev/null
hyprctl reload 2>/dev/null
pkill waybar 2>/dev/null; sleep 0.3; waybar &
pkill dunst 2>/dev/null
