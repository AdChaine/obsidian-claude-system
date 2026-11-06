# install.ps1 — Installe les skills de obsidian-claude-system sur Windows (PowerShell)
# Usage :
#   .\install.ps1                                                  # le vault sera détecté ou demandé à l'usage
#   .\install.ps1 -VaultPath "C:\Users\toi\Documents\mon-cerveau"  # fixe le chemin du vault
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
Write-Host "  1. Copiez vault-template\ la ou vous voulez votre vault Obsidian."
Write-Host "  2. Personnalisez son CLAUDE.md (section Qui je suis)."
Write-Host "  3. Ouvrez Claude Code dans le vault et tapez /resume."
Write-Host ""
Write-Host "Skills : /resume  /client-brief  /compress  /preserve  /scaffold  /audit-vault  /lint-vault"
