#!/usr/bin/env python3
"""Read agent status from an Otto daemon (https://github.com/otto-code).

Talks the daemon's WebSocket JSON-RPC protocol directly (no `otto` CLI or
Node.js needed): connect to ws://<host>/ws, say hello with the standard
client capabilities, then send a `fetch_agents_request`.

Host resolution (matches the otto CLI conventions):
  1. --host argument
  2. OTTO_HOST env (tcp://[user[:pass]@]host[:port], host:port or unix://path)
  3. localhost:6868 (the daemon's default listen address)

Password: URI user-info, then OTTO_PASSWORD env, then empty.

Prints a JSON object compatible with the shell's usage services.
"""
import argparse
import base64
import json
import os
import socket
import struct
import sys
import time

CLIENT_ID = "end4pc-shell"
DEFAULT_HOST = "localhost:6868"
CONNECT_TIMEOUT = 4.0
RESPONSE_TIMEOUT = 6.0

# Capability set the otto CLI advertises; the daemon gates agent listing on it.
CLIENT_CAPABILITIES = {
    "explicitEventSubscriptions": "explicit_event_subscriptions",
    "allProviders": "all_providers",
    "selectiveAgentTimeline": "selective_agent_timeline",
    "reasoningMergeEnum": "reasoning_merge_enum",
    "customModeIcons": "custom_mode_icons",
    "terminalReflowableSnapshot": "terminal_reflowable_snapshot",
    "providerSubagents": "provider_subagents",
    "projectUpdates": "project_updates",
    "communicationsPresenceUpdates": "communications_presence_updates",
    "brainLogWatch": "brain_log_watch",
    "compactProviderSnapshots": "compact_provider_snapshots",
    "providerSnapshotReferences": "provider_snapshot_references",
    "timelineReplacementInvalidation": "timeline_replacement_invalidation",
    "timelineNotifications": "timeline_notifications",
    "pluginTimelineItems": "plugin_timeline_items",
    "workspaceSetupBlocked": "workspace_setup_blocked",
    "browserHost": "browser_host",
}


class WebSocket:
    """Minimal RFC 6455 client: one text frame at a time is all we need."""

    def __init__(self, host, port, path="/ws", password=""):
        self.sock = socket.create_connection((host, port), timeout=CONNECT_TIMEOUT)
        key = base64.b64encode(os.urandom(16)).decode()
        headers = [
            f"GET {path} HTTP/1.1",
            f"Host: {host}:{port}",
            "Upgrade: websocket",
            "Connection: Upgrade",
            f"Sec-WebSocket-Key: {key}",
            "Sec-WebSocket-Version: 13",
        ]
        if password:
            headers.append(f"Authorization: Bearer {password}")
        self.sock.sendall(("\r\n".join(headers) + "\r\n\r\n").encode())

        response = b""
        while b"\r\n\r\n" not in response:
            chunk = self.sock.recv(4096)
            if not chunk:
                raise ConnectionError("handshake EOF")
            response += chunk
        status = response.split(b"\r\n", 1)[0].decode(errors="ignore")
        if " 101 " not in status:
            raise ConnectionError(f"handshake rejected: {status}")
        self.buf = response.split(b"\r\n\r\n", 1)[1]

    def send_text(self, obj):
        payload = json.dumps(obj).encode()
        mask = os.urandom(4)
        header = bytes([0x81])
        n = len(payload)
        if n < 126:
            header += bytes([0x80 | n])
        elif n < 65536:
            header += bytes([0x80 | 126]) + struct.pack(">H", n)
        else:
            header += bytes([0x80 | 127]) + struct.pack(">Q", n)
        self.sock.sendall(header + mask + bytes(b ^ mask[i % 4] for i, b in enumerate(payload)))

    def messages(self, deadline):
        """Yield decoded text frames until the deadline passes."""
        while time.time() < deadline:
            frame = self._frame(deadline)
            if frame is None:
                return
            opcode, payload = frame
            if opcode == 1:
                try:
                    yield json.loads(payload.decode())
                except ValueError:
                    continue

    def _frame(self, deadline):
        buf = self.buf
        while True:
            if len(buf) >= 2:
                b0, b1 = buf[0], buf[1]
                length = b1 & 0x7F
                offset = 2
                if length == 126:
                    if len(buf) < 4:
                        pass
                    else:
                        length = struct.unpack(">H", buf[2:4])[0]
                        offset = 4
                elif length == 127:
                    if len(buf) < 10:
                        pass
                    else:
                        length = struct.unpack(">Q", buf[2:10])[0]
                        offset = 10
                if len(buf) >= offset + length:
                    payload = buf[offset:offset + length]
                    self.buf = buf[offset + length:]
                    return b0 & 0x0F, payload
            remaining = deadline - time.time()
            if remaining <= 0:
                return None
            self.sock.settimeout(min(remaining, 1.0))
            try:
                chunk = self.sock.recv(65536)
            except socket.timeout:
                continue
            except OSError:
                return None
            if not chunk:
                return None
            buf += chunk

    def close(self):
        try:
            self.sock.close()
        except OSError:
            pass


def parse_host(raw):
    """Return (host, port, password, unix_path)."""
    raw = (raw or "").strip()
    if not raw:
        raw = DEFAULT_HOST
    password = os.environ.get("OTTO_PASSWORD", "")
    unix_path = None
    if raw.startswith("unix://"):
        return "localhost", 0, password, raw[len("unix://"):]
    if raw.startswith("tcp://"):
        raw = raw[len("tcp://"):]
        if "@" in raw:
            userinfo, raw = raw.rsplit("@", 1)
            password = userinfo.split(":", 1)[1] if ":" in userinfo else userinfo
    if raw.startswith("ws://"):
        raw = raw[len("ws://"):]
    raw = raw.rstrip("/")
    if ":" in raw:
        host, _, port = raw.rpartition(":")
        try:
            return host.strip("[]"), int(port), password, None
        except ValueError:
            pass
    return raw, 6868, password, None


def fetch_agents(host, port, password, unix_path):
    deadline = time.time() + RESPONSE_TIMEOUT
    if unix_path:
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.settimeout(CONNECT_TIMEOUT)
        sock.connect(unix_path)
        ws = WebSocket.__new__(WebSocket)
        ws.sock = sock
        ws.buf = b""
        # Re-run the handshake over the connected unix socket.
        key = base64.b64encode(os.urandom(16)).decode()
        headers = [
            "GET /ws HTTP/1.1",
            "Host: localhost",
            "Upgrade: websocket",
            "Connection: Upgrade",
            f"Sec-WebSocket-Key: {key}",
            "Sec-WebSocket-Version: 13",
        ]
        if password:
            headers.append(f"Authorization: Bearer {password}")
        sock.sendall(("\r\n".join(headers) + "\r\n\r\n").encode())
        response = b""
        while b"\r\n\r\n" not in response:
            chunk = sock.recv(4096)
            if not chunk:
                raise ConnectionError("handshake EOF")
            response += chunk
        if b" 101 " not in response.split(b"\r\n", 1)[0]:
            raise ConnectionError("handshake rejected")
        ws.buf = response.split(b"\r\n\r\n", 1)[1]
    else:
        ws = WebSocket(host, port, "/ws", password)

    try:
        request_id = f"end4pc-{int(time.time() * 1000)}"
        ws.send_text({
            "type": "hello",
            "clientId": CLIENT_ID,
            "clientType": "cli",
            "protocolVersion": 1,
            "appVersion": "0.9.35",
            "capabilities": CLIENT_CAPABILITIES,
        })
        time.sleep(0.25)  # let the daemon process hello before the request
        ws.send_text({
            "type": "session",
            "message": {"type": "fetch_agents_request", "requestId": request_id},
        })
        error = None
        for message in ws.messages(deadline):
            if not isinstance(message, dict):
                continue
            if message.get("type") != "session":
                continue
            inner = message.get("message") or {}
            payload = inner.get("payload") or {}
            if inner.get("type") == "fetch_agents_response" and payload.get("requestId") == request_id:
                if error:
                    raise ConnectionError(error)
                return payload.get("entries") or []
            if inner.get("type") == "rpc_error" and payload.get("requestId") == request_id:
                error = payload.get("error") or "rpc error"
        raise ConnectionError(error or "timed out waiting for fetch_agents_response")
    finally:
        ws.close()


def shape_entry(entry):
    agent = entry.get("agent") or {}
    project = entry.get("project") or {}
    checkout = project.get("checkout") or {}
    usage = agent.get("lastUsage") or {}
    input_tokens = usage.get("inputTokens") or 0
    output_tokens = usage.get("outputTokens") or 0
    context_max = usage.get("contextWindowMaxTokens") or 0
    context_used = usage.get("contextWindowUsedTokens") or 0
    cwd = agent.get("cwd") or ""
    return {
        "name": agent.get("title") or project.get("workspaceName") or "agent",
        "status": agent.get("status") or "unknown",
        "provider": (agent.get("provider") or "").split("/")[0],
        "model": agent.get("model") or (agent.get("runtimeInfo") or {}).get("model") or "",
        "cwd": cwd,
        "branch": checkout.get("currentBranch") or "",
        "requiresAttention": bool(agent.get("requiresAttention")),
        "attentionReason": agent.get("attentionReason") or "",
        "pendingPermissions": len(agent.get("pendingPermissions") or []),
        "contextPercent": (context_used / context_max) if context_max > 0 else 0,
        "tokens": input_tokens + output_tokens,
        "updatedAt": agent.get("updatedAt") or "",
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--host", help="Otto daemon host (tcp://host:port, host:port, unix://path)")
    args = parser.parse_args()

    host, port, password, unix_path = parse_host(args.host or os.environ.get("OTTO_HOST", ""))
    try:
        entries = fetch_agents(host, port, password, unix_path)
    except Exception as exc:  # unreachable daemon, bad handshake, timeout...
        print(json.dumps({
            "available": False,
            "host": f"{host}:{port}" if not unix_path else unix_path,
            "error": str(exc),
            "agents": [],
            "activeSessions": 0,
            "totalSessions": 0,
            "attentionCount": 0,
            "pendingPermissionCount": 0,
            "tokens": 0,
            "resetsAt": 0,
        }))
        return

    agents = [shape_entry(e) for e in entries if isinstance(e, dict)]
    agents.sort(key=lambda a: (a["status"] != "running", a["requiresAttention"] is False, a["name"]))
    print(json.dumps({
        "available": True,
        "host": f"{host}:{port}" if not unix_path else unix_path,
        "agents": agents,
        "activeSessions": sum(1 for a in agents if a["status"] == "running"),
        "totalSessions": len(agents),
        "attentionCount": sum(1 for a in agents if a["requiresAttention"]),
        "pendingPermissionCount": sum(1 for a in agents if a["pendingPermissions"] > 0),
        "tokens": sum(a["tokens"] for a in agents),
        "resetsAt": 0,
    }))


if __name__ == "__main__":
    main()
