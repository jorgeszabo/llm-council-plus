# Local Device Setup

Use these notes when this repo syncs to a new Mac through iCloud Drive.

## Folder

Main work copy:

```bash
/Users/jorgeszabo/Documents/AI Tools/llm-council-plus
```

Use this copy instead of the old folder under `/Users/jorgeszabo/llm-council-plus`.

## First Setup On Each Mac

Let iCloud fully download the folder first. Then install machine-local dependencies:

```bash
cd "/Users/jorgeszabo/Documents/AI Tools/llm-council-plus/frontend"
npm install
```

If backend dependencies are missing:

```bash
cd "/Users/jorgeszabo/Documents/AI Tools/llm-council-plus"
uv sync
```

`node_modules`, Python environments, and caches are machine-specific. Reinstall them per device instead of relying on iCloud to sync them.

## Start The App

Run from the repo root, not from `frontend`:

```bash
cd "/Users/jorgeszabo/Documents/AI Tools/llm-council-plus"
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

## Start Automatically After Login

The installed PWA cannot start local shell commands by itself.

Because this repo lives in iCloud Drive under `Documents`, macOS privacy protections may block background LaunchAgents from reading the folder. The most reliable option is to use the `.command` launcher and add it to Login Items.

First make sure it is executable:

```bash
cd "/Users/jorgeszabo/Documents/AI Tools/llm-council-plus"
chmod +x "scripts/Start LLM Council.command"
```

Then add this file to macOS Login Items:

```text
/Users/jorgeszabo/Documents/AI Tools/llm-council-plus/scripts/Start LLM Council.command
```

System Settings path:

```text
System Settings > General > Login Items & Extensions > Open at Login
```

Click `+`, choose `Start LLM Council.command`, and add it.

After login, Terminal will open and start the backend/frontend. Then open the installed PWA from the Dock or Applications.

### LaunchAgent Option

There is also a LaunchAgent helper:

```bash
./scripts/macos-install-autostart.sh
```

For this iCloud Documents setup, use it only if macOS has permission to let background shell processes read the folder. If logs show `Operation not permitted`, use the Login Items `.command` method above instead.

Logs are written to:

```text
~/Library/Logs/llm-council-plus/start.log
~/Library/Logs/llm-council-plus/error.log
```

To remove autostart:

```bash
cd "/Users/jorgeszabo/Documents/AI Tools/llm-council-plus"
./scripts/macos-uninstall-autostart.sh
```

## Installed PWA

If autostart is installed, open the installed LLM Council app from the Dock or Applications after login.

If autostart is not installed, start the app with `./start.sh` first, then open the installed PWA.

## Managed Launcher App

The PWA itself cannot start or stop local shell commands. To get app-like behavior, create the managed macOS launcher:

```bash
cd "/Users/jorgeszabo/Documents/50_Projects/LLM-Council-Plus"
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
