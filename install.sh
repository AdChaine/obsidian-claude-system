#!/usr/bin/env bash
# Installe les skills de obsidian-claude-system dans ~/.claude/skills (Claude Code, y compris
# l'onglet Code de Claude Desktop). Alternative sans script : le plugin (voir README).
# Usage :
#   ./install.sh                      # installe ; le vault sera détecté ou demandé à l'usage
#   ./install.sh "/chemin/vers/vault" # installe ET fixe le chemin du vault
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_PATH="${1:-}"
CLAUDE_DIR="$HOME/.claude"
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

cat <<'EOF'

✅ Installation terminée.

Étapes suivantes :
  1. Copiez le dossier vault-template/ là où vous voulez votre vault Obsidian.
  2. Personnalisez son CLAUDE.md (section « Qui je suis »).
  3. Ouvrez Claude Code dans le vault et tapez /resume.

Skills : /resume · /client-brief · /compress · /preserve · /scaffold · /audit-vault · /lint-vault
EOF
