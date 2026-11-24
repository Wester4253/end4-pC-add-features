#!/usr/bin/env python3
"""Query local LLM servers (Ollama, LM Studio, vLLM, text-gen-webui) for running models."""
import json
import os
import sys
import urllib.request
import urllib.error

def query_ollama(host):
    """Query Ollama for running models."""
    try:
        url = f"{host}/api/tags"
        req = urllib.request.Request(url, headers={"Content-Type": "application/json"})
        with urllib.request.urlopen(req, timeout=5) as response:
            data = json.loads(response.read().decode())
            models = data.get("models", [])
            running = sum(1 for m in models if m.get("size", 0) > 0)
            return {
                "type": "ollama",
                "host": host,
                "available": True,
                "running": running,
                "total": len(models),
                "models": [{"name": m.get("name", ""), "size": m.get("size", 0)} for m in models]
            }
    except Exception as e:
        return {"type": "ollama", "host": host, "available": False, "error": str(e)}

def query_lmstudio(host):
    """Query LM Studio for loaded models."""
    try:
        url = f"{host}/v1/models"
        req = urllib.request.Request(url, headers={"Content-Type": "application/json"})
        with urllib.request.urlopen(req, timeout=5) as response:
            data = json.loads(response.read().decode())
            models = data.get("data", [])
            # LM Studio shows loaded models in the list
            running = len(models)
            return {
                "type": "lmstudio",
                "host": host,
                "available": True,
                "running": running,
                "total": running,
                "models": [{"name": m.get("id", ""), "owned_by": m.get("owned_by", "")} for m in models]
            }
    except Exception as e:
        return {"type": "lmstudio", "host": host, "available": False, "error": str(e)}

def query_vllm(host):
    """Query vLLM for running models."""
    try:
        url = f"{host}/v1/models"
        req = urllib.request.Request(url, headers={"Content-Type": "application/json"})
        with urllib.request.urlopen(req, timeout=5) as response:
            data = json.loads(response.read().decode())
            models = data.get("data", [])
            return {
                "type": "vllm",
                "host": host,
                "available": True,
                "running": len(models),
                "total": len(models),
                "models": [{"name": m.get("id", ""), "object": m.get("object", "")} for m in models]
            }
    except Exception as e:
        return {"type": "vllm", "host": host, "available": False, "error": str(e)}

def query_textgen(host):
    """Query text-generation-webui for loaded models."""
    try:
        url = f"{host}/api/v1/model"
        req = urllib.request.Request(url, headers={"Content-Type": "application/json"})
        with urllib.request.urlopen(req, timeout=5) as response:
            data = json.loads(response.read().decode())
            # text-gen-webui returns current model info
            model_name = data.get("model_name", "")
            return {
                "type": "textgen",
                "host": host,
                "available": True,
                "running": 1 if model_name else 0,
                "total": 1,
                "models": [{"name": model_name, "loader": data.get("loader", "")}] if model_name else []
            }
    except Exception as e:
        return {"type": "textgen", "host": host, "available": False, "error": str(e)}

def main():
    servers = {}
    total_running = 0
    total_models = 0
    available = False
    
    # Check Ollama
    ollama_host = os.environ.get("OLLAMA_HOST", "http://localhost:11434")
    if ollama_host:
        result = query_ollama(ollama_host)
        servers["ollama"] = result
        if result.get("available"):
            available = True
            total_running += result.get("running", 0)
            total_models += result.get("total", 0)
    
    # Check LM Studio
    lmstudio_host = os.environ.get("LMSTUDIO_HOST", "http://localhost:1234")
    if lmstudio_host:
        result = query_lmstudio(lmstudio_host)
        servers["lmstudio"] = result
        if result.get("available"):
            available = True
            total_running += result.get("running", 0)
            total_models += result.get("total", 0)
    
    # Check vLLM
    vllm_host = os.environ.get("VLLM_HOST", "http://localhost:8000")
    if vllm_host:
        result = query_vllm(vllm_host)
        servers["vllm"] = result
        if result.get("available"):
            available = True
            total_running += result.get("running", 0)
            total_models += result.get("total", 0)
    
    # Check text-gen-webui
    textgen_host = os.environ.get("TEXTGEN_HOST", "http://localhost:5000")
    if textgen_host:
        result = query_textgen(textgen_host)
        servers["textgen"] = result
        if result.get("available"):
            available = True
            total_running += result.get("running", 0)
            total_models += result.get("total", 0)
    
    print(json.dumps({
        "available": available,
        "servers": servers,
        "totalRunning": total_running,
        "totalModels": total_models
    }))

if __name__ == "__main__":
    main()