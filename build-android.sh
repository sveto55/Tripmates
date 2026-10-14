#!/bin/bash
# Builds tripmates.apk from the web files in this folder.
set -e
rm -rf www android
mkdir www
cp index.html manifest.webmanifest sw.js icon-192.png icon-512.png www/
npm install --no-audit --no-fund
npx cap add android
npx cap sync android

# App icon: legacy PNGs plus an adaptive icon (blue background, logo on top)
RES=android/app/src/main/res
for d in mdpi:48:108 hdpi:72:162 xhdpi:96:216 xxhdpi:144:324 xxxhdpi:192:432; do
  IFS=: read name legacy fg <<< "$d"
  convert icon-512.png -resize ${legacy}x${legacy} $RES/mipmap-$name/ic_launcher.png
  convert icon-512.png -resize ${legacy}x${legacy} $RES/mipmap-$name/ic_launcher_round.png
  convert icon-512.png -resize ${fg}x${fg} $RES/mipmap-$name/ic_launcher_foreground.png
done
mkdir -p $RES/mipmap-anydpi-v26
cat > $RES/mipmap-anydpi-v26/ic_launcher.xml <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
  <background android:drawable="@color/ic_launcher_background"/>
  <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
XML
cp $RES/mipmap-anydpi-v26/ic_launcher.xml $RES/mipmap-anydpi-v26/ic_launcher_round.xml
cat > $RES/values/ic_launcher_background.xml <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<resources>
  <color name="ic_launcher_background">#1D5FD1</color>
</resources>
XML

cd android
chmod +x gradlew
./gradlew assembleDebug --no-daemon
cp app/build/outputs/apk/debug/app-debug.apk ../tripmates.apk
echo "APK ready: tripmates.apk"
