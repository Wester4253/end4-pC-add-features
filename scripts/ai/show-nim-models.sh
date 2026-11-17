#!/usr/bin/env bash
# Prints NVIDIA NIM chat models available to the user's key as a JSON array of model IDs.
# The key is taken from, in order:
#   1. $NIM_API_KEY / $NVAPI_KEY env
#   2. Oh My Pi's keyring DB (~/.omp/agent/agent.db, provider "nvidia")
#   3. The shell's keyring (via secret-tool, label like illogical-impulse Safe Storage) - not used here
# Prints nothing (and exits 0) if no key is found, so the shell can skip silently.
set -euo pipefail

KEY="${NIM_API_KEY:-${NVAPI_KEY:-}}"
if [ -z "$KEY" ] && [ -f "$HOME/.omp/agent/agent.db" ] && command -v sqlite3 >/dev/null 2>&1; then
    KEY=$(sqlite3 "$HOME/.omp/agent/agent.db" \
        "select json_extract(data,'\$.key') from auth_credentials where provider='nvidia' limit 1" 2>/dev/null || true)
fi
if [ -z "$KEY" ]; then
    exit 0
fi

# Only chat-capable models are useful here; filter obvious embed/rerank/vision-only ones.
curl -sS --max-time 20 "https://integrate.api.nvidia.com/v1/models" \
    -H "Authorization: Bearer $KEY" |
python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)["data"]
except Exception:
    sys.exit(0)
skip = ("embed", "rerank", "clip", "guard", "safety", "detector", "riva", "calibration")
models = [m["id"] for m in data if not any(s in m["id"].lower() for s in skip)]
print(json.dumps(models))
'
