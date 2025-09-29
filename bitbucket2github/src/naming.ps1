# Naming, owner selection, language detection

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
        } else { return $tryName }
        $n++
        $suffix = $cfg.TargetNameCollisionSuffix.Replace('{N}', "$n")
        $tryName = "$BaseName$suffix"
    }
}

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
