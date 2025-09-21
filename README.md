# Work & Business Helper Scripts

This repository collects small, pragmatic scripts we use to automate day-to-day work and business tasks.  
Each tool lives in its own subfolder and is self-contained. Typical use cases include document distribution,
file housekeeping, lightweight reporting, and small data transformations.

## Folders
- `/jost_script` — Mail automation via Microsoft Graph (collect PDFs per company, send emails, then move files to `DONE/`).

> Every subfolder has (or should have) its own README with setup and usage details.

## Quick Start
1. Open a subfolder.
2. Read its README.
3. Run from PowerShell (most tools expose `main.ps1`, e.g. `.\main.ps1 -DryRun`).

## Requirements
- PowerShell 5.1+ or PowerShell 7+
- Any script-specific dependencies are documented in the subfolder README.

## Security
- Provide secrets via environment variables or a local `.env` (not committed).
- Never commit credentials, tokens, or private data to the repository.
