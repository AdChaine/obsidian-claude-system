# install.ps1 — Installe les skills de obsidian-claude-system sur Windows (PowerShell)
# Usage :
#   .\install.ps1                                                  # le vault sera détecté ou demandé à l'usage
#   .\install.ps1 -VaultPath "C:\Users\toi\Documents\mon-cerveau"  # cree le vault a partir de
#                                                                   # vault-template\ s'il n'existe pas, et fixe son chemin
# Prérequis : PowerShell 5.1+ ; pas besoin d'être administrateur.

param([string]$VaultPath = "")

$RepoDir   = $PSScriptRoot
$ClaudeDir = "$env:USERPROFILE\.claude"
$SkillsDir = "$ClaudeDir\skills"
$CmdDir    = "$ClaudeDir\commands"
$Stamp     = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

Write-Host ""
Write-Host "-> Installation depuis : $RepoDir"
New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null

Get-ChildItem -Directory "$RepoDir\skills" | ForEach-Object {
    $n   = $_.Name
    $dst = "$SkillsDir\$n"
    if (Test-Path $dst) {
        Move-Item $dst "$dst.bak.$Stamp"
        Write-Host "  [!] skill $n existait deja -> sauvegarde en $n.bak.$Stamp"
    }
    Copy-Item $_.FullName $dst -Recurse
    if (Test-Path "$CmdDir\$n.md") {
        Move-Item "$CmdDir\$n.md" "$CmdDir\$n.md.bak.$Stamp"
        Write-Host "  [>] ancienne commande /$n (v1) mise de cote"
    }
    Write-Host "  [OK] skill $n installe"
}

if ($VaultPath -ne "") {
    $VaultPath = [System.IO.Path]::GetFullPath($VaultPath)
    $RepoFull  = [System.IO.Path]::GetFullPath($RepoDir).TrimEnd('\')
    if ($VaultPath -eq $RepoFull -or $VaultPath.StartsWith("$RepoFull\", [StringComparison]::OrdinalIgnoreCase)) {
        Write-Host "  [X] Le vault ne doit pas etre dans le dossier du depot ($RepoFull) :"
        Write-Host "      un git pull pourrait entrer en conflit avec tes notes. Choisis un autre chemin."
        exit 1
    }
    if (-not (Test-Path $VaultPath) -or -not (Get-ChildItem -Force $VaultPath | Select-Object -First 1)) {
        New-Item -ItemType Directory -Force -Path $VaultPath | Out-Null
        Copy-Item "$RepoDir\vault-template\*" $VaultPath -Recurse -Force
        Write-Host "  [OK] vault cree a partir du modele : $VaultPath"
    } else {
        Write-Host "  [i] $VaultPath existe deja et n'est pas vide : il est conserve tel quel (rien n'est copie)."
    }
    Get-ChildItem "$SkillsDir\*\SKILL.md" | ForEach-Object {
        $c = Get-Content $_.FullName -Raw -Encoding UTF8
        if ($c -match [regex]::Escape("<VAULT_ROOT>")) {
            $c = $c -replace [regex]::Escape("<VAULT_ROOT>"), $VaultPath
            Set-Content $_.FullName -Value $c -Encoding UTF8 -NoNewline
        }
    }
    Write-Host "  [OK] chemin du vault fixe : $VaultPath"
} else {
    Write-Host "  [i] Aucun chemin fourni : le vault sera detecte ou demande a l'usage."
}

Write-Host ""
Write-Host "Installation terminee."
if ($VaultPath -ne "") {
    Write-Host "  1. Personnalise $VaultPath\CLAUDE.md (section Qui je suis)."
    Write-Host "  2. Ouvre Claude Code dans ce dossier : cd `"$VaultPath`" ; claude"
    Write-Host "  3. Tape /resume. (Facultatif : ouvre aussi ce dossier dans Obsidian pour naviguer dans tes notes.)"
} else {
    Write-Host "  1. Cree ton vault : relance .\install.ps1 -VaultPath `"$env:USERPROFILE\Documents\mon-cerveau`""
    Write-Host "     (ou copie vault-template\ hors de ce depot, la ou tu veux)."
    Write-Host "  2. Personnalise son CLAUDE.md, ouvre Claude Code dedans et tape /resume."
}
Write-Host ""
Write-Host "Skills : /resume  /client-brief  /compress  /preserve  /scaffold  /audit-vault  /lint-vault"
