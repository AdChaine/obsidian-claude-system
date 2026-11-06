# Syntaxe Markdown Obsidian — référence de conformité

> Condensé depuis la doc officielle Obsidian (Basic + Advanced formatting syntax,
> Obsidian Flavored Markdown). Sert de check-list avant d'écrire ou modifier une note :
> évite les liens cassés, les pipes mal échappés et les blocs mal rendus.
> Pour la structure des notes (types, frontmatter, arbre de décision), voir `SKILL.md`.

---

## Paragraphes et sauts de ligne

- Une ligne vide sépare deux **paragraphes** distincts (`<p>`). C'est le comportement par défaut.
- Un simple retour à la ligne (Enter) **ne crée pas** un saut de ligne visuel en lecture — la ligne suivante est fondue dans le même paragraphe, sauf si `Strict Line Breaks` est activé dans les réglages.
- Pour forcer un saut de ligne **sans** créer un nouveau paragraphe : deux espaces en fin de ligne, ou `Shift+Enter`.
- Dans les logs de session et notes structurées de ce vault, préférer une ligne vide entre blocs plutôt que des sauts de ligne forcés — plus lisible en diff Git.

## Titres

`#` à `######` (H1 à H6). Toujours un espace après le(s) `#`. Ne pas sauter de niveau sans raison (H2 → H4).

## Emphase

| Style | Syntaxe | Rendu |
|---|---|---|
| Gras | `**texte**` | **texte** |
| Italique | `*texte*` | *texte* |
| Barré | `~~texte~~` | ~~texte~~ |
| Surligné | `==texte==` | ==texte== |
| Gras + italique | `***texte***` | ***texte*** |

Échapper un symbole pour l'afficher tel quel : `\*`, `\_`, `\#`, `` \` ``, `\|`, `\~`.

## Liens internes (wikilinks) — le point le plus sensible de ce vault

- Syntaxe : `[[Nom de la note]]` — résolu par **basename**, sans dossier ni extension nécessaires si le nom est unique dans le vault.
- Chemin explicite pour lever une ambiguïté ou traverser les dossiers : `[[../../Projets/X/BRIEF]]`.
- **Ancre vers un titre** : `[[Note#Titre exact]]` (respecter la casse et les tirets cadratins `—`). Sous-titre : `[[Note#Titre#Sous-titre]]`.
- **Ancre vers un bloc** : `[[Note#^id-bloc]]`.
- **Alias d'affichage** : `[[Note|Texte affiché]]`.
- **Dans un tableau Markdown**, le `|` de l'alias entre en conflit avec les `|` de colonnes → toujours l'échapper : `[[Note\|Alias]]`. Convention recommandée (`[[fichier\|alias]]`) : la respecter partout, y compris dans les listes à puces qui ne sont PAS dans un tableau (là, pas besoin d'échapper).
- Caractères à éviter dans un nom de note (cassent le lien) : `# | ^ : %% [[ ]]`.
- **Un wikilink qui pointe hors du vault (ex. vers `~/.claude/.../memory/`) ne se résout jamais dans Obsidian**, même avec un chemin relatif qui semble correct — Obsidian ne navigue pas au-delà de la racine du vault. Éviter ce type de lien : le contenu utile doit vivre dans le vault.

## Liens externes

`[Texte](https://url)`. Si l'URL contient des espaces : les remplacer par `%20` ou entourer l'URL de `< >`.

## Images et fichiers embarqués

- Externe : `![Alt](https://url)`.
- Interne : `![[Fichier.png]]`. Dimensionner avec `|largeur` ou `|largeurxhauteur` : `![[Fichier.png|400]]`.
- Embed d'une note entière : `![[Note]]`. D'un titre : `![[Note#Titre]]`. D'un bloc : `![[Note#^id]]`.

## Citations

`> texte` — chaque ligne de la citation commence par `>`.

## Listes

- Puces : `-`, `*` ou `+` (rester cohérent dans un même document, `-` recommandé).
- Numérotée : `1.` ou `1)`.
- Tâche : `- [ ]` / `- [x]` — c'est le format lu par Obsidian et les plugins de tâches ; ne jamais utiliser une autre syntaxe de case à cocher.
- Imbrication : indenter (Tab). Mélanger les types de listes en imbriqué est valide.

## Ligne horizontale

`---`, `***` ou `___` seuls sur leur ligne (3 caractères minimum).
⚠️ Ne pas confondre avec les délimiteurs de frontmatter YAML, qui utilisent aussi `---` mais en tout début et fin de bloc de propriétés.

## Code

- Inline : `` `code` ``. Si le code contient un backtick, doubler les délimiteurs : `` ``code`avec backtick`` ``.
- Bloc : trois ``` ``` ``` (ou `~~~`) minimum, avec langage optionnel après le premier fence (` ```bash `, ` ```ts `…).
- Bloc imbriqué dans un bloc (doc technique expliquant un bloc de code) : le fence extérieur doit avoir **plus** de backticks que l'intérieur, ou utiliser un type de fence différent (backticks dehors, tildes dedans).

## Notes de bas de page

`texte[^1]` puis en bas de note : `[^1]: explication`. Note nommée possible : `[^note-nom]`. Footnote inline : `^[texte directement ici]` (rendu en lecture seule, pas en Live Preview).

## Commentaires

`%%texte caché%%` — invisible en lecture, visible uniquement en édition. Utile pour des notes-à-soi-même qui ne doivent pas polluer le rendu, mais dans ce vault préférer une section `## Notes` classique pour rester grep-able par Claude (`%%…%%` peut échapper à une recherche texte selon l'outil).

## Callouts

```markdown
> [!warning] Titre optionnel
> Contenu du callout, supporte **markdown** et [[wikilinks]].
```

Types utiles pour ce vault : `note`, `tip`, `warning`, `danger`, `question`, `todo`, `success`. Foldable : `[!warning]-` (replié) ou `[!warning]+` (déplié). Réservé aux points qui doivent visuellement ressortir (blocage critique, alerte sécurité) — ne pas en abuser, ça casse la lecture linéaire d'un log de session.

## Tableaux

```markdown
| Colonne A | Colonne B |
| --------- | --------- |
| val       | val       |
```

- Alignement : `:--` (gauche), `:--:` (centré), `--:` (droite) dans la ligne de séparation.
- **Tout `|` littéral dans une cellule doit être échappé en `\|`** — cas le plus fréquent : wikilink avec alias (`[[Note\|Alias]]`) ou image redimensionnée (`![[img.png\|200]]`) à l'intérieur d'une cellule.

## Tags

- `#mot-clef` dans le corps, ou en liste dans la propriété `tags:` du frontmatter (jamais les deux syntaxes mélangées pour la même info).
- Caractères autorisés : lettres, chiffres, `_`, `-`, `/` (tags imbriqués `#client/dupont`), pas d'espace.
- Un tag purement numérique est invalide (`#1984` ✗, `#y1984` ✓).
- Insensible à la casse : `#Tag` et `#TAG` sont le même tag.

## Frontmatter (propriétés)

- Bloc YAML entre deux lignes `---` en tout début de fichier.
- Un wikilink **dans une valeur texte** doit être entre guillemets : `source: "[[Note]]"` — sinon le YAML peut se rompre selon les caractères du nom de note (espaces, `—`, `:`).
- Liste : un item par ligne précédé de `- `, pas de `[a, b, c]` inline pour rester lisible en diff.
- Ne jamais utiliser `[[double-crochets]]` sur `tags:` — c'est une liste simple, pas des wikilinks (déjà noté dans `SKILL.md`, anti-pattern #6).

## Échappements généraux

Précéder d'un `\` : `\*` `\_` `\#` `` \` `` `\|` `\~`. Pour une liste numérotée qui ne doit pas être interprétée comme liste, échapper le point : `1\.` (le backslash va devant le point, pas devant le chiffre).

---

## Check-list avant d'écrire dans le vault

1. Un `[[wikilink]]` cible une note qui existe réellement dans le vault.
2. Un wikilink avec alias **dans un tableau ou une liste dense** a son `|` échappé en `\|`.
3. Une valeur de frontmatter contenant un wikilink est entre guillemets.
4. `tags:` est une liste simple, jamais `[[...]]`.
5. Les cases à cocher de tâches utilisent strictement `- [ ]` / `- [x]`.
6. Un callout n'est utilisé que pour un point qui doit vraiment ressortir visuellement.
