#Requires -Version 7
Set-StrictMode -Version Latest

function Write-Log {
    param([string]$Message,[ValidateSet('INFO','WARN','ERROR')][string]$Level='INFO',[string]$LogDir)
    $ts = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    $line = "[$ts] [$Level] $Message"
    Write-Host $line
    if ($LogDir) {
        New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
        Add-Content -Path (Join-Path $LogDir "bb2gh.log") -Value $line
    }
}

function Ensure-Dirs {
    param($cfg)
    foreach ($p in @($cfg.WorkDir,$cfg.LogDir,$cfg.ConfigDir)) {
        New-Item -ItemType Directory -Path $p -Force | Out-Null
    }
}

# ------------------------ Bitbucket REST Auth + Calls ------------------------

function Get-BBHeaders {
    param($cfg)
    $token = $cfg.BBAppPassword; if (-not $token) { $token = $env:BITBUCKET_APP_PASSWORD }
    if (-not $cfg.BBUser)  { throw "BBUser (email) is empty." }
    if (-not $token)       { throw "API token (BBAppPassword or env BITBUCKET_APP_PASSWORD) is empty." }
    $pair = $cfg.BBUser + ":" + $token
    $auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($pair))
    return @{ Authorization = "Basic $auth"; "User-Agent" = "bb2gh-script"; Accept = "application/json" }
}

function Invoke-BB {
    param($cfg, [string]$Url, [int]$MaxRetry = 4)
    $hdr   = Get-BBHeaders -cfg $cfg
    $delay = 1
    for ($i=1; $i -le $MaxRetry; $i++) {
        try { return Invoke-RestMethod -Method GET -Uri $Url -Headers $hdr }
        catch {
            $code = $_.Exception.Response.StatusCode.value__ 2>$null
            if ($i -lt $MaxRetry -and ($code -eq 429 -or $code -ge 500)) {
                Start-Sleep -Seconds $delay; $delay = [Math]::Min($delay * 2, 30); continue
            }
            $body = ""
            if ($_.Exception.Response) { try { $sr = New-Object IO.StreamReader($_.Exception.Response.GetResponseStream()); $body = $sr.ReadToEnd() } catch {} }
            throw "Bitbucket API error on $Url (HTTP $code). Body: $body"
        }
    }
}

# ------------------------ Repo Discovery ------------------------

# Returns array of repo slugs (strings)
function Get-RepoList {
    param($cfg)

    if ($cfg.UseRepoListFile -and (Test-Path $cfg.RepoListFile)) {
        return (Get-Content $cfg.RepoListFile | Where-Object {
            $_ -and $_.Trim() -ne '' -and -not $_.StartsWith('#')
        }).ForEach({ $_.Trim() })
    }

    $slug = ([string]$cfg.BBWorkspace).Trim()
    if (-not $slug) { throw "BBWorkspace is empty." }

    $all = @()
    $repoUrl = "https://api.bitbucket.org/2.0/repositories/{0}?pagelen=100" -f $slug
    do {
        $resp = Invoke-BB -cfg $cfg -Url $repoUrl
        if ($resp -and ($resp.PSObject.Properties.Name -contains 'values')) { $all += $resp.values }
        $repoUrl = ($resp -and ($resp.PSObject.Properties.Name -contains 'next')) ? $resp.next : $null
    } while ($repoUrl)

    return ($all | ForEach-Object { $_.slug } | Where-Object { $_ } | Sort-Object -Unique)
}

# Returns array of PSCustomObject: @{ Slug; ProjectKey; ProjectName }
function Get-RepoMetaList {
    param($cfg)

    $slug = ([string]$cfg.BBWorkspace).Trim()
    if (-not $slug) { throw "BBWorkspace is empty." }

    $all = @()
    $repoUrl = "https://api.bitbucket.org/2.0/repositories/{0}?pagelen=100" -f $slug
    do {
        $resp = Invoke-BB -cfg $cfg -Url $repoUrl
        if ($resp -and ($resp.PSObject.Properties.Name -contains 'values')) {
            foreach ($v in $resp.values) {
                $pkey  = $null; $pname = $null
                if ($v.PSObject.Properties.Name -contains 'project' -and $v.project) {
                    if ($v.project.PSObject.Properties.Name -contains 'key')  { $pkey = $v.project.key }
                    if ($v.project.PSObject.Properties.Name -contains 'name') { $pname = $v.project.name }
                }
                $all += [PSCustomObject]@{
                    Slug        = $v.slug
                    ProjectKey  = $pkey
                    ProjectName = $pname
                }
            }
        }
        $repoUrl = ($resp -and ($resp.PSObject.Properties.Name -contains 'next')) ? $resp.next : $null
    } while ($repoUrl)

    return ($all | Group-Object Slug | ForEach-Object { $_.Group[0] } | Sort-Object Slug)
}

# ------------------------ Naming / Owner selection ------------------------

function Get-TargetOwner {
    param($cfg, [string]$ProjectKey)
    if ($cfg.OwnerPerProjectMap -and $cfg.OwnerPerProjectMap.ContainsKey($ProjectKey)) { return $cfg.OwnerPerProjectMap[$ProjectKey] }
    return $cfg.GHOwer
}

function Build-TargetRepoName {
    param($cfg, [string]$Workspace, [string]$ProjectKey, [string]$RepoSlug)
    $name = $cfg.TargetNameTemplate
    $name = $name.Replace('{WORKSPACE}', $Workspace).Replace('{PROJECT}', ($ProjectKey ?? '')).Replace('{REPO}', $RepoSlug)
    foreach ($k in $cfg.TargetNameReplaceMap.Keys) { $name = $name.Replace($k, $cfg.TargetNameReplaceMap[$k]) }
    if ($cfg.TargetNameLowercase) { $name = $name.ToLowerInvariant() }
    $name = ($name -replace '[^a-z0-9\.\-_]', '-') -replace '-{2,}', '-'
    $name = $name.Trim('.-')
    if (-not $name) { throw "Target repo name resolved to empty." }
    return $name
}

function Ensure-UniqueRepoName {
    param($cfg, [string]$Owner, [string]$BaseName)
    $tryName = $BaseName
    $n = 0
    while ($true) {
        if (Get-Command gh -ErrorAction SilentlyContinue) {
            $exists = gh repo view "$Owner/$tryName" 2>$null
            if (-not $exists) { return $tryName }
        } else {
            return $tryName
        }
        $n++
        $suffix = $cfg.TargetNameCollisionSuffix.Replace('{N}', "$n")
        $tryName = "$BaseName$suffix"
    }
}

# ------------------------ Language detection (heuristic) ------------------------

function Detect-PrimaryLanguage {
    param([string]$BareRepoPath)
    $tmp = Join-Path ([IO.Path]::GetTempPath()) ("bb2gh_detect_" + [IO.Path]::GetFileNameWithoutExtension($BareRepoPath))
    if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp }
    git clone --depth 1 $BareRepoPath $tmp *> $null

    $exts = @{}
    Get-ChildItem -Path $tmp -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
        $e = $_.Extension.ToLowerInvariant()
        if (-not $e) { return }
        if (-not $exts.ContainsKey($e)) { $exts[$e] = 0 }
        $exts[$e]++
    }

    # stronger signals
    if (Test-Path (Join-Path $tmp 'composer.json')) { Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue; return 'php' }
    if (Test-Path (Join-Path $tmp 'package.json'))  { Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue; return 'javascript' }
    if (Test-Path (Join-Path $tmp 'requirements.txt')) { Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue; return 'python' }

    Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue

    if ($exts.Count -eq 0) { return 'unknown' }
    $score = @{
        '.php'='php'; '.js'='javascript'; '.jsx'='javascript'; '.ts'='typescript'; '.tsx'='typescript';
        '.py'='python'; '.rb'='ruby'; '.go'='go'; '.java'='java'; '.cs'='csharp';
        '.scala'='scala'; '.kt'='kotlin'; '.swift'='swift'; '.rs'='rust';
    }
    $langCount = @{}
    foreach ($kv in $exts.GetEnumerator()) {
        $lang = $score[$kv.Key]
        if ($lang) { if (-not $langCount.ContainsKey($lang)) { $langCount[$lang] = 0 }; $langCount[$lang] += $kv.Value }
    }
    if ($langCount.Count -eq 0) { return 'unknown' }
    return ($langCount.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 1).Key
}

# ------------------------ Manifest helpers ------------------------

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

# ------------------------ Git clone / push ------------------------

function Mirror-Clone {
    param($cfg, [string]$Repo)
    $dst = Join-Path $cfg.WorkDir ($Repo + '.git')

    $token = $cfg.BBAppPassword; if (-not $token) { $token = $env:BITBUCKET_APP_PASSWORD }

    $src = if ($cfg.BBAuthMode -eq 'HTTPS') {
        if (-not $cfg.BBGitUser) { throw "BBGitUser (Bitbucket username) is required for HTTPS clone." }
        if (-not $token)         { throw "API token is required for HTTPS clone (BBAppPassword or env var)." }
        "https://$($cfg.BBGitUser):$([Uri]::EscapeDataString($token))@bitbucket.org/$($cfg.BBWorkspace)/$Repo.git"
    } else {
        "git@bitbucket.org:$($cfg.BBWorkspace)/$Repo.git"
    }

    if (Test-Path $dst) {
        Write-Log "Mirror exists → fetching updates: $dst" 'INFO' $cfg.LogDir
        Push-Location $dst
        git fetch --all --prune
        Pop-Location
        return $dst
    }

    $displaySrc = $src -replace ":(?<tok>[^@]+)@", ":***@"
    Write-Log "Cloning mirror: $displaySrc → $dst" 'INFO' $cfg.LogDir
    git clone --mirror $src $dst
    return $dst
}

function Rewrite-BotEmails {
    param($cfg, [string]$RepoGitPath)
    if (-not $cfg.RewriteBotEmail) { return }
    Write-Log "Rewriting @bots.bitbucket.org emails → $($cfg.NewEmail) in $RepoGitPath" 'INFO' $cfg.LogDir
    Push-Location $RepoGitPath
    $script = @"
if echo "`$GIT_AUTHOR_EMAIL" | grep -q "@bots.bitbucket.org"; then
  GIT_AUTHOR_EMAIL="$($cfg.NewEmail)"
fi
if echo "`$GIT_COMMITTER_EMAIL" | grep -q "@bots.bitbucket.org"; then
  GIT_COMMITTER_EMAIL="$($cfg.NewEmail)"
fi
"@
    git filter-branch --env-filter $script --tag-name-filter cat -- --all
    Pop-Location
}

function Mirror-Wiki {
    param($cfg, [string]$Repo)
    if (-not $cfg.IncludeWiki) { return }

    $token = $cfg.BBAppPassword; if (-not $token) { $token = $env:BITBUCKET_APP_PASSWORD }
    $bbWiki = if ($cfg.BBAuthMode -eq 'HTTPS') {
        if (-not $cfg.BBGitUser) { throw "BBGitUser required for HTTPS wiki clone." }
        if (-not $token)         { throw "API token required for HTTPS wiki clone." }
        "https://$($cfg.BBGitUser):$([Uri]::EscapeDataString($token))@bitbucket.org/$($cfg.BBWorkspace)/$Repo.wiki.git"
    } else {
        "git@bitbucket.org:$($cfg.BBWorkspace)/$Repo.wiki.git"
    }

    try { git ls-remote $bbWiki *> $null } catch { Write-Log "No wiki for: $Repo" 'INFO' $cfg.LogDir; return }

    $dst = Join-Path $cfg.WorkDir ($Repo + '.wiki.git')
    if (-not (Test-Path $dst)) {
        $display = $bbWiki -replace ":(?<tok>[^@]+)@", ":***@"
        Write-Log "Cloning wiki mirror: $display → $dst" 'INFO' $cfg.LogDir
        git clone --mirror $bbWiki $dst
    } else {
        Push-Location $dst
        git fetch --all --prune
        Pop-Location
    }

    if ($cfg.RewriteBotEmail) { Rewrite-BotEmails -cfg $cfg -RepoGitPath $dst }
}

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
  Write-Log "Pushing mirror → $Owner/$Repo" 'INFO' $cfg.LogDir
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

# ------------------------ GitHub Topics / Teams / Projects ------------------------

function Set-RepoTopics {
    param($cfg, [string]$Owner, [string]$Repo, [string[]]$Topics)
    if (-not $cfg.UseTopics -or -not $Topics -or $Topics.Count -eq 0) { return }
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { Write-Log "gh CLI not found; skip topics for $Owner/$Repo" 'WARN' $cfg.LogDir; return }
    $cur = gh api -H "Accept: application/vnd.github+json" "/repos/$Owner/$Repo/topics" | ConvertFrom-Json
    $names = @(); if ($cur.names) { $names += $cur.names }
    foreach ($t in $Topics) { if ($names -notcontains $t) { $names += $t } }
    $body = @{ names = $names } | ConvertTo-Json -Compress
    gh api -X PUT -H "Accept: application/vnd.github+json" "/repos/$Owner/$Repo/topics" -f "data=$body" *> $null
    Write-Log "Set topics for $Owner/$Repo: $($names -join ',')" 'INFO' $cfg.LogDir
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
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { Write-Log "gh CLI not found; skip team repo mapping $TeamName → $Repo" 'WARN' $cfg.LogDir; return }
    $perm = if ($Permission) { $Permission } else { $cfg.DefaultTeamPermission }
    gh api -X PUT "/orgs/$($cfg.GHOwer)/teams/$TeamName/repos/$($cfg.GHOwer)/$Repo" -f "permission=$perm" *> $null
    Write-Log "Team '$TeamName' granted '$perm' on $($cfg.GHOwer)/$Repo" 'INFO' $cfg.LogDir
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
    Write-Log "Added repo to GH Project #$ProjectNumber: $Owner/$Repo" 'INFO' $cfg.LogDir
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
