---
name: compress
description: "Sauvegarde la session en cours dans le vault Obsidian : log daté, MAP, TASKS, DECISIONS, BRIEF, contrôle anti-secret et d'obésité, lint du schéma. Utiliser quand l'utilisateur dit : /compress, sauvegarde la session, on clôture, fin de session, note ce qu'on a fait."
---

# compress — Sauvegarder la session en cours

<purpose>
Sauvegarder et archiver la session en cours dans le système Obsidian v2.0, en suivant strictement une checklist ordonnée. Produire un log optimisé pour la prochaine session + mettre à jour le vault.
Avec la mémoire automatique (hooks), de courtes entrées « (auto) » sont déjà ajoutées au log du jour en cours de session : /compress fait le bilan complet (TASKS, DECISIONS, BRIEF, lint) et COMPLÈTE ce log au lieu d'en créer un second.
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
1. ZÉRO SECRET : scanner chaque fichier avant écriture. Bloquer toute valeur sensible (`AIza…`, `sk-…`, `Bearer …`, `password=`) et la remplacer par le nom de la variable d'environnement. (cf. skill `obsidian-note-system` → "Sécurité — Zéro secret")
2. NON-ÉCRASEMENT : jamais de réécriture totale pour une mise à jour. Utiliser l'édition ciblée ou l'ajout en fin de document. Ne jamais écraser un log existant.
3. ANTI-DOUBLON DÉCISIONS : si une décision existante a évolué, ajouter sous l'entrée originale `⚠️ Mise à jour [date] : ancienne = X, nouvelle = Y, raison = Z` — ne pas créer de 2e entrée.
4. VOCABULAIRE FERMÉ : toute note écrite ou modifiée respecte le schéma de `obsidian-note-system`. `type:` et `status:` n'acceptent que les valeurs listées ; une nuance va dans `nature:`, `etat:` ou `priorite:`. Ne jamais inventer une valeur pour coller au contexte.
</strict_rules>

<workflow_steps>
0. RATTRAPAGE (seulement si demandé) : quand le démarrage a signalé une « Session précédente non sauvegardée » et que l'utilisateur accepte de la rattraper, lire le transcript indiqué en ne gardant que les messages de l'utilisateur et les réponses texte (ignorer les gros résultats d'outils), puis dérouler les étapes ci-dessous pour CETTE session-là, avec sa date.
1. LOG : créer le fichier daté `YYYY-MM-DD.md` dans le bon dossier (Projet → `Projets/[X]/Sessions/`, Client → `Clients/[X]/Sessions/`). Routage si la session touche 2 entités : log dans le **projet** si l'action = code, dans le **client** si l'action = stratégie/communication. Multi-sessions le même jour → `YYYY-MM-DD-matin.md` ou `YYYY-MM-DD-[client].md`. Utiliser le <log_template>.
2. MAP : mettre à jour la section "Session courante" (projet) ou "Chantiers actifs" (client) dans le MAP concerné.
3. TASKS : cocher les tâches terminées (remplacer `[ ]` par `[x]`) dans `TASKS.md`.
4. DECISIONS : ajouter les décisions du jour dans `DECISIONS.md` au format ADR (règle anti-doublon ci-dessus).
5. BRIEF : mettre à jour `BRIEF.md` si un chantier a changé de statut (🔴→🟡→✅).
6. CONTRÔLE D'OBÉSITÉ : exécuter `wc -l` sur le `CLAUDE.md` pertinent (projet local si session code ; sinon ignorer). Si > 280 lignes, alerter : buffer avant la limite dure de 300 → la prochaine action sur ce projet devra être une extraction vers `docs/` ou un archivage (ne pas tronquer automatiquement).
7. CYCLE DE VIE : garder les 3 derniers logs + 1 résumé mensuel dans `Sessions/archives/YYYY-MM.md`.
8. LINT DU SCHÉMA (toujours, en dernier) : exécuter le script du skill `lint-vault` : `sh "<dossier du skill lint-vault>/scripts/lint-vault.sh" "<VAULT_ROOT>"`. Sans shell : sauter cette étape et proposer `/lint-vault`.
   Ne lire QUE le rapport, jamais les notes une par une.
   - Vert → une ligne dans le récapitulatif, rien de plus.
   - Rouge → lister les erreurs et proposer la correction. NE JAMAIS corriger en silence,
     et NE JAMAIS élargir le vocabulaire de la skill ou du script pour faire passer le lint :
     une valeur refusée est soit une faute à corriger, soit une décision à valider par l'utilisateur.
</workflow_steps>

<log_template>
---
type: session
status: archive
projet: [nom] ou client: [nom]
date: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [session, [projet-ou-client]]
---

# Session YYYY-MM-DD — [Projet/Client]

## Fait
- [action concrète réalisée]

## Décisions
- [décision prise] — raison courte

## Blocages
- [ou "Aucun"]

## Prochaine session
- Objectif : [1 ligne précise]
- Fichiers à charger : [liste]
</log_template>

<expected_output>
Afficher un récapitulatif factuel et concis des fichiers réellement modifiés et de la nature de chaque modification (pas de message générique).
Exemple : "Log créé (2025-01-15.md) | MAP.md mis à jour (section chantier) | 2 tâches cochées dans TASKS.md | DECISIONS.md +1 ADR."
Signaler toute alerte d'obésité ou tout secret bloqué.
Toujours indiquer le résultat du lint, par exemple : "Schéma vault : conforme." ou
"⚠️ Schéma vault : 3 notes hors vocabulaire — [liste]. Je corrige ?".
Terminer toujours par : *Y a-t-il un apprentissage à ancrer avec /preserve ?*
</expected_output>
