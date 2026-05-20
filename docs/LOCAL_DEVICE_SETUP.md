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

## Installed PWA

Start the app with `./start.sh` first, then open the installed LLM Council app from the Dock or Applications.

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
