#Requires -Version 5.1
<#
.SYNOPSIS
    Company Structure Generator - GUI-Version
    
.DESCRIPTION
    Grafische Benutzeroberfläche zum Erstellen der Ordnerstruktur für InsideDynamic GmbH.
    Verwendet Windows Forms für eine benutzerfreundliche Oberfläche mit Fortschrittsanzeige.
    
.NOTES
    Author: Viktor Nikolayev
    Company: InsideDynamic GmbH
    Version: 1.0
    Date: 2024-12-26
#>

# Windows Forms laden
try {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
} catch {
    Write-Host "❌ Fehler: Windows Forms konnte nicht geladen werden." -ForegroundColor Red
    Write-Host "   Stellen Sie sicher, dass .NET Framework installiert ist." -ForegroundColor Yellow
    Write-Host "   $_" -ForegroundColor Red
    exit 1
}

# Encoding auf UTF-8 setzen
$OutputEncoding = [System.Text.Encoding]::UTF8

# Globale Variablen
$script:Config = $null
$script:TargetPath = ""
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
    Fügt Nachricht zum Log hinzu
#>
function Add-LogMessage {
    param(
        [string]$Message,
        [string]$Type = "Info"
    )
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    
    # Farbe basierend auf Typ
    $color = switch ($Type) {
        "Success" { [System.Drawing.Color]::Green }
        "Error" { [System.Drawing.Color]::Red }
        "Warning" { [System.Drawing.Color]::Orange }
        default { [System.Drawing.Color]::Black }
    }
    
    # Nachricht hinzufügen
    $script:LogTextBox.SelectionStart = $script:LogTextBox.TextLength
    $script:LogTextBox.SelectionLength = 0
    $script:LogTextBox.SelectionColor = $color
    $script:LogTextBox.AppendText("$logMessage`r`n")
    $script:LogTextBox.SelectionColor = $script:LogTextBox.ForeColor
    $script:LogTextBox.ScrollToCaret()
    
    # UI aktualisieren
    [System.Windows.Forms.Application]::DoEvents()
}

<#
.SYNOPSIS
    Erstellt einen Ordner mit README.md
#>
function New-CompanyFolder {
    param(
        [string]$Path,
        [string]$Description = ""
    )
    
    try {
        # Ordner erstellen
        if (-not (Test-Path $Path)) {
            $null = New-Item -Path $Path -ItemType Directory -Force
            $script:Stats.FoldersCreated++
            
            # Relativen Pfad berechnen
            if ($script:RootPath) {
                $relativePath = $Path.Replace($script:RootPath, "").TrimStart("\")
            } else {
                $relativePath = $Path
            }
            Add-LogMessage "Erstelle Ordner: $relativePath" "Success"
        }
        
        # README.md erstellen
        $readmePath = Join-Path $Path "README.md"
        if (-not (Test-Path $readmePath)) {
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
        
        # .gitkeep erstellen
        $gitkeepPath = Join-Path $Path ".gitkeep"
        if (-not (Test-Path $gitkeepPath)) {
            $null = New-Item -Path $gitkeepPath -ItemType File -Force
            $script:Stats.FilesCreated++
        }
        
    } catch {
        Add-LogMessage "Fehler bei $Path : $_" "Error"
        $script:Stats.Errors++
    }
}

<#
.SYNOPSIS
    Verarbeitet rekursiv die Ordnerstruktur
#>
function Process-FolderStructure {
    param(
        [hashtable]$Structure,
        [string]$ParentPath
    )
    
    $totalFolders = $Structure.Keys.Count
    $currentFolder = 0
    
    foreach ($folderName in $Structure.Keys) {
        $currentFolder++
        $folderData = $Structure[$folderName]
        $folderPath = Join-Path $ParentPath $folderName
        
        # Fortschritt aktualisieren
        $percent = [math]::Round(($currentFolder / $totalFolders) * 100)
        $script:ProgressBar.Value = [math]::Min($percent, 100)
        $script:StatusLabel.Text = "Verarbeite: $folderName ($currentFolder/$totalFolders)"
        [System.Windows.Forms.Application]::DoEvents()
        
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

#endregion

#region GUI erstellen

# Hauptformular
$form = New-Object System.Windows.Forms.Form
$form.Text = "Company Structure Generator - InsideDynamic GmbH"
$form.Size = New-Object System.Drawing.Size(700, 600)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.MinimizeBox = $false

# Header Label
$headerLabel = New-Object System.Windows.Forms.Label
$headerLabel.Location = New-Object System.Drawing.Point(20, 20)
$headerLabel.Size = New-Object System.Drawing.Size(640, 40)
$headerLabel.Text = "🏢 Company Structure Generator`nAutomatische Erstellung der Firmenordnerstruktur"
$headerLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$headerLabel.TextAlign = "MiddleCenter"
$form.Controls.Add($headerLabel)

# JSON-Datei Gruppe
$jsonGroupBox = New-Object System.Windows.Forms.GroupBox
$jsonGroupBox.Location = New-Object System.Drawing.Point(20, 80)
$jsonGroupBox.Size = New-Object System.Drawing.Size(640, 60)
$jsonGroupBox.Text = "JSON-Konfigurationsdatei"
$form.Controls.Add($jsonGroupBox)

$jsonTextBox = New-Object System.Windows.Forms.TextBox
$jsonTextBox.Location = New-Object System.Drawing.Point(10, 25)
$jsonTextBox.Size = New-Object System.Drawing.Size(520, 25)
$jsonTextBox.Text = Join-Path $PSScriptRoot "structure.json"
$jsonGroupBox.Controls.Add($jsonTextBox)

$jsonBrowseButton = New-Object System.Windows.Forms.Button
$jsonBrowseButton.Location = New-Object System.Drawing.Point(540, 23)
$jsonBrowseButton.Size = New-Object System.Drawing.Size(80, 25)
$jsonBrowseButton.Text = "Durchsuchen"
$jsonGroupBox.Controls.Add($jsonBrowseButton)

# Zielpfad Gruppe
$targetGroupBox = New-Object System.Windows.Forms.GroupBox
$targetGroupBox.Location = New-Object System.Drawing.Point(20, 150)
$targetGroupBox.Size = New-Object System.Drawing.Size(640, 60)
$targetGroupBox.Text = "Zielordner"
$form.Controls.Add($targetGroupBox)

$targetTextBox = New-Object System.Windows.Forms.TextBox
$targetTextBox.Location = New-Object System.Drawing.Point(10, 25)
$targetTextBox.Size = New-Object System.Drawing.Size(520, 25)
# OneDrive automatisch erkennen
$oneDrivePath = Get-OneDrivePath
if ($oneDrivePath) {
    $targetTextBox.Text = $oneDrivePath
} else {
    $targetTextBox.Text = [Environment]::GetFolderPath('MyDocuments')
}
$targetGroupBox.Controls.Add($targetTextBox)

$targetBrowseButton = New-Object System.Windows.Forms.Button
$targetBrowseButton.Location = New-Object System.Drawing.Point(540, 23)
$targetBrowseButton.Size = New-Object System.Drawing.Size(80, 25)
$targetBrowseButton.Text = "Durchsuchen"
$targetGroupBox.Controls.Add($targetBrowseButton)

# Start Button
$startButton = New-Object System.Windows.Forms.Button
$startButton.Location = New-Object System.Drawing.Point(20, 220)
$startButton.Size = New-Object System.Drawing.Size(640, 35)
$startButton.Text = "🚀 Ordnerstruktur erstellen"
$startButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$startButton.BackColor = [System.Drawing.Color]::LightGreen
$form.Controls.Add($startButton)

# Fortschrittsbalken
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 270)
$progressBar.Size = New-Object System.Drawing.Size(640, 25)
$progressBar.Style = "Continuous"
$progressBar.Value = 0
$script:ProgressBar = $progressBar
$form.Controls.Add($progressBar)

# Status Label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(20, 300)
$statusLabel.Size = New-Object System.Drawing.Size(640, 20)
$statusLabel.Text = "Bereit zum Start..."
$script:StatusLabel = $statusLabel
$form.Controls.Add($statusLabel)

# Log TextBox
$logGroupBox = New-Object System.Windows.Forms.GroupBox
$logGroupBox.Location = New-Object System.Drawing.Point(20, 330)
$logGroupBox.Size = New-Object System.Drawing.Size(640, 180)
$logGroupBox.Text = "Protokoll"
$form.Controls.Add($logGroupBox)

$logTextBox = New-Object System.Windows.Forms.RichTextBox
$logTextBox.Location = New-Object System.Drawing.Point(10, 20)
$logTextBox.Size = New-Object System.Drawing.Size(620, 150)
$logTextBox.ReadOnly = $true
$logTextBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$logTextBox.BackColor = [System.Drawing.Color]::White
$script:LogTextBox = $logTextBox
$logGroupBox.Controls.Add($logTextBox)

# Close Button
$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Location = New-Object System.Drawing.Point(20, 520)
$closeButton.Size = New-Object System.Drawing.Size(640, 30)
$closeButton.Text = "Schließen"
$closeButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.Controls.Add($closeButton)

#endregion

#region Event Handlers

# JSON Durchsuchen Button
$jsonBrowseButton.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "JSON-Dateien (*.json)|*.json|Alle Dateien (*.*)|*.*"
    $openFileDialog.Title = "JSON-Konfigurationsdatei auswählen"
    $openFileDialog.InitialDirectory = $PSScriptRoot
    
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $jsonTextBox.Text = $openFileDialog.FileName
    }
})

# Target Durchsuchen Button
$targetBrowseButton.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Wählen Sie den Zielordner für die Struktur"
    $folderBrowser.SelectedPath = $targetTextBox.Text
    
    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $targetTextBox.Text = $folderBrowser.SelectedPath
    }
})

# Start Button
$startButton.Add_Click({
    try {
        # Buttons deaktivieren
        $startButton.Enabled = $false
        $jsonBrowseButton.Enabled = $false
        $targetBrowseButton.Enabled = $false
        
        # Log löschen
        $logTextBox.Clear()
        $progressBar.Value = 0
        
        # Statistik zurücksetzen
        $script:Stats = @{
            FoldersCreated = 0
            FilesCreated = 0
            Errors = 0
        }
        
        # JSON-Datei prüfen
        $jsonPath = $jsonTextBox.Text
        if (-not (Test-Path $jsonPath)) {
            [System.Windows.Forms.MessageBox]::Show(
                "JSON-Datei nicht gefunden: $jsonPath",
                "Fehler",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
            return
        }
        
        Add-LogMessage "Lade Konfiguration: $jsonPath" "Info"
        
        # JSON laden
        try {
            $script:Config = Get-Content -Path $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
        } catch {
            Add-LogMessage "Fehler beim Laden der JSON-Datei: $_" "Error"
            [System.Windows.Forms.MessageBox]::Show(
                "JSON-Datei konnte nicht geladen werden:`n`n$_",
                "Fehler",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
            return
        }
        
        Add-LogMessage "Firma: $($script:Config.company_name)" "Success"
        Add-LogMessage "Version: $($script:Config.version)" "Success"
        Add-LogMessage "Beschreibung: $($script:Config.description)" "Success"
        
        # Zielpfad bestimmen
        $targetBase = $targetTextBox.Text
        $script:RootPath = Join-Path $targetBase $script:Config.company_name
        
        Add-LogMessage "Zielordner: $script:RootPath" "Info"
        
        # Bestätigung bei existierendem Ordner
        if (Test-Path $script:RootPath) {
            $result = [System.Windows.Forms.MessageBox]::Show(
                "Der Ordner existiert bereits:`n$script:RootPath`n`nMöchten Sie fortfahren?",
                "Warnung",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )
            
            if ($result -eq [System.Windows.Forms.DialogResult]::No) {
                Add-LogMessage "Abgebrochen durch Benutzer" "Warning"
                return
            }
        }
        
        Add-LogMessage "Starte Erstellung der Ordnerstruktur..." "Info"
        $statusLabel.Text = "Erstelle Ordnerstruktur..."
        
        # Hauptordner erstellen
        if (-not (Test-Path $script:RootPath)) {
            $null = New-Item -Path $script:RootPath -ItemType Directory -Force
        }
        
        # Struktur konvertieren
        $structureHash = @{}
        foreach ($property in $script:Config.structure.PSObject.Properties) {
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
        
        # Fortschritt auf 100% setzen
        $progressBar.Value = 100
        $statusLabel.Text = "Fertig!"
        
        # Statistik ausgeben
        Add-LogMessage "═══════════════════════════════════════" "Info"
        Add-LogMessage "STATISTIK:" "Info"
        Add-LogMessage "Ordner erstellt: $($script:Stats.FoldersCreated)" "Success"
        Add-LogMessage "Dateien erstellt: $($script:Stats.FilesCreated)" "Success"
        
        if ($script:Stats.Errors -gt 0) {
            Add-LogMessage "Fehler: $($script:Stats.Errors)" "Error"
        }
        
        Add-LogMessage "═══════════════════════════════════════" "Info"
        
        # Erfolgsmeldung
        if ($script:Stats.Errors -eq 0) {
            Add-LogMessage "Ordnerstruktur erfolgreich erstellt!" "Success"
            
            $result = [System.Windows.Forms.MessageBox]::Show(
                "Ordnerstruktur erfolgreich erstellt!`n`n$script:RootPath`n`nMöchten Sie den Ordner im Explorer öffnen?",
                "Erfolg",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Information
            )
            
            if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
                Start-Process explorer.exe $script:RootPath
            }
        } else {
            Add-LogMessage "Ordnerstruktur mit Fehlern erstellt" "Warning"
            
            [System.Windows.Forms.MessageBox]::Show(
                "Ordnerstruktur mit $($script:Stats.Errors) Fehler(n) erstellt.`n`nBitte prüfen Sie das Protokoll.",
                "Warnung",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )
        }
        
    } catch {
        Add-LogMessage "KRITISCHER FEHLER: $_" "Error"
        
        [System.Windows.Forms.MessageBox]::Show(
            "Kritischer Fehler beim Erstellen der Struktur:`n`n$_",
            "Fehler",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
    } finally {
        # Buttons wieder aktivieren
        $startButton.Enabled = $true
        $jsonBrowseButton.Enabled = $true
        $targetBrowseButton.Enabled = $true
    }
})

#endregion

# Formular anzeigen
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()
