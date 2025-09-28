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
    foreach ($p in @($cfg.WorkDir,$cfg.LogDir)) {
        New-Item -ItemType Directory -Path $p -Force | Out-Null
    }
}

function Get-RepoList {
    param($cfg)

    # Case 1: use static list from repos.txt
    if ($cfg.UseRepoListFile -and (Test-Path $cfg.RepoListFile)) {
        return (Get-Content $cfg.RepoListFile | Where-Object {
            $_ -and $_.Trim() -ne '' -and -not $_.StartsWith('#')
        }).ForEach({ $_.Trim() })
    }

    # Case 2: discover via Bitbucket API (Atlassian API token: email + token)
    # BBUser    = Atlassian email
    # BBAppPassword = API token (or read from env var if empty)
    if (-not $cfg.BBUser)        { throw "BBUser (email) is empty. Set your Atlassian email in config." }
    if (-not $cfg.BBAppPassword) { $cfg.BBAppPassword = $env:BITBUCKET_APP_PASSWORD }
    if (-not $cfg.BBAppPassword) { throw "BBAppPassword (API token) is empty. Put it in config or set BITBUCKET_APP_PASSWORD." }

    $pair = $cfg.BBUser + ":" + $cfg.BBAppPassword
    $auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($pair))
    $hdr  = @{ Authorization = "Basic $auth"; "User-Agent" = "bb2gh-script"; Accept = "application/json" }

    function Invoke-BB([string]$Url) {
        try { return Invoke-RestMethod -Method GET -Uri $Url -Headers $hdr }
        catch {
            $body = ""
            if ($_.Exception.Response) {
                try { $sr = New-Object IO.StreamReader($_.Exception.Response.GetResponseStream()); $body = $sr.ReadToEnd() } catch {}
            }
            throw "Bitbucket API error on $Url. Body: $body"
        }
    }

    # Validate token
    $null = Invoke-BB "https://api.bitbucket.org/2.0/user"

    # Workspace slug
    if (-not $cfg.BBWorkspace) {
        $ws = Invoke-BB "https://api.bitbucket.org/2.0/workspaces?pagelen=100"
        $cfg.BBWorkspace = ($ws.values | Select-Object -Expand slug | Select-Object -First 1)
        if (-not $cfg.BBWorkspace) { throw "No accessible workspace slugs found for $($cfg.BBUser)." }
        Write-Log "Auto-detected workspace: $($cfg.BBWorkspace)" 'INFO' $cfg.LogDir
    }

    $slug = ([string]$cfg.BBWorkspace).Trim()
    if (-not $slug) { throw "BBWorkspace is empty after trim." }

   # Pagination over all repos (robust to missing 'next')
$all = @()
$repoUrl = "https://api.bitbucket.org/2.0/repositories/{0}?pagelen=100" -f $slug
do {
    $resp = Invoke-BB $repoUrl

    # normalize $resp to object with .values
    if ($null -ne $resp) {
        if ($resp.PSObject.Properties.Name -contains 'values') {
            if ($resp.values) { $all += $resp.values }
        } else {
            # Unexpected shape (array/string) — try to coerce or skip with warning
            Write-Log "Bitbucket API returned unexpected shape at $repoUrl" 'WARN' $cfg.LogDir
        }
    }

    # safe-read 'next' (might be absent on last page)
    if ($resp -and ($resp.PSObject.Properties.Name -contains 'next')) {
        $repoUrl = $resp.next
    } else {
        $repoUrl = $null
    }
} while ($repoUrl)

# Return slugs unique and sorted
return ($all | ForEach-Object { $_.slug } | Where-Object { $_ } | Sort-Object -Unique)

}


function Mirror-Clone {
    param($cfg, [string]$Repo)
    $dst = Join-Path $cfg.WorkDir ($Repo + '.git')

    if (Test-Path $dst) {
        Write-Log "Mirror exists: $dst → fetching updates" 'INFO' $cfg.LogDir
        Push-Location $dst
        git fetch --all --prune
        Pop-Location
        return $dst
    }

    $src = if ($cfg.BBAuthMode -eq 'SSH') {
        "git@bitbucket.org:$($cfg.BBWorkspace)/$Repo.git"
    } else {
        "https://$($cfg.BBUser):$([Uri]::EscapeDataString($cfg.BBAppPassword))@bitbucket.org/$($cfg.BBWorkspace)/$Repo.git"
    }

    Write-Log "Cloning mirror: $src → $dst" 'INFO' $cfg.LogDir
    git clone --mirror $src $dst
    return $dst
}

function Rewrite-BotEmails {
    param($cfg, [string]$RepoGitPath)
    if (-not $cfg.RewriteBotEmail) { return }
    Write-Log "Rewriting bot emails to $($cfg.NewEmail) in $RepoGitPath" 'INFO' $cfg.LogDir

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

function Ensure-GitHubRepo {
    param($cfg, [string]$Repo)
    if ($cfg.DownloadOnly) { return } # Skip creation in download-only mode

    $full = "$($cfg.GHOwer)/$Repo"
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        if (-not (gh repo view $full 2>$null)) {
            Write-Log "Creating GitHub repo: $full ($($cfg.Visibility))" 'INFO' $cfg.LogDir
            gh repo create $full --$($cfg.Visibility) --disable-issues=false --disable-wiki=false
        } else {
            Write-Log "GitHub repo already exists: $full" 'INFO' $cfg.LogDir
        }
    } else {
        Write-Log "gh CLI not found. Create $full in GitHub (empty) if needed." 'WARN' $cfg.LogDir
    }
}

function Push-Mirror {
    param($cfg, [string]$Repo, [string]$RepoGitPath)
    if ($cfg.DownloadOnly) { return }    # Skip push in download-only mode

    Push-Location $RepoGitPath
    $ghUrl = if ($cfg.GHAuthMode -eq 'SSH') {
        "git@github.com:$($cfg.GHOwer)/$Repo.git"
    } else {
        if (-not $cfg.GHToken) { throw "GitHub token required for HTTPS push." }
        "https://$($cfg.GHToken):x-oauth-basic@github.com/$($cfg.GHOwer)/$Repo.git"
    }

    if ($cfg.DryRun) {
        Write-Log "DRY-RUN: skipping mirror push → $ghUrl" 'WARN' $cfg.LogDir
        Pop-Location; return
    }

    if (git remote get-url github 2>$null) { git remote remove github | Out-Null }
    git remote add github $ghUrl
    Write-Log "Pushing mirror to GitHub: $Repo" 'INFO' $cfg.LogDir
    git push --mirror --force github
    Pop-Location
}

function Mirror-Wiki {
    param($cfg, [string]$Repo)
    if (-not $cfg.IncludeWiki) { return }
    if ($cfg.DownloadOnly) { 
        # In download-only mode we still pull wiki mirrors so you have a full local backup
        # (no GitHub push will be performed)
    }

    $bbWiki = if ($cfg.BBAuthMode -eq 'SSH') {
        "git@bitbucket.org:$($cfg.BBWorkspace)/$Repo.wiki.git"
    } else {
        if (-not $cfg.BBUser -or -not $cfg.BBAppPassword) { throw "BBUser/BBAppPassword required for wiki over HTTPS." }
        "https://$($cfg.BBUser):$([Uri]::EscapeDataString($cfg.BBAppPassword))@bitbucket.org/$($cfg.BBWorkspace)/$Repo.wiki.git"
    }

    # Probe if wiki exists
    try { git ls-remote $bbWiki *> $null } catch {
        Write-Log "No wiki for: $Repo" 'INFO' $cfg.LogDir
        return
    }

    $dst = Join-Path $cfg.WorkDir ($Repo + '.wiki.git')
    if (-not (Test-Path $dst)) {
        Write-Log "Cloning wiki mirror: $Repo" 'INFO' $cfg.LogDir
        git clone --mirror $bbWiki $dst
    } else {
        Push-Location $dst
        git fetch --all --prune
        Pop-Location
    }

    if ($cfg.RewriteBotEmail) { Rewrite-BotEmails -cfg $cfg -RepoGitPath $dst }

    if ($cfg.DownloadOnly) { return } # stop here in download-only mode

    Push-Location $dst
    $ghWiki = if ($cfg.GHAuthMode -eq 'SSH') {
        "git@github.com:$($cfg.GHOwer)/$Repo.wiki.git"
    } else {
        if (-not $cfg.GHToken) { throw "GitHub token required for HTTPS." }
        "https://$($cfg.GHToken):x-oauth-basic@github.com/$($cfg.GHOwer)/$Repo.wiki.git"
    }

    if ($cfg.DryRun) {
        Write-Log "DRY-RUN: skipping wiki push → $ghWiki" 'WARN' $cfg.LogDir
        Pop-Location; return
    }

    if (git remote get-url github 2>$null) { git remote remove github | Out-Null }
    git remote add github $ghWiki
    Write-Log "Pushing wiki mirror: $Repo" 'INFO' $cfg.LogDir
    git push --mirror --force github
    Pop-Location
}

function Push-LFS {
    param($cfg, [string]$Repo)
    if (-not $cfg.IncludeLFS) { return }
    if ($cfg.DownloadOnly) { return } # skip LFS push when only downloading

    $gh = if ($cfg.GHAuthMode -eq 'SSH') {
        "git@github.com:$($cfg.GHOwer)/$Repo.git"
    } else {
        if (-not $cfg.GHToken) { throw "GitHub token required for HTTPS." }
        "https://$($cfg.GHToken):x-oauth-basic@github.com/$($cfg.GHOwer)/$Repo.git"
    }

    $tmp = Join-Path $cfg.WorkDir ("_lfs_" + $Repo)
    if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp }

    Write-Log "Pumping all LFS objects: $Repo" 'INFO' $cfg.LogDir
    git clone $gh $tmp
    Push-Location $tmp
    git lfs install
    git lfs fetch --all
    if ($cfg.DryRun) {
        Write-Log "DRY-RUN: skipping 'git lfs push --all origin'" 'WARN' $cfg.LogDir
    } else {
        git lfs push --all origin
    }
    Pop-Location
    Remove-Item -Recurse -Force $tmp
}
