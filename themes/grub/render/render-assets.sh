#!/bin/bash
# Adaptation from https://github.com/vinceliuice/grub2-themes/blob/master/assets/render-assets.sh
# Thanks to vinceliuice

INKSCAPE="/usr/bin/inkscape"
OPTIPNG="/usr/bin/optipng"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CFG="${COLORS_CFG:-${SCRIPT_DIR}/colors.cfg}"

if [[ -f "$CFG" ]]; then
  source "$CFG"
else
  echo "Error: colors.cfg not found at $CFG"
  exit 1
fi

TYPE="$1"

if [[ "$TYPE" == "background" ]]; then
  BG_SIZE="${2:-640x480}"
  ASSETS_DIR="background/background-${BG_SIZE}"
elif [[ "$TYPE" == "logo" ]]; then
  INDEX="${SCRIPT_DIR}/logo.txt"
  SRC_FILE="${SCRIPT_DIR}/logo.svg"
  LOGO_SIZE="${2:-512}"
  ASSETS_DIR="logo/logo-${LOGO_SIZE}"
elif [[ "$TYPE" == "select" ]]; then
  RES="$2"
  if [[ -z "$RES" ]]; then
    echo "Missing resolution"
    exit 1
  fi
  INDEX="${SCRIPT_DIR}/select.txt"
  SRC_FILE="${SCRIPT_DIR}/select.svg"
  if [[ "$RES" == "1080p" ]]; then
    EXPORT_DPI="96"
  elif [[ "$RES" == "2k" ]] || [[ "$RES" == "2K" ]]; then
    EXPORT_DPI="144"
  elif [[ "$RES" == "4k" ]] || [[ "$RES" == "4K" ]]; then
    EXPORT_DPI="192"
  else
    echo "Please use either '1080p', '2k' or '4k'"
    exit 1
  fi
  ASSETS_DIR="select/select-${RES}"
else
  RES="$2"
  if [[ -z "$RES" ]]; then
    echo "Missing resolution"
    exit 1
  fi
  INDEX="${SCRIPT_DIR}/logos-${TYPE}.txt"
  SRC_FILE="${SCRIPT_DIR}/logos-${TYPE}.svg"
  if [[ "$RES" == "1080p" ]]; then
    EXPORT_DPI="96"
  elif [[ "$RES" == "2k" ]] || [[ "$RES" == "2K" ]]; then
    EXPORT_DPI="144"
  elif [[ "$RES" == "4k" ]] || [[ "$RES" == "4K" ]]; then
    EXPORT_DPI="192"
  else
    echo "Please use either '1080p', '2k' or '4k'"
    exit 1
  fi
  ASSETS_DIR="${TYPE}/${TYPE}-${RES}"
fi

install -d "$ASSETS_DIR"

if [[ "$TYPE" == "background" ]]; then
  OUT="$ASSETS_DIR/background.png"
  if [[ -f "$OUT" ]]; then
    echo "$OUT exists"
  else
    echo -e "\nRendering $OUT"
    magick -size "$BG_SIZE" "xc:${BACKGROUND}" "$OUT"
    $OPTIPNG -strip all -nc "$OUT" 2>/dev/null
  fi
  exit 0
fi

TMP_FILE="${SCRIPT_DIR}/tmp-$(basename "$SRC_FILE")"

if [[ "$TYPE" == "logo" ]]; then
  sed -e "s/#1a1a1a/${BACKGROUND}/g" \
      -e "s/#333333/${COLOR1}/g" \
      -e "s/#4d4d4d/${COLOR2}/g" \
      -e "s/#666666/${COLOR3}/g" \
      -e "s/#999999/${COLOR4}/g" \
      -e "s/#cccccc/${COLOR5}/g" \
      -e "s/#ececec/${COLOR6}/g" \
      "$SRC_FILE" > "$TMP_FILE"
elif [[ "$TYPE" == "select" ]]; then
  FILL_COLOR="${SELECT:-#ffffff}"
  sed -e "s/#ffffff/${FILL_COLOR}/g" "$SRC_FILE" > "$TMP_FILE"
else
  FILL_COLOR="${ICONS:-#ffffff}"
  sed -e "s/#ffffff/${FILL_COLOR}/g" "$SRC_FILE" > "$TMP_FILE"
fi

while read -r id; do
  if [[ -f "$ASSETS_DIR/$id.png" ]]; then
    echo "$ASSETS_DIR/$id.png exists"
  elif [[ "$id" == "" ]]; then
    continue
  else
    echo -e "\nRendering $ASSETS_DIR/$id.png"
    if [[ "$TYPE" == "logo" ]]; then
      $INKSCAPE "--export-id=$id" \
                "--export-width=$LOGO_SIZE" \
                "--export-height=$LOGO_SIZE" \
                "--export-id-only" \
                "--export-filename=$ASSETS_DIR/$id.png" "$TMP_FILE" >/dev/null
    else
      $INKSCAPE "--export-id=$id" \
                "--export-dpi=$EXPORT_DPI" \
                "--export-id-only" \
                "--export-filename=$ASSETS_DIR/$id.png" "$TMP_FILE" >/dev/null
    fi
    $OPTIPNG -strip all -nc "$ASSETS_DIR/$id.png" 2>/dev/null
  fi
done < "$INDEX"

rm -f "$TMP_FILE"

if [[ "$TYPE" == "icons" ]]; then
  cd "$ASSETS_DIR" || exit 1
  cp -a archlinux.png arch.png
  cp -a gnu-linux.png linux.png
  cp -a gnu-linux.png unknown.png
  cp -a gnu-linux.png lfs.png
  cp -a manjaro.png Manjaro.i686.png
  cp -a manjaro.png Manjaro.x86_64.png
  cp -a manjaro.png manjarolinux.png
  cp -a pop-os.png pop.png
  cp -a driver.png memtest.png
fi
exit 0
