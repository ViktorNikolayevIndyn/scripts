#Requires -Version 7
$ErrorActionPreference = 'Stop'

# Resolve project root (go one level up from tests)
$projRoot = Split-Path -Parent $PSCommandPath
$projRoot = Split-Path -Parent $projRoot

# Load all modules
. (Join-Path $projRoot 'src\load.ps1')

# Import config
$cfg = Import-PowerShellDataFile -Path (Join-Path $projRoot 'config\config.psd1')
$cfg = Normalize-CfgPaths -cfg $cfg
Ensure-Dirs -cfg $cfg

# Ensure authentication is available
if (-not $env:BITBUCKET_APP_PASSWORD -and -not $cfg.BBAppPassword) {
  throw "Set BITBUCKET_APP_PASSWORD environment variable or BBAppPassword in config."
}

# Discover repositories
$repos = Get-RepoList -cfg $cfg
Write-Host ("Total repositories: {0}" -f $repos.Count)
$repos | Select-Object -First 10 | ForEach-Object { Write-Host $_ }
