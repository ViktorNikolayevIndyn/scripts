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

# Discover repository metadata
$meta = Get-RepoMetaList -cfg $cfg
$manifest = Load-Manifest -cfg $cfg

$idx=0
foreach ($it in $meta) {
  $idx++
  $slug=$it.Slug; $pkey=$it.ProjectKey; $pname=$it.ProjectName
  $backup = Join-Path $cfg.WorkDir ($slug + '.git')
  $owner  = Get-TargetOwner -cfg $cfg -ProjectKey $pkey
  $base   = Build-TargetRepoName -cfg $cfg -Workspace $cfg.BBWorkspace -ProjectKey $pkey -RepoSlug $slug
  $unique = Ensure-UniqueRepoName -cfg $cfg -Owner $owner -BaseName $base
  $vis    = $cfg.TargetVisibilityDefault
  $lang   = (Test-Path $backup) ? (Detect-PrimaryLanguage -BareRepoPath $backup) : 'unknown'
  $id     = $cfg.ManifestIdPrefix + (('{0:0000}' -f $idx))
  $row    = New-ManifestRow -cfg $cfg -Id $id -Ws $cfg.BBWorkspace -PKey $pkey -PName $pname -Slug $slug `
                             -Owner $owner -Repo $unique -Visibility $vis -Backup $backup -Lang $lang
  $manifest = Upsert-ManifestRow -cfg $cfg -manifest $manifest -Slug $slug -rowToMerge $row
}
Save-Manifest -cfg $cfg -rows $manifest

# Show first rows of manifest
Import-Csv -Path $cfg.ManifestPath -Delimiter ';' | Select-Object -First 5 | Format-Table
