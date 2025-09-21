# env\creds.ps1
# profiles read values from environment (.env loaded into Process scope)
$Global:CredProfiles = @{
  default = @{
    TenantId     = $env:DEFAULT_TENANT_ID
    ClientId     = $env:DEFAULT_CLIENT_ID
    SecretEnvVar = 'DEFAULT_CLIENT_SECRET'   # env var that holds client secret value
  }
  # optional second profile example:
  # finance = @{
  #   TenantId     = $env:FIN_TENANT_ID
  #   ClientId     = $env:FIN_CLIENT_ID
  #   SecretEnvVar = 'FIN_CLIENT_SECRET'
  # }
}
