# BB2GH (Bitbucket → GitHub Migration)

## How it works
- Clones all Bitbucket repositories as mirrors.
- (Optional) rewrites bot emails (@bots.bitbucket.org) to your GitHub email.
- Creates corresponding GitHub repositories.
- Pushes everything (branches, tags, commits) with `--mirror`.

## Files
- `config/config.psd1` → settings
- `config/repos.txt` → optional static list of repositories
- `src/git-functions.ps1` → PowerShell functions
- `main.ps1` → orchestrator

## Run
```powershell
pwsh -File C:\PROJECT\bb2gh\main.ps1


# Requirements
- PowerShell 7
- Git installed and in PATH
- (Optional) GitHub CLI gh for auto repo creation
- SSH keys configured if using SSH
