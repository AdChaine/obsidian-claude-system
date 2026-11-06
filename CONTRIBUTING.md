# Contribuer

Merci de votre intérêt. Issues et pull requests sont bienvenues : nouveaux types de notes, commandes additionnelles, adaptations (Notion, Logseq…), traductions, corrections.

## Avant de commencer

- **Un bug ?** Ouvrez une issue avec le modèle « Bug » : OS, version de Claude Code, commande lancée, résultat attendu et obtenu.
- **Une idée ?** Ouvrez d'abord une issue « Idée » pour en discuter : ça évite une PR refusée pour une question de périmètre.

## Règles du dépôt

1. **Standard des commandes (vérifié en CI).** Tout skill-commande dans `skills/` a un frontmatter `name` (= nom du dossier) + `description`, et contient les 4 balises XML `<purpose>`, `<strict_rules>`, `<workflow_steps>`, `<expected_output>` (ouvrantes et fermantes). Validez en local avant de pousser :
   ```bash
   ./scripts/validate-skills.sh
   ```
2. **Zéro chemin personnel.** Les chemins de vault s'écrivent `<VAULT_ROOT>`, jamais `/Users/vous/...`.
3. **Zéro secret, zéro donnée réelle.** Aucune clé, aucun nom de client, aucun e-mail dans les exemples : utilisez les gabarits `_EXEMPLE-*`.
4. **Vocabulaire fermé.** Un nouveau `type:` ou `status:` se discute dans une issue et s'ajoute au skill **et** à `skills/lint-vault/scripts/lint-vault.sh` dans la même PR.
5. **POSIX.** Les scripts restent en `sh`/`grep`/`awk` portables (macOS, Linux, Git Bash sous Windows).

## Pull request

- Une PR = un sujet.
- Décrivez le changement et comment vous l'avez testé (vault de test, commande lancée).
- La CI doit être verte avant la relecture.

En contribuant, vous acceptez que votre contribution soit publiée sous la [licence MIT](LICENSE) du projet, et vous respectez le [code de conduite](CODE_OF_CONDUCT.md).
