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
  foreach ($p in @($cfg.WorkDir,$cfg.LogDir)) { New-Item -ItemType Directory -Path $p -Force | Out-Null }
}

function Get-RepoList {
  param($cfg)
  if ($cfg.UseRepoListFile -and (Test-Path $cfg.RepoListFile)) {
    (Get-Content $cfg.RepoListFile | Where-Object { $_ -and $_.Trim() -ne '' -and -not $_.StartsWith('#') }).ForEach({ $_.Trim() })
  } else {
    if ($cfg.BBAuthMode -ne 'HTTPS') { throw "Для API Bitbucket нужен HTTPS и App Password." }
    $creds = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($cfg.BBUser):$($cfg.BBAppPassword)"))
    $url = "https://api.bitbucket.org/2.0/repositories/$($cfg.BBWorkspace)?pagelen=100"
    $all = @()
    do {
      $resp = Invoke-RestMethod -Method Get -Uri $url -Headers @{ Authorization = "Basic $creds" }
      $all += ($resp.values.slug)
      $url = $resp.next
    } while ($url)
    $all
  }
}

function Mirror-Clone {
  param($cfg, [string]$Repo)
  $dst = Join-Path $cfg.WorkDir ($Repo + '.git')
  if (Test-Path $dst) {
    Write-Log "Зеркало уже есть: $dst — обновляю fetch..." 'INFO' $cfg.LogDir
    Push-Location $dst
    git fetch --all --prune
    Pop-Location
    return $dst
  }
  $src = if ($cfg.BBAuthMode -eq 'SSH') {
    "git@bitbucket.org:$($cfg.BBWorkspace)/$Repo.git"
  } else {
    if (-not $cfg.BBUser -or -not $cfg.BBAppPassword) { throw "Нужны BBUser/BBAppPassword" }
    "https://$($cfg.BBUser):$([Uri]::EscapeDataString($cfg.BBAppPassword))@bitbucket.org/$($cfg.BBWorkspace)/$Repo.git"
  }
  Write-Log "Клонирую зеркалом: $src -> $dst" 'INFO' $cfg.LogDir
  git clone --mirror $src $dst
  $dst
}

function Rewrite-BotEmails {
  param($cfg, [string]$RepoGitPath)
  if (-not $cfg.RewriteBotEmail) { return }
  Write-Log "Переписываю bot-email на $($cfg.NewEmail) в $RepoGitPath" 'INFO' $cfg.LogDir
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
  # Пытаемся через gh, если установлен
  if (Get-Command gh -ErrorAction SilentlyContinue) {
    $full = "$($cfg.GHOwer)/$Repo"
    if (-not (gh repo view $full 2>$null)) {
      Write-Log "Создаю GitHub репозиторий: $full ($($cfg.Visibility))" 'INFO' $cfg.LogDir
      gh repo create $full --$($cfg.Visibility) --disable-issues=false --disable-wiki=false --public:$($cfg.Visibility -eq 'public') --private:$($cfg.Visibility -eq 'private')
    } else {
      Write-Log "GitHub репозиторий уже существует: $full" 'INFO' $cfg.LogDir
    }
  } else {
    Write-Log "gh не найден. Создай $($cfg.GHOwer)/$Repo вручную в GitHub (пустой)." 'WARN' $cfg.LogDir
  }
}

function Push-Mirror {
  param($cfg, [string]$Repo, [string]$RepoGitPath)
  Push-Location $RepoGitPath
  $ghUrl = if ($cfg.GHAuthMode -eq 'SSH') {
    "git@github.com:$($cfg.GHOwer)/$Repo.git"
  } else {
    if (-not $cfg.GHToken) { throw "Нужен GHToken для HTTPS" }
    "https://$($cfg.GHToken):x-oauth-basic@github.com/$($cfg.GHOwer)/$Repo.git"
  }

  if ($cfg.DryRun) {
    Write-Log "DRY-RUN: пропускаю push --mirror в $ghUrl" 'WARN' $cfg.LogDir
    Pop-Location; return
  }

  if (git remote get-url github 2>$null) { git remote remove github | Out-Null }
  git remote add github $ghUrl
  Write-Log "Пушу зеркалом в GitHub: $Repo" 'INFO' $cfg.LogDir
  git push --mirror --force github
  Pop-Location
}

function Mirror-Wiki {
  param($cfg,[string]$Repo)
  if (-not $cfg.IncludeWiki) { return }
  $src = if ($cfg.BBAuthMode -eq 'SSH') {
    "git@bitbucket.org:$($cfg.BBWorkspace)/$Repo.wiki.git"
  } else {
    if (-not $cfg.BBUser -or -not $cfg.BBAppPassword) { throw "Нужны BBUser/BBAppPassword для wiki HTTPS" }
    "https://$($cfg.BBUser):$([Uri]::EscapeDataString($cfg.BBAppPassword))@bitbucket.org/$($cfg.BBWorkspace)/$Repo.wiki.git"
  }
  $dst = Join-Path $cfg.WorkDir ($Repo + '.wiki.git')
  try {
    git ls-remote $src *> $null
  } catch {
    Write-Log "Wiki нет: $Repo" 'INFO' $cfg.LogDir
    return
  }
  if (-not (Test-Path $dst)) {
    Write-Log "Клонирую wiki зеркалом: $Repo" 'INFO' $cfg.LogDir
    git clone --mirror $src $dst
  } else {
    Push-Location $dst; git fetch --all --prune; Pop-Location
  }
  if ($cfg.RewriteBotEmail) { Rewrite-BotEmails -cfg $cfg -RepoGitPath $dst }
  Push-Location $dst
  $ghWiki = if ($cfg.GHAuthMode -eq 'SSH') {
    "git@github.com:$($cfg.GHOwer)/$Repo.wiki.git"
  } else {
    if (-not $cfg.GHToken) { throw "Нужен GHToken для HTTPS" }
    "https://$($cfg.GHToken):x-oauth-basic@github.com/$($cfg.GHOwer)/$Repo.wiki.git"
  }
  if (git remote get-url github 2>$null) { git remote remove github | Out-Null }
  git remote add github $ghWiki
  git push --mirror --force github
  Pop-Location
}

function Push-LFS {
  param($cfg,[string]$Repo)
  if (-not $cfg.IncludeLFS) { return }
  $tmp = Join-Path $cfg.WorkDir ("_lfs_" + $Repo)
  if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp }
  $gh = if ($cfg.GHAuthMode -eq 'SSH') {
    "git@github.com:$($cfg.GHOwer)/$Repo.git"
  } else {
    if (-not $cfg.GHToken) { throw "Нужен GHToken для HTTPS" }
    "https://$($cfg.GHToken):x-oauth-basic@github.com/$($cfg.GHOwer)/$Repo.git"
  }
  Write-Log "Прокачиваю LFS: $Repo" 'INFO' $cfg.LogDir
  git clone $gh $tmp
  Push-Location $tmp
  git lfs install
  git lfs fetch --all
  git lfs push --all origin
  Pop-Location
  Remove-Item -Recurse -Force $tmp
}
