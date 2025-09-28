#Requires -Version 7
$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $PSCommandPath
$ConfigPath = Join-Path $scriptRoot '..\config\config.psd1'
$Functions  = Join-Path $scriptRoot '..\src\git-functions.ps1'

. $Functions
$cfg = Import-PowerShellDataFile -Path $ConfigPath
Ensure-Dirs -cfg $cfg

Write-Log "=== TEST: using git-functions + config ===" 'INFO' $cfg.LogDir
Write-Log ("Config: Workspace={0}, UseRepoListFile={1}, DownloadOnly={2}" -f $cfg.BBWorkspace, $cfg.UseRepoListFile, $cfg.DownloadOnly) 'INFO' $cfg.LogDir

$repos = Get-RepoList -cfg $cfg
Write-Host ("Total repositories: {0}" -f $repos.Count)
$repos | ForEach-Object { Write-Host $_ }

if ($repos.Count -gt 0 -and ($cfg.BBAuthMode -eq 'HTTPS')) {
    $first = $repos[0]
    $token = $cfg.BBAppPassword; if (-not $token) { $token = $env:BITBUCKET_APP_PASSWORD }
    $probeUrl = "https://$($cfg.BBGitUser):$([Uri]::EscapeDataString($token))@bitbucket.org/$($cfg.BBWorkspace)/$first.git"
    Write-Host "`nProbing HTTPS access to: https://$($cfg.BBGitUser):***@bitbucket.org/$($cfg.BBWorkspace)/$first.git"
    & git ls-remote $probeUrl *> $null
    if ($LASTEXITCODE -eq 0) { Write-Host "OK: HTTPS access works for $first" }
    else { Write-Host "FAIL: HTTPS access failed for $first" -ForegroundColor Yellow }
}

Write-Log "=== TEST DONE ===" 'INFO' $cfg.LogDir
