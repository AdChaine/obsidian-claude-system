---
name: client-brief
description: "Produit une synthèse fidèle d'un client à partir du vault Obsidian (RAG strict : rien d'inventé, trous signalés « non documenté »). Utiliser quand l'utilisateur dit : /client-brief, brief client, fiche client, résume-moi le client X, où en est le client X."
---

# client-brief — Charger la fiche d'un client

<purpose>
Générer une synthèse de la situation d'un client en chargeant 3 sources précises et rien d'autre.
Usage : `/client-brief AcmeCorp` · `/client-brief Client-B`. Objectif : être dans le bon contexte en 15 secondes.
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
1. FIDÉLITÉ ABSOLUE : restituer UNIQUEMENT ce qui figure dans les 3 fichiers chargés. Interdiction totale d'inférer ou de deviner.
2. TRAITEMENT DU VIDE : si une information est absente d'une catégorie après extraction, écrire exactement : "— (non documenté)".
3. BUDGET DE LIGNES : maximum 3 bullet points par section, une seule ligne chacun.
4. TRAÇABILITÉ : chaque "Point d'attention permanent" pointe vers sa source (ex : `(cf. [[fiche]])` ou `(cf. BRIEF)`).
5. ZÉRO SECRET : ne jamais recopier une valeur sensible (clé API, mot de passe) — référencer le nom uniquement.
</strict_rules>

<workflow_steps>
1. Charger `Clients/[NomClient]/BRIEF.md`.
2. Charger `Clients/[NomClient]/Emails/[CLIENT]-MAP.md` (ou `Réunion/` selon la source).
3. Charger le dernier log dans `Clients/[NomClient]/Sessions/`.
4. Brouillon interne (invisible) : extraire les données brutes pour chaque section de l'<expected_output>. Noter "VIDE" si rien n'est trouvé.
5. Générer la réponse finale en appliquant les <strict_rules> sur le brouillon.
6. Si `BRIEF.md` est introuvable → ne pas inventer : appliquer le <fallback> à la place.
</workflow_steps>

<expected_output>
# Point de synchro — [NomClient]
**En une phrase :** [ce que fait le client + enjeu principal]

### Chantiers 🔴
[Extraction ou "— (non documenté)"]

### Chantiers 🟡
[Extraction ou "— (non documenté)"]

### Dernière session ([date])
- Fait : [résumé] · En suspens : [résumé]  (ou "— (non documenté)")

### Points d'attention permanents
[Liste avec sources `(cf. [[fiche]])` ou "— (non documenté)"]

**Prochaine action logique :** [action actionnable issue des documents]

*On travaille sur quoi pour [NomClient] aujourd'hui ?*
</expected_output>

<fallback>
Si `BRIEF.md` n'existe pas, ne rien inventer. Proposer de le créer via le playbook de robustification en 6 étapes :
1. Créer `Clients/[NomClient]/BRIEF.md` (interlocuteurs + chantiers).
2. Créer `Clients/[NomClient]/Emails/[CLIENT]-MAP.md`.
3. Identifier les 3-5 sujets récurrents → créer fiches thématiques.
4. Lire corps complets des threads clés → enrichir les fiches.
5. Ajouter wikilinks croisés entre fiches + vers MAP.
6. Mettre à jour `CLAUDE.md` : focus actuel du client.
Les conventions de création de notes (kebab-case, source en en-tête, max 300 lignes, ≤ 7 wikilinks, 0 orphelin) sont définies dans le skill `obsidian-note-system`.
</fallback>
