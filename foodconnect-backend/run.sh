#!/usr/bin/env bash
set -euo pipefail

# Simple dev runner for the FoodConnect backend
export PYTHONPATH="$PYTHONPATH:$(pwd)"

# Default port can be overridden: PORT=8000 ./run.sh
PORT=${PORT:-8000}

exec uvicorn app.main:app \
  --host 0.0.0.0 \
  --port "$PORT" \
  --reload
