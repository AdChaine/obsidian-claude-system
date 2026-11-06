---
name: resume
description: "Charge le contexte minimal d'un client ou d'un projet du vault Obsidian pour reprendre le travail sans rien réexpliquer (lit le MAP et le bloc Session courante). Utiliser quand l'utilisateur dit : /resume, reprends, on reprend, où en est-on sur X, charge le contexte de X, début de session."
---

# resume — Charger le contexte d'une session

<purpose>
Être opérationnel en 30 secondes sans rien réexpliquer. Charger le strict minimum pour reprendre le travail sur un client ou un projet.
Usage : `/resume` (demander le contexte) · `/resume client-a` · `/resume mon-saas` (contexte direct).
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
1. CHARGEMENT MINIMAL : ne JAMAIS charger tous les fichiers d'une entité. Charger uniquement ce qui est listé dans le bloc "Session courante" / "Chantiers actifs".
2. FIDÉLITÉ : restituer uniquement ce qui figure dans les fichiers chargés ; ne pas inférer l'état d'avancement.
3. EXPIRATION : vérifier les champs `expires:` du frontmatter des fichiers chargés. Tout `expires:` dépassé → alerter explicitement (contexte potentiellement obsolète), ne pas le traiter comme actif.
4. AUTO-RÉPARATION : si le bloc "Session courante" est absent du MAP, l'ajouter (<session_block_template>) AVANT toute autre action.
5. MÉMOIRE AUTOMATIQUE : si le contexte contient déjà un message `[obsidian-memory]` injecté au démarrage pour la même entité, ne pas relire le MAP : partir de ce bloc et charger seulement les fichiers de « Charger ».
</strict_rules>

<workflow_steps>
1. Si le contexte n'est pas précisé en argument → demander : "Sur quel client ou projet on travaille ?"
2. Identifier et charger le MAP :
   - Projet → `Projets/[NomProjet]/[PROJET]-MAP.md`
   - Client → `Clients/[NomClient]/Emails/[CLIENT]-MAP.md`
3. Lire le bloc "🔴 Session courante" (projet) ou "🔴 Chantiers actifs" (client).
4. Vérifier les `expires:` des frontmatter → alerter si dépassés.
5. Charger UNITAIREMENT les 2-3 fichiers listés dans "Charger :" (s'appuyer sur la <loading_matrix> selon le type de session) — rien d'autre.
6. Produire la synthèse de l'<expected_output>.
</workflow_steps>

<session_block_template>
## 🔴 Session courante
- **Objectif :** [à remplir]
- **Charger :** [fichiers]
- **Ignorer :** [fichiers]
- **Blocage :** Aucun
</session_block_template>

<loading_matrix>
| Type de session | Charger |
|---|---|
| Debug / fix rapide | MAP + ARCHITECTURE |
| Nouvelle feature | MAP + TASKS + ARCHITECTURE |
| Nouveau modèle DB | MAP + MODELES + DECISIONS |
| Revue stratégique | MAP + BRIEF + TASKS |
| Session client | BRIEF client + MAP client |
| Session client emails | BRIEF client + fiche thématique ciblée |
</loading_matrix>

<expected_output>
Résumer en 5 bullets maximum :
- Où on en était
- Objectif du jour
- Tâches en suspens
- Points d'attention (inclure toute alerte `expires:` dépassé)
- Blocages connus

Terminer par : *On continue sur quoi exactement ?*
</expected_output>
