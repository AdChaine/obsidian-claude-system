# Shot-list — GIF de démo

> La démo actuelle (`assets/demo.gif`) est une animation HTML rendue avec HyperFrames. Ce shot-list reste valable pour la remplacer par un vrai enregistrement.

> Objectif : faire comprendre l'outil en **5 secondes**, montrer la **fluidité**. Pas un tutoriel — une preuve visuelle.

## Réglages d'enregistrement
- Outil : **CleanShot X** (macOS) ou **LICEcap** (gratuit, multi-OS) → export **.gif**.
- Format : **paysage**, fenêtre Claude Code **+** explorateur de fichiers Obsidian **côte à côte** (le « avant/après » visuel est l'argument).
- Durée cible : **8–12 s**. Largeur ≤ **1200 px**. Poids ≤ **5 Mo** (sinon GitHub rame).
- Thème sombre, police lisible (≥ 14 pt), curseur visible.

## Scénario recommandé : `/scaffold` (le plus parlant)
1. **(0–1 s)** Plan large : Claude Code à gauche, arborescence Obsidian à droite (vide ou minimale).
2. **(1–3 s)** Tu tapes `/scaffold`, tu réponds `2` (Projet Vault) puis un nom (ex. `mon-app`).
3. **(3–6 s)** Claude crée la structure ; on voit les fichiers **apparaître instantanément** à droite (`mon-app-MAP.md`, `BRIEF.md`, `ARCHITECTURE.md`…).
4. **(6–8 s)** Tu ouvres `mon-app-MAP.md` : il n'est **pas vide** (frontmatter + bloc « Session courante »). Fin.

## Alternative : `/audit-vault`
1. `/audit-vault` → le script tourne (< 1 s).
2. `+Inbox/TODO-liens.md` s'ouvre, rempli de cases à cocher. Message « X candidats orphelins ».
   → Argument : « l'IA n'a lu aucun fichier, tout le travail lourd est fait par grep ».

## Intégration
1. Place le fichier ici : `assets/demo.gif`.
2. Dans `README.md`, remplace la ligne « 🎬 Démo à venir… » par :
   ```markdown
   ![Démo](assets/demo.gif)
   ```
3. Commit + push.
