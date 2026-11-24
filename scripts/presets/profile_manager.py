#!/usr/bin/env python3
"""Manage Dynamic Island profiles (save/load/export/import)."""
import json
import os
import sys
import shutil
from pathlib import Path

PROFILES_DIR = Path.home() / ".config" / "quickshell" / "end4-pC" / "profiles"
PROFILES_DIR.mkdir(parents=True, exist_ok=True)

def list_profiles():
    """List all saved profiles."""
    profiles = []
    for f in PROFILES_DIR.glob("*.json"):
        try:
            with open(f) as fp:
                data = json.load(fp)
            profiles.append({
                "name": f.stem,
                "description": data.get("description", ""),
                "created": data.get("created", ""),
                "dynamicIsland": data.get("dynamicIsland", {})
            })
        except Exception:
            continue
    return {"profiles": profiles}

def save_profile(name, description, config):
    """Save current config as a profile."""
    profile_file = PROFILES_DIR / f"{name}.json"
    data = {
        "name": name,
        "description": description,
        "created": __import__("datetime").datetime.now().isoformat(),
        "dynamicIsland": config
    }
    with open(profile_file, "w") as f:
        json.dump(data, f, indent=2)
    return {"success": True, "path": str(profile_file)}

def load_profile(name):
    """Load a profile."""
    profile_file = PROFILES_DIR / f"{name}.json"
    if not profile_file.exists():
        return {"success": False, "error": "Profile not found"}
    try:
        with open(profile_file) as f:
            data = json.load(f)
        return {"success": True, "config": data.get("dynamicIsland", {})}
    except Exception as e:
        return {"success": False, "error": str(e)}

def delete_profile(name):
    """Delete a profile."""
    profile_file = PROFILES_DIR / f"{name}.json"
    if profile_file.exists():
        profile_file.unlink()
        return {"success": True}
    return {"success": False, "error": "Profile not found"}

def export_profile(name, export_path):
    """Export a profile to a file."""
    profile_file = PROFILES_DIR / f"{name}.json"
    if not profile_file.exists():
        return {"success": False, "error": "Profile not found"}
    try:
        shutil.copy2(profile_file, export_path)
        return {"success": True, "path": str(export_path)}
    except Exception as e:
        return {"success": False, "error": str(e)}

def import_profile(import_path):
    """Import a profile from a file."""
    try:
        with open(import_path) as f:
            data = json.load(f)
        name = data.get("name", Path(import_path).stem)
        # Avoid overwriting - append number if exists
        counter = 1
        original_name = name
        while (PROFILES_DIR / f"{name}.json").exists():
            name = f"{original_name}_{counter}"
            counter += 1
        profile_file = PROFILES_DIR / f"{name}.json"
        shutil.copy2(import_path, profile_file)
        return {"success": True, "name": name}
    except Exception as e:
        return {"success": False, "error": str(e)}

def main():
    if len(sys.argv) < 2:
        print(json.dumps({"error": "Usage: profile_manager.py <command> [args...]"}))
        sys.exit(1)
    
    command = sys.argv[1]
    
    if command == "list":
        print(json.dumps(list_profiles()))
    elif command == "save":
        if len(sys.argv) < 4:
            print(json.dumps({"error": "Usage: profile_manager.py save <name> <description> [config_json]"}))
            sys.exit(1)
        name = sys.argv[2]
        description = sys.argv[3]
        if len(sys.argv) > 4:
            config = json.loads(sys.argv[4])
        else:
            config = json.loads(sys.stdin.read())
        print(json.dumps(save_profile(name, description, config)))
    elif command == "load":
        if len(sys.argv) < 3:
            print(json.dumps({"error": "Usage: profile_manager.py load <name>"}))
            sys.exit(1)
        print(json.dumps(load_profile(sys.argv[2])))
    elif command == "delete":
        if len(sys.argv) < 3:
            print(json.dumps({"error": "Usage: profile_manager.py delete <name>"}))
            sys.exit(1)
        print(json.dumps(delete_profile(sys.argv[2])))
    elif command == "export":
        if len(sys.argv) < 4:
            print(json.dumps({"error": "Usage: profile_manager.py export <name> <export_path>"}))
            sys.exit(1)
        print(json.dumps(export_profile(sys.argv[2], sys.argv[3])))
    elif command == "import":
        if len(sys.argv) < 3:
            print(json.dumps({"error": "Usage: profile_manager.py import <import_path>"}))
            sys.exit(1)
        print(json.dumps(import_profile(sys.argv[2])))
    else:
        print(json.dumps({"error": f"Unknown command: {command}"}))
        sys.exit(1)

if __name__ == "__main__":
    main()