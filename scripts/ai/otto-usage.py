#!/usr/bin/env python3
"""Query Otto daemon over WebSocket JSON-RPC for agent status."""
import asyncio
import json
import os
import sys
import websockets

async def query_otto():
    host = os.environ.get("OTTO_HOST", "ws://localhost:6868")
    password = os.environ.get("OTTO_PASSWORD", "")
    
    try:
        # Ensure proper WebSocket URL format
        if not host.startswith(("ws://", "wss://")):
            if host.startswith("tcp://"):
                host = host.replace("tcp://", "ws://")
            else:
                host = f"ws://{host}"
        
        # Connect to Otto daemon
        async with websockets.connect(host) as ws:
            # Authenticate if password provided
            if password:
                auth_msg = {
                    "jsonrpc": "2.0",
                    "method": "auth",
                    "params": {"password": password},
                    "id": 1
                }
                await ws.send(json.dumps(auth_msg))
                response = await ws.recv()
                auth_result = json.loads(response)
                if not auth_result.get("result", {}).get("success", False):
                    return {"available": False, "error": "Authentication failed"}
            
            # Get agents list
            agents_msg = {
                "jsonrpc": "2.0",
                "method": "agents.list",
                "params": {},
                "id": 2
            }
            await ws.send(json.dumps(agents_msg))
            response = await ws.recv()
            agents_result = json.loads(response)
            
            agents = agents_result.get("result", {}).get("agents", [])
            
            active_sessions = sum(1 for a in agents if a.get("status") == "running")
            total_sessions = len(agents)
            
            attention_count = sum(1 for a in agents if a.get("needsAttention", False))
            pending_permission_count = sum(1 for a in agents if a.get("pendingPermission", False))
            
            # Get token usage if available
            tokens = 0
            for a in agents:
                tokens += a.get("tokenUsage", 0)
            
            return {
                "available": True,
                "host": host,
                "agents": agents,
                "activeSessions": active_sessions,
                "totalSessions": total_sessions,
                "attentionCount": attention_count,
                "pendingPermissionCount": pending_permission_count,
                "tokens": tokens,
                "resetsAt": 0  # Not provided by Otto daemon
            }
    except Exception as e:
        return {"available": False, "error": str(e)}

def main():
    try:
        result = asyncio.run(query_otto())
    except Exception as e:
        result = {"available": False, "error": str(e)}
    print(json.dumps(result))

if __name__ == "__main__":
    main()