#!/bin/bash

set -euo pipefail

REPO_URL="${LLM_COUNCIL_REPO_URL:-https://github.com/jorgeszabo/llm-council-plus.git}"
BRANCH="${LLM_COUNCIL_BRANCH:-codex-pwa-app}"
INSTALL_DIR="${LLM_COUNCIL_INSTALL_DIR:-$HOME/Developer/LLM Council Plus}"

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.local/bin"

log() {
  printf '\n==> %s\n' "$*"
}

need_command() {
  command -v "$1" >/dev/null 2>&1
}

install_with_brew() {
  local package="$1"

  if ! need_command brew; then
    echo "Homebrew is required to install missing dependency: $package"
    echo "Install Homebrew first, then run this installer again:"
    echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
  fi

  brew list "$package" >/dev/null 2>&1 || brew install "$package"
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This installer is for macOS."
  exit 1
fi

if ! need_command git; then
  echo "Git is required. If macOS prompts you to install Command Line Tools, accept it, then rerun this installer."
  xcode-select --install 2>/dev/null || true
  exit 1
fi

if ! need_command node || ! need_command npm; then
  log "Installing Node.js with Homebrew"
  install_with_brew node
fi

if ! need_command uv; then
  log "Installing uv with Homebrew"
  install_with_brew uv
fi

log "Installing LLM Council Plus"
mkdir -p "$(dirname "$INSTALL_DIR")"

if [[ -d "$INSTALL_DIR/.git" ]]; then
  log "Updating existing checkout at $INSTALL_DIR"
  cd "$INSTALL_DIR"
  git fetch origin "$BRANCH"
  git switch "$BRANCH" 2>/dev/null || git switch -c "$BRANCH" --track "origin/$BRANCH"
  git pull --ff-only origin "$BRANCH"
else
  if [[ -e "$INSTALL_DIR" ]]; then
    echo "Install path exists but is not a Git checkout:"
    echo "$INSTALL_DIR"
    echo "Move it aside or set LLM_COUNCIL_INSTALL_DIR to another path."
    exit 1
  fi

  git clone --branch "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
  cd "$INSTALL_DIR"
fi

log "Installing backend dependencies"
uv sync

log "Installing frontend dependencies"
cd "$INSTALL_DIR/frontend"
npm install
cd "$INSTALL_DIR"

log "Creating managed launcher app"
chmod +x scripts/*.sh "scripts/Start LLM Council.command" 2>/dev/null || true
./scripts/macos-create-managed-launcher.sh

cat <<DONE

LLM Council Plus is installed.

Launcher:
  $HOME/Applications/LLM Council Plus Launcher.app

Next steps:
  1. Open "LLM Council Plus Launcher.app".
  2. If Chrome opens localhost, install the PWA from Chrome.
  3. Configure API keys and council models in Settings.

No API keys or conversations were copied from Jorge's machine.
DONE

open "$HOME/Applications/LLM Council Plus Launcher.app"
