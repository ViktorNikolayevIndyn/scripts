#Requires -Version 5.1
<#
.SYNOPSIS
    Company Structure Generator - Konsolen-Version
    
.DESCRIPTION
    Erstellt automatisch die komplette Ordnerstruktur für InsideDynamic GmbH aus einer JSON-Konfiguration.
    Unterstützt OneDrive/SharePoint/lokale Pfade und erstellt README.md in jedem Ordner.
    
.PARAMETER JsonFile
    Pfad zur JSON-Konfigurationsdatei (Standard: structure.json)
    
.PARAMETER TargetPath
    Zielpfad für die Ordnerstruktur (Standard: aktuelles Verzeichnis)
    
.PARAMETER CreateReadme
    README.md in jedem Ordner erstellen (Standard: $true)
    
.PARAMETER CreateExamples
    .gitkeep Dateien erstellen (Standard: $true)
    
.PARAMETER Force
    Bestehende Dateien überschreiben ohne Rückfrage (Standard: $false)
    
.EXAMPLE
    .\create_structure.ps1
    
.EXAMPLE
    .\create_structure.ps1 -TargetPath "C:\Users\Viktor\OneDrive"
    
.EXAMPLE
    .\create_structure.ps1 -JsonFile "custom.json" -TargetPath "D:\Firmendokumente" -Force
    
.NOTES
    Author: Viktor Nikolayev
    Company: InsideDynamic GmbH
    Version: 1.0
    Date: 2024-12-26
#>

[CmdletBinding()]
param(
    [Parameter(Position=0)]
    [string]$JsonFile = "structure.json",
    
    [Parameter()]
    [string]$TargetPath = "",
    
    [Parameter()]
    [switch]$CreateReadme = $true,
    
    [Parameter()]
    [switch]$CreateExamples = $true,
    
    [Parameter()]
    [switch]$Force = $false
)

# Encoding auf UTF-8 setzen
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Statistik-Variablen
$script:Stats = @{
    FoldersCreated = 0
    FilesCreated = 0
    Errors = 0
}

#region Hilfsfunktionen

<#
.SYNOPSIS
    Erkennt automatisch OneDrive-Pfade
#>
function Get-OneDrivePath {
    [CmdletBinding()]
    param()
    
    # OneDrive Personal
    $oneDrivePersonal = [Environment]::GetEnvironmentVariable("OneDrive")
    if ($oneDrivePersonal -and (Test-Path $oneDrivePersonal)) {
        return $oneDrivePersonal
    }
    
    # OneDrive Business
    $oneDriveBusiness = [Environment]::GetEnvironmentVariable("OneDriveCommercial")
    if ($oneDriveBusiness -and (Test-Path $oneDriveBusiness)) {
        return $oneDriveBusiness
    }
    
    # Fallback: Suche im Benutzerprofil
    $userProfile = [Environment]::GetFolderPath('UserProfile')
    $possiblePaths = @(
        (Join-Path $userProfile "OneDrive"),
        (Join-Path $userProfile "OneDrive - InsideDynamic GmbH"),
        (Join-Path $userProfile "OneDrive - InsideDynamic")
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            return $path
        }
    }
    
    return $null
}

<#
.SYNOPSIS
    Gibt Header aus
#>
function Write-Header {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  🏢 Company Structure Generator" -ForegroundColor White
    Write-Host "  InsideDynamic GmbH" -ForegroundColor Gray
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
}

<#
.SYNOPSIS
    Erstellt einen Ordner mit README.md
#>
function New-CompanyFolder {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        
        [Parameter()]
        [string]$Description = ""
    )
    
    try {
        # Ordner erstellen
        if (-not (Test-Path $Path)) {
            $null = New-Item -Path $Path -ItemType Directory -Force
            $script:Stats.FoldersCreated++
            
            # Relativen Pfad für Anzeige berechnen
            if ($script:RootPath) {
                $relativePath = $Path.Replace($script:RootPath, "").TrimStart("\")
            } else {
                $relativePath = $Path
            }
            Write-Host "  📁 Erstelle: $relativePath" -ForegroundColor Green
        }
        
        # README.md erstellen
        if ($CreateReadme) {
            $readmePath = Join-Path $Path "README.md"
            if (-not (Test-Path $readmePath) -or $Force) {
                $folderName = Split-Path $Path -Leaf
                $readmeContent = @"
# $folderName

$Description

---

*Erstellt mit Company Structure Generator für InsideDynamic GmbH*
"@
                $readmeContent | Out-File -FilePath $readmePath -Encoding UTF8 -Force
                $script:Stats.FilesCreated++
            }
        }
        
        # .gitkeep erstellen
        if ($CreateExamples) {
            $gitkeepPath = Join-Path $Path ".gitkeep"
            if (-not (Test-Path $gitkeepPath) -or $Force) {
                $null = New-Item -Path $gitkeepPath -ItemType File -Force
                $script:Stats.FilesCreated++
            }
        }
        
    } catch {
        Write-Host "  ❌ Fehler bei $Path : $_" -ForegroundColor Red
        $script:Stats.Errors++
    }
}

<#
.SYNOPSIS
    Verarbeitet rekursiv die Ordnerstruktur
#>
function Process-FolderStructure {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Structure,
        
        [Parameter(Mandatory)]
        [string]$ParentPath
    )
    
    foreach ($folderName in $Structure.Keys) {
        $folderData = $Structure[$folderName]
        $folderPath = Join-Path $ParentPath $folderName
        
        # Beschreibung extrahieren
        $description = ""
        if ($folderData -is [hashtable] -and $folderData.ContainsKey('description')) {
            $description = $folderData['description']
        }
        
        # Ordner erstellen
        New-CompanyFolder -Path $folderPath -Description $description
        
        # Unterordner verarbeiten
        if ($folderData -is [hashtable] -and $folderData.ContainsKey('folders')) {
            Process-FolderStructure -Structure $folderData['folders'] -ParentPath $folderPath
        }
    }
}

<#
.SYNOPSIS
    Zeigt Fortschrittsbalken an
#>
function Show-Progress {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Activity,
        
        [Parameter(Mandatory)]
        [int]$Current,
        
        [Parameter(Mandatory)]
        [int]$Total
    )
    
    $percent = [math]::Round(($Current / $Total) * 100)
    Write-Progress -Activity $Activity -Status "$Current von $Total" -PercentComplete $percent
}

<#
.SYNOPSIS
    Gibt Statistik aus
#>
function Write-Statistics {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  📊 STATISTIK" -ForegroundColor White
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  ✅ Ordner erstellt:  $($script:Stats.FoldersCreated)" -ForegroundColor Green
    Write-Host "  ✅ Dateien erstellt: $($script:Stats.FilesCreated)" -ForegroundColor Green
    if ($script:Stats.Errors -gt 0) {
        Write-Host "  ❌ Fehler:           $($script:Stats.Errors)" -ForegroundColor Red
    }
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
}

#endregion

#region Hauptprogramm

try {
    # Header ausgeben
    Write-Header
    
    # JSON-Datei prüfen
    $jsonPath = $JsonFile
    if (-not [System.IO.Path]::IsPathRooted($jsonPath)) {
        $jsonPath = Join-Path $PSScriptRoot $jsonPath
    }
    
    if (-not (Test-Path $jsonPath)) {
        Write-Host "❌ Fehler: JSON-Datei nicht gefunden: $jsonPath" -ForegroundColor Red
        exit 1
    }
    
    # JSON laden
    Write-Host "📄 Lade Konfiguration: $jsonPath" -ForegroundColor Cyan
    $config = Get-Content -Path $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
    
    Write-Host "  ✅ Firma: $($config.company_name)" -ForegroundColor Green
    Write-Host "  ✅ Version: $($config.version)" -ForegroundColor Green
    Write-Host "  ✅ Beschreibung: $($config.description)" -ForegroundColor Green
    Write-Host ""
    
    # Zielpfad bestimmen
    if ([string]::IsNullOrEmpty($TargetPath)) {
        # OneDrive automatisch erkennen
        $oneDrivePath = Get-OneDrivePath
        if ($oneDrivePath) {
            Write-Host "💡 OneDrive erkannt: $oneDrivePath" -ForegroundColor Yellow
            $useOneDrive = Read-Host "Möchten Sie OneDrive verwenden? (J/N)"
            if ($useOneDrive -match '^[JjYy]$') {
                $TargetPath = $oneDrivePath
            }
        }
        
        # Falls nicht OneDrive, aktuelles Verzeichnis verwenden
        if ([string]::IsNullOrEmpty($TargetPath)) {
            $TargetPath = Get-Location
        }
    }
    
    # Vollständigen Pfad erstellen
    $script:RootPath = Join-Path $TargetPath $config.company_name
    
    Write-Host "📁 Zielordner: $script:RootPath" -ForegroundColor Cyan
    Write-Host ""
    
    # Bestätigung einholen
    if (Test-Path $script:RootPath) {
        Write-Host "⚠️  ACHTUNG: Ordner existiert bereits!" -ForegroundColor Yellow
        Write-Host "   Bestehende Dateien können überschrieben werden." -ForegroundColor Yellow
        Write-Host ""
    }
    
    if (-not $Force) {
        $confirm = Read-Host "Fortfahren? (J/N)"
        if ($confirm -notmatch '^[JjYy]$') {
            Write-Host "❌ Abgebrochen durch Benutzer." -ForegroundColor Red
            exit 0
        }
    }
    
    Write-Host ""
    Write-Host "🚀 Erstelle Ordnerstruktur..." -ForegroundColor Green
    Write-Host ""
    
    # Hauptordner erstellen
    if (-not (Test-Path $script:RootPath)) {
        $null = New-Item -Path $script:RootPath -ItemType Directory -Force
    }
    
    # Struktur konvertieren (PSCustomObject zu Hashtable)
    $structureHash = @{}
    foreach ($property in $config.structure.PSObject.Properties) {
        $structureHash[$property.Name] = @{}
        
        if ($property.Value.description) {
            $structureHash[$property.Name]['description'] = $property.Value.description
        }
        
        if ($property.Value.folders) {
            $foldersHash = @{}
            foreach ($folder in $property.Value.folders.PSObject.Properties) {
                $foldersHash[$folder.Name] = @{
                    'description' = $folder.Value.description
                }
            }
            $structureHash[$property.Name]['folders'] = $foldersHash
        }
    }
    
    # Struktur erstellen
    Process-FolderStructure -Structure $structureHash -ParentPath $script:RootPath
    
    # Statistik ausgeben
    Write-Statistics
    
    # Erfolgsmeldung
    if ($script:Stats.Errors -eq 0) {
        Write-Host "🎉 Ordnerstruktur erfolgreich erstellt!" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Ordnerstruktur mit Fehlern erstellt." -ForegroundColor Yellow
    }
    Write-Host "📁 Pfad: $script:RootPath" -ForegroundColor Cyan
    Write-Host ""
    
    # Explorer öffnen (optional)
    $openExplorer = Read-Host "Möchten Sie den Ordner im Explorer öffnen? (J/N)"
    if ($openExplorer -match '^[JjYy]$') {
        Start-Process explorer.exe $script:RootPath
    }
    
} catch {
    Write-Host ""
    Write-Host "❌ KRITISCHER FEHLER: $_" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}

#endregion
