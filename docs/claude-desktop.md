# Utiliser obsidian-claude-system dans Claude Desktop

Claude Desktop propose trois façons de travailler. Le système fonctionne dans les trois.

| Mode | Ce qu'il faut | Différence avec Claude Code |
|---|---|---|
| **Onglet Code** | Rien de plus que pour Claude Code | Aucune |
| **Cowork** | Le plugin + le dossier du vault partagé | Aucune : Cowork a accès aux fichiers et peut lancer les scripts |
| **Chat** | Les skills (zips) + un serveur MCP de fichiers | Pas de shell : `/audit-vault`, `/lint-vault` et le lint de `/compress` passent par les outils de fichiers, plus lents sur un gros vault |

Les paquets sont attachés à chaque [release](https://github.com/AdChaine/obsidian-claude-system/releases/latest) : `obsidian-memory.plugin` et un zip par skill. Vous pouvez aussi les construire vous-même avec `./scripts/package.sh` (résultat dans `dist/`).

---

## Onglet Code

Suivez l'installation Claude Code du [README](../README.md#où-lutiliser) : plugin en une ligne ou `install.sh` / `install.ps1`. Ouvrez ensuite une session dans le dossier de votre vault.

---

## Cowork

1. Téléchargez `obsidian-memory.plugin` depuis la dernière release.
2. Dans Claude Desktop, passez en mode **Cowork**, puis importez le fichier (glisser-déposer dans la conversation, ou menu des plugins). Acceptez l'installation dans l'aperçu.
3. Donnez à Cowork l'accès au **dossier de votre vault** (celui qui contient `CLAUDE.md`, `Clients/`, `Projets/`).
4. Tapez « on reprend le projet X » ou utilisez `/resume`.

Le vault est détecté automatiquement s'il est le dossier partagé. Sinon, Claude demande le chemin une fois.

---

## Mode chat

Le mode chat n'a pas de shell. Il lui faut deux choses : les skills, et un accès aux fichiers du vault.

### 1. Donner accès au vault (serveur MCP de fichiers)

Le plus simple : **Réglages → Extensions**, installez l'extension **Filesystem** et ajoutez le dossier de votre vault.

Sans l'extension, ajoutez le serveur à la main dans le fichier de configuration (**Réglages → Développeur → Modifier la configuration**) :

```json
{
  "mcpServers": {
    "vault": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/chemin/absolu/vers/mon-cerveau"]
    }
  }
}
```

Windows : `"C:\\Users\\vous\\Documents\\mon-cerveau"` (antislashs doublés). Node.js doit être installé. Redémarrez Claude Desktop ensuite.

N'autorisez que le dossier du vault, pas tout votre disque.

### 2. Importer les skills

1. Téléchargez les zips de la release (un par skill).
2. **Réglages → Capacités → Skills → Importer**, un zip à la fois. Commencez par `obsidian-note-system` (la gouvernance), puis `resume` et `compress`.
3. Activez chaque skill importé.

### 3. Utiliser

Écrivez en langage naturel : « reprends le client Dupont », « sauvegarde la session », « retiens que… ». Claude choisit le bon skill et lit ou écrit dans le vault via le serveur de fichiers.

### Limites du mode chat

- `/audit-vault` et `/lint-vault` lisent les fichiers un à un au lieu d'un script en une passe : au-delà de quelques centaines de notes, préférez Cowork ou Claude Code.
- Le hook `pre-commit` ne concerne que les vaults versionnés avec Git, gérés depuis un terminal.

---

## Claude dans le navigateur (claude.ai)

Les skills s'importent de la même façon (Réglages → Capacités), mais claude.ai n'a pas accès aux fichiers de votre ordinateur. Il lui faut un vault accessible en ligne, par exemple un dépôt GitHub via le connecteur GitHub (lecture) ou Claude Code sur le web (lecture et écriture). Ce mode n'est pas encore documenté ici.
