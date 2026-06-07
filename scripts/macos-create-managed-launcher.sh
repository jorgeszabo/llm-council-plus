#!/bin/bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAUNCHER_SCRIPT="$REPO_ROOT/scripts/managed-pwa-launcher.sh"
PWA_APP="${LLM_COUNCIL_PWA_APP:-$HOME/Applications/Chrome Apps.localized/LLM Council Plus.app}"
APP_DIR="$HOME/Applications"
APP_PATH="$APP_DIR/LLM Council Plus Launcher.app"
APPLESCRIPT="$(mktemp)"

mkdir -p "$APP_DIR"

cat > "$APPLESCRIPT" <<APPLESCRIPT
on run
  do shell script quoted form of "$LAUNCHER_SCRIPT"
end run
APPLESCRIPT

rm -rf "$APP_PATH"
osacompile -o "$APP_PATH" "$APPLESCRIPT"
rm -f "$APPLESCRIPT"

if [[ -f "$PWA_APP/Contents/Resources/app.icns" ]]; then
  cp "$PWA_APP/Contents/Resources/app.icns" "$APP_PATH/Contents/Resources/applet.icns"
  touch "$APP_PATH"
fi

echo "Created launcher app:"
echo "$APP_PATH"
echo ""
echo "Put this app in your Dock instead of the Chrome PWA icon."
echo "It starts LLM Council Plus, opens the PWA, and stops the servers when the PWA quits."
