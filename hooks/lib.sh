#!/bin/sh
# lib.sh — fonctions communes aux hooks de mémoire automatique (obsidian-memory).
# POSIX pur. Les hooks ne doivent JAMAIS gêner une session : en cas de doute, ils se taisent (exit 0).

OM_HOME="${OBSIDIAN_MEMORY_HOME:-$HOME/.claude/obsidian-memory}"
OM_STATE="$OM_HOME/state"

# Lit l'entrée JSON du hook (stdin) une seule fois.
om_read_input() { OM_INPUT=$(cat); }

# Extrait un champ texte simple du JSON d'entrée (pas de dépendance à jq).
om_field() {
  printf '%s' "$OM_INPUT" | tr '\n' ' ' \
    | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -1 | sed 's/\\\\/\\/g'
}

# Extrait un booléen du JSON d'entrée.
om_bool() {
  printf '%s' "$OM_INPUT" | tr '\n' ' ' \
    | sed -nE "s/.*\"$1\"[[:space:]]*:[[:space:]]*(true|false).*/\1/p" | head -1
}

# Un dossier est un vault s'il contient CLAUDE.md et Clients/ ou Projets/.
om_is_vault() { [ -f "$1/CLAUDE.md" ] && { [ -d "$1/Clients" ] || [ -d "$1/Projets" ]; }; }

# Détermine le contexte. Renseigne OM_VAULT, OM_MODE (vault|repo) et OM_PROJECT (repo seulement).
# Retourne 1 si la session n'a rien à voir avec un vault : les hooks restent alors muets.
om_detect() {
  OM_VAULT=""; OM_MODE=""; OM_PROJECT=""
  d="$1"
  # 1. Le dossier de travail est dans un vault.
  while [ -n "$d" ] && [ "$d" != "/" ] && [ "$d" != "." ]; do
    if om_is_vault "$d"; then OM_VAULT="$d"; OM_MODE=vault; return 0; fi
    d=$(dirname "$d")
  done
  # 2. Un dépôt de code relié au vault : son CLAUDE.md importe le CLAUDE.md du vault (« @<vault>/CLAUDE.md »,
  #    ligne créée par /scaffold type 1).
  root=$(git -C "$1" rev-parse --show-toplevel 2>/dev/null || printf '%s' "$1")
  for f in "$1/CLAUDE.md" "$root/CLAUDE.md"; do
    [ -f "$f" ] || continue
    v=$(sed -n 's#^@\(.*\)/CLAUDE\.md[[:space:]]*$#\1#p' "$f" | head -1)
    case "$v" in "~"*) v="$HOME${v#\~}" ;; esac
    if [ -n "$v" ] && om_is_vault "$v"; then
      OM_VAULT="$v"; OM_MODE=repo; OM_PROJECT=$(basename "$root"); return 0
    fi
  done
  return 1
}

# Nombre de messages réellement tapés par l'utilisateur dans le transcript
# (hors résultats d'outils et messages techniques injectés).
om_prompts() {
  [ -f "$1" ] || { echo 0; return; }
  grep '"type":"user"' "$1" | grep '"role":"user","content":"' \
    | grep -v -e '"isMeta":true' -e '"isCompactSummary":true' | wc -l | tr -d ' '
}

# Nombre de lancements de /compress (manuel) dans le transcript.
om_compress_runs() {
  [ -f "$1" ] || { echo 0; return; }
  grep -cE 'command-name>/?(obsidian-memory:)?compress<|"skill":"(obsidian-memory:)?compress"' "$1" | tr -d ' '
}

# Fichiers modifiés par Claude pendant la session (chemins seulement, jamais le contenu).
om_edited_files() {
  [ -f "$1" ] || return 0
  grep -oE '"name":"(Edit|Write|MultiEdit|NotebookEdit)","input":\{"(file_path|notebook_path)":"[^"]+"' "$1" \
    | sed 's/.*_path":"//; s/"$//' | sort -u | head -15
}

# État par session : « prompts_sauvegardés compress_vus ».
om_state_get() { cat "$OM_STATE/$1" 2>/dev/null || echo "0 0"; }
om_state_set() { mkdir -p "$OM_STATE" && echo "$2 $3" > "$OM_STATE/$1"; }

# Verrou : empêche le même hook de tourner deux fois (plugin ET install.sh actifs ensemble).
om_once() {
  mkdir -p "$OM_STATE/locks" 2>/dev/null
  mkdir "$OM_STATE/locks/$1" 2>/dev/null
}

# MAP la plus récemment modifiée du vault (ou celle du projet donné en $2 si elle existe).
om_current_map() {
  if [ -n "$2" ]; then
    for p in "$1"/Projets/*/; do
      n=$(basename "$p")
      if [ "$(printf '%s' "$n" | tr 'A-Z' 'a-z')" = "$(printf '%s' "$2" | tr 'A-Z' 'a-z')" ]; then
        m=$(ls -t "$p"*-MAP.md 2>/dev/null | head -1)
        [ -n "$m" ] && { echo "$m"; return; }
      fi
    done
  fi
  ls -t "$1"/Projets/*/*-MAP.md "$1"/Clients/*/Emails/*-MAP.md 2>/dev/null | grep -v '_EXEMPLE' | head -1
}
