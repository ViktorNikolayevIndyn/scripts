<# install.ps1 — prereq checker/fixer + optional pwsh install

EXAMPLES
  .\install.ps1
  .\install.ps1 -InstallPwsh -PwshVersion 7.5.3
  .\install.ps1 -InstallDotNet -ImportProxyFromIE
  .\install.ps1 -TestGraph -Root "C:\PROJECT\jost_script" -SenderUPN admin@contoso.com
#>

[CmdletBinding()]
param(
  [switch]$SetTls = $true,
  [switch]$SetExecutionPolicy = $true,
  [switch]$ImportProxyFromIE,
  [switch]$InstallDotNet,
  [switch]$TestGraph,
  [switch]$InstallPwsh,                  # <— новое: устанавливать PowerShell 7
  [string]$PwshVersion = "7.5.3",        # версия pwsh для установки
  [string]$Root = $PSScriptRoot,
  [string]$SenderUPN
)

# ---------- helpers ----------
function Write-Info([string]$m){ $ts = Get-Date -Format s; Write-Host "[$ts] $m" }
function Write-OK([string]$m){ Write-Host "[ OK ] $m" -ForegroundColor Green }
function Write-Warn([string]$m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Write-Err([string]$m){ Write-Host "[ERR ] $m" -ForegroundColor Red }

function Assert-Admin {
  $id=[Security.Principal.WindowsIdentity]::GetCurrent()
  $p =New-Object Security.Principal.WindowsPrincipal($id)
  if(-not $p.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)){
    throw "Run this script in an elevated PowerShell (Run as Administrator)."
  }
}

function Test-Net([string]$TargetHost){
  try{
    (Test-NetConnection $TargetHost -Port 443 -WarningAction SilentlyContinue).TcpTestSucceeded
  } catch {
    $false
  }
}

# ---------- F) Network reachability ----------
foreach($target in 'login.microsoftonline.com','graph.microsoft.com'){
  if(Test-Net $target){ Write-OK "443 reachable: $target" }
  else { Write-Err "443 NOT reachable: $target" }
}


function Get-DotNetRelease {
  $keys=@(
    'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\NET Framework Setup\NDP\v4\Full'
  )
  foreach($k in $keys){ try{ $v=(Get-ItemProperty -Path $k -ErrorAction Stop).Release; if($v){ return [int]$v } }catch{} }
  0
}
function Test-DotNet48 { (Get-DotNetRelease) -ge 528040 }

function Get-PwshInfo {
  $cmd = Get-Command pwsh -ErrorAction SilentlyContinue
  if(-not $cmd){ return [pscustomobject]@{ Exists=$false; Path=$null; Version=$null } }
  try{
    $v = & $cmd.Source -NoLogo -NoProfile -Command '$PSVersionTable.PSVersion.ToString()'
    [pscustomobject]@{ Exists=$true; Path=$cmd.Source; Version=$v.Trim() }
  } catch {
    [pscustomobject]@{ Exists=$true; Path=$cmd.Source; Version=$null }
  }
}

# ---------- 0) pre-flight ----------
try { Assert-Admin } catch { Write-Err $_; exit 1 }
Write-Info "Host shell: $($PSVersionTable.PSEdition) $($PSVersionTable.PSVersion)  OS: $([Environment]::OSVersion.VersionString)"

# ---------- A) PowerShell 7 detection / install ----------
$pw = Get-PwshInfo
if($pw.Exists){
  Write-OK "pwsh detected: $($pw.Version) at $($pw.Path)"
} else {
  Write-Warn "pwsh not found (Windows PowerShell 5.1 only)."
  if($InstallPwsh){
    try{
      $msi = "PowerShell-$PwshVersion-win-x64.msi"
      $url = "https://github.com/PowerShell/PowerShell/releases/download/v$PwshVersion/$msi"
      $tmp = Join-Path $env:TEMP $msi
      Write-Info "Downloading pwsh $PwshVersion ..."
      Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing
      Write-Info "Installing pwsh (silent MSI)..."
      Start-Process msiexec.exe -ArgumentList "/i `"$tmp`" /qn ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_MU=1" -Wait
      $pw = Get-PwshInfo
      if($pw.Exists){ Write-OK "pwsh installed: $($pw.Version)"; }
      else { Write-Err "pwsh installation finished but not detected (reboot may be required)." }
    } catch { Write-Err "pwsh installation failed: $($_.Exception.Message)" }
  } else {
    Write-Warn "Run with -InstallPwsh to install PowerShell 7 automatically."
  }
}

# ---------- B) TLS 1.2 ----------
if($SetTls){
  try{
    $paths=@(
      'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319',
      'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319'
    )
    foreach($p in $paths){
      New-Item $p -Force | Out-Null
      New-ItemProperty $p -Name SchUseStrongCrypto -Type DWord -Value 1 -Force | Out-Null
      New-ItemProperty $p -Name SystemDefaultTlsVersions -Type DWord -Value 1 -Force | Out-Null
    }
    $sch='HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client'
    New-Item $sch -Force | Out-Null
    New-ItemProperty $sch -Name Enabled -Type DWord -Value 1 -Force | Out-Null
    New-ItemProperty $sch -Name DisabledByDefault -Type DWord -Value 0 -Force | Out-Null
    try{ [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 }catch{}
    Write-OK "TLS 1.2 configured."
  } catch { Write-Err "TLS setup failed: $($_.Exception.Message)" }
}

# ---------- C) ExecutionPolicy ----------
if($SetExecutionPolicy){
  try{ Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force -ErrorAction Stop; Write-OK "ExecutionPolicy RemoteSigned (LocalMachine)"; }
  catch { Write-Err "ExecutionPolicy change failed: $($_.Exception.Message)" }
}

# ---------- D) Proxy (optional) ----------
if($ImportProxyFromIE){
  try{ netsh winhttp import proxy source=ie | Out-Null; $cur = (netsh winhttp show proxy) 2>&1; Write-OK "WinHTTP proxy set.`n$cur" }
  catch { Write-Err "Proxy import failed: $($_.Exception.Message)" }
}

# ---------- E) .NET 4.8 ----------
if(Test-DotNet48){ Write-OK ".NET Framework 4.8 detected." }
elseif($InstallDotNet){
  $url="https://download.microsoft.com/download/2/5/2/2524F6C2-6C0E-4410-BB31-6C3AFE225963/ndp48-x86-x64-allos-enu.exe"
  $tmp=Join-Path $env:TEMP "ndp48setup.exe"
  try{
    Write-Info "Downloading .NET 4.8..."
    Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing
    Write-Info "Installing .NET 4.8..."
    Start-Process $tmp -ArgumentList "/q /norestart" -Wait
    if(Test-DotNet48){ Write-OK ".NET 4.8 installed (reboot may be required)." } else { Write-Err ".NET 4.8 not detected after install." }
  } catch { Write-Err ".NET 4.8 installation failed: $($_.Exception.Message)" }
} else {
  Write-Warn ".NET 4.8 NOT detected. Use -InstallDotNet to install automatically."
}

# ---------- F) Network reachability ----------
foreach($h in 'login.microsoftonline.com','graph.microsoft.com'){
  if(Test-Net $h){ Write-OK "443 reachable: $h" } else { Write-Err "443 NOT reachable: $h" }
}

# ---------- G) Optional Graph test ----------
if($TestGraph){
  try{
    . (Join-Path $Root 'functions.ps1')
    Load-EnvRoot $Root
    $def    = Get-CredProfile 'default'
    $secret = Get-ClientSecret $def.SecretEnvVar
    $token  = Get-GraphToken $def.TenantId $def.ClientId $secret
    $roles  = Get-TokenRoles $token
    if($roles -and ($roles -contains 'Mail.Send')){ Write-OK "Graph token OK: Mail.Send present." }
    else { Write-Err "Graph token OK, but Mail.Send role NOT present." }
    if($SenderUPN){
      if(Test-GraphHealth $token $SenderUPN){ Write-OK "Graph health passed for $SenderUPN" }
      else { Write-Err "Graph health FAILED for $SenderUPN" }
    }
  } catch { Write-Err "Graph test failed: $($_.Exception.Message)" }
} else {
  Write-Warn "Graph test skipped. Run with -TestGraph -Root <project> [-SenderUPN user@domain]"
}

Write-Info "Done. Use 'pwsh' (if installed) or 'powershell' to run your main script."
