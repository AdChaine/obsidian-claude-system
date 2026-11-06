---
name: obsidian-note-system
description: >
  Crée, structure et maintient les 8 types de notes du vault Obsidian pour Claude Code.
  Déclencher pour : créer/modifier note Obsidian, CLAUDE.md, MAP, BRIEF client ou projet,
  fiche thématique, DECISIONS, TASKS, ARCHITECTURE, MODELES, log session,
  /compress /resume /preserve /client-brief, structurer vault pour Claude Code.
---

# Obsidian Note System — v2.1

## TL;DR (lire en premier)

```
Vault = Clients/ + Projets/ + Entreprise/ + +Inbox/
Chaque entité a : MAP (point d'entrée) + BRIEF (contexte) + fichiers spécifiques
Claude lit MAP en premier → charge uniquement les fichiers indiqués
/compress à la fin de chaque session (checklist 5 points)
0 note orpheline — toute note a un wikilink entrant depuis MAP ou BRIEF
Vocabulaire FERMÉ pour type: et status: — vérifié par /lint-vault
En cas de doute sur où ranger → +Inbox/YYYY-MM-DD-sujet-DRAFT.md
Syntaxe Markdown/Obsidian exacte (pipes échappés, ancres, callouts) → references/markdown-syntax.md
```

---

## Vocabulaire fermé du frontmatter

`type:` décrit le RÔLE de la note, jamais sa provenance. Huit valeurs, pas une de plus :
`map` · `brief` · `fiche` · `tache` · `backlog` · `decisions` · `session` · `architecture`

`status:` décrit le cycle de vie. Deux vocabulaires selon le rôle :
- entités : `brouillon` · `actif` · `gele` · `archive`
- tâches (`type: tache`) : `a-faire` · `en-cours` · `bloque` · `attente` · `fait` · `annule`

Besoin d'une nuance ? Elle ne va JAMAIS dans `type:` ni `status:` :
- provenance (email, reunion, ticket, devis…) → `nature:`
- état métier (publie, livre, resolu, migre…) → `etat:`
- urgence → `priorite:`

Écrire une valeur hors liste crée une clé morte que les Bases et les requêtes
ignorent en silence. `/lint-vault` refuse ces valeurs.

**Ne jamais reproduire la syntaxe exacte d'une balise d'ancrage** (`LEARNINGS`,
`TACHES-ACTIVES`, `SOMMAIRE`) dans de la prose ou un exemple : les commandes
matchent la première occurrence et écriraient au mauvais endroit.

---

## Les 8 types de notes

| # | Fichier | Rôle | Responsable | ~tokens |
|---|---|---|---|---|
| 1 | `CLAUDE.md` | Cerveau maître — identité + vault | Vous | 800 |
| 2 | `[NOM]-MAP.md` | Point d'entrée + navigation | Mixte | 600 |
| 3 | `Clients/[X]/BRIEF.md` | Contexte client permanent | Vous | 800 |
| 4 | `Clients/[X]/[Source]/[theme].md` | Sujet précis (emails/réunions) | Claude | 400-800 |
| 5 | `Projets/[X]/BRIEF.md` | Vision + stack + phases | Vous | 700 |
| 6 | `Projets/[X]/ARCHITECTURE\|MODELES\|DECISIONS.md` | Détail technique | Claude | 600-800 |
| 7 | `Projets/[X]/TASKS.md` | Backlog par phase | Claude | 500 |
| 8 | `[...]/Sessions/YYYY-MM-DD.md` | Log de session | Claude | 200 |

**Responsabilités :**
- L'utilisateur écrit : BRIEF (vision), DECISIONS (arbitrages), CLAUDE.md (règles perso)
- Claude écrit : logs Sessions/, MAJ TASKS, fiches thématiques issues d'emails
- Mixte : MAP (Claude propose, l'utilisateur valide)

---

## Arbre de décision — où ranger une info ?

```
L'info concerne UN client spécifique ?
  ├─ Oui → Info permanente / identité client ? → BRIEF client
  │         Sujet récurrent dans 3+ emails ? → fiche thématique [Source]/[theme].md
  │         Navigation / carte mentale ? → MAP client
  └─ Non → C'est un projet code ?
              ├─ Vision/stack/phases ? → BRIEF projet
              ├─ Structure code/routes ? → ARCHITECTURE
              ├─ Schéma DB/modèles ? → MODELES
              ├─ Décision technique avec raison ? → DECISIONS
              ├─ Tâche à faire ? → TASKS
              └─ Log de session ? → Sessions/YYYY-MM-DD.md

Info transverse (touche plusieurs projets) ? → Entreprise/ ou note en racine + wikilinks entrants
Incertain ? → +Inbox/YYYY-MM-DD-sujet-DRAFT.md (jamais de décision arbitraire)
```

---

## Quand NE PAS créer une note

- Info qui tient en 1 ligne dans le BRIEF → bullet dans BRIEF, pas de fiche
- Décision sans raison durable → pas d'ADR
- Log de réunion qu'on lira 1 seule fois → Sessions/ (pas une fiche thématique)
- Note < 3 lignes de contenu réel → bullet dans une autre note ou +Inbox/
- Note sans wikilink entrant possible depuis MAP ou BRIEF → refus, aller dans +Inbox/

**Règle anti-duplication :** MAP pointe, il ne duplique pas. Si une info est dans BRIEF,
le MAP fait `[[BRIEF]] — voir section X`, pas de copie.

---

## TYPE 1 — CLAUDE.md

**Règle :** Maximum **300 lignes**. Au-delà → archiver dans "Journal d'archivage"
puis vers `CLAUDE-archive.md` quand > 6 mois ET non cité récemment.

**Structure** → voir `references/templates.md#claude-md`

**Règles de densité :**
- Stack : version réelle exacte ("React 19.0.0", pas "React")
- Statut projet : précis ("Phase 1 terminée — Phase 2 en cours")
- Focus client : le vrai chantier actuel, mis à jour à chaque changement de priorité

---

## TYPE 2 — MAP

Point d'entrée absolu. Répond en 30s à "où on en est ?"

### MAP Projet — frontmatter correct
```yaml
---
projet: mon-saas
type: map
tags: [mon-saas, map, navigation]
status: actif
updated: 2025-01-15
---
```
⚠️ `tags:` = liste simple YAML — PAS de doubles crochets `[[]]`

### Bloc "Session courante" (à ajouter dans TOUS les MAPs projet)
```markdown
## 🔴 Session courante
- **Objectif :** [ce qu'on fait aujourd'hui — 1 ligne]
- **Charger :** TASKS + ARCHITECTURE
- **Ignorer :** MODELES, DECISIONS
- **Blocage :** [ou "Aucun"]
```
Ce bloc est mis à jour à chaque début de session par `/resume`.
Si absent du MAP existant → l'ajouter avant toute autre modification.

### MAP Client — structure
```markdown
## 👥 Interlocuteurs
## 🔴 Chantiers actifs  ← avec [[wikilinks]] vers fiches
## 📁 Fiches thématiques  ← groupées par catégorie
## 🔗 Liens transversaux
```

---

## TYPE 3 — BRIEF Client

Chargé via `/client-brief`. Source de vérité sur l'identité du client.

**Structure** → voir `references/templates.md#brief-client`

**Règle de robustification client** (playbook en 6 étapes pour chaque client) :
1. Créer `Clients/[NomClient]/BRIEF.md` avec interlocuteurs + chantiers
2. Créer `Clients/[NomClient]/[Source]-MAP.md` (Source = Emails, Réunion, etc.)
3. Identifier les 3-5 sujets récurrents → créer fiches thématiques
4. Lire corps complets des threads clés → enrichir les fiches
5. Ajouter wikilinks croisés entre fiches + vers MAP
6. Mettre à jour `CLAUDE.md` : focus actuel du client

---

## TYPE 4 — Fiche thématique

**Source flexible :** `Emails/`, `Réunion/`, `Notes/` selon l'origine.
Ex: `Clients/AcmeCorp/Réunion/2025-03-onboarding.md`

**Provenance obligatoire en en-tête :**
```markdown
> Source : email de [Personne] du [YYYY-MM-DD], sujet "[sujet exact]"
> Ou : réunion [date] avec [personnes présentes]
> Corps complets lus : oui / non (snippets seulement)
```

**Limite :** > 300 lignes → splitter en deux fiches + lien entre elles.

**Mise à jour (pas de doublon) :**
Ajouter une section en bas, ne pas réécrire l'existant :
```markdown
## ⚠️ Mise à jour [YYYY-MM-DD]
Ancienne règle : X → Nouvelle règle : Y — Raison : Z
```

**Structure** → voir `references/templates.md#fiche-thematique`

---

## TYPE 5 — BRIEF Projet

**Règle critique :** Vérifier la stack réelle avant d'écrire (lire `package.json`,
le schéma de base de données). La note peut mentir, le code est la vérité.

ARCHITECTURE.md et MODELES.md = résumés haut-niveau du repo.
La source de vérité reste dans `docs/` du repo Git.

**Structure** → voir `references/templates.md#brief-projet`

---

## TYPE 6 — Fiches techniques (ARCHITECTURE / MODELES / DECISIONS)

### ARCHITECTURE.md
- Arbre `src/`, routes, server actions, composants, librairies core, tests, env vars
- Lien vers `docs/architecture.md` du repo (ne pas dupliquer)

### MODELES.md
- Vue d'ensemble ASCII, champs clés par modèle, nullable avec ref DECISIONS
- Migrations appliquées (nom + contenu 1 ligne), enums

### DECISIONS.md — format ADR
```markdown
## [YYYY-MM] Titre

**Décision :** [1 ligne]
**Raison :** [2-3 lignes max]
**Note :** [exception / date réévaluation] (optionnel)
```

**Mise à jour d'une décision existante** (ne pas créer de doublon) :
Ajouter `⚠️ Mise à jour [date] : ancienne = X, nouvelle = Y, raison = Z`
sous la décision originale. Garder l'original pour la traçabilité.

---

## TYPE 7 — TASKS.md

Backlog par phase. Source temporaire en attendant votre outil de gestion.

**Règle traçabilité :** Feature prévue Phase 2 mais déjà faite →
cocher en Phase 1 + note `(prévu Phase 2, fait)`.

**Structure** → voir `references/templates.md#tasks`

---

## TYPE 8 — Log de session (`Sessions/YYYY-MM-DD.md`)

Type à part entière — frontmatter + structure définis.

```yaml
---
type: session
projet: [nom] ou client: [nom]
date: YYYY-MM-DD
tags: [session, [projet-ou-client]]
---
```

```markdown
# Session YYYY-MM-DD — [Projet/Client]

## Fait
- [action 1]

## Décisions
- [décision — raison courte]

## Blocages
- [ou "Aucun"]

## Prochaine session
- Objectif : [1 ligne]
- Fichiers à charger : [liste]
```

**Nommage multi-sessions/jour :** `2025-01-15-matin.md` ou `2025-01-15-client-a.md`

**Session touchant 2 entités :** log dans le projet si action = code,
dans le client si action = stratégie/communication.

**Cycle de vie :** Garder 3 derniers logs + 1 résumé mensuel.
Résumé : `Sessions/archives/YYYY-MM.md` (condensé de tous les logs du mois).

---

## Conventions transversales

### YAML frontmatter
```yaml
---
projet: mon-saas          # ou client: client-a
type: brief                # map | brief | fiche | tache | backlog | decisions | session | architecture
status: actif              # brouillon | actif | gele | archive
tags: [mon-saas, web]  # LISTE SIMPLE — jamais [[doubles crochets]]
updated: 2025-01-15        # mis à jour uniquement si contenu substantiel change
expires: 2025-06-30        # optionnel — Claude signale si dépassé lors de /resume
---
```

**status: frozen** → Claude demande confirmation avant toute modification.
**status: archived** → lecture seule, ne pas modifier.

### Palette emoji (fermée — ne pas en ajouter d'autres)
```
🔴 urgent / bloquant     🟡 en cours         ✅ terminé
📋 planifié / backlog    ⚠️  attention        🔗 liens connexes
```

### Wikilinks — règles
- Max **5-7 liens** par fiche (pas 20 — c'est du bruit)
- Priorité : MAP + BRIEF + 2-3 fiches vraiment connexes
- Liens relatifs pour traverser les dossiers : `[[../../Projets/Mon-SaaS/BRIEF]]`
- **Règle anti-orphelins :** toute note a au moins 1 backlink entrant (MAP ou BRIEF)
- Vérifier avec le panel Backlinks natif Obsidian (audit mensuel : 0 backlinks = lier ou archiver)
- **Syntaxe exacte obligatoire** (alias échappé dans un tableau `[[Note\|Alias]]`, ancre `[[Note#Titre exact]]`, wikilink entre guillemets dans le frontmatter) → détail complet dans `references/markdown-syntax.md`. Un lien mal échappé ou pointant vers un fichier renommé/déplacé est le principal générateur de faux orphelins et de liens cassés dans ce vault.

### Dossiers vs tags
- **Dossier** = entité unique (1 client, 1 projet)
- **Tag** = dimension transverse (#urgent, #design, #juridique)
- 1 note → 1 dossier, N tags

### 🔒 Sécurité — Zéro secret (règle dure)
**Aucune valeur de secret ne doit JAMAIS figurer dans le vault.** Mots de passe, clés API, tokens, secrets OAuth, chaînes de connexion DB, URLs de webhook privées : interdits en clair dans toute note.
- Tout secret est géré via un gestionnaire dédié (gestionnaire de mots de passe) ou un fichier **`.env` / `.env.local`** (jamais commité, hors vault).
- Dans une note, **référencer uniquement le nom de la variable** : `ANTHROPIC_API_KEY`, `STRIPE_SECRET_KEY` — jamais la valeur.
- Pour un accès humain (login client, FTP…) : noter "accès dans le gestionnaire de mots de passe — coffre [X]", pas l'identifiant.
- **Réflexe `/compress` et rédaction de doc :** avant d'écrire un log ou une fiche, vérifier qu'aucune valeur sensible ne s'y glisse. Patterns à refuser : `AIza…`, `sk-…`, `Bearer …`, `password=`, clés en base64 longues.
- Si un secret est découvert en clair dans une note existante → le retirer immédiatement, le remplacer par le nom de variable + alerter l'utilisateur (la clé est à révoquer/roter).

---

## Structure du vault

```
Vault/
├── CLAUDE.md                         ← cerveau maître (max 300L)
├── +Inbox/                           ← capture rapide + DRAFT en attente
│
├── Clients/
│   ├── Index-clients.md              ← liste de vos clients
│   └── [NomClient]/
│       ├── BRIEF.md
│       ├── Sessions/
│       │   ├── YYYY-MM-DD.md
│       │   └── archives/YYYY-MM.md
│       ├── Livrables/
│       ├── Emails/                   ← fiches issues des emails
│       │   ├── [CLIENT]-MAP.md
│       │   └── [theme].md
│       └── Réunion/                  ← fiches issues des réunions (ex: AcmeCorp)
│           └── YYYY-MM-DD-sujet.md
│
├── Projets/
│   └── [NomProjet]/
│       ├── [PROJET]-MAP.md           ← contient bloc "Session courante"
│       ├── BRIEF.md
│       ├── ARCHITECTURE.md
│       ├── MODELES.md
│       ├── DECISIONS.md
│       ├── TASKS.md
│       └── Sessions/
│
├── Entreprise/                       ← votre activité (équipe, finances, processus)
│   └── MonActivite/BRIEF.md
│
└── Personnel/
    └── [Formations, Side-projects, etc.]
```

---

## Commandes

### `/resume` — Début de session
1. Lire `[PROJET]-MAP.md` ou `Clients/[X]/BRIEF.md`
2. Lire le bloc "Session courante" (projet) ou "Chantiers actifs" (client)
3. Charger **uniquement** les fichiers listés dans "Charger :"
4. Vérifier si des `expires:` sont dépassés → alerter
5. Résumer en 5 lignes : où on en est, objectif du jour, blocages

### `/compress` — Fin de session (checklist obligatoire)
1. Créer `Sessions/YYYY-MM-DD.md` (TYPE 8)
2. Mettre à jour "Session courante" dans le MAP
3. Cocher les tâches terminées dans `TASKS.md`
4. Ajouter les décisions du jour dans `DECISIONS.md`
5. Mettre à jour `BRIEF.md` si un chantier a changé de statut

### `/preserve` — Ancrer une décision dans CLAUDE.md
Format dans "Décisions et apprentissages permanents" :
```markdown
### [YYYY-MM-DD] [Titre de la décision]
**Contexte :** [pourquoi cette décision a été prise]
**Règle :** [la règle applicable à l'avenir]
**Exemple :** [cas concret si utile]
```

### `/client-brief` — Charger contexte client
1. Lire `Clients/[NomClient]/BRIEF.md`
2. Lire `Clients/[NomClient]/Emails/[CLIENT]-MAP.md`
3. Identifier chantiers 🔴 urgents
4. Résumer contexte en 5 lignes

### Trier +Inbox/ (à la main ou en demandant à Claude)
Pour chaque fichier DRAFT dans +Inbox/ :
1. Appliquer l'arbre de décision (section 3)
2. Créer la note au bon endroit avec le bon template
3. Ajouter wikilink entrant depuis MAP ou BRIEF
4. Supprimer le DRAFT de +Inbox/

---

## Optimisation tokens

| Session | Charger |
|---|---|
| Debug/fix rapide | MAP + ARCHITECTURE |
| Nouvelle feature | MAP + TASKS + ARCHITECTURE |
| Nouveau modèle DB | MAP + MODELES + DECISIONS |
| Revue stratégique | MAP + BRIEF + TASKS |
| Session client | BRIEF client + MAP client |
| Session client emails | BRIEF client + fiche thématique ciblée |

**Règle absolue :** Ne jamais charger tous les fichiers d'un projet.
Le bloc "Session courante" du MAP dit exactement quoi charger.

---

## Anti-patterns (ce qu'il ne faut JAMAIS faire)

- Note orpheline sans backlink entrant → refus création
- Fiche thématique > 300 lignes sans split
- Décision dans TASKS (décision → DECISIONS, tâche → TASKS)
- Info client dans fiche projet (ou inverse)
- MAP qui duplique le contenu de BRIEF (MAP pointe, ne duplique pas)
- `tags: [[nom]]` avec doubles crochets dans YAML → invalide
- Modifier `updated:` pour une correction de typo → seulement pour contenu substantiel
- 2 entrées DECISIONS pour la même décision → 1 entrée + section "Mise à jour"
- Emoji hors palette fermée → bruit visuel
- **Valeur de secret (clé API, mot de passe, token) en clair dans une note → interdit absolu** (voir "Sécurité — Zéro secret")

---

## Audit périodique du vault (trimestriel)

```bash
# Lister les notes sans backlinks (potentiellement orphelines)
# Dans Obsidian : panneau Backlinks > "Notes non liées"

# Vérifier CLAUDE.md
wc -l CLAUDE.md  # alerte si > 300

# Vérifier updated: périmés (notes "actives" non modifiées depuis > 3 mois)
grep -r "status: actif" . | grep "updated: 202[0-9]-0[1-9]"
```

**Checklist trimestrielle :**
- [ ] 0 notes orphelines (0 backlinks entrants)
- [ ] CLAUDE.md ≤ 300 lignes
- [ ] Décisions > 6 mois non citées → CLAUDE-archive.md
- [ ] Sessions/ : garder 3 derniers + résumé mensuel
- [ ] `status: frozen/archived` cohérents avec réalité
- [ ] Clients perdus → `Clients/_archive/NomClient-YYYY/`

---

## Métriques de succès

- `/resume` → opérationnel en < 30 secondes
- Notes orphelines : **0**
- CLAUDE.md : **≤ 300 lignes**
- Wikilinks par fiche : **≤ 7**

---

> Pour les templates complets de chaque type, voir `references/templates.md`
> Pour les scripts de maintenance, voir `references/scripts.md`
> Pour la syntaxe Markdown/Obsidian exacte (wikilinks, callouts, tableaux, frontmatter), voir `references/markdown-syntax.md`
