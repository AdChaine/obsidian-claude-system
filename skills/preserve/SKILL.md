---
name: preserve
description: "Ancre une décision ou un apprentissage permanent dans le CLAUDE.md racine du vault (ancre <!-- LEARNINGS -->), avec diff et validation avant écriture. Utiliser quand l'utilisateur dit : /preserve, retiens ça, règle permanente, à partir de maintenant toujours, ajoute ça au cerveau."
---

# preserve — Ancrer un apprentissage permanent dans CLAUDE.md

<purpose>
Insérer une règle ou décision permanente dans le Cerveau Maître (CLAUDE.md vault) sans altérer sa structure existante. À utiliser pour : nouvelle convention de travail, décision architecturale, préférence clarifiée, erreur à ne plus répéter, nouveau client/projet, lien transversal découvert.
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
1. Ne JAMAIS supprimer, écraser ou modifier une règle existante sans ordre explicite.
2. Ne JAMAIS supprimer ni déplacer les balises HTML `<!-- LEARNINGS:START -->` / `<!-- LEARNINGS:END -->`.
3. Human-in-the-loop : montrer le diff exact et attendre confirmation AVANT d'écrire (modifier CLAUDE.md = action grave).
4. Limite 300 lignes : si CLAUDE.md dépasse 300 lignes après l'ajout, proposer de déplacer les décisions > 6 mois et non citées vers `CLAUDE-archive.md`, et les clients/projets terminés vers "Journal d'archivage". Toujours garder actifs : convictions, règles de travail, clients/projets en cours.
</strict_rules>

<routing>
Déterminer la cible selon le type d'apprentissage :
- Décision / règle / erreur à ne plus répéter → bloc encadré par les balises `LEARNINGS` (voir <workflow_steps>).
- Nouvelle règle de travail → section "Comment travailler avec moi".
- Nouveau client → tableau "Mes clients actifs".
- Nouveau projet → tableau "Mes projets / code".
- Lien transversal → section "Liens transversaux à garder en tête".
Seul le type "décision/règle" utilise l'ancre déterministe ; les autres ciblent leur section/tableau par nom.
</routing>

<workflow_steps>
1. Formater l'apprentissage au format ADR :
   `### [YYYY-MM-DD] [Titre]` puis `**Contexte :**` / `**Règle :**` / `**Exemple :**` (optionnel).
2. Ouvrir `<VAULT_ROOT>/CLAUDE.md (le CLAUDE.md à la racine de ton vault)`.
3. Localiser la cible via <routing>. Pour une décision/règle : repérer la balise exacte `<!-- LEARNINGS:END -->`.
4. Insérer l'apprentissage formaté **immédiatement au-dessus** de `<!-- LEARNINGS:END -->` (ou dans la section nommée pour les autres types).
5. Afficher l'aperçu de l'insertion et attendre la confirmation explicite avant la sauvegarde.
</workflow_steps>

<expected_output>
Avant toute écriture, afficher uniquement :
"Voici l'insertion prévue (cible : [balise LEARNINGS / nom de section]) :
[aperçu exact de la modification]
Confirmez-vous la modification du Cerveau Maître ?"
N'écrire qu'après confirmation.
</expected_output>
