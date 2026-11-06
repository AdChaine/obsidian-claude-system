#!/bin/sh
# session-end.sh — hook SessionEnd : filet de sécurité, sans appel au modèle.
# Si la session se termine avec des demandes non sauvegardées, note dans Sessions/journal-auto.md
# la date, le dossier, les fichiers modifiés et le chemin du transcript. Le démarrage suivant le signale.
. "$(dirname "$0")/lib.sh"
om_read_input
CWD=$(om_field cwd); [ -n "$CWD" ] || CWD=$(pwd)
SID=$(om_field session_id); T=$(om_field transcript_path)
om_detect "$CWD" || exit 0
[ -n "$SID" ] && [ -f "$T" ] || exit 0

P=$(om_prompts "$T"); C=$(om_compress_runs "$T")
set -- $(om_state_get "$SID"); S=${1:-0}; SC=${2:-0}
[ "$C" -gt "$SC" ] && exit 0                 # /compress lancé depuis la dernière sauvegarde
U=$((P - S)); [ "$U" -gt 0 ] || exit 0
om_once "end-$SID-$P" || exit 0

J="$OM_VAULT/Sessions/journal-auto.md"
mkdir -p "$OM_VAULT/Sessions"
if [ ! -f "$J" ]; then
  cat > "$J" <<HEAD
---
type: session
status: actif
updated: $(date +%Y-%m-%d)
tags: [session, journal-auto]
---

# Journal automatique

> Écrit par le hook de fin de session d'obsidian-memory quand une session se termine sans sauvegarde complète. Lu au démarrage suivant. Inutile de l'éditer.
HEAD
fi
FILES=$(om_edited_files "$T" | sed "s#^$OM_VAULT/##" | paste -sd, - | sed 's/,/, /g')
{
  echo ""
  echo "## $(date '+%Y-%m-%d %H:%M') — non sauvegardée"
  echo "- Dossier : $CWD"
  echo "- Demandes non sauvegardées : $U"
  echo "- Fichiers modifiés : ${FILES:-aucun}"
  echo "- Transcript : $T"
} >> "$J"
sed -i.bak "s/^updated: .*/updated: $(date +%Y-%m-%d)/" "$J" && rm -f "$J.bak"
# Garder le journal court : en-tête + 200 dernières lignes.
if [ "$(wc -l < "$J")" -gt 260 ]; then
  { head -11 "$J"; tail -200 "$J"; } > "$J.tmp" && mv "$J.tmp" "$J"
fi
exit 0
