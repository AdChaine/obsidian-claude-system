# Scripts de maintenance — Obsidian Note System

## Vérifier la taille de CLAUDE.md

```bash
#!/bin/bash
VAULT="${VAULT:-$HOME/chemin/vers/ton/vault}"
LINES=$(wc -l < "$VAULT/CLAUDE.md")
if [ "$LINES" -gt 300 ]; then
  echo "⚠️  CLAUDE.md dépasse 300 lignes ($LINES) — archiver les décisions > 6 mois"
else
  echo "✅ CLAUDE.md OK ($LINES lignes)"
fi
```

## Lister les notes potentiellement périmées (updated > 3 mois)

```bash
#!/bin/bash
VAULT="${VAULT:-$HOME/chemin/vers/ton/vault}"
CUTOFF=$(date -v-3m +%Y-%m-%d 2>/dev/null || date -d "3 months ago" +%Y-%m-%d)
echo "Notes avec status:active non mises à jour depuis $CUTOFF :"
grep -rl "status: actif" "$VAULT" | while read f; do
  UPDATED=$(grep "updated:" "$f" | head -1 | awk '{print $2}')
  if [[ "$UPDATED" < "$CUTOFF" ]]; then
    echo "  ⚠️  $f (updated: $UPDATED)"
  fi
done
```

## Compter les lignes de chaque type de note

```bash
#!/bin/bash
VAULT="${VAULT:-$HOME/chemin/vers/ton/vault}"
echo "=== Tailles des notes principales ==="
find "$VAULT" -name "*.md" -not -path "*/Sessions/*" -not -path "*/_archive/*" | while read f; do
  LINES=$(wc -l < "$f")
  NAME=$(basename "$f")
  if [ "$LINES" -gt 300 ]; then
    echo "  ⚠️  $NAME : $LINES lignes (> 300)"
  fi
done
```

## Détecter les notes sans wikilink entrant (orphelines)

```bash
#!/bin/bash
# Utiliser via Obsidian natif : Menu > Options > Plugins > Backlinks
# Ou via la commande "Show backlinks panel" sur chaque note
# Notes avec 0 backlinks = candidats à archiver ou lier
echo "Utiliser le panneau Backlinks d'Obsidian pour identifier les orphelines."
echo "Notes sans backlinks = lier depuis MAP ou BRIEF, ou déplacer vers +Inbox/"
```

## Archiver les vieux logs de session

```bash
#!/bin/bash
VAULT="${VAULT:-$HOME/chemin/vers/ton/vault}"
# Garder les 3 derniers, archiver le reste
find "$VAULT" -path "*/Sessions/*.md" -not -path "*/archives/*" -not -name "*.md" | \
  sort -r | tail -n +4 | while read f; do
    DIR=$(dirname "$f")
    mkdir -p "$DIR/archives"
    mv "$f" "$DIR/archives/"
    echo "Archivé : $f"
  done
```
