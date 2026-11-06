# Changelog

Format inspiré de [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/), versions selon [SemVer](https://semver.org/lang/fr/).

## [2.0.1] — 2026-11-06

### Corrigé
- `install.sh` et `install.ps1` créent désormais le vault à partir de `vault-template/` quand le chemin donné n'existe pas (ou est vide). Avant, ils fixaient le chemin dans les skills sans créer le dossier, et le README faisait ouvrir `vault-template/` dans le dépôt : les skills cherchaient un vault inexistant et les notes atterrissaient dans le clone git.
- Un vault existant n'est jamais écrasé ; un chemin situé dans le dépôt est refusé.
- La CI vérifie l'installation dans un dossier temporaire (création, non-écrasement, refus du dépôt).

### Changé
- README : sections « Pour qui ? » et « Démarrage rapide » en tête, Obsidian présenté comme facultatif, étapes 6 à 9 alignées sur le vault créé par le script.

## [2.0.0] — 2026-11-06

Fonctionne désormais dans Claude Desktop (Cowork et mode chat), en plus de Claude Code.

### Changé (rupture)
- Les 7 commandes deviennent des **skills** (`skills/<nom>/SKILL.md`) : `/resume`, `/compress`, etc. se lancent toujours avec `/nom` dans Claude Code, et Claude les déclenche aussi à partir de la demande. Le dossier `commands/` disparaît.
- `install.sh` / `install.ps1` installent dans `~/.claude/skills/` et mettent de côté les anciennes commandes v1 (`.bak`) pour éviter les doublons.
- `scripts/lint-vault.sh` déménage dans `skills/lint-vault/scripts/` (le hook `pre-commit` pointe vers la nouvelle place).
- `scripts/validate-commands.sh` devient `scripts/validate-skills.sh` (frontmatter + balises XML).

### Ajouté
- **Plugin** `obsidian-memory` (`.claude-plugin/`) installable dans Claude Code (`/plugin install obsidian-memory --marketplace AdChaine/obsidian-claude-system`) et dans Cowork (fichier `.plugin`).
- Détection automatique du vault (dossier de travail, dossier partagé, serveur MCP de fichiers), sinon demande unique.
- Mode sans shell pour le chat de Claude Desktop (`/audit-vault`, `/lint-vault`, lint de `/compress`).
- `scripts/package.sh` et une action GitHub qui attache le `.plugin` et un zip par skill à chaque release.
- Guide `docs/claude-desktop.md`.

### Corrigé
- `install.sh` plantait en fin d'installation (variable `VAULT_ROOT` non définie).
- Le vault modèle ne respectait pas son propre schéma (`status: active` au lieu de `actif`, `type: index`) ; la CI le vérifie désormais.

## [1.0.0] — 2026-11-05

Première version publique.

### Commandes
- `/resume` : reprise du contexte d'un client ou projet en ne chargeant que les fichiers utiles.
- `/client-brief` : synthèse fidèle d'un client (RAG strict, trous signalés).
- `/compress` : sauvegarde de session avec contrôle anti-secret, alerte d'obésité et lint du schéma.
- `/preserve` : ancrage d'une décision permanente avec diff et validation humaine.
- `/scaffold` : création d'un repo code, projet vault ou client vault, chaque note hydratée par son gabarit.
- `/audit-vault` : chasse aux notes orphelines en une passe `grep` ; exclut désormais `+Inbox/` et `Sources/`, et gère les `\|` échappés dans les tableaux.
- `/lint-vault` : contrôle du schéma (vocabulaire fermé, frontmatter, orphelins), utilisable en hook `pre-commit`.

### Skill
- `obsidian-note-system` v2.1 : gouvernance (8 types de notes, 0 orpheline, zéro secret) et référence de syntaxe Markdown/Obsidian.

### Outillage
- Installation macOS/Linux (`install.sh`) et Windows (`install.ps1`).
- CI de validation des commandes XML.
- Démo animée, image de partage, guides de contribution, code de conduite, politique de sécurité, modèles d'issue et de PR.

[2.0.0]: https://github.com/AdChaine/obsidian-claude-system/releases/tag/v2.0.0
