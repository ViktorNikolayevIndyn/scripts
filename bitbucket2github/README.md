# BB2GH (Bitbucket → GitHub)

## What this project does
- Auto-discovers all repositories in a Bitbucket workspace via API (when `UseRepoListFile = $false`).
- Downloads each repo as a **bare mirror** (all branches/tags/history).
- (Optional) Rewrites `@bots.bitbucket.org` emails to your GitHub email.
- (Optional) Mirrors wiki repos locally.
- (Optional) Creates/pushes to GitHub (disabled when `DownloadOnly = $true`).

## Configure
Edit `config/config.psd1`:
- Set `BBWorkspace`.
- For API discovery set `UseRepoListFile = $false`, and fill `BBUser` + `BBAppPassword` (Bitbucket App Password with `repository:read`).
- Choose SSH/HTTPS for both Bitbucket and GitHub sides.
- Set `DownloadOnly = $true` to only download; set to `$false` to also push to GitHub.

## Run
```powershell
# PowerShell 7
pwsh -File C:\PROJECT\scripts_git\bitbucket2github\main.ps1

```

# Requirements
- PowerShell 7
- Git installed and in PATH
- (Optional) GitHub CLI gh for auto repo creation
- SSH keys configured if using SSH


