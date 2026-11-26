#!/bin/sh
# Memasang ikon aplikasi + gambar layar pembuka (Android & iOS) dari SATU
# gambar logo.
#
#   sh tool/branding/apply_icons.sh jalur/ke/logo.png
#
# Syarat gambar: persegi, 1024 px (minimal 512), logo BERWARNA di atas latar
# putih. Butuh macOS (kompilator `swiftc` dari Xcode).
set -eu

if [ "$#" -ne 1 ]; then
  echo "pemakaian: sh tool/branding/apply_icons.sh <logo.png>" >&2
  exit 1
fi

SRC=$1
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

swiftc -O "$ROOT/tool/branding/mkicons.swift" -o "$WORK/mkicons"
"$WORK/mkicons" "$SRC" "$WORK/out"

RES="$ROOT/android/app/src/main/res"
for d in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
  cp "$WORK/out/android/mipmap-$d/"*.png "$RES/mipmap-$d/"
  cp "$WORK/out/android/drawable-$d/ic_launch_image.png" "$RES/drawable-$d/"
done

IOS="$ROOT/ios/Runner"
for s in @1x @2x @3x; do
  cp "$WORK/out/ios/LaunchImage$s.png" \
    "$IOS/Assets.xcassets/LaunchImage.imageset/LaunchImage$s.png"
done
for icon in AppIcon AppIcon-dev AppIcon-stg; do
  cp "$WORK/out/ios/Logo.png" "$IOS/AppIcons/$icon.icon/Assets/Logo.png"
done

# Ikon 512 px untuk halaman toko (Play Console).
cp "$WORK/out/android/ic_launcher-playstore.png" \
  "$ROOT/tool/branding/store-icon-512.png"

echo "Ikon terpasang. Periksa hasilnya di perangkat sebelum rilis."
