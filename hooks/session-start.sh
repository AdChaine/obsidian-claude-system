#!/bin/sh
# session-start.sh — hook SessionStart : charge la mémoire sans que l'utilisateur tape /resume.
# Injecte dans le contexte le bloc « Session courante » (ou « Chantiers actifs ») de l'entité active,
# et signale une session précédente terminée sans sauvegarde. Muet hors d'un vault.
. "$(dirname "$0")/lib.sh"
om_read_input
CWD=$(om_field cwd); [ -n "$CWD" ] || CWD=$(pwd)
SID=$(om_field session_id); SRC=$(om_field source)
om_detect "$CWD" || exit 0
om_once "start-$SID-${SRC:-x}-$(om_prompts "$(om_field transcript_path)")" || exit 0
find "$OM_STATE" -mindepth 1 -mtime +7 -exec rm -rf {} + 2>/dev/null

MAP=$(om_current_map "$OM_VAULT" "$OM_PROJECT")
JOURNAL="$OM_VAULT/Sessions/journal-auto.md"

echo "[obsidian-memory] Mémoire chargée automatiquement : inutile de lancer /resume."
echo "Vault : $OM_VAULT"
if [ -n "$MAP" ]; then
  echo "Entité active : ${MAP#"$OM_VAULT"/} (modifiée le $(date -r "$MAP" +%Y-%m-%d))"
  awk 'on && /^## /{exit} /^## .*(Session courante|Chantiers actifs)/{on=1} on{print; if (++n >= 12) exit}' "$MAP"
  OTHERS=$(ls -t "$OM_VAULT"/Projets/*/*-MAP.md "$OM_VAULT"/Clients/*/Emails/*-MAP.md 2>/dev/null \
    | grep -v '_EXEMPLE' | grep -vxF "$MAP" | head -3 \
    | sed -E 's#.*/(Projets|Clients)/([^/]+)/.*#\2#' | paste -sd, - | sed 's/,/, /g')
  [ -n "$OTHERS" ] && echo "Autres entités récentes : $OTHERS"
else
  echo "Aucune entité (MAP) encore créée dans ce vault : propose /scaffold quand l'utilisateur démarre un projet ou un client."
fi

# Session précédente terminée sans sauvegarde (entrée du journal plus récente que la MAP).
if [ -f "$JOURNAL" ] && { [ -z "$MAP" ] || ! [ "$MAP" -nt "$JOURNAL" ]; }; then
  LAST=$(awk '/^## /{b=""} {b=b $0 "\n"} END{printf "%s", b}' "$JOURNAL")
  case "$LAST" in *"non sauvegardée"*)
    echo ""
    echo "Session précédente non sauvegardée :"
    printf '%s\n' "$LAST" | sed '/^$/d'
    echo "→ Propose en UNE ligne de rattraper la sauvegarde (lire ce transcript, puis appliquer le skill compress). N'insiste pas si l'utilisateur refuse."
  ;; esac
fi

echo ""
echo "Consignes : ne charge les fichiers listés dans « Charger » que si la demande concerne cette entité ; pour une autre entité, applique le skill resume. La sauvegarde se fait automatiquement en cours de session ; /compress reste disponible pour un bilan complet."
exit 0
