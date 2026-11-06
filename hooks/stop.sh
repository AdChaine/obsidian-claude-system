#!/bin/sh
# stop.sh — hook Stop : sauvegarde automatique en cours de session.
# Toutes les N demandes de l'utilisateur (OBSIDIAN_MEMORY_SAVE_EVERY, 8 par défaut, 0 = désactivé),
# demande à Claude d'ajouter une courte entrée au log du jour et de mettre à jour la MAP.
# Un /compress manuel remet le compteur à zéro. Muet hors d'un vault.
. "$(dirname "$0")/lib.sh"
om_read_input
[ "$(om_bool stop_hook_active)" = true ] && exit 0
EVERY="${OBSIDIAN_MEMORY_SAVE_EVERY:-8}"
[ "$EVERY" -gt 0 ] 2>/dev/null || exit 0
CWD=$(om_field cwd); [ -n "$CWD" ] || CWD=$(pwd)
SID=$(om_field session_id); T=$(om_field transcript_path)
om_detect "$CWD" || exit 0
[ -n "$SID" ] && [ -f "$T" ] || exit 0

P=$(om_prompts "$T"); C=$(om_compress_runs "$T")
set -- $(om_state_get "$SID"); S=${1:-0}; SC=${2:-0}
if [ "$C" -gt "$SC" ]; then om_state_set "$SID" "$P" "$C"; exit 0; fi   # /compress lancé à la main
[ $((P - S)) -ge "$EVERY" ] || exit 0
om_once "stop-$SID-$P" || exit 0
om_state_set "$SID" "$P" "$C"

MAP=$(om_current_map "$OM_VAULT" "$OM_PROJECT")
HINT="aucune MAP trouvée"; [ -n "$MAP" ] && HINT="${MAP#"$OM_VAULT"/}"
REASON="Sauvegarde automatique obsidian-memory ($((P - S)) demandes depuis la dernière). Sans poser de question et sans reprendre le travail en cours : 1) ajoute à la fin du log du jour de l'entité concernée (Projets/X/Sessions/$(date +%Y-%m-%d).md ou Clients/X/Sessions/$(date +%Y-%m-%d).md ; s'il n'existe pas, crée-le avec ce frontmatter : type: session, status: archive, date: $(date +%Y-%m-%d), puis un titre « # Session $(date +%Y-%m-%d) — X ») une section « ### $(date +%H:%M) (auto) » de 3 à 6 puces : fait, décisions, prochaine étape ; 2) mets à jour le bloc Session courante (ou Chantiers actifs) de la MAP : Objectif et Charger. Vault : $OM_VAULT. Entité probable : $HINT. Zéro secret. Si la session ne concerne aucune entité du vault ou n'a rien produit de notable, n'écris rien. Ta réponse visible se limite ensuite à une seule ligne, sans autre commentaire : « Mémoire mise à jour. » ou « Rien à sauvegarder. »"
ESC=$(printf '%s' "$REASON" | sed 's/\\/\\\\/g; s/"/\\"/g')
printf '{"decision":"block","reason":"%s"}\n' "$ESC"
exit 0
