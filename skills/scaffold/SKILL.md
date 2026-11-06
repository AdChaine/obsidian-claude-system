---
name: scaffold
description: "Crée la structure standard d'une nouvelle entité (repo de code, projet du vault ou client du vault), chaque fichier pré-rempli par son gabarit, jamais de note vide. Utiliser quand l'utilisateur dit : /scaffold, nouveau projet, nouveau client, initialise, crée la structure de X."
---

# scaffold — Initialiser une nouvelle structure (code / projet vault / client vault)

<purpose>
Générer la structure standardisée d'une nouvelle entité en demandant son TYPE et son NOM, en routant vers le bon dossier cible, et en hydratant chaque fichier avec le gabarit correspondant (jamais de note vide).
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
1. NON-DESTRUCTION : avant de créer un dossier ou un fichier, vérifier s'il existe. Ne JAMAIS écraser un fichier existant — le signaler et passer au suivant.
2. PAS DE FICHIER VIDE : chaque `.md` créé contient au minimum son frontmatter YAML + son titre H1. Pour les MAP/BRIEF/TASKS, utiliser les gabarits de `skills/obsidian-note-system/references/templates.md`.
3. CRÉATION VAULT = action modérée : pour les types 2 et 3, annoncer le chemin cible et demander confirmation avant d'écrire.
4. DATAVIEW = OPT-IN : ne jamais injecter de bloc `dataview` sans accord explicite (le plugin n'est pas natif). Le bloc s'AJOUTE aux wikilinks explicites du MAP, il ne les remplace jamais (Claude navigue via les liens en dur, pas via le rendu Dataview qu'il ne voit pas).
</strict_rules>

<workflow_steps>
1. Demander : "Quel type de structure ? (1: Repo Code · 2: Projet Vault · 3: Client Vault) — et quel NOM ?" Attendre la réponse.
2. Déterminer TARGET_DIR :
   - (1) Repo Code   → dossier de travail courant (`cwd`).
   - (2) Projet Vault → `<VAULT_ROOT>/Projets/[NOM]`.
   - (3) Client Vault → `<VAULT_ROOT>/Clients/[NOM]`.
   Pour les types 2 et 3, demander aussi : "Inclure un dashboard Dataview dans le MAP (nécessite le plugin communautaire) ? y/N". Si oui → ajouter le bloc `#dataview-map-snippet` de `references/templates.md` SOUS les wikilinks (jamais à leur place).
3. Générer dans TARGET_DIR selon le type :

   (1) REPO CODE :
   - Créer `docs/` (PAS de `Sessions/` — les logs vivent dans le vault).
   - Créer `CLAUDE.md` : ligne 1 = `@<VAULT_ROOT>/CLAUDE.md`, ligne vide, puis `## Règles locales du projet`, puis un `## 0. Routeur de documentation` pointant vers `docs/`.

   (2) PROJET VAULT :
   - Créer `Sessions/`.
   - Créer `[NOM]-MAP.md` avec frontmatter (`type: map`) + `# [NOM] — MAP` + le bloc `## 🔴 Session courante` (Objectif / Charger / Ignorer / Blocage).
   - Créer `BRIEF.md`, `ARCHITECTURE.md`, `MODELES.md`, `DECISIONS.md`, `TASKS.md` — chacun avec frontmatter (`type:` adéquat, `status: actif`, `updated:`) + titre H1, hydratés depuis `references/templates.md`.

   (3) CLIENT VAULT :
   - Créer `Sessions/` et `Emails/`.
   - Créer `BRIEF.md` (frontmatter `type: brief` + `# BRIEF — [NOM]` + sections Interlocuteurs / Chantiers 🔴🟡 / Points d'attention).
   - Créer `Emails/[NOM]-MAP.md` (frontmatter `type: map` + `# [NOM]-MAP` + `## 🔴 Chantiers actifs`).
4. VÉRIFICATION : confirmer que chaque dossier/fichier prévu existe bien sur le disque.
</workflow_steps>

<expected_output>
Récapitulatif factuel : type choisi, TARGET_DIR, puis la liste des dossiers et fichiers réellement créés (et ceux ignorés car déjà présents).
</expected_output>
