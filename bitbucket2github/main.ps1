#Requires -Version 7
$ErrorActionPreference = 'Stop'

$ConfigPath = 'C:\PROJECT\bb2gh\config\config.psd1'
$Functions  = 'C:\PROJECT\bb2gh\src\git-functions.ps1'

. $Functions
$cfg = Import-PowerShellDataFile -Path $ConfigPath

Ensure-Dirs -cfg $cfg

Write-Log "=== BB2GH START ===" 'INFO' $cfg.LogDir
Write-Log "Workspace: $($cfg.BBWorkspace) → GitHub Owner: $($cfg.GHOwer)" 'INFO' $cfg.LogDir

$repos = Get-RepoList -cfg $cfg
Write-Log "Found repositories: $($repos.Count)" 'INFO' $cfg.LogDir

foreach ($r in $repos) {
    try {
        Write-Log ">>> Repository: $r" 'INFO' $cfg.LogDir
        $mirror = Mirror-Clone -cfg $cfg -Repo $r
        if ($cfg.RewriteBotEmail) { Rewrite-BotEmails -cfg $cfg -RepoGitPath $mirror }
        Ensure-GitHubRepo -cfg $cfg -Repo $r
        Push-Mirror -cfg $cfg -Repo $r -RepoGitPath $mirror
        Write-Log "<<< OK: $r" 'INFO' $cfg.LogDir
    } catch {
        Write-Log "FAIL $r: $($_.Exception.Message)" 'ERROR' $cfg.LogDir
    }
}

Write-Log "=== BB2GH DONE ===" 'INFO' $cfg.LogDir
