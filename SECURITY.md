# Sécurité

## Versions maintenues

Seule la dernière version publiée (voir [Releases](../../releases)) reçoit des correctifs.

## Signaler une faille

**N'ouvrez pas d'issue publique.** Utilisez le signalement privé de GitHub : onglet **Security → Report a vulnerability**.

Indiquez la commande ou le script concerné, le scénario de reproduction et l'impact (ex. : un secret qui pourrait finir dans le vault, une commande qui écrit hors du vault, un script qui supprime des fichiers). Réponse visée sous 7 jours.

## Périmètre

Ce projet ne stocke ni ne transmet aucune donnée : il fournit des commandes et des scripts locaux. Les failles les plus pertinentes concernent donc :
- l'écriture ou la suppression de fichiers hors du vault ciblé ;
- un contournement de la règle « zéro secret » (`/compress`, skill `obsidian-note-system`) ;
- les scripts d'installation (`install.sh`, `install.ps1`).
