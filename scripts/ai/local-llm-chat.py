#!/usr/bin/env python3
"""Chat with local LLM servers (Ollama, LM Studio, vLLM, text-gen-webui)."""
import json
import os
import sys
import urllib.request
import urllib.error

def chat_ollama(host, model, messages, stream=False):
    """Chat with Ollama."""
    url = f"{host}/api/chat"
    payload = {
        "model": model,
        "messages": messages,
        "stream": stream
    }
    data = json.dumps(payload).encode()
    req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=60) as response:
            if stream:
                # For streaming, read line by line
                full_response = ""
                for line in response:
                    chunk = json.loads(line.decode())
                    if "message" in chunk and "content" in chunk["message"]:
                        full_response += chunk["message"]["content"]
                        print(json.dumps({"content": chunk["message"]["content"], "done": chunk.get("done", False)}))
                        sys.stdout.flush()
                return {"content": full_response, "done": True}
            else:
                result = json.loads(response.read().decode())
                return {"content": result.get("message", {}).get("content", ""), "done": True}
    except Exception as e:
        return {"error": str(e)}

def chat_openai_compatible(host, model, messages, stream=False):
    """Chat with LM Studio, vLLM, or text-gen-webui (OpenAI-compatible API)."""
    url = f"{host}/v1/chat/completions"
    payload = {
        "model": model,
        "messages": messages,
        "stream": stream,
        "max_tokens": 2048,
        "temperature": 0.7
    }
    data = json.dumps(payload).encode()
    req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=60) as response:
            if stream:
                full_response = ""
                for line in response:
                    line = line.decode().strip()
                    if line.startswith("data: "):
                        data_str = line[6:]
                        if data_str == "[DONE]":
                            break
                        try:
                            chunk = json.loads(data_str)
                            choices = chunk.get("choices", [])
                            if choices and "delta" in choices[0]:
                                content = choices[0]["delta"].get("content", "")
                                if content:
                                    full_response += content
                                    print(json.dumps({"content": content, "done": False}))
                                    sys.stdout.flush()
                        except Exception:
                            continue
                return {"content": full_response, "done": True}
            else:
                result = json.loads(response.read().decode())
                choices = result.get("choices", [])
                if choices:
                    content = choices[0].get("message", {}).get("content", "")
                    return {"content": content, "done": True}
                return {"content": "", "done": True}
    except Exception as e:
        return {"error": str(e)}

def chat_textgen(host, model, messages, stream=False):
    """Chat with text-generation-webui."""
    url = f"{host}/api/v1/chat"
    # Convert messages to text-gen-webui format
    prompt = ""
    for msg in messages:
        role = msg.get("role", "user")
        content = msg.get("content", "")
        if role == "system":
            prompt += f"<|system|>\n{content}\n"
        elif role == "user":
            prompt += f"<|user|>\n{content}\n"
        elif role == "assistant":
            prompt += f"<|assistant|>\n{content}\n"
    prompt += "<|assistant|>\n"
    
    payload = {
        "prompt": prompt,
        "max_new_tokens": 2048,
        "temperature": 0.7,
        "stream": stream
    }
    data = json.dumps(payload).encode()
    req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=60) as response:
            if stream:
                full_response = ""
                for line in response:
                    line = line.decode().strip()
                    if line.startswith("data: "):
                        data_str = line[6:]
                        if data_str == "[DONE]":
                            break
                        try:
                            chunk = json.loads(data_str)
                            token = chunk.get("token", "")
                            if token:
                                full_response += token
                                print(json.dumps({"content": token, "done": False}))
                                sys.stdout.flush()
                        except Exception:
                            continue
                return {"content": full_response, "done": True}
            else:
                result = json.loads(response.read().decode())
                return {"content": result.get("text", ""), "done": True}
    except Exception as e:
        return {"error": str(e)}

def main():
    if len(sys.argv) < 4:
        print(json.dumps({"error": "Usage: local-llm-chat.py <server_type> <host> <model> [messages_json]"}))
        sys.exit(1)
    
    server_type = sys.argv[1]
    host = sys.argv[2]
    model = sys.argv[3]
    
    # Read messages from stdin if not provided as argument
    if len(sys.argv) > 4:
        messages = json.loads(sys.argv[4])
    else:
        messages = json.loads(sys.stdin.read())
    
    stream = os.environ.get("STREAM", "false").lower() == "true"
    
    if server_type == "ollama":
        result = chat_ollama(host, model, messages, stream)
    elif server_type in ("lmstudio", "vllm"):
        result = chat_openai_compatible(host, model, messages, stream)
    elif server_type == "textgen":
        result = chat_textgen(host, model, messages, stream)
    else:
        result = {"error": f"Unknown server type: {server_type}"}
    
    if not stream:
        print(json.dumps(result))

if __name__ == "__main__":
    main()