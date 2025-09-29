# Common helpers used across modules

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
    foreach ($p in @($cfg.WorkDir,$cfg.LogDir,$cfg.ConfigDir)) {
        New-Item -ItemType Directory -Path $p -Force | Out-Null
    }
}
