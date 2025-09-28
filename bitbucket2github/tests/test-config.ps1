#Requires -Version 7
$ErrorActionPreference = 'Stop'

# Load config
$scriptRoot = Split-Path -Parent $PSCommandPath
$ConfigPath = Join-Path $scriptRoot '..\config\config.psd1'
$cfg = Import-PowerShellDataFile -Path $ConfigPath

# Auth (email + API token). Если в конфиге пусто — берём из переменной окружения.
$email    = $cfg.BBUser
$apiToken = if ($cfg.BBAppPassword) { $cfg.BBAppPassword } else { $env:BITBUCKET_APP_PASSWORD }
if (-not $email -or -not $apiToken) { throw "BBUser (email) or API token is missing (set in config.psd1 or BITBUCKET_APP_PASSWORD)." }

# Build Basic Auth header
$pair = $email + ":" + $apiToken
$auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($pair))
$hdr  = @{ Authorization = "Basic $auth"; "User-Agent" = "bb2gh-test"; Accept = "application/json" }

function Get-JsonBody($ex) {
  if ($ex.Exception.Response) {
    try { return (New-Object IO.StreamReader($ex.Exception.Response.GetResponseStream())).ReadToEnd() } catch { return "" }
  }
  return ""
}
function GET($url) {
  try { Invoke-RestMethod -Method GET -Uri $url -Headers $hdr }
  catch { $body = Get-JsonBody $_; Write-Host "HTTP error on $url" -Foreground Yellow; if ($body) { Write-Host $body }; throw }
}

Write-Host "=== Step 1: /user (token check) ===" -Foreground Cyan
$userInfo = GET "https://api.bitbucket.org/2.0/user"
$userInfo | Select-Object username, display_name, account_id | Format-Table

Write-Host "`n=== Step 2: /workspaces (discover) ===" -Foreground Cyan
$wsResp = GET "https://api.bitbucket.org/2.0/workspaces?pagelen=100"
$wsSlugs = $wsResp.values | ForEach-Object { $_.slug }
$wsSlugs | ForEach-Object { Write-Host $_ }

# Pick workspace from config; if empty or not found — take the first available
$wsSlug = $cfg.BBWorkspace
if (-not $wsSlug -or -not ($wsSlugs -contains $wsSlug)) {
  $wsSlug = $wsSlugs | Select-Object -First 1
  Write-Host "`nUsing detected workspace slug: $wsSlug" -Foreground Green
} else {
  Write-Host "`nUsing configured workspace slug: $wsSlug" -Foreground Green
}

Write-Host "`n=== Step 3: All repositories (with pagination) ===" -Foreground Cyan

# pick workspace slug safely
$wsSlug = $cfg.BBWorkspace
$wsSlugs = $wsResp.values | ForEach-Object { $_.slug }
if (-not $wsSlug -or -not ($wsSlugs -contains $wsSlug)) {
    $wsSlug = $wsSlugs | Select-Object -First 1
    Write-Host ("Using detected workspace slug: '{0}'" -f $wsSlug) -Foreground Green
} else {
    Write-Host ("Using configured workspace slug: '{0}'" -f $wsSlug) -Foreground Green
}

# guard against stray characters like "=100"
$wsSlug = ([string]$wsSlug).Trim()

$all = @()
$repoUrl = "https://api.bitbucket.org/2.0/repositories/{0}?pagelen=100" -f $wsSlug
do {
    Write-Host ">>> GET $repoUrl"
    $resp = GET $repoUrl
    if ($resp.values) { $all += $resp.values }
    $repoUrl = $resp.next
} while ($repoUrl)

Write-Host ("Total repositories: {0}" -f $all.Count) -Foreground Green
$all | ForEach-Object { $_.slug } | Sort-Object | ForEach-Object { Write-Host $_ }
