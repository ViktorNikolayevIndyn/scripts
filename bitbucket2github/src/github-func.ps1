# GitHub: repo ensure, push, topics, teams, projects, LFS

function Ensure-GitHubRepo {
  param($cfg, [string]$Repo, [string]$ProjectKey, [string]$Owner, [string]$Visibility)
  if ($cfg.DownloadOnly) { return }
  if (-not $Owner) { $Owner = $cfg.GHOwer }
  if (-not $Visibility) { $Visibility = $cfg.TargetVisibilityDefault }

  $full = "$Owner/$Repo"
  if (Get-Command gh -ErrorAction SilentlyContinue) {
    if (-not (gh repo view $full 2>$null)) {
      Write-Log "Creating GitHub repo: $full ($Visibility)" 'INFO' $cfg.LogDir
      $visFlag = if ($Visibility -eq 'public') { '--public' } else { '--private' }
      gh repo create $full $visFlag --disable-issues=false --disable-wiki=false *> $null
    } else {
      Write-Log "GitHub repo exists: $full" 'INFO' $cfg.LogDir
    }
  } else {
    Write-Log "gh CLI not found. Create $full manually if needed." 'WARN' $cfg.LogDir
  }
}

function Push-Mirror {
  param($cfg, [string]$Repo, [string]$RepoGitPath, [string]$Owner)
  if ($cfg.DownloadOnly) { return }
  if (-not $Owner) { $Owner = $cfg.GHOwer }
  Push-Location $RepoGitPath
  $ghUrl = if ($cfg.GHAuthMode -eq 'SSH') {
    "git@github.com:$Owner/$Repo.git"
  } else {
    if (-not $cfg.GHToken) { throw "GitHub token required for HTTPS push." }
    "https://$($cfg.GHToken):x-oauth-basic@github.com/$Owner/$Repo.git"
  }
  if (git remote get-url github 2>$null) { git remote remove github | Out-Null }
  git remote add github $ghUrl
  Write-Log "Pushing mirror → ${Owner}/${Repo}" 'INFO' $cfg.LogDir
  git push --mirror --force github
  Pop-Location
}

function Push-LFS {
  param($cfg, [string]$Repo)
  if (-not $cfg.IncludeLFS) { return }
  if ($cfg.DownloadOnly) { return }
  $gh = if ($cfg.GHAuthMode -eq 'SSH') { "git@github.com:$($cfg.GHOwer)/$Repo.git" }
        else { if (-not $cfg.GHToken) { throw "GitHub token required for HTTPS." }; "https://$($cfg.GHToken):x-oauth-basic@github.com/$($cfg.GHOwer)/$Repo.git" }
  $tmp = Join-Path $cfg.WorkDir ("_lfs_" + $Repo)
  if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp }
  git clone $gh $tmp
  Push-Location $tmp
  git lfs install
  git lfs fetch --all
  git lfs push --all origin
  Pop-Location
  Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}

function Set-RepoTopics {
    param($cfg, [string]$Owner, [string]$Repo, [string[]]$Topics)
    if (-not $cfg.UseTopics -or -not $Topics -or $Topics.Count -eq 0) { return }
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { Write-Log "gh CLI not found; skip topics for ${Owner}/${Repo}" 'WARN' $cfg.LogDir; return }
    $cur = gh api -H "Accept: application/vnd.github+json" "/repos/$Owner/$Repo/topics" | ConvertFrom-Json
    $names = @(); if ($cur.names) { $names += $cur.names }
    foreach ($t in $Topics) { if ($names -notcontains $t) { $names += $t } }
    $body = @{ names = $names } | ConvertTo-Json -Compress
    gh api -X PUT -H "Accept: application/vnd.github+json" "/repos/$Owner/$Repo/topics" -f "data=$body" *> $null
    Write-Log "Set topics for ${Owner}/${Repo}: $($names -join ',')" 'INFO' $cfg.LogDir
}

function Ensure-GHTeam {
    param($cfg, [string]$TeamName)
    if (-not $cfg.CreateTeams) { return $null }
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { Write-Log "gh CLI not found; skip team create: $TeamName" 'WARN' $cfg.LogDir; return $null }
    $exists = gh api "/orgs/$($cfg.GHOwer)/teams/$TeamName" 2>$null
    if (-not $exists) { gh team create "$TeamName" --org "$($cfg.GHOwer)" --privacy closed *> $null; Write-Log "Created team: $TeamName" 'INFO' $cfg.LogDir }
    return $TeamName
}

function Add-RepoToTeam {
    param($cfg, [string]$TeamName, [string]$Repo, [string]$Permission)
    if (-not $cfg.CreateTeams -or -not $TeamName) { return }
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { Write-Log "gh CLI not found; skip team repo mapping $TeamName → ${Repo}" 'WARN' $cfg.LogDir; return }
    $perm = if ($Permission) { $Permission } else { $cfg.DefaultTeamPermission }
    gh api -X PUT "/orgs/$($cfg.GHOwer)/teams/$TeamName/repos/$($cfg.GHOwer)/$Repo" -f "permission=$perm" *> $null
    Write-Log "Team '$TeamName' grants '$perm' on $($cfg.GHOwer)/${Repo}" 'INFO' $cfg.LogDir
}

function Ensure-GHProject {
    param($cfg, [string]$Key, [string]$Name)
    if (-not $cfg.UseGHProjects) { return $null }
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { Write-Log "gh CLI not found; skip GH Project ensure" 'WARN' $cfg.LogDir; return $null }
    $owner = $cfg.GHProjectOwner
    $projectsJson = gh project list --owner "$owner" --format json | ConvertFrom-Json
    $title = $cfg.GHProjectTitleFormat.Replace('{KEY}', $Key).Replace('{NAME}', ($Name ?? $Key))
    $existing = $projectsJson | Where-Object { $_.title -eq $title } | Select-Object -First 1
    if ($existing) { Write-Log "GH Project exists: $title (#$($existing.number))" 'INFO' $cfg.LogDir; return $existing.number }
    if (-not $cfg.GHProjectCreateIfMissing) { Write-Log "GH Project missing and auto-create disabled: $title" 'WARN' $cfg.LogDir; return $null }
    $created = gh project create --owner "$owner" --title "$title" --format json | ConvertFrom-Json
    Write-Log "Created GH Project: $title (#$($created.number))" 'INFO' $cfg.LogDir
    return $created.number
}

function Add-Repo-As-ProjectItem {
    param($cfg, [string]$Owner, [string]$Repo, [int]$ProjectNumber)
    if (-not $cfg.GHProjectAddRepoItems -or -not $ProjectNumber) { return }
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { Write-Log "gh CLI not found; skip adding repo to project" 'WARN' $cfg.LogDir; return }
    $url = "https://github.com/$Owner/$Repo"
    gh project item-add --owner "$($cfg.GHProjectOwner)" --project-number $ProjectNumber --url "$url" *> $null
    Write-Log "Added repo to GH Project #${ProjectNumber}: ${Owner}/${Repo}" 'INFO' $cfg.LogDir
    if ($cfg.GHProjectStatusField -and $cfg.GHProjectStatusValue) {
        try {
            $items = gh project item-list --owner "$($cfg.GHProjectOwner)" --project-number $ProjectNumber --format json | ConvertFrom-Json
            $item = $items | Where-Object { $_.content.type -eq 'Repository' -and $_.content.repository -like "$Owner/$Repo" } | Select-Object -First 1
            if ($item) {
                gh project item-edit --owner "$($cfg.GHProjectOwner)" --project-number $ProjectNumber --id $item.id `
                    --field "$($cfg.GHProjectStatusField)" --value "$($cfg.GHProjectStatusValue)" *> $null
                Write-Log "Set Project field '$($cfg.GHProjectStatusField)'='$($cfg.GHProjectStatusValue)' for item $($item.id)" 'INFO' $cfg.LogDir
            }
        } catch {
            Write-Log "Can't set project field (maybe missing): $($_.Exception.Message)" 'WARN' $cfg.LogDir
        }
    }
}
