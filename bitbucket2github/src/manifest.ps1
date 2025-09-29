# Manifest: CSV load/save + row builders

function Load-Manifest {
  param($cfg)
  if (Test-Path $cfg.ManifestPath) { return Import-Csv -Path $cfg.ManifestPath -Delimiter ';' }
  return @()
}
function Save-Manifest {
  param($cfg, $rows)
  $dir = Split-Path $cfg.ManifestPath -Parent
  New-Item -ItemType Directory -Path $dir -Force | Out-Null
  $rows | Export-Csv -Path $cfg.ManifestPath -Delimiter ';' -NoTypeInformation -Encoding UTF8
}
function New-ManifestRow {
  param($cfg, [string]$Id,[string]$Ws,[string]$PKey,[string]$PName,[string]$Slug,[string]$Owner,[string]$Repo,[string]$Visibility,[string]$Backup,[string]$Lang)
  [PSCustomObject]@{
    id                = $Id
    bb_workspace      = $Ws
    bb_project_key    = $PKey
    bb_project_name   = $PName
    bb_repo_slug      = $Slug
    target_owner      = $Owner
    target_repo       = $Repo
    target_visibility = $Visibility
    backup_path       = $Backup
    language          = $Lang
    to_export         = 'true'
    export_status     = 'new'
    export_git        = 'github'
    target_url        = ''
  }
}
function Upsert-ManifestRow {
  param($cfg, $manifest, [string]$Slug, $rowToMerge)
  $found = $manifest | Where-Object { $_.bb_repo_slug -eq $Slug } | Select-Object -First 1
  if ($found) {
    foreach ($p in $rowToMerge.PSObject.Properties) {
      if ($p.Value -and ($p.Name -ne 'id')) { $found.$($p.Name) = $p.Value }
    }
    return ,$manifest
  } else {
    return ,@($manifest + $rowToMerge)
  }
}
function Set-ManifestStatus {
  param($manifest,[string]$Slug,[string]$Status,[string]$TargetUrl='')
  $found = $manifest | Where-Object { $_.bb_repo_slug -eq $Slug } | Select-Object -First 1
  if ($found) {
    $found.export_status = $Status
    if ($TargetUrl) { $found.target_url = $TargetUrl }
  }
  return ,$manifest
}
