#!/usr/bin/env bash
# Teste les hooks de mémoire automatique sur un vault et un transcript factices.
# Usage : ./scripts/test-hooks.sh   (code 1 au premier échec)
set -uo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
H="$REPO_DIR/hooks"
X="$(mktemp -d)"; trap 'rm -rf "$X"' EXIT
export OBSIDIAN_MEMORY_HOME="$X/home"
V="$X/vault"; cp -R "$REPO_DIR/vault-template" "$V"
mkdir -p "$V/Projets/Alpha/Sessions"
printf -- '---\ntype: map\nstatus: actif\n---\n# Alpha — MAP\n\n## 🔴 Session courante\n- **Objectif :** finir la facturation\n- **Charger :** TASKS\n\n## Autre\nx\n' > "$V/Projets/Alpha/ALPHA-MAP.md"
TR="$X/t.jsonl"
prompt() { echo "{\"type\":\"user\",\"message\":{\"role\":\"user\",\"content\":\"demande $1\"}}" >> "$TR"; }
for i in 1 2 3; do prompt $i; done
echo '{"type":"user","message":{"role":"user","content":[{"type":"tool_result","content":"x"}]}}' >> "$TR"
echo "{\"type\":\"assistant\",\"message\":{\"content\":[{\"type\":\"tool_use\",\"name\":\"Edit\",\"input\":{\"file_path\":\"$V/Projets/Alpha/TASKS.md\"}}]}}" >> "$TR"
input() { printf '{"session_id":"%s","transcript_path":"%s","cwd":"%s","stop_hook_active":%s,"source":"startup"}' "$1" "$TR" "$2" "${3:-false}"; }

FAIL=0
ok()  { echo "  ✓ $1"; }
ko()  { echo "  ✗ $1"; FAIL=1; }
check() { if eval "$2"; then ok "$1"; else ko "$1"; fi; }

OUT=$(input s1 "$V/Projets" | sh "$H/session-start.sh")
check "démarrage dans le vault : bloc Session courante injecté" '[[ "$OUT" == *"finir la facturation"* ]]'
check "démarrage : le projet d'exemple n'est pas pris pour l'entité active" '[[ "$OUT" != *"_EXEMPLE"* ]]'
OUT=$(input s1b /tmp | sh "$H/session-start.sh")
check "démarrage hors vault : silence" '[ -z "$OUT" ]'

OUT=$(input s1 "$V" | sh "$H/stop.sh")
check "fin de réponse sous le seuil (3 < 8) : rien" '[ -z "$OUT" ]'
OUT=$(input s1 "$V" | OBSIDIAN_MEMORY_SAVE_EVERY=3 sh "$H/stop.sh")
check "seuil atteint : demande de sauvegarde (JSON block)" '[[ "$OUT" == "{\"decision\":\"block\",\"reason\":\""* ]]'
check "la demande est du JSON valide" 'printf "%s" "$OUT" | python3 -m json.tool >/dev/null'
OUT=$(input s1 "$V" | OBSIDIAN_MEMORY_SAVE_EVERY=3 sh "$H/stop.sh")
check "pas de deuxième demande sans nouvelle demande utilisateur" '[ -z "$OUT" ]'
OUT=$(input s1 "$V" true | OBSIDIAN_MEMORY_SAVE_EVERY=1 sh "$H/stop.sh")
check "stop_hook_active : jamais de boucle" '[ -z "$OUT" ]'
OUT=$(input s1 "$V" | OBSIDIAN_MEMORY_SAVE_EVERY=0 sh "$H/stop.sh")
check "OBSIDIAN_MEMORY_SAVE_EVERY=0 désactive la sauvegarde" '[ -z "$OUT" ]'

input s1 "$V" | sh "$H/session-end.sh"
check "fermeture sans rien de neuf : pas de journal" '[ ! -f "$V/Sessions/journal-auto.md" ]'
prompt 4
input s1 "$V" | sh "$H/session-end.sh"
J="$V/Sessions/journal-auto.md"
check "fermeture avec une demande non sauvegardée : journal écrit" 'grep -q "non sauvegardée" "$J"'
check "journal : fichiers modifiés listés" 'grep -q "Projets/Alpha/TASKS.md" "$J"'
input s1 "$V" | sh "$H/session-end.sh"
check "fermeture rejouée (plugin + install.sh) : une seule entrée" '[ "$(grep -c "^## .*non sauvegardée" "$J")" = 1 ]'
OUT=$(input s2 "$V" | sh "$H/session-start.sh")
check "démarrage suivant : session non sauvegardée signalée" '[[ "$OUT" == *"Session précédente non sauvegardée"* ]]'

echo '{"type":"user","message":{"role":"user","content":"<command-name>/compress</command-name>"}}' >> "$TR"
for i in 5 6 7; do prompt $i; done
OUT=$(input s1 "$V" | OBSIDIAN_MEMORY_SAVE_EVERY=3 sh "$H/stop.sh")
check "/compress manuel remet le compteur à zéro" '[ -z "$OUT" ]'

R="$X/alpha"; mkdir -p "$R"; git -C "$R" init -q; echo "@$V/CLAUDE.md" > "$R/CLAUDE.md"
OUT=$(input s3 "$R" | sh "$H/session-start.sh")
check "dépôt de code relié au vault (@vault/CLAUDE.md) : contexte du projet" '[[ "$OUT" == *"Projets/Alpha/ALPHA-MAP.md"* ]]'

check "le vault reste conforme au lint après le journal" 'sh "$REPO_DIR/skills/lint-vault/scripts/lint-vault.sh" "$V" >/dev/null'
exit $FAIL
