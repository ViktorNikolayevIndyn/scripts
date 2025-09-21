param(
  [Parameter(Mandatory)][string]$Key,            # напр. 'default' или 'finance'
  [switch]$FromClipboard                          # можно вставить секрет из буфера
)
$root = Split-Path $PSScriptRoot -Parent
$envFile = Join-Path (Join-Path $root 'env') 'secrets.clixml'
if (-not (Test-Path (Split-Path $envFile -Parent))) { New-Item -ItemType Directory -Path (Split-Path $envFile -Parent) -Force | Out-Null }

if ($FromClipboard) {
  $plain = Get-Clipboard
  if ([string]::IsNullOrWhiteSpace($plain)) { throw 'Clipboard is empty' }
  $sec = ConvertTo-SecureString $plain -AsPlainText -Force
} else {
  $sec = Read-Host 'Enter client secret' -AsSecureString
}

$enc = $sec | ConvertFrom-SecureString  # DPAPI шифрование под текущего пользователя
$map = if (Test-Path $envFile) { Import-Clixml $envFile } else { @{} }
$map[$Key] = $enc
$map | Export-Clixml $envFile
Write-Host "Secret '$Key' saved to $envFile"
