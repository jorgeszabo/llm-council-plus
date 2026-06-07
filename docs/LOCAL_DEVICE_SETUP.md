# Local Device Setup

Use these notes when setting up or moving LLM Council Plus on a Mac.

## Folder

Main work copy:

```bash
/Users/jorgeszabo/Developer/LLM Council Plus
```

Use this Developer copy instead of iCloud/Documents folders. Developer folders avoid iCloud placeholder files, sync locks, and macOS Documents privacy issues.

Compatibility symlink:

```text
/Users/jorgeszabo/Documents/50_Projects/LLM-Council-Plus -> /Users/jorgeszabo/Developer/LLM Council Plus
```

## First Setup On Each Mac

For a fresh Mac, the simplest install is:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/jorgeszabo/llm-council-plus/codex-pwa-app/scripts/install-macos.sh)"
```

This clones the custom branch, installs dependencies, creates the launcher app, and opens it. It does not copy Jorge's API keys or conversations.

Install machine-local dependencies:

```bash
cd "/Users/jorgeszabo/Developer/LLM Council Plus/frontend"
npm install
```

If backend dependencies are missing:

```bash
cd "/Users/jorgeszabo/Developer/LLM Council Plus"
uv sync
```

`node_modules`, Python environments, and caches are machine-specific. Reinstall them per device instead of syncing them.

## Start The App

Run from the repo root, not from `frontend`:

```bash
cd "/Users/jorgeszabo/Developer/LLM Council Plus"
./start.sh
```

Open:

```text
http://localhost:5173
```

Backend runs on:

```text
http://localhost:8001
```

## Managed Launcher App

The PWA itself cannot start or stop local shell commands. To get app-like behavior, use the managed macOS launcher:

```bash
cd "/Users/jorgeszabo/Developer/LLM Council Plus"
./scripts/macos-create-managed-launcher.sh
```

This creates:

```text
~/Applications/LLM Council Plus Launcher.app
```

Put **LLM Council Plus Launcher.app** in the Dock instead of the Chrome PWA icon.

When opened, it:

1. Starts the backend on `localhost:8001` if needed.
2. Starts the frontend on `localhost:5173` if needed.
3. Opens the installed Chrome PWA.
4. Waits for the PWA to quit.
5. Stops only the server processes it started.

Logs are written to:

```text
~/Library/Logs/llm-council-plus/managed-launcher.log
~/Library/Logs/llm-council-plus/managed-backend.log
~/Library/Logs/llm-council-plus/managed-frontend.log
```

## Start Automatically After Login

The installed PWA cannot start local shell commands by itself.

If you want LLM Council to start automatically after login, add the managed launcher app to Login Items:

```text
~/Applications/LLM Council Plus Launcher.app
```

System Settings path:

```text
System Settings > General > Login Items & Extensions > Open at Login
```

Click `+`, choose `LLM Council Plus Launcher.app`, and add it.

Alternative terminal-based launcher:

```bash
cd "/Users/jorgeszabo/Developer/LLM Council Plus"
chmod +x "scripts/Start LLM Council.command"
```

Then add this file to Login Items if you prefer seeing a Terminal window:

```text
/Users/jorgeszabo/Developer/LLM Council Plus/scripts/Start LLM Council.command
```

### LaunchAgent Option

There is also a LaunchAgent helper:

```bash
./scripts/macos-install-autostart.sh
```

Now that the repo is in `~/Developer`, the LaunchAgent is less likely to hit macOS Documents privacy restrictions. The managed launcher app is still the preferred path because it can stop the servers when the PWA quits.

Logs are written to:

```text
~/Library/Logs/llm-council-plus/start.log
~/Library/Logs/llm-council-plus/error.log
```

To remove autostart:

```bash
cd "/Users/jorgeszabo/Developer/LLM Council Plus"
./scripts/macos-uninstall-autostart.sh
```

## Installed PWA

If autostart is installed, open the installed LLM Council app from the Dock or Applications after login.

If autostart is not installed, start the app with `./start.sh` first, then open the installed PWA.

If the installed app shows an old icon or old behavior, remove/reinstall the PWA from Chrome:

1. Open `http://localhost:5173` in Chrome.
2. Remove the old installed app from Chrome apps or the app menu.
3. Reload the page.
4. Install it again.

## Settings And Conversations

Local settings and conversations live in:

```text
data/settings.json
data/conversations/
```

This includes configured council models, API keys, search provider settings, and conversation history. The `data/` folder is ignored by Git, so it will not be pushed to GitHub.

If setting up a new copy manually, make sure the `data/` folder is copied or synced before deleting the old copy.

## Git Branches

Custom app branch:

```text
codex-pwa-app
```

Remotes:

```text
origin = jacob-bd/llm-council-plus
fork   = jorgeszabo/llm-council-plus
```

Jacob's upstream updates stay on `origin/main`. Your PWA/theme changes stay on `codex-pwa-app`.
