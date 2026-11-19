#!/usr/bin/env python3
"""Read AI usage from local LLM servers (Ollama, LM Studio, vLLM, etc.)."""
import json
import os
import sys
import time
import urllib.request
import urllib.error

# Default endpoints for common local LLM servers
DEFAULT_ENDPOINTS = {
    "ollama": "http://localhost:11434",
    "lmstudio": "http://localhost:1234",
    "vllm": "http://localhost:8000",
    "textgen": "http://localhost:5000",
}

def query_ollama(base_url):
    """Query Ollama API for model info and usage."""
    try:
        # Get running models
        req = urllib.request.Request(f"{base_url}/api/ps")
        with urllib.request.urlopen(req, timeout=5) as resp:
            data = json.loads(resp.read())
        
        models = data.get("models", [])
        total_memory = sum(m.get("size_vram", 0) for m in models)
        
        return {
            "available": True,
            "type": "ollama",
            "running_models": len(models),
            "models": [{"name": m.get("name", ""), "size_vram": m.get("size_vram", 0)} for m in models],
            "vram_used": total_memory,
        }
    except Exception as e:
        return {"available": False, "type": "ollama", "error": str(e)}

def query_lmstudio(base_url):
    """Query LM Studio API."""
    try:
        req = urllib.request.Request(f"{base_url}/v1/models")
        with urllib.request.urlopen(req, timeout=5) as resp:
            data = json.loads(resp.read())
        
        models = data.get("data", [])
        return {
            "available": True,
            "type": "lmstudio",
            "models": [{"name": m.get("id", ""), "loaded": m.get("loaded", False)} for m in models],
        }
    except Exception as e:
        return {"available": False, "type": "lmstudio", "error": str(e)}

def query_vllm(base_url):
    """Query vLLM API."""
    try:
        req = urllib.request.Request(f"{base_url}/v1/models")
        with urllib.request.urlopen(req, timeout=5) as resp:
            data = json.loads(resp.read())
        
        models = data.get("data", [])
        return {
            "available": True,
            "type": "vllm",
            "models": [{"name": m.get("id", "")} for m in models],
        }
    except Exception as e:
        return {"available": False, "type": "vllm", "error": str(e)}

def main():
    import argparse
    parser = argparse.ArgumentParser(description="Local LLM Usage Monitor")
    parser.add_argument("--ollama", default=os.environ.get("OLLAMA_HOST", "http://localhost:11434"))
    parser.add_argument("--lmstudio", default=os.environ.get("LMSTUDIO_HOST", "http://localhost:1234"))
    parser.add_argument("--vllm", default=os.environ.get("VLLM_HOST", "http://localhost:8000"))
    parser.add_argument("--textgen", default=os.environ.get("TEXTGEN_HOST", "http://localhost:5000"))
    args = parser.parse_args()

    results = {
        "available": False,
        "servers": {},
        "total_running": 0,
        "total_models": 0,
    }

    # Query each server
    for name, url in [("ollama", args.ollama), ("lmstudio", args.lmstudio), 
                       ("vllm", args.vllm), ("textgen", args.textgen)]:
        if not url:
            continue
        if name == "ollama":
            result = query_ollama(url)
        elif name == "lmstudio":
            result = query_lmstudio(url)
        elif name == "vllm":
            result = query_vllm(url)
        else:
            result = {"available": False, "type": name}
        
        results["servers"][name] = result
        if result.get("available"):
            results["available"] = True
            if "running_models" in result:
                results["total_running"] += result["running_models"]
            results["total_models"] += len(result.get("models", []))

    print(json.dumps(results))

if __name__ == "__main__":
    main()