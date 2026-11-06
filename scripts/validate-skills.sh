#!/usr/bin/env bash
# Valide les skills de skills/ : frontmatter (name = nom du dossier, description non vide,
# ≤ 1024 caractères) et, pour les skills-commandes, les 4 balises XML requises.
# Utilisé en local par les contributeurs ET par la CI.  Usage : ./scripts/validate-skills.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REQUIRED=(purpose strict_rules workflow_steps expected_output)
NO_XML="obsidian-note-system"   # skill de gouvernance : pas de structure XML imposée

fail=0; count=0
echo "→ Validation des skills dans skills/"
for f in "$REPO_DIR"/skills/*/SKILL.md; do
  count=$((count + 1))
  dir="$(basename "$(dirname "$f")")"
  problems=""
  [ "$(head -1 "$f")" = "---" ] || problems="$problems frontmatter-absent"
  fm="$(awk 'NR==1{next} /^---$/{exit} {print}' "$f")"
  name="$(printf '%s\n' "$fm" | sed -n 's/^name:[[:space:]]*//p' | head -1)"
  [ "$name" = "$dir" ] || problems="$problems name≠dossier($name)"
  desc="$(printf '%s\n' "$fm" | awk '/^description:/{f=1; sub(/^description:[[:space:]]*>?[[:space:]]*/,""); print; next} f&&/^[[:space:]]/{print; next} f{exit}')"
  [ -n "$(printf '%s' "$desc" | tr -d '[:space:]"')" ] || problems="$problems description-vide"
  [ "$(printf '%s' "$desc" | wc -m)" -le 1024 ] || problems="$problems description>1024"
  if [ "$dir" != "$NO_XML" ]; then
    for tag in "${REQUIRED[@]}"; do
      grep -q "<$tag>" "$f" && grep -q "</$tag>" "$f" || problems="$problems <$tag>"
    done
  fi
  if [ -z "$problems" ]; then echo "  ✅ $dir"; else echo "  ❌ $dir —$problems"; fail=1; fi
done
for j in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
  python3 -m json.tool "$REPO_DIR/$j" >/dev/null 2>&1 || { echo "  ❌ $j : JSON invalide"; fail=1; }
done
echo "----------------------------------------"
if [ "$fail" -eq 0 ]; then echo "✅ $count skill(s) valide(s)."; else echo "❌ Validation échouée."; exit 1; fi
