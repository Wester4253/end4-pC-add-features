#!/usr/bin/env python3
"""Read Oh My Pi (OMP) session files to get token usage and active agents."""
import json
import os
import glob
import time
from pathlib import Path
from datetime import datetime, timedelta

def read_omp_usage():
    """Parse OMP session files for usage statistics."""
    home = Path(os.environ.get("OMP_HOME", Path.home() / ".omp"))
    
    # OMP session directory
    sessions_dir = home / "sessions"
    if not sessions_dir.exists():
        return {"available": False}
    
    now = time.time()
    window = 5 * 3600  # 5 hour window
    
    total_tokens = 0
    requests_last_minute = 0
    active_sessions = 0
    sessions_list = []
    models_set = set()
    rpm_limit = 40  # Default RPM limit for NIM
    
    # Check session files
    for session_file in sessions_dir.glob("*.json"):
        try:
            with open(session_file) as f:
                session = json.load(f)
        except Exception:
            continue
        
        # Check if process is still alive
        pid = session.get("pid")
        if pid and os.path.exists(f"/proc/{pid}"):
            active_sessions += 1
            sessions_list.append({
                "name": session.get("name", ""),
                "model": session.get("model", ""),
                "cwd": session.get("cwd", ""),
                "pid": pid
            })
            if session.get("model"):
                models_set.add(session.get("model"))
        
        # Parse usage from session log
        log_file = session.get("logFile")
        if log_file and Path(log_file).exists():
            try:
                with open(log_file, errors="ignore") as f:
                    for line in f:
                        try:
                            entry = json.loads(line)
                            if entry.get("type") == "usage":
                                ts = entry.get("timestamp", 0)
                                if now - ts <= window:
                                    total_tokens += entry.get("tokens", 0)
                                if now - ts <= 60:
                                    requests_last_minute += 1
                        except Exception:
                            continue
            except Exception:
                continue
    
    return {
        "available": True,
        "tokens": total_tokens,
        "requestsLastMinute": requests_last_minute,
        "rpmLimit": rpm_limit,
        "activeSessions": active_sessions,
        "sessions": sessions_list,
        "models": list(models_set)
    }

if __name__ == "__main__":
    print(json.dumps(read_omp_usage()))