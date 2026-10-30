#!/bin/bash

selected=$(cliphist list | rofi -dmenu -p "󰅍" -theme ~/.config/rofi/launcher.rasi)

if [[ -n "$selected" ]]; then
  echo "$selected" | cliphist decode | wl-copy
fi
