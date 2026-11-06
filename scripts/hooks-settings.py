#!/usr/bin/env python3
"""Ajoute ou retire les hooks de mémoire automatique dans ~/.claude/settings.json.

Usage : hooks-settings.py add|remove <settings.json> <dossier_des_hooks>
Idempotent : les entrées existantes d'obsidian-memory sont toujours retirées avant d'ajouter.
Une copie de sauvegarde est faite avant toute écriture. Rien d'autre n'est modifié.
"""
import json, os, shutil, sys, time

MARK = "obsidian-memory/hooks/"
EVENTS = {"SessionStart": "session-start.sh", "Stop": "stop.sh", "SessionEnd": "session-end.sh"}

def main():
    action, path, hooks_dir = sys.argv[1], sys.argv[2], sys.argv[3]
    data = {}
    if os.path.exists(path):
        with open(path, encoding="utf-8") as f:
            raw = f.read().strip()
        data = json.loads(raw) if raw else {}
        shutil.copy2(path, f"{path}.bak.{int(time.time())}")
    hooks = data.setdefault("hooks", {})
    for ev in EVENTS:
        groups = []
        for g in hooks.get(ev, []):
            kept = [h for h in g.get("hooks", []) if MARK not in h.get("command", "")]
            if kept:
                groups.append({**g, "hooks": kept})
        if action == "add":
            cmd = f'sh "{hooks_dir}/{EVENTS[ev]}"'
            groups.append({"hooks": [{"type": "command", "command": cmd, "timeout": 10}]})
        if groups:
            hooks[ev] = groups
        else:
            hooks.pop(ev, None)
    if not hooks:
        data.pop("hooks")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")

if __name__ == "__main__":
    main()
