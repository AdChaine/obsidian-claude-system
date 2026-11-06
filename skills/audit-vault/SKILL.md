---
name: audit-vault
description: "Repère les notes orphelines du vault Obsidian (aucun lien entrant) en une passe économe et écrit le backlog dans +Inbox/TODO-liens.md. Utiliser quand l'utilisateur dit : /audit-vault, notes orphelines, liens manquants, nettoie le vault, audit du vault."
---

# audit-vault — Traquer les notes orphelines (économe en tokens)

<purpose>
Repérer les CANDIDATS aux notes orphelines (fichiers `.md` sans aucun lien entrant `[[...]]`) via un script bash en une passe, sans saturer le contexte LLM, puis lister le résultat dans la boîte de réception pour rattachement manuel.
</purpose>

<vault_root>
`<VAULT_ROOT>` désigne la racine du vault Obsidian. Si ce texte n'a pas été remplacé par un chemin à l'installation, la déterminer dans cet ordre :
1. Le dossier de travail ou le dossier partagé (Claude Code, Cowork) s'il contient un `CLAUDE.md` et un dossier `Clients/` ou `Projets/`.
2. Le dossier exposé par un serveur MCP de fichiers (Claude Desktop en mode chat) : lister les dossiers autorisés et prendre celui qui a cette structure.
3. Sinon, demander le chemin à l'utilisateur. Ne jamais créer de vault par supposition.
</vault_root>

<environnement>
Avec un shell (Claude Code, Cowork) : suivre les étapes telles quelles. Sans shell (Claude Desktop en mode chat avec un serveur MCP de fichiers) : remplacer chaque commande shell par l'outil de fichiers équivalent (lister, rechercher, lire, écrire) et le signaler en une ligne dans le récapitulatif.
</environnement>

<strict_rules>
1. ÉCONOMIE DE TOKENS : avec un shell, exécuter l'audit via l'outil `bash`. Sans shell (Claude Desktop en mode chat) : lister les `.md` avec les mêmes exclusions, rechercher les `[[` avec l'outil de recherche du serveur de fichiers, puis faire la différence ; au-delà d'environ 300 notes, prévenir que c'est coûteux et proposer de le lancer depuis Claude Code ou Cowork. Ne JAMAIS ouvrir/lire le contenu des fichiers avec les outils d'édition.
2. UTILITAIRES POSIX : utiliser `grep` (PAS `rg` — `rg` peut être absent ou wrappé par un shell selon les machines ; `grep` est universel).
3. SÉCURITÉ DES NOMS : gérer espaces et accents (comparaisons en chaînes fixes `grep -vxFf`, listes `sort -u`).
4. SÉMANTIQUE : parler de "candidats orphelins" — le matching par basename est une heuristique.
</strict_rules>

<workflow_steps>
1. Exécuter ce script bash exact (une passe) :
```bash
cd "<VAULT_ROOT>" || exit 1
T=$(mktemp -d) || exit 1
# A. Cibles de liens (hors +Inbox/ : la TODO ne doit pas masquer ses propres orphelins ; basename nettoyé : sans chemin, sans alias/ancre, sans \ du \| échappé en tableau, sans .md, sans espaces de fin)
grep -rhoE '\[\[[^]|#]+' . --include='*.md' \
  --exclude-dir=.git --exclude-dir=.obsidian --exclude-dir=.claude --exclude-dir=+Inbox 2>/dev/null \
  | sed 's/^\[\[//' | awk -F'/' '{print $NF}' | sed 's/\\$//; s/[[:space:]]*$//; s/\.md$//' \
  | sort -u > "$T/liens.txt"
# B. Fichiers candidats (hors dossiers système, Sessions/, archives/, Sources/ = fichiers d'origine bruts, templates, et fichiers racines)
find . -type f -name '*.md' \
  | grep -vE '/(\.obsidian|\.git|\.claude|Sessions|archives|Sources|\+Inbox)/' \
  | grep -vE '(-MAP|BRIEF|CLAUDE)\.md$' \
  | grep -viE 'template' \
  | awk -F'/' '{print $NF}' | sed 's/\.md$//' | sort -u > "$T/fichiers.txt"
# C. Différence : fichiers jamais cités comme cible de lien
grep -vxFf "$T/liens.txt" "$T/fichiers.txt" > "$T/orphelins.txt"
wc -l < "$T/orphelins.txt"
cat "$T/orphelins.txt"
rm -rf "$T"
```
2. Récupérer la liste affichée en fin de script (la liste finale uniquement).
3. Écrire/mettre à jour `<VAULT_ROOT>/+Inbox/TODO-liens.md` : chaque candidat en case à cocher `- [ ] [[nom]] — à rattacher (MAP/BRIEF) ou archiver`, avec un en-tête daté.
</workflow_steps>

<expected_output>
"🔍 Audit terminé. [X] candidats orphelins détectés. Liste écrite dans `+Inbox/TODO-liens.md` pour rattachement manuel."
</expected_output>
