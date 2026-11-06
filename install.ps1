# install.ps1 — Installe les skills de obsidian-claude-system sur Windows (PowerShell)
# Usage :
#   .\install.ps1                                                  # le vault sera détecté ou demandé à l'usage
#   .\install.ps1 -VaultPath "C:\Users\toi\Documents\mon-cerveau"  # cree le vault a partir de
#                                                                   # vault-template\ s'il n'existe pas, et fixe son chemin
#   .\install.ps1 -NoHooks       # sans la memoire automatique
#   .\install.ps1 -RemoveHooks   # desactive la memoire automatique et s'arrete la
# Prérequis : PowerShell 5.1+ ; pas besoin d'être administrateur.

param([string]$VaultPath = "", [switch]$NoHooks, [switch]$RemoveHooks)

$RepoDir   = $PSScriptRoot
$ClaudeDir = "$env:USERPROFILE\.claude"
$SkillsDir = "$ClaudeDir\skills"
$CmdDir    = "$ClaudeDir\commands"
$Stamp     = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$HooksDir  = "$ClaudeDir\obsidian-memory\hooks"
$Settings  = "$ClaudeDir\settings.json"

function ConvertTo-OmHash($o) {
    if ($null -eq $o) { return $null }
    if ($o -is [System.Management.Automation.PSCustomObject]) {
        $h = [ordered]@{}
        foreach ($p in $o.PSObject.Properties) { $h[$p.Name] = ConvertTo-OmHash $p.Value }
        return $h
    }
    if ($o -is [System.Collections.IEnumerable] -and $o -isnot [string]) {
        $list = New-Object System.Collections.ArrayList
        foreach ($i in $o) { [void]$list.Add((ConvertTo-OmHash $i)) }
        return ,$list
    }
    return $o
}

# Ajoute (ou retire) les hooks de memoire automatique dans settings.json, sans toucher au reste.
function Set-OmHooks([bool]$Add) {
    $data = [ordered]@{}
    if (Test-Path $Settings) {
        $raw = Get-Content $Settings -Raw -Encoding UTF8
        if ($raw -and $raw.Trim()) { $data = ConvertTo-OmHash ($raw | ConvertFrom-Json) }
        Copy-Item $Settings "$Settings.bak.$Stamp"
    }
    if (-not $data.Contains("hooks")) { $data["hooks"] = [ordered]@{} }
    $hooks = $data["hooks"]
    $events = [ordered]@{ "SessionStart" = "session-start.sh"; "Stop" = "stop.sh"; "SessionEnd" = "session-end.sh" }
    $dir = $HooksDir -replace '\\', '/'
    foreach ($ev in $events.Keys) {
        $groups = New-Object System.Collections.ArrayList
        if ($hooks.Contains($ev)) {
            foreach ($g in $hooks[$ev]) {
                $kept = New-Object System.Collections.ArrayList
                foreach ($h in $g["hooks"]) { if ("$($h["command"])" -notlike "*obsidian-memory/hooks/*") { [void]$kept.Add($h) } }
                if ($kept.Count -gt 0) { $g["hooks"] = $kept; [void]$groups.Add($g) }
            }
        }
        if ($Add) {
            $cmd = "sh `"$dir/$($events[$ev])`""
            [void]$groups.Add([ordered]@{ "hooks" = @([ordered]@{ "type" = "command"; "command" = $cmd; "timeout" = 10 }) })
        }
        if ($groups.Count -gt 0) { $hooks[$ev] = $groups } elseif ($hooks.Contains($ev)) { $hooks.Remove($ev) }
    }
    if ($hooks.Count -eq 0) { $data.Remove("hooks") }
    New-Item -ItemType Directory -Force -Path $ClaudeDir | Out-Null
    $json = $data | ConvertTo-Json -Depth 32
    [System.IO.File]::WriteAllText($Settings, $json + "`n", (New-Object System.Text.UTF8Encoding $false))
}

if ($RemoveHooks) {
    Set-OmHooks $false
    if (Test-Path $HooksDir) { Remove-Item -Recurse -Force $HooksDir }
    Write-Host "Memoire automatique desactivee (hooks retires de $Settings, sauvegarde .bak faite)."
    exit 0
}

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

# Memoire automatique : hooks SessionStart / Stop / SessionEnd (muets hors d'un vault).
# Claude Code sous Windows execute les hooks avec Git Bash, d'ou les scripts .sh.
if (-not $NoHooks) {
    New-Item -ItemType Directory -Force -Path $HooksDir | Out-Null
    Copy-Item "$RepoDir\hooks\*.sh" $HooksDir -Force
    Set-OmHooks $true
    Write-Host "  [OK] memoire automatique activee (desactiver : .\install.ps1 -RemoveHooks)"
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
