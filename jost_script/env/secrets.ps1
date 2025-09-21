# env\secrets.ps1
# Файл хранит ЗАШИФРОВАННЫЕ строки (DPAPI) вида: key -> encryptedString
$Global:SecretsFile = Join-Path $PSScriptRoot 'secrets.clixml'

if (Test-Path $Global:SecretsFile) {
  $Global:Secrets = Import-Clixml $Global:SecretsFile
  if (-not ($Global:Secrets -is [hashtable])) { $Global:Secrets = @{} }
} else {
  $Global:Secrets = @{}
}
