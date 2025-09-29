# Bitbucket API + clone helpers (HTTPS only for Git)

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

# Array<string> of slugs
function Get-RepoList {
    param($cfg)
    if ($cfg.UseRepoListFile -and (Test-Path $cfg.RepoListFile)) {
        return (Get-Content $cfg.RepoListFile | Where-Object { $_ -and $_.Trim() -ne '' -and -not $_.StartsWith('#') }).ForEach({ $_.Trim() })
    }
    $ws = ([string]$cfg.BBWorkspace).Trim()
    if (-not $ws) { throw "BBWorkspace is empty." }

    $all = @()
    $url = "https://api.bitbucket.org/2.0/repositories/{0}?pagelen=100" -f $ws
    do {
        $resp = Invoke-BB -cfg $cfg -Url $url
        if ($resp -and ($resp.PSObject.Properties.Name -contains 'values')) { $all += $resp.values }
        $url = ($resp -and ($resp.PSObject.Properties.Name -contains 'next')) ? $resp.next : $null
    } while ($url)

    return ($all | ForEach-Object { $_.slug } | Where-Object { $_ } | Sort-Object -Unique)
}

# Array<PSObject {Slug, ProjectKey, ProjectName}>
function Get-RepoMetaList {
    param($cfg)
    $ws = ([string]$cfg.BBWorkspace).Trim()
    if (-not $ws) { throw "BBWorkspace is empty." }

    $all = @()
    $url = "https://api.bitbucket.org/2.0/repositories/{0}?pagelen=100" -f $ws
    do {
        $resp = Invoke-BB -cfg $cfg -Url $url
        if ($resp -and ($resp.PSObject.Properties.Name -contains 'values')) {
            foreach ($v in $resp.values) {
                $pkey=$null;$pname=$null
                if ($v.PSObject.Properties.Name -contains 'project' -and $v.project) {
                    if ($v.project.PSObject.Properties.Name -contains 'key')  { $pkey  = $v.project.key }
                    if ($v.project.PSObject.Properties.Name -contains 'name') { $pname = $v.project.name }
                }
                $all += [PSCustomObject]@{ Slug=$v.slug; ProjectKey=$pkey; ProjectName=$pname }
            }
        }
        $url = ($resp -and ($resp.PSObject.Properties.Name -contains 'next')) ? $resp.next : $null
    } while ($url)

    return ($all | Group-Object Slug | ForEach-Object { $_.Group[0] } | Sort-Object Slug)
}

function Mirror-Clone {
    param($cfg, [string]$Repo)
    $dst = Join-Path $cfg.WorkDir ($Repo + '.git')
    $token = $cfg.BBAppPassword; if (-not $token) { $token = $env:BITBUCKET_APP_PASSWORD }

    $src = if ($cfg.BBAuthMode -eq 'HTTPS') {
        if (-not $cfg.BBGitUser) { throw "BBGitUser is required for HTTPS clone." }
        if (-not $token)         { throw "API token is required for HTTPS clone." }
        "https://$($cfg.BBGitUser):$([Uri]::EscapeDataString($token))@bitbucket.org/$($cfg.BBWorkspace)/$Repo.git"
    } else {
        "git@bitbucket.org:$($cfg.BBWorkspace)/$Repo.git"
    }

    if (Test-Path $dst) {
        Write-Log "Mirror exists → fetch: $dst" 'INFO' $cfg.LogDir
        Push-Location $dst; git fetch --all --prune; Pop-Location
        return $dst
    }

    $displaySrc = $src -replace ":(?<tok>[^@]+)@", ":***@"
    Write-Log "Cloning mirror: $displaySrc → $dst" 'INFO' $cfg.LogDir
    git clone --mirror $src $dst
    return $dst
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
        Push-Location $dst; git fetch --all --prune; Pop-Location
    }
}

function Rewrite-BotEmails {
    param($cfg, [string]$RepoGitPath)
    if (-not $cfg.RewriteBotEmail) { return }
    if (-not (Test-Path $RepoGitPath)) { return }

    Write-Log "Rewriting @bots.bitbucket.org emails → $($cfg.NewEmail) in $RepoGitPath" 'INFO' $cfg.LogDir
    Push-Location $RepoGitPath
    # Use here-string and escape $ to keep bash env vars intact
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
