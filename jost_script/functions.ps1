# functions.ps1

function Write-Info([string]$msg){ $ts = Get-Date -Format 's'; Write-Host "[$ts] $msg" }
function Ensure-Dir([string]$Path){ if(-not (Test-Path $Path)){ New-Item -ItemType Directory -Path $Path -Force | Out-Null } }

function Import-DotEnv([string]$Path){
  if(-not (Test-Path $Path)){ return }
  foreach($raw in Get-Content -Path $Path){
    $line = $raw.Trim()
    if([string]::IsNullOrWhiteSpace($line)){ continue }
    if($line.StartsWith('#')){ continue }
    $eq = $line.IndexOf('=')
    if($eq -lt 1){ continue }
    $key = $line.Substring(0,$eq).Trim()
    $val = $line.Substring($eq+1).Trim()
    if(($val.StartsWith('"') -and $val.EndsWith('"')) -or ($val.StartsWith("'") -and $val.EndsWith("'"))){
      $val = $val.Substring(1,$val.Length-2)
    }
    [Environment]::SetEnvironmentVariable($key,$val,'Process')
  }
}

function Parse-Bool($v){
  if($null -eq $v){ return $false }
  $s = ($v.ToString()).Trim().ToLower()
  return @('1','true','yes','ja','y','wahr') -contains $s
}

function Load-EnvRoot([string]$Root){
  # 1) .env -> env variables (Process scope)
  Import-DotEnv (Join-Path $Root 'env\.env')

  # 2) config scripts
  . (Join-Path $Root 'env\graph.ps1')
  . (Join-Path $Root 'env\email.ps1')
  . (Join-Path $Root 'env\creds.ps1')

  # 3) optional overrides from .env for behavior
  if($env:DEFAULT_SENDER_UPN){ $Global:Graph.DefaultSenderUPN = $env:DEFAULT_SENDER_UPN }
  if($env:SEND_MODE){ $Global:Graph.SendMode = $env:SEND_MODE }
  if($env:ALLOWED_EXT){ $Global:Graph.AllowedExt = @($env:ALLOWED_EXT.Split(',') | ForEach-Object { $_.Trim() }) }
  if($env:MAX_TOTAL_MB){ $Global:Graph.MaxTotalMB = [int]$env:MAX_TOTAL_MB }
  if($env:MAX_FILES_PER_MAIL){ $Global:Graph.MaxFilesPerMail = [int]$env:MAX_FILES_PER_MAIL }
  if($env:MOVE_ON_MESSAGE_ONLY){ $Global:Graph.MoveOnMessageOnly = Parse-Bool $env:MOVE_ON_MESSAGE_ONLY }

  # 4) companies.csv
  $csv = Join-Path $Root 'env\companies.csv'
  if(-not (Test-Path $csv)){ throw "companies.csv not found: $csv" }

  $rows = Import-Csv -Path $csv -Delimiter ';'
  $Global:Companies = @()
  foreach($r in $rows){
    $to = ($r.emailto -replace ';',',' -split ',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
    $Global:Companies += [pscustomobject]@{
      Name        = $r.name
      FolderPath  = $r.folderpath
      SendTo      = @($to)
      Attachment  = Parse-Bool $r.attachment
      Active      = Parse-Bool $r.active
      CredName    = $r.credname
      SendFromUPN = $r.senderupn
    }
  }

  # 5) validate default profile from env\creds.ps1 (values come from .env)
  if(-not $Global:CredProfiles -or -not $Global:CredProfiles.ContainsKey('default')){
    throw "Cred profile 'default' is missing in env\creds.ps1"
  }
  $def = $Global:CredProfiles['default']
  if([string]::IsNullOrWhiteSpace($def.TenantId) -or [string]::IsNullOrWhiteSpace($def.ClientId)){
    throw "DEFAULT_TENANT_ID / DEFAULT_CLIENT_ID must be set in env\.env"
  }
}

function Get-CredProfile([string]$CredName){
  $name = if([string]::IsNullOrWhiteSpace($CredName)){ 'default' } else { $CredName }
  if(-not $Global:CredProfiles -or -not $Global:CredProfiles.ContainsKey($name)){
    throw "Cred profile '$name' not found in env\creds.ps1"
  }
  return $Global:CredProfiles[$name]
}

function Get-ClientSecret([string]$EnvVar){
  $v = [Environment]::GetEnvironmentVariable($EnvVar,'Process')
  if([string]::IsNullOrWhiteSpace($v)){ $v = [Environment]::GetEnvironmentVariable($EnvVar,'User') }
  if([string]::IsNullOrWhiteSpace($v)){ $v = [Environment]::GetEnvironmentVariable($EnvVar,'Machine') }
  if([string]::IsNullOrWhiteSpace($v)){ throw "App client secret not found in env var $EnvVar" }
  ConvertTo-SecureString $v -AsPlainText -Force
}

function Get-GraphToken([string]$Tenant,[string]$Client,[securestring]$Secret){
  $plain = [Runtime.InteropServices.Marshal]::PtrToStringUni(
             [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Secret))
  try{
    $body=@{
      client_id     = $Client
      scope         = 'https://graph.microsoft.com/.default'
      client_secret = $plain
      grant_type    = 'client_credentials'
    }
    $uri="https://login.microsoftonline.com/$Tenant/oauth2/v2.0/token"
    (Invoke-RestMethod -Method Post -Uri $uri -Body $body -ContentType 'application/x-www-form-urlencoded').access_token
  } finally { $plain = $null }
}

function Test-GraphHealth([string]$AccessToken,[string]$SenderUPN){
  $roles = Get-TokenRoles $AccessToken
  if($roles -and ($roles -contains 'Mail.Send')){
    Write-Info "Graph health: token ok (Mail.Send present)"
    return $true
  } else {
    Write-Info "Graph health: Mail.Send role NOT present in token"
    return $false
  }
}

function Expand-Template([string]$tpl,$file,$company){
  if([string]::IsNullOrWhiteSpace($tpl)){ return $tpl }
  $t = $tpl
  if($file -and $file.PSObject.Properties.Name -contains 'FileName'){
    $t = $t.Replace('{FileName}', $file.FileName)
  } else {
    $t = $t.Replace('{FileName}', '')
  }
  $t = $t.Replace('{FirmName}', $company.Name).Replace('{firmaname}', $company.Name).Replace('{Name}', $company.Name)
  return $t
}

function Collect-Files([string]$Folder,[string[]]$AllowedExt){
  if(-not (Test-Path $Folder -PathType Container)){ return @() }
  $i=1; $out=@()
  Get-ChildItem -Path $Folder -File |
    Where-Object { $AllowedExt -contains $_.Extension.ToLower() } |
    Sort-Object Name |
    ForEach-Object{
      $out += [pscustomobject]@{
        Pos       = $i
        FileName  = $_.Name
        Extension = $_.Extension.ToLower()
        FullPath  = $_.FullName
      }
      $i++
    }
  return $out
}

function Make-Attachments([string[]]$Files){
  $list=@()
  foreach($p in $Files){
    $b=[System.IO.File]::ReadAllBytes($p); $b64=[System.Convert]::ToBase64String($b)
    $list += @{
      "@odata.type" = "#microsoft.graph.fileAttachment"
      name         = (Split-Path $p -Leaf)
      contentType  = "application/octet-stream"
      contentBytes = $b64
    }
  }
  return $list
}

function Send-GraphMail {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)][string]   $AccessToken,
    [Parameter(Mandatory)][string]   $FromUpn,
    [Parameter(Mandatory)][string[]] $To,
    [Parameter(Mandatory)][string]   $Subject,
    [Parameter(Mandatory)][string]   $BodyHtml,
    [string[]] $AttachmentPaths = @()
  )
  $ErrorActionPreference = 'Stop'

  $msg = @{
    subject      = $Subject
    body         = @{ contentType = "HTML"; content = $BodyHtml }
    toRecipients = @($To | ForEach-Object { @{ emailAddress = @{ address = $_ } } })
  }

  if($AttachmentPaths.Count -gt 0){
    $atts = @()
    foreach($p in $AttachmentPaths){
      $bytes = [IO.File]::ReadAllBytes($p)
      $b64   = [Convert]::ToBase64String($bytes)
      $atts += @{
        "@odata.type" = "#microsoft.graph.fileAttachment"
        name          = [IO.Path]::GetFileName($p)
        contentType   = "application/pdf"
        contentBytes  = $b64
      }
    }
    $msg.attachments = $atts
  }

  $payload = @{ message = $msg; saveToSentItems = $true } | ConvertTo-Json -Depth 8

  try {
    Invoke-RestMethod -Method POST `
      -Uri "https://graph.microsoft.com/v1.0/users/$FromUpn/sendMail" `
      -Headers @{ Authorization = "Bearer $AccessToken" } `
      -Body $payload -ContentType "application/json" | Out-Null
    return $true
  } catch {
    return $false
  }
}


function Move-ToDone([string]$CompanyFolder,[string[]]$Files){
  $done = Join-Path $CompanyFolder 'DONE'; Ensure-Dir $done
  foreach($src in $Files){
    $dst=Join-Path $done (Split-Path $src -Leaf)
    if(Test-Path $dst){
      $ts=Get-Date -Format 'yyyyMMdd_HHmmss'
      $base=[IO.Path]::GetFileNameWithoutExtension($dst)
      $ext =[IO.Path]::GetExtension($dst)
      $dst=Join-Path $done "$base`_$ts$ext"
    }
    Move-Item -LiteralPath $src -Destination $dst
  }
}

function Build-Work([object[]]$Companies,[hashtable]$Graph){
  $work=@()
  foreach($c in $Companies){
    if(-not (Parse-Bool $c.Active)){ Write-Info "Skip inactive: $($c.Name)"; continue }
    if(-not (Test-DirSafe $c.FolderPath)){ Write-Info "Skip no folder: $($c.Name)"; continue }
    if(-not $c.SendTo -or $c.SendTo.Count -eq 0){ Write-Info "Skip no recipients: $($c.Name)"; continue }

    $files = Collect-Files $c.FolderPath $Graph.AllowedExt

    if($files.Count -eq 0){
      if(-not (Parse-Bool $c.Attachment)){
        Write-Info "Queue message-only: $($c.Name)"
        $work += [pscustomobject]@{ Company=$c; Files=@() }
      } else {
        Write-Info "Skip empty: $($c.Name)"
      }
      continue
    }

    $work += [pscustomobject]@{ Company=$c; Files=$files }
  }
  $work
}

# NEW: извлечь роли (app permissions) из токена
function Get-TokenRoles([string]$Jwt){
  try{
    $parts = $Jwt.Split('.')
    $pad = 4 - ($parts[1].Length % 4); if($pad -lt 4){ $parts[1] += ('=' * $pad) }
    $json = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($parts[1].Replace('-','+').Replace('_','/')))
    ($json | ConvertFrom-Json).roles
  } catch { @() }
}

# NEW: безопасная проверка папки
function Test-DirSafe([string]$Path){
  try{
    if([string]::IsNullOrWhiteSpace($Path)){ return $false }
    return (Test-Path -Path $Path -PathType Container -ErrorAction Stop)
  } catch {
    Write-Info "Path not reachable: $Path ($($_.Exception.Message))"
    return $false
  }
}

# NEW: безопасный сбор файлов
function Collect-Files([string]$Folder,[string[]]$AllowedExt){
  if(-not (Test-DirSafe $Folder)){ return @() }
  try{
    $i=1; $out=@()
    $gciParams = @{ Path = $Folder; File = $true; ErrorAction = 'Stop' }
    if($Global:Graph.ContainsKey('Recurse') -and $Global:Graph.Recurse){ $gciParams.Recurse = $true }
    Get-ChildItem @gciParams |
      Where-Object { $AllowedExt -contains $_.Extension.ToLower() } |
      Sort-Object FullName |
      ForEach-Object{
        $out += [pscustomobject]@{ Pos=$i; FileName=$_.Name; Extension=$_.Extension.ToLower(); FullPath=$_.FullName }; $i++
      }
    return $out
  } catch {
    Write-Info "Collect files failed: $Folder ($($_.Exception.Message))"
    return @()
  }
}

function Format-Size([long]$bytes) {
    if ($bytes -ge 1GB) { "{0:N1} GB" -f ($bytes / 1GB) }
    elseif ($bytes -ge 1MB) { "{0:N1} MB" -f ($bytes / 1MB) }
    elseif ($bytes -ge 1KB) { "{0:N1} KB" -f ($bytes / 1KB) }
    else { "$bytes B" }
}

function Send-ScanMail {
    param(
        [Parameter(Mandatory)] [string] $FilePath,
        [Parameter(Mandatory)] [string] $To,
        [Parameter(Mandatory)] [string] $FromUpn,
        [Parameter(Mandatory)] [string] $AccessToken,
        [switch] $Attach
    )

    $fi = [IO.FileInfo]$FilePath

    $msg = @{
        subject      = "[SCAN] $($fi.Name)"
        body         = @{
            contentType = "Text"
            content     = "Автоматическое письмо."
        }
        toRecipients = @(@{ emailAddress = @{ address = $To } })
    }

    if ($Attach.IsPresent) {
        $b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($fi.FullName))
        $msg.attachments = @(@{
            "@odata.type" = "#microsoft.graph.fileAttachment"
            name          = $fi.Name
            contentType   = "application/pdf"
            contentBytes  = $b64
        })
    }

    $payload = @{ message = $msg; saveToSentItems = $true } | ConvertTo-Json -Depth 8

    Invoke-RestMethod -Method POST `
        -Uri "https://graph.microsoft.com/v1.0/users/$FromUpn/sendMail" `
        -Headers @{ Authorization = "Bearer $AccessToken" } `
        -Body $payload -ContentType "application/json" | Out-Null

    $size = Format-Size $fi.Length
    Write-Host ("[{0}] {1} -> {2} ({3}) - OK" -f (Get-Date -Format s), $fi.Name, $To, $size)
}
