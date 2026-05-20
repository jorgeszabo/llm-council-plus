#!/bin/bash

set -euo pipefail

LABEL="com.jorgeszabo.llm-council-plus"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLIST_DIR="$HOME/Library/LaunchAgents"
PLIST_PATH="$PLIST_DIR/$LABEL.plist"
LOG_DIR="$HOME/Library/Logs/llm-council-plus"
LAUNCHCTL_DOMAIN="gui/$(id -u)"
START_NOW="true"

if [[ "${1:-}" == "--no-start" ]]; then
  START_NOW="false"
fi

mkdir -p "$PLIST_DIR" "$LOG_DIR"

cat > "$PLIST_PATH" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>

  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>$REPO_ROOT/start.sh</string>
  </array>

  <key>WorkingDirectory</key>
  <string>$REPO_ROOT</string>

  <key>RunAtLoad</key>
  <true/>

  <key>KeepAlive</key>
  <false/>

  <key>EnvironmentVariables</key>
  <dict>
    <key>PATH</key>
    <string>/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.local/bin</string>
    <key>LLM_COUNCIL_BIND_HOST</key>
    <string>127.0.0.1</string>
  </dict>

  <key>StandardOutPath</key>
  <string>$LOG_DIR/start.log</string>

  <key>StandardErrorPath</key>
  <string>$LOG_DIR/error.log</string>
</dict>
</plist>
PLIST

launchctl bootout "$LAUNCHCTL_DOMAIN" "$PLIST_PATH" 2>/dev/null || true
launchctl bootstrap "$LAUNCHCTL_DOMAIN" "$PLIST_PATH"

if [[ "$START_NOW" == "true" ]]; then
  launchctl kickstart -k "$LAUNCHCTL_DOMAIN/$LABEL"
fi

echo "LLM Council Plus autostart installed."
echo "LaunchAgent: $PLIST_PATH"
if [[ "$START_NOW" == "false" ]]; then
  echo "The app will start automatically at next login."
else
  echo "The app was started now."
fi
echo "Logs:"
echo "  $LOG_DIR/start.log"
echo "  $LOG_DIR/error.log"
