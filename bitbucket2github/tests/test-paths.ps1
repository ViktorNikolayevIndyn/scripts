#Requires -Version 7
$ErrorActionPreference = 'Stop'

# Resolve project root (go one level up from tests)
$projRoot = Split-Path -Parent $PSCommandPath   # ...\tests
$projRoot = Split-Path -Parent $projRoot        # ...\bitbucket2github

# Load all modules
. (Join-Path $projRoot 'src\load.ps1')

# Import config
$cfg = Import-PowerShellDataFile -Path (Join-Path $projRoot 'config\config.psd1')
$cfg = Normalize-CfgPaths -cfg $cfg
Ensure-Dirs -cfg $cfg

# Verify required paths exist
@($cfg.WorkDir,$cfg.LogDir,$cfg.ConfigDir,$cfg.ManifestPath) | ForEach-Object {
  if (-not (Test-Path $_)) { throw "Path not created: $_" }
}
Write-Host "OK: relative paths resolved and created."
