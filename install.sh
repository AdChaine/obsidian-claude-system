#!/usr/bin/env bash
# Installe les skills de obsidian-claude-system dans ~/.claude/skills (Claude Code, y compris
# l'onglet Code de Claude Desktop). Alternative sans script : le plugin (voir README).
# Usage :
#   ./install.sh                      # installe ; le vault sera détecté ou demandé à l'usage
#   ./install.sh "/chemin/vers/vault" # installe, crée le vault à partir de vault-template/
#                                     # s'il n'existe pas encore, et fixe son chemin
# Options :
#   --no-hooks      n'active pas la mémoire automatique (chargement au démarrage, sauvegarde en cours de session)
#   --remove-hooks  désactive la mémoire automatique et s'arrête là
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_PATH=""; HOOKS=1; REMOVE_HOOKS=0
for a in "$@"; do
  case "$a" in
    --no-hooks) HOOKS=0 ;;
    --remove-hooks) REMOVE_HOOKS=1 ;;
    -*) echo "Option inconnue : $a"; exit 2 ;;
    *) VAULT_PATH="$a" ;;
  esac
done
CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/obsidian-memory/hooks"
SETTINGS="$CLAUDE_DIR/settings.json"

if [ "$REMOVE_HOOKS" = 1 ]; then
  if command -v python3 >/dev/null 2>&1; then
    python3 "$REPO_DIR/scripts/hooks-settings.py" remove "$SETTINGS" "$HOOKS_DIR"
    rm -rf "$HOOKS_DIR"
    echo "✓ Mémoire automatique désactivée (hooks retirés de $SETTINGS, sauvegarde .bak faite)."
  else
    echo "python3 introuvable : retire à la main de $SETTINGS les hooks qui pointent vers $HOOKS_DIR."
  fi
  exit 0
fi
SKILLS_DIR="$CLAUDE_DIR/skills"
CMD_DIR="$CLAUDE_DIR/commands"
STAMP="$(date +%s)"

echo "→ Installation depuis : $REPO_DIR"
mkdir -p "$SKILLS_DIR"

for src in "$REPO_DIR"/skills/*/; do
  n="$(basename "$src")"
  dst="$SKILLS_DIR/$n"
  if [ -d "$dst" ]; then
    mv "$dst" "$dst.bak.$STAMP"
    echo "  ⚠️  skill $n existait déjà → sauvegardé en $n.bak.$STAMP"
  fi
  cp -R "$src" "$dst"
  # Ancienne version (v1) installée en commande : la mettre de côté pour éviter les doublons
  if [ -f "$CMD_DIR/$n.md" ]; then
    mv "$CMD_DIR/$n.md" "$CMD_DIR/$n.md.bak.$STAMP"
    echo "  ↪ ancienne commande /$n (v1) mise de côté en $n.md.bak.$STAMP"
  fi
  echo "  ✓ skill $n installé"
done

if [ -n "$VAULT_PATH" ]; then
  case "$VAULT_PATH" in "~"*) VAULT_PATH="$HOME${VAULT_PATH#\~}" ;; esac
  case "$VAULT_PATH" in "$REPO_DIR"|"$REPO_DIR"/*)
    echo "  ✗ Le vault ne doit pas être dans le dossier du dépôt ($REPO_DIR) :"
    echo "    un git pull pourrait entrer en conflit avec tes notes. Choisis un autre chemin."
    exit 1 ;;
  esac
  if [ ! -e "$VAULT_PATH" ] || [ -z "$(ls -A "$VAULT_PATH" 2>/dev/null)" ]; then
    mkdir -p "$VAULT_PATH"
    cp -R "$REPO_DIR/vault-template/." "$VAULT_PATH/"
    echo "  ✓ vault créé à partir du modèle : $VAULT_PATH"
  else
    echo "  ℹ️  $VAULT_PATH existe déjà et n'est pas vide : il est conservé tel quel (rien n'est copié)."
  fi
  for f in "$SKILLS_DIR"/*/SKILL.md; do
    grep -q "<VAULT_ROOT>" "$f" || continue
    sed -i.tmp "s|<VAULT_ROOT>|$VAULT_PATH|g" "$f" && rm -f "$f.tmp"
  done
  echo "  ✓ chemin du vault fixé : $VAULT_PATH"
  if [ -d "$VAULT_PATH/.git" ]; then
    cp "$REPO_DIR/scripts/pre-commit.sample" "$VAULT_PATH/.git/hooks/pre-commit"
    chmod +x "$VAULT_PATH/.git/hooks/pre-commit"
    echo "  ✓ hook pre-commit installé dans le vault (contourner : git commit --no-verify)"
  fi
else
  echo "  ℹ️  Aucun chemin fourni : le vault sera détecté (dossier de travail) ou demandé à l'usage."
fi

# Mémoire automatique : hooks SessionStart / Stop / SessionEnd (muets hors d'un vault).
if [ "$HOOKS" = 1 ]; then
  mkdir -p "$HOOKS_DIR"
  cp "$REPO_DIR"/hooks/*.sh "$HOOKS_DIR"/
  if command -v python3 >/dev/null 2>&1; then
    python3 "$REPO_DIR/scripts/hooks-settings.py" add "$SETTINGS" "$HOOKS_DIR"
    echo "  ✓ mémoire automatique activée (désactiver : ./install.sh --remove-hooks)"
  else
    echo "  ⚠️  python3 introuvable : mémoire automatique non activée. Voir README, section « Mémoire automatique »."
  fi
fi

echo ""
echo "✅ Installation terminée."
echo ""
echo "Étapes suivantes :"
if [ -n "$VAULT_PATH" ]; then
  echo "  1. Personnalise $VAULT_PATH/CLAUDE.md (section « Qui je suis »)."
  echo "  2. Ouvre Claude Code dans ce dossier : cd \"$VAULT_PATH\" && claude"
  echo "  3. Tape /resume. (Facultatif : ouvre aussi ce dossier dans Obsidian pour naviguer dans tes notes.)"
else
  echo "  1. Crée ton vault : relance ./install.sh \"\$HOME/Documents/mon-cerveau\""
  echo "     (ou copie vault-template/ hors de ce dépôt, là où tu veux)."
  echo "  2. Personnalise son CLAUDE.md, ouvre Claude Code dedans et tape /resume."
fi
echo ""
echo "Skills : /resume · /client-brief · /compress · /preserve · /scaffold · /audit-vault · /lint-vault"
