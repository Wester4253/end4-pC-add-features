#!/usr/bin/env python3
"""Read AI usage from Oh My Pi (omp) agent transcripts.

OMP sessions are pi-harness transcripts: JSONL files under
~/.omp/agent/sessions/**/*.jsonl and ~/.pi/agent/sessions/**/*.jsonl
(assistant messages carry a `usage` object with input/output/cacheRead
tokens). Sidecar files such as `changes.jsonl` are ignored: only files
containing a `session` record are treated as transcripts.

Reports totals for the trailing 5h window, requests in the last minute,
and per-session busy/idle state. Prints a JSON object compatible with
the shell's usage services.
"""
import glob
import json
import os
import time
from datetime import datetime, timezone

WINDOW = 5 * 3600
BUSY_TIMEOUT = 10 * 60  # transcript silent for this long = no longer busy
NOW = time.time()

SESSION_GLOBS = [
    os.path.expanduser("~/.omp/agent/sessions/**/*.jsonl"),
    os.path.expanduser("~/.pi/agent/sessions/**/*.jsonl"),
]


def parse_ts(entry):
    ts = entry.get("timestamp")
    if ts is None:
        return None
    if isinstance(ts, (int, float)):  # epoch milliseconds (message.timestamp)
        return ts / 1000.0
    try:
        return datetime.fromisoformat(str(ts).replace("Z", "+00:00")).timestamp()
    except ValueError:
        return None


def session_state(entries):
    """Derive (cwd, model, last_ts, busy) from parsed transcript entries."""
    cwd, model, last_ts = "", "", 0.0
    last_assistant_stop, last_role = None, None
    for entry in entries:
        ts = parse_ts(entry) or 0.0
        last_ts = max(last_ts, ts)
        etype = entry.get("type")
        if etype == "session":
            cwd = entry.get("cwd") or cwd
            continue
        message = entry.get("message")
        if not isinstance(message, dict):
            continue
        role = message.get("role")
        if role:
            last_role = role
        if role == "assistant":
            if message.get("model"):
                model = message["model"]
            if message.get("stopReason"):
                last_assistant_stop = message["stopReason"]

    # Mid-turn: the transcript ends with a pending tool call or result.
    mid_turn = last_role == "toolResult" or last_assistant_stop == "toolUse"
    busy = mid_turn and (NOW - last_ts) < BUSY_TIMEOUT
    return cwd, model, last_ts, busy


def main():
    tokens = 0
    requests_last_minute = 0
    window_requests = []  # timestamps of usage-carrying responses in the window
    models = {}
    sessions = []
    seen = set()

    for pattern in SESSION_GLOBS:
        for path in glob.glob(pattern, recursive=True):
            if path in seen:
                continue
            seen.add(path)
            try:
                if NOW - os.path.getmtime(path) > WINDOW * 2:
                    continue
                with open(path, errors="ignore") as f:
                    entries = []
                    for line in f:
                        if '"usage"' not in line and '"role"' not in line \
                           and '"type":"session"' not in line:
                            continue
                        try:
                            entries.append(json.loads(line))
                        except ValueError:
                            continue
            except OSError:
                continue

            if not any(e.get("type") == "session" for e in entries):
                continue  # changes.jsonl and other sidecars

            usage_entries = []
            for entry in entries:
                if not entry:
                    continue
                ts = parse_ts(entry)
                message = entry.get("message") or {}
                usage = message.get("usage")
                if usage and ts:
                    count = (usage.get("input") or 0) + (usage.get("output") or 0) \
                        + (usage.get("cacheRead") or 0)
                    usage_entries.append((ts, count, message.get("model") or "?"))
                    if NOW - ts <= 60:
                        requests_last_minute += 1
                    if NOW - ts <= WINDOW:
                        window_requests.append(ts)
                        tokens += count
                        model = message.get("model") or "?"
                        models[model] = models.get(model, 0) + count

            cwd, model, last_ts, busy = session_state(entries)
            if last_ts <= 0 or NOW - last_ts > WINDOW:
                continue  # dormant: no activity in the usage window
            name = os.path.basename(cwd.rstrip("/")) if cwd else os.path.basename(path)
            sessions.append({
                "name": name,
                "status": "busy" if busy else "idle",
                "cwd": cwd,
                "model": model,
                "lastActiveAt": int(last_ts),
            })

    sessions.sort(key=lambda s: -s["lastActiveAt"])
    resets_at = int(min(window_requests) + WINDOW) if window_requests else 0

    print(json.dumps({
        "available": True,
        "tokens": tokens,
        "requestsLastMinute": requests_last_minute,
        "rpmLimit": int(os.environ.get("NIM_RPM_LIMIT", "40")),
        "resetsAt": resets_at,
        "activeSessions": sum(1 for s in sessions if s["status"] == "busy"),
        "sessions": sessions,
        "models": sorted(models.items(), key=lambda kv: -kv[1]),
    }))


if __name__ == "__main__":
    main()
