# Loads all modules in correct order
. (Join-Path $PSScriptRoot 'paths.ps1')
. (Join-Path $PSScriptRoot 'common.ps1')
. (Join-Path $PSScriptRoot 'bitbucket-func.ps1')
. (Join-Path $PSScriptRoot 'naming.ps1')
. (Join-Path $PSScriptRoot 'manifest.ps1')
. (Join-Path $PSScriptRoot 'github-func.ps1')
