# CLAUDE.md — Cerveau persistant de [Prénom Nom]

> Lis ce fichier en entier au début de chaque session. Il définit qui je suis, comment travailler avec moi, et ce qui compte.
> C'est le **Cerveau Maître** (TYPE 1). Maximum 300 lignes — au-delà, archiver (voir `/preserve`).

---

## Qui je suis

**[Prénom Nom]** — [Ville, Pays]
- [Rôle principal]
- [Autre activité]
- Objectif de vie : [en une phrase]

---

## Mes convictions professionnelles (à intégrer dans chaque conseil)

- [Conviction 1 — guide les conseils de Claude]
- [Conviction 2]
- [Conviction 3]

---

## Priorités actuelles (classées par impact)

1. [Priorité à plus fort impact]
2. [...]
3. [...]

---

## Mes clients actifs

| Client | Secteur | Focus actuel | Fiche |
|---|---|---|---|
| **[Client A]** | [Secteur] | [Chantier du moment] | `Clients/[Client-A]/BRIEF.md` |

> Index complet : `Clients/Index-clients.md`

---

## Mes projets / code

| Projet | Stack (versions réelles) | Statut | Fiche |
|---|---|---|---|
| **[Mon-SaaS]** | [stack principale] | [Phase 1 ✅ · Phase 2 🟡] | `Projets/[Mon-SaaS]/BRIEF.md` |

---

## Comment travailler avec moi

### Langue
[Français / anglais pour le code]

### Style de communication
[Direct et concis / pédagogique selon le contexte]

### Ce que j'attends de Claude
1. Proposer des solutions, pas juste exécuter
2. Alerter quand une décision semble risquée
3. Mémoriser sans que je répète (ce fichier + logs de session)
4. Faire des liens entre mes projets spontanément

### Règles pour les actions sur fichiers
- **Légères** (créer une note, ajouter du contenu) → agir directement
- **Modérées** (modifier un fichier existant, déplacer) → annoncer puis agir
- **Graves** (supprimer, restructurer, modifier CLAUDE.md) → confirmation explicite

---

## Liens transversaux à garder en tête

- [Connexion non-évidente entre projets — ex : "le module de facturation du projet A sert aussi au projet B"]

---

## Structure du vault Obsidian

`Clients/[NomClient]/` → BRIEF + Sessions/ + Emails/ (MAP + notes kebab-case)
`Projets/[nom-projet]/` → BRIEF + MAP + ARCHITECTURE + DECISIONS + TASKS
`Taches/` → une note par tâche **engagée** (le backlog reste dans les TASKS.md)
`Ressources/` → savoir transverse, non rattaché à un client ni à un projet
`+Inbox/` → capture rapide, à trier
Fichiers structurants en MAJUSCULES. Notes thématiques en kebab-case. MAP = point d'entrée unique.

**Vocabulaire fermé du frontmatter** (contrôlé par `/lint-vault`) :
`type:` map · brief · fiche · tache · backlog · decisions · session · architecture
`status:` (entité) brouillon · actif · gele · archive
`status:` (tache) a-faire · en-cours · bloque · attente · fait · annule
Une valeur hors de ces listes est une erreur, pas une nuance : la nuance va dans
`nature:` (provenance) ou `etat:` (état métier).

---

## Décisions et apprentissages permanents

> Section mise à jour automatiquement par `/preserve`
> ⚙️ `/preserve` insère toute nouvelle entrée juste avant la balise de fin du bloc
> LEARNINGS ci-dessous. Ne pas supprimer les balises, et ne jamais réécrire leur
> syntaxe exacte ailleurs dans ce fichier : l'ancre doit rester unique, sinon
> `/preserve` insère au mauvais endroit.

<!-- LEARNINGS:START -->

- [YYYY-MM-DD] **[Titre de la première décision]** : [contexte + règle]. (exemple à remplacer)

<!-- LEARNINGS:END -->

---

## Journal d'archivage

> Décisions/projets/clients archivés, déplacés ici quand CLAUDE.md dépasse 300 lignes, puis vers `CLAUDE-archive.md`.

- *[Vide pour l'instant]*

---
*Dernière mise à jour : YYYY-MM-DD*
