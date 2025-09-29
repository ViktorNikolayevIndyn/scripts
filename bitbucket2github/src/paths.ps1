# Path utilities: keep everything relative to project root.
$Global:BB2GH_Root = Split-Path -Parent $PSScriptRoot

function Resolve-Rel {
  param([Parameter(Mandatory)][string]$Path)
  if ([IO.Path]::IsPathRooted($Path)) { return $Path }
  return (Join-Path $Global:BB2GH_Root $Path)
}

function Normalize-CfgPaths {
  param($cfg)
  $cfg.WorkDir      = Resolve-Rel $cfg.WorkDir
  $cfg.LogDir       = Resolve-Rel $cfg.LogDir
  $cfg.ConfigDir    = Resolve-Rel $cfg.ConfigDir
  $cfg.ManifestPath = Resolve-Rel $cfg.ManifestPath
  $cfg.RepoListFile = Resolve-Rel $cfg.RepoListFile
  return $cfg
}
