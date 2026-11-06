#!/bin/sh
# lint-vault.sh — contrôle d'intégrité du schéma d'un vault Obsidian.
# POSIX pur (grep/sed/awk/find). Aucune dépendance, aucune écriture dans le vault.
# Usage : ./lint-vault.sh [chemin_du_vault]
# Sortie : rapport lisible. Code 1 si au moins une erreur (utilisable en pre-commit).

VAULT="${1:-.}"
TMPD=$(mktemp -d "${TMPDIR:-/tmp}/lint-vault.XXXXXX") || exit 2
trap 'rm -rf "$TMPD"' EXIT INT TERM
cd "$VAULT" || { echo "Vault introuvable : $VAULT"; exit 2; }

TYPES='map brief fiche tache backlog decisions session architecture'
STATUS_ENTITE='brouillon actif gele archive'
STATUS_TACHE='a-faire en-cours bloque attente fait annule'
ERR=0
sect() { printf '\n\033[1m%s\033[0m\n' "$1"; }
fail() { ERR=1; }

# liste des notes du vault (globs protégés : ne jamais stocker -path dans une variable)
notes() {
  find . -name '*.md' \
    -not -path './.git/*' -not -path './.obsidian/*' -not -path './.trash/*' \
    -not -path './.claude/*' -not -name 'CLAUDE.md'
}

# frontmatter d'une note : awk entre les deux premiers ---
fm() { awk '/^---$/{c++;next} c==1' "$1"; }

sect "1. Clé de statut fantôme (statut: au lieu de status:)"
N=$(notes | xargs grep -l '^statut:' 2>/dev/null | tee $TMPD/lint_statut.txt | wc -l | tr -d ' ')
[ "$N" -eq 0 ] && echo "   OK" || { fail; echo "   $N note(s) :"; sed 's/^/     /' $TMPD/lint_statut.txt; }

sect "2. Valeurs de status: hors vocabulaire"
notes | while read -r f; do
  t=$(fm "$f" | sed -n 's/^type: *//p' | head -1 | sed 's/ *#.*//')
  s=$(fm "$f" | sed -n 's/^status: *//p' | head -1 | sed 's/ *#.*//;s/ *$//')
  [ -z "$s" ] && continue
  case " $TYPES " in *" $t "*) ;; *) continue ;; esac
  if [ "$t" = tache ]; then V="$STATUS_TACHE"; else V="$STATUS_ENTITE"; fi
  case " $V " in *" $s "*) ;; *) echo "     $f  ->  status: $s (type: $t)" ;; esac
done > $TMPD/lint_status.txt
if [ -s $TMPD/lint_status.txt ]; then fail; echo "   $(wc -l < $TMPD/lint_status.txt | tr -d ' ') note(s) :"; cat $TMPD/lint_status.txt; else echo "   OK"; fi

sect "3. Valeurs de type: hors vocabulaire"
notes | while read -r f; do
  t=$(fm "$f" | sed -n 's/^type: *//p' | head -1 | sed 's/ *#.*//;s/ *$//')
  [ -z "$t" ] && continue
  case " $TYPES " in *" $t "*) ;; *) echo "     $f  ->  type: $t" ;; esac
done > $TMPD/lint_type.txt
if [ -s $TMPD/lint_type.txt ]; then fail; echo "   $(wc -l < $TMPD/lint_type.txt | tr -d ' ') note(s) :"; cat $TMPD/lint_type.txt; else echo "   OK"; fi

sect "4. Notes sans frontmatter"
notes | while read -r f; do
  [ "$(head -1 "$f")" = "---" ] || echo "     $f"
done > $TMPD/lint_fm.txt
if [ -s $TMPD/lint_fm.txt ]; then fail; echo "   $(wc -l < $TMPD/lint_fm.txt | tr -d ' ') note(s) :"; cat $TMPD/lint_fm.txt; else echo "   OK"; fi

sect "5. Notes > 300 lignes sans sommaire"
notes | while read -r f; do
  n=$(wc -l < "$f" | tr -d ' ')
  [ "$n" -gt 300 ] || continue
  grep -q '<!-- SOMMAIRE -->' "$f" && continue
  grep -qiE '^#{2,3} *(Index|Sommaire|Table des mati)' "$f" && continue
  echo "     $f  ($n lignes)"
done > $TMPD/lint_long.txt
if [ -s $TMPD/lint_long.txt ]; then echo "   $(wc -l < $TMPD/lint_long.txt | tr -d ' ') note(s) — avertissement :"; cat $TMPD/lint_long.txt; else echo "   OK"; fi

sect "6. Candidats orphelins (aucun lien entrant)"
grep -rhoE '\[\[[^]|#]+' . --include='*.md' \
  --exclude-dir=.git --exclude-dir=.obsidian --exclude-dir=.claude 2>/dev/null \
  | sed 's/^\[\[//' | awk -F'/' '{print $NF}' | sed 's/[[:space:]]*$//; s/\.md$//' | sort -u > $TMPD/lint_liens.txt
find . -type f -name '*.md' \
  | grep -vE '/(\.obsidian|\.git|\.claude|Sessions|archives|\+Inbox)/' \
  | grep -vE '(-MAP|BRIEF|CLAUDE)\.md$' | grep -viE 'template' \
  | awk -F'/' '{print $NF}' | sed 's/\.md$//' | sort -u > $TMPD/lint_fichiers.txt
grep -vxFf $TMPD/lint_liens.txt $TMPD/lint_fichiers.txt > $TMPD/lint_orph.txt 2>/dev/null
echo "   $(wc -l < $TMPD/lint_orph.txt | tr -d ' ') candidat(s) — avertissement (heuristique par basename)"

sect "7. Fichiers vides ou sans titre à la racine"
find . -maxdepth 1 -type f \( -size -3c -o -name 'Sans titre*' \) | sed 's/^/     /' > $TMPD/lint_vides.txt
if [ -s $TMPD/lint_vides.txt ]; then fail; cat $TMPD/lint_vides.txt; else echo "   OK"; fi

sect "8. Fichiers parasites (.DS_Store)"
N=$(find . -name '.DS_Store' -not -path './.git/*' | wc -l | tr -d ' ')
[ "$N" -eq 0 ] && echo "   OK" || echo "   $N .DS_Store — avertissement (à ignorer via .gitignore)"

printf '\n\033[1mRésultat : %s\033[0m\n' "$([ $ERR -eq 0 ] && echo 'schéma conforme' || echo 'ERREURS DE SCHÉMA — voir ci-dessus')"
exit $ERR
