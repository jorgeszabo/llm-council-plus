#!/bin/bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "Starting LLM Council Plus from:"
echo "$REPO_ROOT"
echo ""

./start.sh
