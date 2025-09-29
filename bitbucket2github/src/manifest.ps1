# Manifest: CSV load/save + row builders

function Load-Manifest {
  param($cfg)
  if (Test-Path $cfg.ManifestPath) {
    $data = Import-Csv -Path $cfg.ManifestPath -Delimiter ';'
    return @($data)  # always return an array
  }
  return @()
}

function Save-Manifest {
  param($cfg, $rows)
  $dir = Split-Path $cfg.ManifestPath -Parent
  New-Item -ItemType Directory -Path $dir -Force | Out-Null

  # Ensure $rows is enumerable (Export-Csv expects a collection)
  $toWrite = @($rows)
  $toWrite | Export-Csv -Path $cfg.ManifestPath -Delimiter ';' -NoTypeInformation -Encoding UTF8
}

function New-ManifestRow {
  param(
    $cfg,
    [string]$Id,
    [string]$Ws,
    [string]$PKey,
    [string]$PName,
    [string]$Slug,
    [string]$Owner,
    [string]$Repo,
    [string]$Visibility,
    [string]$Backup,
    [string]$Lang
  )
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

  # Normalize to array
  $list = @($manifest)

  # Try find existing row by slug
  $found = $list | Where-Object { $_.bb_repo_slug -eq $Slug } | Select-Object -First 1

  if ($found) {
    foreach ($p in $rowToMerge.PSObject.Properties) {
      if ($p.Name -ne 'id' -and $null -ne $p.Value -and "$($p.Value)".Length -gt 0) {
        $found.$($p.Name) = $p.Value
      }
    }
  } else {
    $list += $rowToMerge
  }

  return ,$list
}

function Set-ManifestStatus {
  param($manifest,[string]$Slug,[string]$Status,[string]$TargetUrl='')

  $list = @($manifest)
  $found = $list | Where-Object { $_.bb_repo_slug -eq $Slug } | Select-Object -First 1
  if ($found) {
    $found.export_status = $Status
    if ($TargetUrl) { $found.target_url = $TargetUrl }
  }
  return ,$list
}
