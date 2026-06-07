#!/bin/bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PWA_APP="${LLM_COUNCIL_PWA_APP:-$HOME/Applications/Chrome Apps.localized/LLM Council Plus.app}"
LOG_DIR="$HOME/Library/Logs/llm-council-plus"
BACKEND_LOG="$LOG_DIR/managed-backend.log"
FRONTEND_LOG="$LOG_DIR/managed-frontend.log"
LAUNCHER_LOG="$LOG_DIR/managed-launcher.log"
BACKEND_PID=""
FRONTEND_PID=""

mkdir -p "$LOG_DIR"

log() {
  printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$LAUNCHER_LOG"
}

is_listening() {
  lsof -nP -iTCP:"$1" -sTCP:LISTEN >/dev/null 2>&1
}

wait_for_port() {
  local port="$1"
  local name="$2"
  local tries=60

  for ((i = 1; i <= tries; i++)); do
    if is_listening "$port"; then
      log "$name is ready on port $port."
      return 0
    fi
    sleep 1
  done

  log "$name did not become ready on port $port."
  return 1
}

stop_pid_tree() {
  local pid="$1"
  [[ -z "$pid" ]] && return 0
  kill "$pid" 2>/dev/null || true
  pkill -P "$pid" 2>/dev/null || true
}

cleanup() {
  log "Stopping LLM Council Plus processes started by this launcher."
  stop_pid_tree "$FRONTEND_PID"
  stop_pid_tree "$BACKEND_PID"
}

trap cleanup EXIT INT TERM

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.local/bin"

log "Launcher starting from $REPO_ROOT."

if is_listening 8001; then
  log "Backend already running on port 8001; leaving it alone."
else
  log "Starting backend on http://localhost:8001."
  (
    cd "$REPO_ROOT"
    LLM_COUNCIL_BIND_HOST=127.0.0.1 uv run python -m backend.main
  ) >>"$BACKEND_LOG" 2>&1 &
  BACKEND_PID="$!"
  wait_for_port 8001 "Backend"
fi

if is_listening 5173; then
  log "Frontend already running on port 5173; leaving it alone."
else
  log "Starting frontend on http://localhost:5173."
  (
    cd "$REPO_ROOT/frontend"
    npm run dev -- --host 127.0.0.1
  ) >>"$FRONTEND_LOG" 2>&1 &
  FRONTEND_PID="$!"
  wait_for_port 5173 "Frontend"
fi

if [[ -d "$PWA_APP" ]]; then
  log "Opening installed PWA: $PWA_APP"
  open -W "$PWA_APP"
else
  log "Installed PWA was not found. Opening browser URL instead."
  open "http://localhost:5173"
  osascript -e 'display dialog "LLM Council Plus is running. Close this dialog when you want to stop the servers." buttons {"Stop"} default button "Stop" with title "LLM Council Plus"'
fi

log "PWA closed."
