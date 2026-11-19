#!/usr/bin/env python3
"""Local LLM chat using Ollama, LM Studio, vLLM, or text-generation-webui."""
import json
import os
import sys
import subprocess
import requests

def call_ollama(prompt, model=None):
    """Call Ollama API."""
    try:
        url = os.environ.get("OLLAMA_HOST", "http://localhost:11434")
        data = {
            "model": model or "llama3.2",
            "prompt": prompt,
            "stream": False
        }
        response = requests.post(f"{url}/api/generate", json=data, timeout=60)
        if response.status_code == 200:
            return response.json().get("response", "")
    except Exception as e:
        pass
    return None

def call_lmstudio(prompt, model=None):
    """Call LM Studio API (OpenAI compatible)."""
    try:
        url = os.environ.get("LMSTUDIO_HOST", "http://localhost:1234")
        data = {
            "model": model or "local-model",
            "messages": [{"role": "user", "content": prompt}],
            "temperature": 0.7,
            "max_tokens": 2048
        }
        response = requests.post(f"{url}/v1/chat/completions", json=data, timeout=60)
        if response.status_code == 200:
            return response.json()["choices"][0]["message"]["content"]
    except Exception as e:
        pass
    return None

def call_vllm(prompt, model=None):
    """Call vLLM API (OpenAI compatible)."""
    try:
        url = os.environ.get("VLLM_HOST", "http://localhost:8000")
        data = {
            "model": model or "local-model",
            "messages": [{"role": "user", "content": prompt}],
            "temperature": 0.7,
            "max_tokens": 2048
        }
        response = requests.post(f"{url}/v1/chat/completions", json=data, timeout=60)
        if response.status_code == 200:
            return response.json()["choices"][0]["message"]["content"]
    except Exception as e:
        pass
    return None

def call_textgen(prompt, model=None):
    """Call text-generation-webui API."""
    try:
        url = os.environ.get("TEXTGEN_HOST", "http://localhost:5000")
        data = {
            "prompt": prompt,
            "max_new_tokens": 2048,
            "temperature": 0.7,
            "top_p": 0.9
        }
        response = requests.post(f"{url}/api/v1/generate", json=data, timeout=60)
        if response.status_code == 200:
            return response.json()["results"][0]["text"]
    except Exception as e:
        pass
    return None

def main():
    if len(sys.argv) < 3:
        print("Usage: local-llm-chat.py <prompt> <provider>")
        sys.exit(1)

    prompt = sys.argv[1]
    provider = sys.argv[2]

    result = None
    if provider == "ollama":
        result = call_ollama(prompt)
    elif provider == "lmstudio":
        result = call_lmstudio(prompt)
    elif provider == "vllm":
        result = call_vllm(prompt)
    elif provider == "textgen":
        result = call_textgen(prompt)
    elif provider == "local":
        # Try all providers in order
        result = call_ollama(None)
        if not result:
            result = call_lmstudio(prompt)
        if not result:
            result = call_vllm(prompt)
        if not result:
            result = call_textgen(prompt)

    if result:
        print(result)
    else:
        print("Error: No LLM provider available or all providers failed")
        sys.exit(1)

if __name__ == "__main__":
    main()