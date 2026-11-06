#!/usr/bin/env bash
# Construit les paquets à distribuer dans dist/ :
#   - obsidian-memory.plugin  → plugin pour Cowork (Claude Desktop) et Claude Code
#   - skills/<nom>.zip         → un zip par skill, à importer dans Claude Desktop (mode chat) ou claude.ai
# Usage : ./scripts/package.sh
set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST="$REPO_DIR/dist"
rm -rf "$DIST" && mkdir -p "$DIST/skills"
cd "$REPO_DIR"
zip -qr "$DIST/obsidian-memory.plugin" .claude-plugin skills README.md LICENSE -x "*.DS_Store" -x ".claude-plugin/marketplace.json"
echo "  ✓ dist/obsidian-memory.plugin"
cd "$REPO_DIR/skills"
for d in */; do
  n="${d%/}"
  zip -qr "$DIST/skills/$n.zip" "$n" -x "*.DS_Store"
  echo "  ✓ dist/skills/$n.zip"
done
