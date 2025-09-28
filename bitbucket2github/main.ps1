#Requires -Version 7
$ErrorActionPreference = 'Stop'

# Resolve paths relative to this script file
$scriptRoot = Split-Path -Parent $PSCommandPath
$ConfigPath = Join-Path $scriptRoot 'config\config.psd1'
$Functions  = Join-Path $scriptRoot 'src\git-functions.ps1'

# Load functions and config
. $Functions
$cfg = Import-PowerShellDataFile -Path $ConfigPath

Ensure-Dirs -cfg $cfg

Write-Log ("=== BB2GH START ===") 'INFO' $cfg.LogDir
Write-Log ("Workspace: {0} → GitHub Owner: {1}" -f $cfg.BBWorkspace, $cfg.GHOwer) 'INFO' $cfg.LogDir
Write-Log ("Mode: DownloadOnly={0}, DryRun={1}" -f $cfg.DownloadOnly, $cfg.DryRun) 'INFO' $cfg.LogDir

# Get repo list (from file or via API)
$repos = Get-RepoList -cfg $cfg
Write-Log ("Found repositories: {0}" -f $repos.Count) 'INFO' $cfg.LogDir

foreach ($r in $repos) {
    try {
        Write-Log (">>> Repository: {0}" -f $r) 'INFO' $cfg.LogDir

        # 1) clone/fetch mirror from Bitbucket
        $mirror = Mirror-Clone -cfg $cfg -Repo $r

        # 2) rewrite bot emails if enabled
        if ($cfg.RewriteBotEmail) { Rewrite-BotEmails -cfg $cfg -RepoGitPath $mirror }

        # 3) wiki mirror (local always; push only if DownloadOnly=$false)
        Mirror-Wiki -cfg $cfg -Repo $r

        if (-not $cfg.DownloadOnly) {
            # 4) ensure GH repo exists & push mirror
            Ensure-GitHubRepo -cfg $cfg -Repo $r
            Push-Mirror      -cfg $cfg -Repo $r -RepoGitPath $mirror

            # 5) push LFS after mirror
            Push-LFS         -cfg $cfg -Repo $r
        } else {
            Write-Log "DownloadOnly: skipping GitHub creation/push for $r" 'WARN' $cfg.LogDir
        }

        Write-Log ("<<< OK: {0}" -f $r) 'INFO' $cfg.LogDir
    }
    catch {
        Write-Log ("FAIL {0}: {1}" -f $r, $_.Exception.Message) 'ERROR' $cfg.LogDir
    }
}

Write-Log ("=== BB2GH DONE ===") 'INFO' $cfg.LogDir
