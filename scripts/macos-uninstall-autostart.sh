#!/bin/bash

set -euo pipefail

LABEL="com.jorgeszabo.llm-council-plus"
PLIST_PATH="$HOME/Library/LaunchAgents/$LABEL.plist"
LAUNCHCTL_DOMAIN="gui/$(id -u)"

launchctl bootout "$LAUNCHCTL_DOMAIN" "$PLIST_PATH" 2>/dev/null || true
rm -f "$PLIST_PATH"

echo "LLM Council Plus autostart removed."
