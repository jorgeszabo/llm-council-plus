#!/bin/bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAUNCHER_SCRIPT="$REPO_ROOT/scripts/managed-pwa-launcher.sh"
PWA_APP="${LLM_COUNCIL_PWA_APP:-$HOME/Applications/Chrome Apps.localized/LLM Council Plus.app}"
SVG_ICON="$REPO_ROOT/frontend/public/app-icon-v2.svg"
APP_DIR="$HOME/Applications"
APP_PATH="$APP_DIR/LLM Council Plus Launcher.app"
APPLESCRIPT="$(mktemp)"

mkdir -p "$APP_DIR"

create_icns_from_svg() {
  local svg_path="$1"
  local icns_path="$2"
  local work_dir
  local base_png
  local iconset

  command -v qlmanage >/dev/null 2>&1 || return 1
  command -v sips >/dev/null 2>&1 || return 1
  command -v iconutil >/dev/null 2>&1 || return 1

  work_dir="$(mktemp -d)"
  iconset="$work_dir/AppIcon.iconset"
  mkdir -p "$iconset"

  qlmanage -t -s 1024 -o "$work_dir" "$svg_path" >/dev/null 2>&1 || return 1
  base_png="$(find "$work_dir" -maxdepth 1 -type f -name '*.png' | head -n 1)"
  [[ -n "$base_png" ]] || return 1

  sips -z 16 16 "$base_png" --out "$iconset/icon_16x16.png" >/dev/null
  sips -z 32 32 "$base_png" --out "$iconset/icon_16x16@2x.png" >/dev/null
  sips -z 32 32 "$base_png" --out "$iconset/icon_32x32.png" >/dev/null
  sips -z 64 64 "$base_png" --out "$iconset/icon_32x32@2x.png" >/dev/null
  sips -z 128 128 "$base_png" --out "$iconset/icon_128x128.png" >/dev/null
  sips -z 256 256 "$base_png" --out "$iconset/icon_128x128@2x.png" >/dev/null
  sips -z 256 256 "$base_png" --out "$iconset/icon_256x256.png" >/dev/null
  sips -z 512 512 "$base_png" --out "$iconset/icon_256x256@2x.png" >/dev/null
  sips -z 512 512 "$base_png" --out "$iconset/icon_512x512.png" >/dev/null
  sips -z 1024 1024 "$base_png" --out "$iconset/icon_512x512@2x.png" >/dev/null

  iconutil -c icns "$iconset" -o "$icns_path"
  rm -rf "$work_dir"
}

cat > "$APPLESCRIPT" <<APPLESCRIPT
on run
  do shell script quoted form of "$LAUNCHER_SCRIPT"
end run
APPLESCRIPT

rm -rf "$APP_PATH"
osacompile -o "$APP_PATH" "$APPLESCRIPT"
rm -f "$APPLESCRIPT"

ICON_PATH=""
ICON_TEMP=""

if [[ -f "$PWA_APP/Contents/Resources/app.icns" ]]; then
  ICON_PATH="$PWA_APP/Contents/Resources/app.icns"
elif [[ -f "$SVG_ICON" ]]; then
  ICON_PATH="$(mktemp -t llm-council-icon).icns"
  ICON_TEMP="$ICON_PATH"
  create_icns_from_svg "$SVG_ICON" "$ICON_PATH" || ICON_PATH=""
fi

if [[ -n "$ICON_PATH" && -f "$ICON_PATH" ]]; then
  cp "$ICON_PATH" "$APP_PATH/Contents/Resources/AppIcon.icns"
  cp "$ICON_PATH" "$APP_PATH/Contents/Resources/applet.icns"
  /usr/libexec/PlistBuddy -c "Set :CFBundleIconFile AppIcon" "$APP_PATH/Contents/Info.plist"
  /usr/libexec/PlistBuddy -c "Delete :CFBundleIconName" "$APP_PATH/Contents/Info.plist" 2>/dev/null || true
fi

if [[ -n "$ICON_TEMP" ]]; then
  rm -f "$ICON_TEMP"
fi

codesign --force --deep --sign - "$APP_PATH" >/dev/null 2>&1 || true
touch "$APP_PATH"

echo "Created launcher app:"
echo "$APP_PATH"
echo ""
echo "Put this app in your Dock instead of the Chrome PWA icon."
echo "It starts LLM Council Plus, opens the PWA, and stops the servers when the PWA quits."
