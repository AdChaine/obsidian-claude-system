---
name: lint-vault
description: "Contrôle l'intégrité du schéma du vault Obsidian (vocabulaire fermé type/status, frontmatter, gros fichiers, orphelins, fichiers parasites), en lecture seule. Utiliser quand l'utilisateur dit : /lint-vault, vérifie le vault, le schéma est-il respecté, contrôle d'intégrité."
---

# lint-vault — Contrôle d'intégrité du schéma (économe en tokens)

<purpose>
Vérifier que le vault respecte son propre schéma : vocabulaire fermé de `type:` et
`status:`, frontmatter présent, gros fichiers indexés, notes orphelines, fichiers
parasites. Détecte la DÉRIVE avant qu'elle ne contamine des centaines de notes.
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
1. ÉCONOMIE DE TOKENS : avec un shell, tout passe par le script `bash`. Ne JAMAIS lire les notes une par une avec les outils d'édition.
2. UTILITAIRES POSIX : `grep`/`sed`/`awk`/`find` uniquement (pas `rg`, pas `jq`).
3. LECTURE SEULE : le script n'écrit jamais dans le vault. Toute correction est proposée à l'utilisateur, jamais appliquée en silence.
4. DISTINGUER erreur (schéma violé, code de sortie 1) et avertissement (orphelins, .DS_Store — heuristiques).
5. NE PAS ÉLARGIR le vocabulaire pour faire passer le lint. Si une valeur manque vraiment, c'est une décision : la porter dans la skill ET dans le script, jamais dans une note isolée.
</strict_rules>

<workflow_steps>
1. Exécuter le script livré avec ce skill : `sh "<dossier de ce skill>/scripts/lint-vault.sh" "<VAULT_ROOT>"`.
   Sans shell (Claude Desktop en mode chat) : appliquer les mêmes contrôles avec les outils de fichiers, en ne lisant que les 10 premières lignes de chaque note (le frontmatter) ; vocabulaire fermé et seuils dans `scripts/lint-vault.sh` et dans le skill `obsidian-note-system`.
2. Lire UNIQUEMENT le rapport renvoyé.
3. Si erreurs : les présenter groupées par catégorie, avec pour chacune la correction
   proposée, et demander validation avant toute écriture.
4. Si le vault est vert : le dire en une ligne, ne rien faire d'autre.
5. Si des candidats orphelins sont signalés, proposer `/audit-vault` pour écrire le
   backlog dans `+Inbox/TODO-liens.md`.
</workflow_steps>

<expected_output>
"✅ Schéma conforme." — ou —
"⚠️ [N] erreurs de schéma : [catégories]. Correction proposée : [...]. Je corrige ?"
</expected_output>
