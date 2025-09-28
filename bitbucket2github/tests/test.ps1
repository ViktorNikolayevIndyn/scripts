# ВСТАВЬ свои значения:

$apiToken = "ATATT3xFfGF0pHOmJZvEg2PQLmAhNge2Yl8uW6kgtnVARWuyPL2S03gk9F7TtEd-YWa-OO9jhnv73AEbmk4wedExW7OaCh_UgqxWSZQR0ujdE57QWkPbl-1zBhYNrHFB6NV7CeYE4nyUQZQ9f0cBNPXBBmO5e318E1aZC3hJQlsRXI3baOIsNgY=338E3735"

#Requires -Version 7
$ErrorActionPreference = 'Stop'

# === ВСТАВЬ свои данные ===
$email    = "viktor.nikolayev@gmail.com"       # Atlassian e-mail
      # длинный ATATT...

# === Сборка Basic Auth заголовка ===
$pair = $email + ":" + $apiToken
$auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($pair))
$hdr  = @{
  Authorization = "Basic $auth"
  "User-Agent"  = "bb2gh-test"
  Accept        = "application/json"
}

function Test-Call($url) {
  try {
    Write-Host ">>> GET $url"
    $resp = Invoke-RestMethod -Method Get -Uri $url -Headers $hdr
    return $resp
  } catch {
    $body = ""
    if ($_.Exception.Response) {
      try {
        $sr = New-Object IO.StreamReader($_.Exception.Response.GetResponseStream())
        $body = $sr.ReadToEnd()
      } catch {}
    }
    Write-Host "Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Yellow
    Write-Host "Body  : $body" -ForegroundColor Yellow
    throw
  }
}

Write-Host "=== Step 1: /user (проверка токена) ===" -ForegroundColor Cyan
$userInfo = Test-Call "https://api.bitbucket.org/2.0/user"
$userInfo | Format-List

Write-Host "`n=== Step 2: /workspaces (список воркспейсов) ===" -ForegroundColor Cyan
$workspaces = Test-Call "https://api.bitbucket.org/2.0/workspaces?pagelen=50"
$workspaces.values | Select-Object -Expand slug

Write-Host "`n=== Step 3: /repositories/<workspace> (первые 5 репо) ===" -ForegroundColor Cyan
# auto-pick the first workspace slug, or pick by name if нужно
$wsList = Test-Call "https://api.bitbucket.org/2.0/workspaces?pagelen=50"
$wsSlugs = $wsList.values | ForEach-Object { $_.slug }
$wsSlug  = $wsSlugs | Select-Object -First 1    # или выбери нужный вручную из $wsSlugs

Write-Host ("Using workspace slug: {0}" -f $wsSlug) -ForegroundColor Green

$repos = Test-Call ("https://api.bitbucket.org/2.0/repositories/{0}?pagelen=5" -f $wsSlug)
$repos.values | Select-Object slug

