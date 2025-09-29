#Requires -Version 7
$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $PSCommandPath
$ConfigPath = Join-Path $scriptRoot 'config\config.psd1'
. (Join-Path $scriptRoot 'src\load.ps1')

$cfg = Import-PowerShellDataFile -Path $ConfigPath
$cfg = Normalize-CfgPaths -cfg $cfg

Ensure-Dirs -cfg $cfg
Write-Log "=== BB2GH RUN ===" 'INFO' $cfg.LogDir
Write-Log ("Workspace={0}; DownloadOnly={1}" -f $cfg.BBWorkspace,$cfg.DownloadOnly) 'INFO' $cfg.LogDir

# Phase 1: prepare manifest
$meta = Get-RepoMetaList -cfg $cfg
$manifest = Load-Manifest -cfg $cfg

$idx=0; $total=$meta.Count
foreach ($it in $meta) {
  $idx++
  $slug  = $it.Slug
  $pkey  = $it.ProjectKey
  $pname = $it.ProjectName
  Write-Log ("[PREP {0}/{1}] {2} (proj={3})" -f $idx,$total,$slug,($pkey ?? '')) 'INFO' $cfg.LogDir

  $backup = Join-Path $cfg.WorkDir ($slug + '.git')
  $owner  = Get-TargetOwner -cfg $cfg -ProjectKey $pkey
  $base   = Build-TargetRepoName -cfg $cfg -Workspace $cfg.BBWorkspace -ProjectKey $pkey -RepoSlug $slug
  $unique = Ensure-UniqueRepoName -cfg $cfg -Owner $owner -BaseName $base
  $vis    = $cfg.TargetVisibilityDefault

  $lang = if (Test-Path $backup) { Detect-PrimaryLanguage -BareRepoPath $backup } else { 'unknown' }

  $id = $cfg.ManifestIdPrefix + (('{0:0000}' -f $idx))
  $row = New-ManifestRow -cfg $cfg -Id $id -Ws $cfg.BBWorkspace -PKey $pkey -PName $pname -Slug $slug `
                         -Owner $owner -Repo $unique -Visibility $vis -Backup $backup -Lang $lang
  $manifest = Upsert-ManifestRow -cfg $cfg -manifest $manifest -Slug $slug -rowToMerge $row
}
Save-Manifest -cfg $cfg -rows $manifest
Write-Log "Manifest prepared/updated: $($cfg.ManifestPath)" 'INFO' $cfg.LogDir

# Phase 2: execute by CSV
$manifest = Load-Manifest -cfg $cfg
$rows = $manifest | Where-Object { $_.to_export -match '^(true|1|yes)$' }
$idx=0; $total=$rows.Count

foreach ($row in $rows) {
  $idx++
  $slug  = $row.bb_repo_slug
  $owner = $row.target_owner
  $repo  = $row.target_repo
  $vis   = if ($row.target_visibility) { $row.target_visibility } else { $cfg.TargetVisibilityDefault }

  Write-Log ("[RUN {0}/{1}] {2} → {3}/{4}" -f $idx,$total,$slug,$owner,$repo) 'INFO' $cfg.LogDir
  try {
    $mirror = Mirror-Clone -cfg $cfg -Repo $slug
    Rewrite-BotEmails -cfg $cfg -RepoGitPath $mirror
    Mirror-Wiki -cfg $cfg -Repo $slug

    if (-not $cfg.DownloadOnly) {
      Ensure-GitHubRepo -cfg $cfg -Repo $repo -ProjectKey $row.bb_project_key -Owner $owner -Visibility $vis
      Push-Mirror      -cfg $cfg -Repo $repo -RepoGitPath $mirror -Owner $owner
      Push-LFS         -cfg $cfg -Repo $repo

      $topics = @()
      if ($cfg.UseTopics -and $row.bb_project_key) {
        $topics += "$($cfg.ProjectTopicPrefix):$($row.bb_project_key)"
        $topics += "bb-project:$($row.bb_project_key)"
        if ($row.language -and $row.language -ne 'unknown') { $topics += "lang:$($row.language)" }
      }
      if ($topics.Count -gt 0) { Set-RepoTopics -cfg $cfg -Owner $owner -Repo $repo -Topics $topics }

      if ($cfg.CreateTeams -and $row.bb_project_key) {
        $team = Ensure-GHTeam -cfg $cfg -TeamName $row.bb_project_key
        Add-RepoToTeam -cfg $cfg -TeamName $team -Repo $repo -Permission $cfg.DefaultTeamPermission
      }
      if ($cfg.UseGHProjects -and $row.bb_project_key) {
        $pnum = Ensure-GHProject -cfg $cfg -Key $row.bb_project_key -Name $row.bb_project_name
        if ($pnum) { Add-Repo-As-ProjectItem -cfg $cfg -Owner $owner -Repo $repo -ProjectNumber $pnum }
      }

      $targetUrl = "git@github.com:$owner/$repo.git"
      $manifest = Set-ManifestStatus -manifest $manifest -Slug $slug -Status 'done' -TargetUrl $targetUrl
      Save-Manifest -cfg $cfg -rows $manifest
    } else {
      $manifest = Set-ManifestStatus -manifest $manifest -Slug $slug -Status 'done'
      Save-Manifest -cfg $cfg -rows $manifest
    }

    Write-Log ("OK: {0}" -f $slug) 'INFO' $cfg.LogDir
  }
  catch {
    $manifest = Set-ManifestStatus -manifest $manifest -Slug $slug -Status 'failed'
    Save-Manifest -cfg $cfg -rows $manifest
    Write-Log ("FAIL {0}: {1}" -f $slug, $_.Exception.Message) 'ERROR' $cfg.LogDir
  }
}

Write-Log "=== BB2GH DONE ===" 'INFO' $cfg.LogDir
