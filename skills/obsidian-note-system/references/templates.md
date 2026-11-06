# Templates — Obsidian Note System

## #claude-md — CLAUDE.md

```markdown
# CLAUDE.md — Cerveau persistant de [Prénom Nom]
> Lis ce fichier en entier au début de chaque session.

## Qui je suis
[Nom, ville, rôles principaux, objectif de vie en 1 phrase]

## Mes convictions professionnelles
[3-5 bullets — guide les conseils de Claude]

## Priorités actuelles
1. [Impact le plus élevé]
2. ...

## Mes clients actifs
| Client | Secteur | Focus actuel |
|---|---|---|
| **[Nom]** | [Secteur] | [Chantier précis du moment] |
> Fiches détaillées : Clients/[NomClient]/BRIEF.md

## Mes projets
| Projet | Stack réelle | Statut |
|---|---|---|
| **[Nom]** | [versions exactes] | [Phase X — en cours/terminée] |
> Architectures : Projets/[Projet]/

## Skills disponibles
| Commande | Usage |
|---|---|
| `/resume` | Début session — lit MAP, charge contexte |
| `/compress` | Fin session — log + MAJ vault (checklist 5 points) |
| `/preserve` | Ancre décision permanente dans CLAUDE.md |
| `/client-brief` | Charge contexte client avant session |

## Comment travailler avec moi
### Langue : [français / anglais pour le code]
### Style : [direct / pédagogique selon contexte]
### Attentes : [proposer solutions, alerter risques, mémoriser sans répéter]
### Règles fichiers :
- Légères (créer, ajouter) → agir directement
- Modérées (modifier existant) → annoncer puis agir
- Graves (supprimer, restructurer, modifier CLAUDE.md) → confirmation explicite

## Liens transversaux
[Connexions non-évidentes entre projets — ex: "le module de facturation du projet A sert aussi au projet B"]

## Structure du vault
[Arbre de dossiers avec commentaires]

## Décisions et apprentissages permanents
> Alimenté par /preserve

### [YYYY-MM-DD] [Titre décision]
**Contexte :** ...
**Règle :** ...

## Journal d'archivage
> Archivé depuis ici vers CLAUDE-archive.md quand > 6 mois + non cité récemment
```

---

## #brief-client — BRIEF Client

```markdown
# BRIEF — [Client]
> Secteur : [X] · URL : [url] · Mission : [X]

## Qui est [Client]
[3-4 lignes : secteur, taille, positionnement, contexte marché]

## Interlocuteurs clés
| Nom | Rôle | Email | Tél |
|---|---|---|---|

## Chantiers actifs
### 🔴 Urgents
- [[fiche-liée]] — description courte

### 🟡 En cours
- [[fiche-liée]] — description courte

### ✅ Terminés récemment
- [action] — [date]

## Points d'attention permanents
- [Ce qu'on ne doit JAMAIS oublier]

## Décisions actées
- [YYYY-MM-DD] [Décision] — raison courte

## Sessions
> Logs dans Sessions/YYYY-MM-DD.md

## Contexte stratégique
[Périmètre mission, concurrents, objectifs, règles spécifiques]
```

---

## #fiche-thematique — Fiche thématique

```markdown
# [Client] — [Sujet]
> Source : email de [Personne] du [YYYY-MM-DD], sujet "[sujet]"
> Ou : réunion [date] avec [personnes]
> Corps complets lus : oui / non

## Contexte
[Pourquoi ce sujet existe — 3-4 lignes max]

## Chronologie
[Ordre chronologique — dates + faits bruts]

## Analyse / Diagnostic
[Ce qui a été compris, causes identifiées]

## Décisions prises
- [YYYY-MM-DD] [Qui] : [décision exacte]

## Règles actées
- [Règle non-négociable]

## Statut ([YYYY-MM-DD])
- ✅ Fait / ⏳ En attente [de qui] / 📋 Planifié / ❌ Bloqué

## 🔗 Liens connexes
- [[CLIENT-MAP]] — Vue d'ensemble
- [[fiche-liée]] — Raison du lien (max 5-7 liens)
```

---

## #brief-projet — BRIEF Projet

```markdown
---
projet: [nom-kebab]
type: brief
status: actif
tags: [nom, web]
updated: YYYY-MM-DD
---

# [Nom Projet] — Brief
> Repo : [org/repo] · Local : [/chemin/absolu]
> [[MAP]] · [[ARCHITECTURE]] · [[MODELES]] · [[DECISIONS]] · [[TASKS]]

## Vision
[2-3 phrases : quoi, pour qui, pourquoi, philosophie]

## Stack technique (état réel — vérifier package.json)
| Couche | Choix | Version |
|---|---|---|

## Hiérarchie de données
```
[Entité principale]
  └── [Sous-entité]
        └── [...]
```

## Rôles utilisateurs
| Rôle | Portée | Droits |
|---|---|---|
> ⚠️ Mentionner rôles renommés ou gelés

## Fonctionnalités en production
| Domaine | État |
|---|---|
| [Feature] | ✅ / 🟡 / ❌ |
> ⚠️ Corriger si des features "Phase 2" sont déjà faites

## Phases
### ✅ Phase 0 — [Nom] (terminée)
### 🟡 Phase 1 — [Nom] (en cours)
### 📋 Phase 2 — [Nom] (planifiée)

## Environnement
- Requises : DATABASE_URL, AUTH_SECRET, ...
- Optionnelles : ...

## Différenciation
[Ce qui différencie du marché existant]
```

---

## #tasks — TASKS.md

```markdown
---
projet: [nom]
type: backlog
tags: [nom, backlog]
updated: YYYY-MM-DD
---

# [Nom Projet] — Tasks
> Source temporaire — sera remplacé par [outil] 🔄

## ✅ Phase X — [Nom] (TERMINÉE)
### [Sous-domaine]
- [x] [Feature] (prévu Phase 2, fait)
- [x] [Feature]

## 🟡 Phase X — [Nom] (EN COURS)
### Tests
- [ ] [Test à écrire] — **priorité**
### Déploiement
- [ ] [Action]

## 📋 Phase X — [Nom] (PLANIFIÉE)
- [ ] [Item]

## 🚨 Bugs & dette technique connus
- [ ] [Description] — non bloquant
```
---

## #dataview-map-snippet — Dashboard Dataview (OPTIONNEL)

> ⚠️ **Nécessite le plugin communautaire Dataview.** Sans lui, ce bloc s'affiche en code brut non rendu.
> ⚠️ **Couche HUMAINE uniquement.** Dataview rend un tableau à la volée que **Claude ne voit PAS** (Claude lit le code source = la requête DQL, pas le résultat rendu). Ce bloc **s'ajoute** aux wikilinks explicites du MAP — il ne les remplace JAMAIS : les liens en dur restent les "routes" de navigation de l'IA.

MAP client — fiches thématiques liées, triées par date de modif :

```dataview
TABLE file.mtime AS "Modifié", status AS "Statut"
FROM "Clients/[NOM]"
WHERE file.name != "[NOM]-MAP" AND file.name != "BRIEF"
SORT file.mtime DESC
```

MAP projet — fichiers du projet :

```dataview
TABLE type AS "Type", status AS "Statut", updated AS "MAJ"
FROM "Projets/[NOM]"
WHERE file.name != "[NOM]-MAP"
SORT updated DESC
```
