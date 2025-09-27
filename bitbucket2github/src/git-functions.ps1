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

    # Case 1: repos.txt is provided
    if ($cfg.UseRepoListFile -and (Test-Path $cfg.RepoListFile)) {
        return (Get-Content $cfg.RepoListFile | Where-Object {
            $_ -and $_.Trim() -ne '' -and -not $_.StartsWith('#')
        }).ForEach({ $_.Trim() })
    }

    # Case 2: auto-discovery from Bitbucket API
    if ($cfg.BBAuthMode -ne 'HTTPS') {
        throw "Bitbucket API requires HTTPS + App Password"
    }

    $creds = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($cfg.BBUser):$($cfg.BBAppPassword)"))
    $url = "https://api.bitbucket.org/2.0/repositories/$($cfg.BBWorkspace)?pagelen=100"

    $all = @()
    do {
        $resp = Invoke-RestMethod -Method Get -Uri $url -Headers @{ Authorization = "Basic $creds" }
        $all += ($resp.values.slug)
        $url = $resp.next
    } while ($url)

    return $all
}

function Mirror-Clone {
    param($cfg, [string]$Repo)
    $dst = Join-Path $cfg.WorkDir ($Repo + '.git')

    if (Test-Path $dst) {
        Write-Log "Mirror already exists: $dst → running fetch" 'INFO' $cfg.LogDir
        Push-Location $dst
        git fetch --all --prune
        Pop-Location
        return $dst
    }

    $src = if ($cfg.BBAuthMode -eq 'SSH') {
        "git@bitbucket.org:$($cfg.BBWorkspace)/$Repo.git"
    } else {
        if (-not $cfg.BBUser -or -not $cfg.BBAppPassword) { throw "BBUser/BBAppPassword required" }
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
    $full = "$($cfg.GHOwer)/$Repo"

    # Try GitHub CLI if installed
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        if (-not (gh repo view $full 2>$null)) {
            Write-Log "Creating GitHub repo: $full ($($cfg.Visibility))" 'INFO' $cfg.LogDir
            gh repo create $full --$($cfg.Visibility)
        } else {
            Write-Log "GitHub repo already exists: $full" 'INFO' $cfg.LogDir
        }
    } else {
        Write-Log "gh CLI not found. Create repo $full manually in GitHub (empty)." 'WARN' $cfg.LogDir
    }
}

function Push-Mirror {
    param($cfg, [string]$Repo, [string]$RepoGitPath)

    Push-Location $RepoGitPath
    $ghUrl = if ($cfg.GHAuthMode -eq 'SSH') {
        "git@github.com:$($cfg.GHOwer)/$Repo.git"
    } else {
        if (-not $cfg.GHToken) { throw "GitHub token required for HTTPS" }
        "https://$($cfg.GHToken):x-oauth-basic@github.com/$($cfg.GHOwer)/$Repo.git"
    }

    if ($cfg.DryRun) {
        Write-Log "DRY-RUN: skipping push → $ghUrl" 'WARN' $cfg.LogDir
        Pop-Location; return
    }

    if (git remote get-url github 2>$null) { git remote remove github | Out-Null }
    git remote add github $ghUrl

    Write-Log "Pushing mirror to GitHub: $Repo" 'INFO' $cfg.LogDir
    git push --mirror --force github
    Pop-Location
}
