#!/usr/bin/env python3
"""Read AI usage from Oh My Pi (omp) session files (~/.omp/agent/sessions/**/*.jsonl).

Each assistant message carries a `usage` object (input/output/cacheRead tokens).
Reports totals for the last 5h window and active agent processes.
Prints a JSON object compatible with the shell's usage services.
"""
import glob
import json
import os
import time
from datetime import datetime

SESSIONS_DIR = os.path.expanduser("~/.omp/agent/sessions")
WINDOW = 5 * 3600
now = time.time()

tokens = 0
models = {}
requests_last_minute = 0

for path in glob.glob(os.path.join(SESSIONS_DIR, "**", "*.jsonl"), recursive=True):
    try:
        if now - os.path.getmtime(path) > WINDOW * 2:
            continue
        with open(path, errors="ignore") as f:
            for line in f:
                if '"usage"' not in line:
                    continue
                try:
                    data = json.loads(line)
                except ValueError:
                    continue
                ts = data.get("timestamp")
                if not ts:
                    continue
                try:
                    t = datetime.fromisoformat(ts.replace("Z", "+00:00")).timestamp()
                except ValueError:
                    continue
                if now - t > WINDOW:
                    continue
                if now - t <= 60:
                    requests_last_minute += 1
                message = data.get("message") or {}
                usage = message.get("usage")
                if not usage:
                    continue
                model = message.get("model") or "?"
                count = (usage.get("input") or 0) + (usage.get("output") or 0) + (usage.get("cacheRead") or 0)
                tokens += count
                models[model] = models.get(model, 0) + count
    except OSError:
        continue

# Active omp agent processes (best effort via /proc)
sessions = []
me = os.getpid()
for pid_dir in glob.glob("/proc/[0-9]*"):
    pid = os.path.basename(pid_dir)
    if pid == str(me):
        continue
    try:
        with open(f"{pid_dir}/comm") as f:
            comm = f.read().strip()
        if comm not in ("omp", "oh-my-pi", "node"):
            continue
        with open(f"{pid_dir}/cmdline", "rb") as f:
            cmdline = f.read().decode(errors="ignore")
        if "omp" not in cmdline or "quickshell" in cmdline:
            continue
        # Label from the process working directory
        label = "omp agent"
        try:
            cwd = os.path.realpath(f"{pid_dir}/cwd")
            if cwd.startswith("/home/") and cwd != os.path.expanduser("~"):
                label = os.path.basename(cwd)
        except OSError:
            pass
        sessions.append({"name": label, "status": "busy", "cwd": ""})
    except OSError:
        continue

print(json.dumps({
    "available": True,
    "tokens": tokens,
    "requestsLastMinute": requests_last_minute,
    "rpmLimit": int(os.environ.get("NIM_RPM_LIMIT", "40")),
    "resetsAt": 0,
    "activeSessions": len(sessions),
    "sessions": sessions,
    "models": sorted(models.items(), key=lambda kv: -kv[1]),
}))
