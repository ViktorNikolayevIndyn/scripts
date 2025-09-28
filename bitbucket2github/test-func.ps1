#Requires -Version 7
$ErrorActionPreference = 'Stop'

# Resolve paths relative to this script
$scriptRoot = Split-Path -Parent $PSCommandPath
$ConfigPath = Join-Path $scriptRoot 'config\config.psd1'
$Functions  = Join-Path $scriptRoot 'src\git-functions.ps1'

# Load functions and config
. $Functions
$cfg = Import-PowerShellDataFile -Path $ConfigPath

# Ensure directories (logs/work)
Ensure-Dirs -cfg $cfg

Write-Log "=== TEST: using git-functions + config ===" 'INFO' $cfg.LogDir
Write-Log ("Config: Workspace={0}, UseRepoListFile={1}, DownloadOnly={2}" -f $cfg.BBWorkspace, $cfg.UseRepoListFile, $cfg.DownloadOnly) 'INFO' $cfg.LogDir

# 1) List repositories via our Get-RepoList()
$repos = Get-RepoList -cfg $cfg
Write-Host ("Total repositories: {0}" -f $repos.Count)
$repos | ForEach-Object { Write-Host $_ }

# 2) Optional connectivity check to Bitbucket SSH for the first repo (no clone)
#    Safe probe: git ls-remote over SSH if BBAuthMode=SSH
if ($repos.Count -gt 0 -and ($cfg.BBAuthMode -eq 'SSH')) {
    $first = $repos[0]
    $sshUrl = "git@bitbucket.org:$($cfg.BBWorkspace)/$first.git"
    Write-Host "`nProbing SSH access to: $sshUrl"
    try {
        git ls-remote $sshUrl | Out-Null
        Write-Host "OK: SSH access works for $first"
    } catch {
        Write-Host "WARN: SSH probe failed for $first. Check your SSH key for bitbucket.org"
    }
}

Write-Log "=== TEST DONE ===" 'INFO' $cfg.LogDir
