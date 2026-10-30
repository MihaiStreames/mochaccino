#!/usr/bin/env bash
set -euo pipefail

# pkill exits 1 when nothing matched, which shouldn't stop the restart
pkill -x waybar || true
hyprctl dispatch 'hl.dsp.exec_cmd("waybar")'
