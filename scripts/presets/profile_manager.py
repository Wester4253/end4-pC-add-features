#!/usr/bin/env python3
"""Shell Profile Manager - Save/load complete shell configurations."""
import json
import os
import shutil
import sys
from pathlib import Path

CONFIG_DIR = Path.home() / ".config" / "illogical-impulse"
PROFILES_DIR = CONFIG_DIR / "profiles"
CONFIG_FILE = CONFIG_DIR / "config.json"

def list_profiles():
    """List all saved profiles."""
    PROFILES_DIR.mkdir(parents=True, exist_ok=True)
    profiles = []
    for f in PROFILES_DIR.glob("*.json"):
        try:
            with open(f) as fp:
                data = json.load(fp)
            profiles.append({
                "name": f.stem,
                "description": data.get("description", ""),
                "created": data.get("created", ""),
                "icon": data.get("icon", "save"),
            })
        except Exception:
            pass
    return profiles

def save_profile(name, description="", icon="save"):
    """Save current config as a profile."""
    PROFILES_DIR.mkdir(parents=True, exist_ok=True)
    if not CONFIG_FILE.exists():
        return {"success": False, "error": "Config file not found"}
    
    with open(CONFIG_FILE) as fp:
        config = json.load(fp)
    
    # Remove runtime/temp fields
    config.pop("__runtime", None)
    
    profile = {
        "name": name,
        "description": description,
        "icon": icon,
        "created": __import__("datetime").datetime.now().isoformat(),
        "config": config,
    }
    
    profile_file = PROFILES_DIR / f"{name}.json"
    with open(profile_file, "w") as fp:
        json.dump(profile, fp, indent=2)
    
    return {"success": True, "profile": str(profile_file)}

def load_profile(name):
    """Load a profile and apply it."""
    profile_file = PROFILES_DIR / f"{name}.json"
    if not profile_file.exists():
        return {"success": False, "error": f"Profile '{name}' not found"}
    
    with open(profile_file) as fp:
        profile = json.load(fp)
    
    # Backup current config
    backup_file = CONFIG_FILE.with_suffix(".json.backup")
    if CONFIG_FILE.exists():
        shutil.copy2(CONFIG_FILE, backup_file)
    
    # Write new config
    with open(CONFIG_FILE, "w") as fp:
        json.dump(profile.get("config", {}), fp, indent=2)
    
    return {"success": True, "backup": str(backup_file)}

def delete_profile(name):
    """Delete a profile."""
    profile_file = PROFILES_DIR / f"{name}.json"
    if not profile_file.exists():
        return {"success": False, "error": f"Profile '{name}' not found"}
    
    profile_file.unlink()
    return {"success": True}

def export_profile(name, output_path):
    """Export a profile to a file."""
    profile_file = PROFILES_DIR / f"{name}.json"
    if not profile_file.exists():
        return {"success": False, "error": f"Profile '{name}' not found"}
    
    shutil.copy2(profile_file, output_path)
    return {"success": True}

def import_profile(input_path, name=None):
    """Import a profile from a file."""
    with open(input_path) as fp:
        profile = json.load(fp)
    
    if name is None:
        name = Path(input_path).stem
    
    # Validate profile structure
    if "config" not in profile:
        return {"success": False, "error": "Invalid profile format"}
    
    profile["name"] = name
    profile["created"] = __import__("datetime").datetime.now().isoformat()
    
    PROFILES_DIR.mkdir(parents=True, exist_ok=True)
    profile_file = PROFILES_DIR / f"{name}.json"
    with open(profile_file, "w") as fp:
        json.dump(profile, fp, indent=2)
    
    return {"success": True}

def main():
    import argparse
    parser = argparse.ArgumentParser(description="Shell Profile Manager")
    subparsers = parser.add_subparsers(dest="command", required=True)
    
    # List
    subparsers.add_parser("list", help="List all profiles")
    
    # Save
    save_parser = subparsers.add_parser("save", help="Save current config as profile")
    save_parser.add_argument("name", help="Profile name")
    save_parser.add_argument("--description", "-d", default="", help="Profile description")
    save_parser.add_argument("--icon", "-i", default="save", help="Profile icon")
    
    # Load
    load_parser = subparsers.add_parser("load", help="Load a profile")
    load_parser.add_argument("name", help="Profile name")
    
    # Delete
    delete_parser = subparsers.add_parser("delete", help="Delete a profile")
    delete_parser.add_argument("name", help="Profile name")
    
    # Export
    export_parser = subparsers.add_parser("export", help="Export a profile")
    export_parser.add_argument("name", help="Profile name")
    export_parser.add_argument("output", help="Output file path")
    
    # Import
    import_parser = subparsers.add_parser("import", help="Import a profile")
    import_parser.add_argument("input", help="Input file path")
    import_parser.add_argument("--name", "-n", help="Profile name (default: filename)")
    
    args = parser.parse_args()
    
    if args.command == "list":
        profiles = list_profiles()
        print(json.dumps(profiles, indent=2))
    elif args.command == "save":
        result = save_profile(args.name, args.description, args.icon)
        print(json.dumps(result))
    elif args.command == "load":
        result = load_profile(args.name)
        print(json.dumps(result))
    elif args.command == "delete":
        result = delete_profile(args.name)
        print(json.dumps(result))
    elif args.command == "export":
        result = export_profile(args.name, args.output)
        print(json.dumps(result))
    elif args.command == "import":
        result = import_profile(args.input, args.name)
        print(json.dumps(result))

if __name__ == "__main__":
    main()