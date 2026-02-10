#!/usr/bin/env bash
set -euo pipefail

# --- Check dependencies ---
DEPS=(inkscape optipng magick)
for cmd in "${DEPS[@]}"; do
  command -v "$cmd" &>/dev/null || { echo "Error: $cmd not found"; exit 1; }
done

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RENDERER="${SCRIPT_DIR}/render-assets.sh"

# --- Parse --colors flag ---
COLORS_CFG=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --colors)
      COLORS_CFG="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

if [[ -z "$COLORS_CFG" ]]; then
  COLORS_CFG="${SCRIPT_DIR}/colors.cfg"
fi

if [[ ! -f "$COLORS_CFG" ]]; then
  echo "Error: colors.cfg not found at $COLORS_CFG"
  exit 1
fi

export COLORS_CFG

"$RENDERER" icons      1080p
"$RENDERER" select     1080p
"$RENDERER" logo       100
"$RENDERER" logo       256
"$RENDERER" background 640x480
