#!/bin/bash

# Finclar AI - Icon Generator
# Generates all iOS and Android icon sizes from 1024x1024 source PNG

SRC="/Users/Efe/Projects/Mobile/finclar_ai/assets/icons/1024x1024-icon.png"
BASE="/Users/Efe/Projects/Mobile/finclar_ai/assets/icons"

echo "Generating Finclar AI icons..."

# ─── iOS ──────────────────────────────────────────────────────────────────────
IOS_DIR="$BASE/ios"
mkdir -p "$IOS_DIR"

for SIZE in 20 29 40 58 60 76 80 87 120 152 167 180 1024; do
  OUT="$IOS_DIR/icon-${SIZE}x${SIZE}.png"
  sips -z "$SIZE" "$SIZE" "$SRC" --out "$OUT" > /dev/null 2>&1
  echo "  iOS ${SIZE}x${SIZE}"
done

# ─── Android launcher icons ───────────────────────────────────────────────────
generate_android() {
  local DENSITY=$1
  local SIZE=$2
  local DIR="$BASE/android/mipmap-$DENSITY"
  mkdir -p "$DIR"
  sips -z "$SIZE" "$SIZE" "$SRC" --out "$DIR/ic_launcher.png" > /dev/null 2>&1
  echo "  Android launcher $DENSITY ${SIZE}x${SIZE}"
}

generate_android mdpi    48
generate_android hdpi    72
generate_android xhdpi   96
generate_android xxhdpi  144
generate_android xxxhdpi 192

# Play Store
mkdir -p "$BASE/android/store"
sips -z 512 512 "$SRC" --out "$BASE/android/store/ic_launcher_512x512.png" > /dev/null 2>&1
echo "  Android Play Store 512x512"

# ─── Android adaptive icon foreground ────────────────────────────────────────
generate_adaptive() {
  local DENSITY=$1
  local SIZE=$2
  local DIR="$BASE/android/mipmap-$DENSITY"
  mkdir -p "$DIR"
  sips -z "$SIZE" "$SIZE" "$SRC" --out "$DIR/ic_launcher_foreground.png" > /dev/null 2>&1
  echo "  Android adaptive foreground $DENSITY ${SIZE}x${SIZE}"
}

generate_adaptive mdpi    108
generate_adaptive hdpi    162
generate_adaptive xhdpi   216
generate_adaptive xxhdpi  324
generate_adaptive xxxhdpi 432

echo ""
echo "Done! Icons saved to:"
echo "   iOS     -> $IOS_DIR"
echo "   Android -> $BASE/android"
