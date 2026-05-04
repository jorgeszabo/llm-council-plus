# LLM Council Plus Frontend

Vite-powered React frontend for LLM Council Plus.

## Run Locally

From the repository root, use the combined launcher:

```bash
./start.sh
```

Or start the frontend directly:

```bash
cd frontend
npm run dev
```

The frontend runs on `http://localhost:5173` and talks to the backend on `http://localhost:8001`.

## Install As An App

LLM Council Plus is configured as a Progressive Web App. After starting the servers, open `http://localhost:5173` in Chrome or Edge and use the **Install App** button in the sidebar. The installed app opens in a standalone window and keeps using the local backend on port `8001`.

The backend and frontend still need to be running, usually via `./start.sh`, before the installed app can talk to models and load conversations.
