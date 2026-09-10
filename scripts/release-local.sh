#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VERSION="$(tr -d '[:space:]' < VERSION)"
APP="$ROOT/dist/ProjectDock.app"
DMG="$ROOT/dist/ProjectDock-v${VERSION}.dmg"
STAGE="$ROOT/dist/dmg"

printf '\nProjectDock local release builder\n'
printf 'Version: %s\n\n' "$VERSION"

rm -rf "$ROOT/dist" "$ROOT/.build-arm64" "$ROOT/.build-x86_64"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

printf '→ Building Apple Silicon release...\n'
swift build -c release --arch arm64 --scratch-path .build-arm64

printf '→ Building Intel release...\n'
swift build -c release --arch x86_64 --scratch-path .build-x86_64

ARM_BIN="$(find .build-arm64 -type f -path '*/release/ProjectDock' | head -n 1)"
X86_BIN="$(find .build-x86_64 -type f -path '*/release/ProjectDock' | head -n 1)"

if [[ -z "$ARM_BIN" || -z "$X86_BIN" ]]; then
  echo 'Could not locate one or both compiled ProjectDock binaries.' >&2
  exit 1
fi

printf '→ Creating universal binary...\n'
lipo -create "$ARM_BIN" "$X86_BIN" -output "$APP/Contents/MacOS/ProjectDock"
chmod +x "$APP/Contents/MacOS/ProjectDock"

printf '→ Generating app icon...\n'
mkdir -p build/iconset
swift scripts/generate_icon.swift build/ProjectDock-1024.png

sips -z 16 16 build/ProjectDock-1024.png --out build/iconset/icon_16x16.png >/dev/null
sips -z 32 32 build/ProjectDock-1024.png --out build/iconset/icon_16x16@2x.png >/dev/null
sips -z 32 32 build/ProjectDock-1024.png --out build/iconset/icon_32x32.png >/dev/null
sips -z 64 64 build/ProjectDock-1024.png --out build/iconset/icon_32x32@2x.png >/dev/null
sips -z 128 128 build/ProjectDock-1024.png --out build/iconset/icon_128x128.png >/dev/null
sips -z 256 256 build/ProjectDock-1024.png --out build/iconset/icon_128x128@2x.png >/dev/null
sips -z 256 256 build/ProjectDock-1024.png --out build/iconset/icon_256x256.png >/dev/null
sips -z 512 512 build/ProjectDock-1024.png --out build/iconset/icon_256x256@2x.png >/dev/null
sips -z 512 512 build/ProjectDock-1024.png --out build/iconset/icon_512x512.png >/dev/null
cp build/ProjectDock-1024.png build/iconset/icon_512x512@2x.png
iconutil -c icns build/iconset -o "$APP/Contents/Resources/ProjectDock.icns"

printf '→ Writing app metadata...\n'
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>ProjectDock</string>
    <key>CFBundleIconFile</key>
    <string>ProjectDock</string>
    <key>CFBundleIdentifier</key>
    <string>com.jayybg.ProjectDock</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>ProjectDock</string>
    <key>CFBundleDisplayName</key>
    <string>ProjectDock</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${VERSION}</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

plutil -lint "$APP/Contents/Info.plist" >/dev/null

printf '→ Ad-hoc signing ProjectDock.app...\n'
codesign --force --deep --sign - "$APP"
codesign --verify --deep --strict "$APP"

printf '→ Creating drag-to-Applications DMG...\n'
mkdir -p "$STAGE"
ditto "$APP" "$STAGE/ProjectDock.app"
ln -s /Applications "$STAGE/Applications"

hdiutil create \
  -volname "ProjectDock" \
  -srcfolder "$STAGE" \
  -ov \
  -format UDZO \
  "$DMG" >/dev/null

hdiutil verify "$DMG" >/dev/null

printf '\n✓ Release created successfully\n'
printf '  %s\n\n' "$DMG"
printf 'SHA-256: '
shasum -a 256 "$DMG" | awk '{print $1}'

printf '\nOpen dist/ and upload ProjectDock-v%s.dmg to the GitHub v%s release.\n' "$VERSION" "$VERSION"
