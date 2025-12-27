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
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic

# Encoding auf UTF-8 mit BOM setzen (wichtig für Windows Forms)
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

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
    Speichert die aktuelle TreeView-Struktur in eine JSON-Datei
.PARAMETER FilePath
    Der vollständige Pfad zur Ziel-JSON-Datei
.PARAMETER TreeView
    Die TreeView-Control mit der zu speichernden Struktur
.PARAMETER StatusLabel
    Optional: Label für Status-Updates
.RETURNS
    $true bei Erfolg, $false bei Fehler
#>
function Save-StructureToFile {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath,
        
        [Parameter(Mandatory=$true)]
        [System.Windows.Forms.TreeView]$TreeView,
        
        [Parameter(Mandatory=$false)]
        [System.Windows.Forms.Label]$StatusLabel,
        
        [Parameter(Mandatory=$false)]
        [System.Windows.Forms.CheckBox]$ReadmeCheckBox,
        
        [Parameter(Mandatory=$false)]
        [System.Windows.Forms.CheckBox]$GitkeepCheckBox,
        
        [Parameter(Mandatory=$false)]
        [System.Windows.Forms.CheckBox]$WindowsPropsCheckBox,
        
        [Parameter(Mandatory=$false)]
        [System.Windows.Forms.CheckBox]$DesktopIniCheckBox
    )
    
    try {
        # Struktur aus TreeView rekonstruieren - [ordered] für Reihenfolge
        $newStructure = [ordered]@{}
        $rootNode = $TreeView.Nodes[0]
        
        foreach ($node in $rootNode.Nodes) {
            $folderName = $node.Tag.Name
            $folderDesc = $node.Tag.Description
            
            $folderData = [ordered]@{
                description = $folderDesc
            }
            
            # Aktiv-Status speichern (nur wenn false)
            if (-not $node.Checked) {
                $folderData['enabled'] = $false
            }
            
            # Export-Optionen nur speichern wenn true
            if ($node.Tag.ContainsKey('CreateReadme') -and $node.Tag.CreateReadme) {
                $folderData['create_readme'] = $true
            }
            if ($node.Tag.ContainsKey('CreateGitkeep') -and $node.Tag.CreateGitkeep) {
                $folderData['create_gitkeep'] = $true
            }
            if ($node.Tag.ContainsKey('CreateWindowsProps') -and $node.Tag.CreateWindowsProps) {
                $folderData['create_windows_props'] = $true
            }
            if ($node.Tag.ContainsKey('CreateDesktopIni') -and $node.Tag.CreateDesktopIni) {
                $folderData['create_desktop_ini'] = $true
            }
            
            $newStructure[$folderName] = $folderData
            
            if ($node.Nodes.Count -gt 0) {
                $subFolders = [ordered]@{}
                foreach ($subNode in $node.Nodes) {
                    $subName = $subNode.Tag.Name
                    $subDesc = $subNode.Tag.Description
                    
                    $subFolderData = [ordered]@{
                        description = $subDesc
                    }
                    
                    # Aktiv-Status für Unterordner
                    if (-not $subNode.Checked) {
                        $subFolderData['enabled'] = $false
                    }
                    
                    # Export-Optionen für Unterordner
                    if ($subNode.Tag.ContainsKey('CreateReadme') -and $subNode.Tag.CreateReadme) {
                        $subFolderData['create_readme'] = $true
                    }
                    if ($subNode.Tag.ContainsKey('CreateGitkeep') -and $subNode.Tag.CreateGitkeep) {
                        $subFolderData['create_gitkeep'] = $true
                    }
                    if ($subNode.Tag.ContainsKey('CreateWindowsProps') -and $subNode.Tag.CreateWindowsProps) {
                        $subFolderData['create_windows_props'] = $true
                    }
                    if ($subNode.Tag.ContainsKey('CreateDesktopIni') -and $subNode.Tag.CreateDesktopIni) {
                        $subFolderData['create_desktop_ini'] = $true
                    }
                    
                    $subFolders[$subName] = $subFolderData
                }
                $newStructure[$folderName]['folders'] = $subFolders
            }
        }
        
        # Config aktualisieren
        $script:EditorConfig.structure = [PSCustomObject]$newStructure
        
        # Export-Optionen Default-Werte speichern
        if ($ReadmeCheckBox) {
            $script:EditorConfig | Add-Member -NotePropertyName 'default_create_readme' -NotePropertyValue $ReadmeCheckBox.Checked -Force
        }
        if ($GitkeepCheckBox) {
            $script:EditorConfig | Add-Member -NotePropertyName 'default_create_gitkeep' -NotePropertyValue $GitkeepCheckBox.Checked -Force
        }
        if ($WindowsPropsCheckBox) {
            $script:EditorConfig | Add-Member -NotePropertyName 'default_create_windows_props' -NotePropertyValue $WindowsPropsCheckBox.Checked -Force
        }
        if ($DesktopIniCheckBox) {
            $script:EditorConfig | Add-Member -NotePropertyName 'default_create_desktop_ini' -NotePropertyValue $DesktopIniCheckBox.Checked -Force
        }
        
        # Als JSON speichern
        $jsonOutput = $script:EditorConfig | ConvertTo-Json -Depth 10
        $jsonOutput | Out-File -FilePath $FilePath -Encoding UTF8 -Force
        
        # Status aktualisieren
        if ($StatusLabel) {
            $statusLabel.Text = "✓ Gespeichert: $(Get-Date -Format 'HH:mm:ss')"
            $statusLabel.BackColor = [System.Drawing.Color]::LightGreen
        }
        
        return $true
        
    } catch {
        # Status aktualisieren
        if ($StatusLabel) {
            $StatusLabel.Text = "✗ Fehler beim Speichern"
            $StatusLabel.BackColor = [System.Drawing.Color]::LightCoral
        }
        
        throw $_
    }
}

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
        [string]$Description = "",
        [bool]$CreateReadme = $false,
        [bool]$CreateGitkeep = $false,
        [bool]$CreateWindowsProps = $false,
        [bool]$CreateDesktopIni = $false
    )
    
    try {
        # Ordner erstellen
        if (-not (Test-Path $Path)) {
            $null = New-Item -Path $Path -ItemType Directory -Force
            $script:Stats.FoldersCreated++
            
            # Relativen Pfad berechnen
            $relativePath = $Path.Replace($script:RootPath, "").TrimStart("\")
            Add-LogMessage "Erstelle Ordner: $relativePath" "Success"
        }
        
        # README.md erstellen (nur wenn aktiviert)
        if ($CreateReadme) {
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
        }
        
        # .gitkeep erstellen (nur wenn aktiviert)
        if ($CreateGitkeep) {
            $gitkeepPath = Join-Path $Path ".gitkeep"
            if (-not (Test-Path $gitkeepPath)) {
                $null = New-Item -Path $gitkeepPath -ItemType File -Force
                $script:Stats.FilesCreated++
            }
        }
        
        # desktop.ini erstellen (nur wenn aktiviert)
        if ($CreateDesktopIni) {
            $desktopIniPath = Join-Path $Path "desktop.ini"
            if (-not (Test-Path $desktopIniPath)) {
                $folderName = Split-Path $Path -Leaf
                $desktopIniContent = @"
[.ShellClassInfo]
InfoTip=$Description
IconResource=%SystemRoot%\system32\SHELL32.dll,4
"@
                $desktopIniContent | Out-File -FilePath $desktopIniPath -Encoding UTF8 -Force
                # Desktop.ini als System- und versteckte Datei markieren
                $fileItem = Get-Item $desktopIniPath -Force
                $fileItem.Attributes = 'Hidden,System'
                $script:Stats.FilesCreated++
            }
        }
        
        # Windows Properties setzen (nur wenn aktiviert)
        if ($CreateWindowsProps) {
            # Ordner-Attribute setzen
            $folderItem = Get-Item $Path -Force
            # Beschreibung als Kommentar setzen (falls möglich)
            # Dies ist Windows-spezifisch und erfordert COM-Objekte
        }
        
    } catch {
        Add-LogMessage "Fehler bei $Path : $_" "Error"
        $script:Stats.Errors++
    }
}

<#
.SYNOPSIS
    Öffnet visuellen Struktur-Editor
#>
function Open-StructureEditor {
    param(
        [string]$JsonPath
    )
    
    if (-not (Test-Path $JsonPath)) {
        [System.Windows.Forms.MessageBox]::Show(
            "JSON-Datei nicht gefunden: $JsonPath",
            "Fehler",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
        return
    }
    
    # Editor-Form erstellen
    $editorForm = New-Object System.Windows.Forms.Form
    $editorForm.Text = "📁 Struktur-Editor - $(Split-Path $JsonPath -Leaf)"
    $editorForm.Size = New-Object System.Drawing.Size(850, 580)
    $editorForm.StartPosition = "CenterScreen"
    $editorForm.MinimizeBox = $true
    $editorForm.MaximizeBox = $true
    
    # JSON laden
    try {
        $jsonContent = Get-Content -Path $JsonPath -Raw -Encoding UTF8
        $script:EditorConfig = $jsonContent | ConvertFrom-Json
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Fehler beim Laden der JSON-Datei: $_",
            "Fehler",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
        return
    }
    
    # Toolbar Panel (внизу вместо вверху)
    $toolbarPanel = New-Object System.Windows.Forms.Panel
    $toolbarPanel.Dock = "Bottom"
    $toolbarPanel.Height = 45
    $toolbarPanel.BackColor = [System.Drawing.Color]::WhiteSmoke
    $editorForm.Controls.Add($toolbarPanel)
    
    # Speichern Button
    $saveButton = New-Object System.Windows.Forms.Button
    $saveButton.Location = New-Object System.Drawing.Point(10, 7)
    $saveButton.Size = New-Object System.Drawing.Size(120, 30)
    $saveButton.Text = "💾 Speichern"
    $saveButton.BackColor = [System.Drawing.Color]::LightGreen
    $toolbarPanel.Controls.Add($saveButton)
    
    # Speichern Als Button
    $saveAsButton = New-Object System.Windows.Forms.Button
    $saveAsButton.Location = New-Object System.Drawing.Point(140, 7)
    $saveAsButton.Size = New-Object System.Drawing.Size(150, 30)
    $saveAsButton.Text = "💾 Als Vorlage..."
    $toolbarPanel.Controls.Add($saveAsButton)
    
    # Neuer Ordner Button
    $addButton = New-Object System.Windows.Forms.Button
    $addButton.Location = New-Object System.Drawing.Point(300, 7)
    $addButton.Size = New-Object System.Drawing.Size(120, 30)
    $addButton.Text = "➕ Ordner"
    $toolbarPanel.Controls.Add($addButton)
    
    # Bearbeiten Button
    $editButton = New-Object System.Windows.Forms.Button
    $editButton.Location = New-Object System.Drawing.Point(430, 7)
    $editButton.Size = New-Object System.Drawing.Size(120, 30)
    $editButton.Text = "✏️ Bearbeiten"
    $toolbarPanel.Controls.Add($editButton)
    
    # Löschen Button
    $deleteButton = New-Object System.Windows.Forms.Button
    $deleteButton.Location = New-Object System.Drawing.Point(560, 7)
    $deleteButton.Size = New-Object System.Drawing.Size(100, 30)
    $deleteButton.Text = "🗑️ Löschen"
    $toolbarPanel.Controls.Add($deleteButton)
    
    # Nach oben Button
    $moveUpButton = New-Object System.Windows.Forms.Button
    $moveUpButton.Location = New-Object System.Drawing.Point(670, 7)
    $moveUpButton.Size = New-Object System.Drawing.Size(70, 30)
    $moveUpButton.Text = "↑ Hoch"
    $toolbarPanel.Controls.Add($moveUpButton)
    
    # Nach unten Button
    $moveDownButton = New-Object System.Windows.Forms.Button
    $moveDownButton.Location = New-Object System.Drawing.Point(745, 7)
    $moveDownButton.Size = New-Object System.Drawing.Size(70, 30)
    $moveDownButton.Text = "↓ Runter"
    $toolbarPanel.Controls.Add($moveDownButton)
    
    # TreeView для Struktur (Vollbild)
    $treeView = New-Object System.Windows.Forms.TreeView
    $treeView.Dock = "Fill"
    $treeView.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $treeView.CheckBoxes = $true
    $treeView.HideSelection = $false
    $treeView.Scrollable = $true
    $treeView.Padding = New-Object System.Windows.Forms.Padding(0, 0, 0, 20)
    $editorForm.Controls.Add($treeView)
    
    # Export-Optionen GroupBox
    $optionsGroup = New-Object System.Windows.Forms.GroupBox
    $optionsGroup.Text = "⚙️ Export-Optionen"
    $optionsGroup.Dock = "Bottom"
    $optionsGroup.Height = 50
    $editorForm.Controls.Add($optionsGroup)
    
    # Sortierung mit Index Checkbox (nur für Anzeige)
    $sortIndexCheck = New-Object System.Windows.Forms.CheckBox
    $sortIndexCheck.Text = "Index anzeigen (00_, 01_...)"
    $sortIndexCheck.Location = New-Object System.Drawing.Point(10, 18)
    $sortIndexCheck.Size = New-Object System.Drawing.Size(200, 18)
    $sortIndexCheck.Checked = $true
    $optionsGroup.Controls.Add($sortIndexCheck)
    
    # README.md Checkbox
    $readmeCheck = New-Object System.Windows.Forms.CheckBox
    $readmeCheck.Text = "README.md"
    $readmeCheck.Location = New-Object System.Drawing.Point(220, 18)
    $readmeCheck.Size = New-Object System.Drawing.Size(110, 18)
    $readmeCheck.Checked = $true
    $optionsGroup.Controls.Add($readmeCheck)
    
    # .gitkeep Checkbox
    $gitkeepCheck = New-Object System.Windows.Forms.CheckBox
    $gitkeepCheck.Text = ".gitkeep"
    $gitkeepCheck.Location = New-Object System.Drawing.Point(340, 18)
    $gitkeepCheck.Size = New-Object System.Drawing.Size(90, 18)
    $gitkeepCheck.Checked = $true
    $optionsGroup.Controls.Add($gitkeepCheck)
    
    # Beschreibung in Ordner-Eigenschaften Checkbox
    $folderPropsCheck = New-Object System.Windows.Forms.CheckBox
    $folderPropsCheck.Text = "Windows-Props"
    $folderPropsCheck.Location = New-Object System.Drawing.Point(440, 18)
    $folderPropsCheck.Size = New-Object System.Drawing.Size(130, 18)
    $folderPropsCheck.Checked = $false
    $optionsGroup.Controls.Add($folderPropsCheck)
    
    # Beschreibung in desktop.ini Checkbox
    $desktopIniCheck = New-Object System.Windows.Forms.CheckBox
    $desktopIniCheck.Text = "desktop.ini"
    $desktopIniCheck.Location = New-Object System.Drawing.Point(580, 18)
    $desktopIniCheck.Size = New-Object System.Drawing.Size(100, 18)
    $desktopIniCheck.Checked = $false
    $optionsGroup.Controls.Add($desktopIniCheck)
    
    # Status Label
    $statusLabel = New-Object System.Windows.Forms.Label
    $statusLabel.Text = "Bereit"
    $statusLabel.Dock = "Bottom"
    $statusLabel.Height = 25
    $statusLabel.BackColor = [System.Drawing.Color]::WhiteSmoke
    $statusLabel.BorderStyle = "Fixed3D"
    $statusLabel.TextAlign = "MiddleLeft"
    $statusLabel.Padding = New-Object System.Windows.Forms.Padding(5, 0, 0, 0)
    $editorForm.Controls.Add($statusLabel)
    
    # Funktion: TreeView füllen
    function Fill-TreeView {
        $treeView.Nodes.Clear()
        
        # Export-Optionen Default-Werte laden
        if ($script:EditorConfig.PSObject.Properties['default_create_readme']) {
            $readmeCheck.Checked = $script:EditorConfig.default_create_readme
        } else {
            $readmeCheck.Checked = $true
        }
        
        if ($script:EditorConfig.PSObject.Properties['default_create_gitkeep']) {
            $gitkeepCheck.Checked = $script:EditorConfig.default_create_gitkeep
        } else {
            $gitkeepCheck.Checked = $true
        }
        
        if ($script:EditorConfig.PSObject.Properties['default_create_windows_props']) {
            $folderPropsCheck.Checked = $script:EditorConfig.default_create_windows_props
        } else {
            $folderPropsCheck.Checked = $false
        }
        
        if ($script:EditorConfig.PSObject.Properties['default_create_desktop_ini']) {
            $desktopIniCheck.Checked = $script:EditorConfig.default_create_desktop_ini
        } else {
            $desktopIniCheck.Checked = $false
        }
        
        # Root Node
        $rootNode = New-Object System.Windows.Forms.TreeNode
        $rootNode.Text = $script:EditorConfig.company_name
        $rootNode.Tag = @{
            Type = "Root"
            Name = $script:EditorConfig.company_name
            Description = $script:EditorConfig.description
        }
        $rootNode.Checked = $true
        $treeView.Nodes.Add($rootNode) | Out-Null
        
        # Struktur durchlaufen
        foreach ($prop in $script:EditorConfig.structure.PSObject.Properties) {
            $folderName = $prop.Name
            $folderData = $prop.Value
            
            $node = New-Object System.Windows.Forms.TreeNode
            $node.Text = "$folderName"
            if ($folderData.description) {
                $node.ToolTipText = $folderData.description
            }
            $node.Tag = @{
                Type = "Folder"
                Name = $folderName
                Description = $folderData.description
                ParentPath = ""
            }
            # Checked-Status aus JSON laden (default = true)
            $node.Checked = if ($folderData.PSObject.Properties['enabled']) { $folderData.enabled } else { $true }
            $rootNode.Nodes.Add($node) | Out-Null
            
            # Unterordner
            if ($folderData.folders) {
                foreach ($subProp in $folderData.folders.PSObject.Properties) {
                    $subName = $subProp.Name
                    $subData = $subProp.Value
                    
                    $subNode = New-Object System.Windows.Forms.TreeNode
                    $subNode.Text = "$subName"
                    if ($subData.description) {
                        $subNode.ToolTipText = $subData.description
                    }
                    $subNode.Tag = @{
                        Type = "SubFolder"
                        Name = $subName
                        Description = $subData.description
                        ParentPath = $folderName
                    }
                    # Checked-Status für Unterordner aus JSON laden
                    $subNode.Checked = if ($subData.PSObject.Properties['enabled']) { $subData.enabled } else { $true }
                    $node.Nodes.Add($subNode) | Out-Null
                }
            }
        }
        
        $rootNode.Expand()
    }
    
    # Funktion: Indices neu vergeben (всегда в данных, опционально в отображении)
    function Update-NodeIndices {
        param($ParentNode)
        
        if (-not $ParentNode -or $ParentNode.Nodes.Count -eq 0) {
            return
        }
        
        for ($i = 0; $i -lt $ParentNode.Nodes.Count; $i++) {
            $node = $ParentNode.Nodes[$i]
            $baseName = $node.Tag.Name -replace '^\d+_', ''
            $newName = "{0:D2}_{1}" -f $i, $baseName
            $node.Tag.Name = $newName
            
            # Text je nach Checkbox: mit oder ohne Index
            if ($sortIndexCheck.Checked) {
                $node.Text = $newName
            } else {
                $node.Text = $baseName
            }
        }
    }
    
    # Funktion: Alle Indices aktualisieren (rekursiv)
    function Update-AllIndices {
        param($ParentNode)
        
        if (-not $ParentNode) {
            return
        }
        
        # Kinder des aktuellen Nodes aktualisieren
        Update-NodeIndices -ParentNode $ParentNode
        
        # Rekursiv für alle Kinder
        foreach ($child in $ParentNode.Nodes) {
            if ($child.Nodes.Count -gt 0) {
                Update-AllIndices -ParentNode $child
            }
        }
    }
    
    # TreeView füllen
    Fill-TreeView
    
    # Event: Index Anzeige umschalten
    $sortIndexCheck.Add_CheckedChanged({
        if ($treeView.Nodes.Count -gt 0) {
            $rootNode = $treeView.Nodes[0]
            
            # Alle Nodes durchgehen und Text aktualisieren
            foreach ($node in $rootNode.Nodes) {
                $baseName = $node.Tag.Name -replace '^\d+_', ''
                if ($sortIndexCheck.Checked) {
                    $node.Text = $node.Tag.Name  # Mit Index
                } else {
                    $node.Text = $baseName  # Ohne Index
                }
                
                # Unterordner
                foreach ($subNode in $node.Nodes) {
                    $subBaseName = $subNode.Tag.Name -replace '^\d+_', ''
                    if ($sortIndexCheck.Checked) {
                        $subNode.Text = $subNode.Tag.Name
                    } else {
                        $subNode.Text = $subBaseName
                    }
                }
            }
            
            $statusLabel.Text = if ($sortIndexCheck.Checked) { "✓ Indices angezeigt" } else { "✓ Indices ausgeblendet" }
            $statusLabel.BackColor = [System.Drawing.Color]::LightGreen
        }
    })
    
    # Funktion: Root-Dialog öffnen
    function Open-RootDialog {
        # Dialog erstellen
        $dialogForm = New-Object System.Windows.Forms.Form
        $dialogForm.Text = "Firmennamen bearbeiten"
        $dialogForm.Size = New-Object System.Drawing.Size(420, 250)
        $dialogForm.StartPosition = "CenterScreen"
        $dialogForm.FormBorderStyle = "FixedDialog"
        $dialogForm.MaximizeBox = $false
        $dialogForm.MinimizeBox = $false
        
        # Panel für Inhalt
        $dialogPanel = New-Object System.Windows.Forms.Panel
        $dialogPanel.Location = New-Object System.Drawing.Point(0, 0)
        $dialogPanel.Size = New-Object System.Drawing.Size(400, 150)
        $dialogForm.Controls.Add($dialogPanel)
        
        $yPos = 15
        
        # Name Label
        $nameLabel = New-Object System.Windows.Forms.Label
        $nameLabel.Text = "Firmenname (Root-Ordner):"
        $nameLabel.Location = New-Object System.Drawing.Point(10, $yPos)
        $nameLabel.Size = New-Object System.Drawing.Size(360, 20)
        $dialogPanel.Controls.Add($nameLabel)
        $yPos += 20
        
        # Name Input
        $nameInput = New-Object System.Windows.Forms.TextBox
        $nameInput.Text = $script:EditorConfig.company_name
        $nameInput.Location = New-Object System.Drawing.Point(10, $yPos)
        $nameInput.Size = New-Object System.Drawing.Size(360, 22)
        $dialogPanel.Controls.Add($nameInput)
        $yPos += 30
        
        # Beschreibung Label
        $descLabel = New-Object System.Windows.Forms.Label
        $descLabel.Text = "Beschreibung:"
        $descLabel.Location = New-Object System.Drawing.Point(10, $yPos)
        $descLabel.Size = New-Object System.Drawing.Size(360, 20)
        $dialogPanel.Controls.Add($descLabel)
        $yPos += 20
        
        # Beschreibung Input
        $descInput = New-Object System.Windows.Forms.TextBox
        $descInput.Text = $script:EditorConfig.description
        $descInput.Location = New-Object System.Drawing.Point(10, $yPos)
        $descInput.Size = New-Object System.Drawing.Size(360, 60)
        $descInput.Multiline = $true
        $descInput.ScrollBars = "Vertical"
        $dialogPanel.Controls.Add($descInput)
        
        # Button Panel
        $buttonPanel = New-Object System.Windows.Forms.Panel
        $buttonPanel.Location = New-Object System.Drawing.Point(0, 160)
        $buttonPanel.Size = New-Object System.Drawing.Size(400, 50)
        $buttonPanel.Dock = "Bottom"
        $dialogForm.Controls.Add($buttonPanel)
        
        # OK Button
        $okButton = New-Object System.Windows.Forms.Button
        $okButton.Text = "OK"
        $okButton.Location = New-Object System.Drawing.Point(150, 10)
        $okButton.Size = New-Object System.Drawing.Size(100, 30)
        $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $buttonPanel.Controls.Add($okButton)
        
        # Abbrechen Button
        $cancelButton = New-Object System.Windows.Forms.Button
        $cancelButton.Text = "Abbrechen"
        $cancelButton.Location = New-Object System.Drawing.Point(260, 10)
        $cancelButton.Size = New-Object System.Drawing.Size(100, 30)
        $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $buttonPanel.Controls.Add($cancelButton)
        
        $dialogForm.AcceptButton = $okButton
        $dialogForm.CancelButton = $cancelButton
        
        # Dialog anzeigen
        $result = $dialogForm.ShowDialog()
        
        if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
            $newName = $nameInput.Text.Trim()
            $newDesc = $descInput.Text.Trim()
            
            if ([string]::IsNullOrWhiteSpace($newName)) {
                [System.Windows.Forms.MessageBox]::Show(
                    "Bitte geben Sie einen Firmennamen ein.",
                    "Fehler",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Warning
                )
                return
            }
            
            # Config aktualisieren
            $script:EditorConfig.company_name = $newName
            $script:EditorConfig.description = $newDesc
            
            # TreeView aktualisieren
            $rootNode = $treeView.Nodes[0]
            $rootNode.Text = $newName
            $rootNode.Tag.Name = $newName
            $rootNode.Tag.Description = $newDesc
            $rootNode.ToolTipText = $newDesc
            
            $statusLabel.Text = "✓ Firmenname aktualisiert: $newName"
            $statusLabel.BackColor = [System.Drawing.Color]::LightGreen
        }
        
        $dialogForm.Dispose()
    }
    
    # Funktion: Ordner-Dialog öffnen
    function Open-FolderDialog {
        param(
            [System.Windows.Forms.TreeNode]$NodeToEdit = $null,
            [bool]$IsEditMode = $false
        )
        
        # Dialog erstellen
        $dialogForm = New-Object System.Windows.Forms.Form
        $dialogForm.Text = if ($IsEditMode) { "Ordner bearbeiten" } else { "Neuen Ordner erstellen" }
        $dialogForm.Size = New-Object System.Drawing.Size(420, 480)
        $dialogForm.StartPosition = "CenterParent"
        $dialogForm.FormBorderStyle = "FixedDialog"
        $dialogForm.MaximizeBox = $false
        $dialogForm.MinimizeBox = $false
        
        # Panel mit Scrolling
        $dialogPanel = New-Object System.Windows.Forms.Panel
        $dialogPanel.Location = New-Object System.Drawing.Point(0, 0)
        $dialogPanel.Size = New-Object System.Drawing.Size(400, 400)
        $dialogPanel.AutoScroll = $true
        $dialogForm.Controls.Add($dialogPanel)
        
        $yPos = 15
        
        # Parent Label/Display (nur für Create-Modus)
        if (-not $IsEditMode) {
            $selectedNode = $treeView.SelectedNode
            if (-not $selectedNode) {
                $selectedNode = $treeView.Nodes[0]
            }
            
            $parentLabel = New-Object System.Windows.Forms.Label
            $parentLabel.Text = "Übergeordneter Ordner:"
            $parentLabel.Location = New-Object System.Drawing.Point(10, $yPos)
            $parentLabel.Size = New-Object System.Drawing.Size(360, 20)
            $dialogPanel.Controls.Add($parentLabel)
            $yPos += 20
            
            $parentDisplay = New-Object System.Windows.Forms.TextBox
            $parentDisplay.Text = $selectedNode.Tag.Name
            $parentDisplay.Location = New-Object System.Drawing.Point(10, $yPos)
            $parentDisplay.Size = New-Object System.Drawing.Size(360, 22)
            $parentDisplay.ReadOnly = $true
            $parentDisplay.BackColor = [System.Drawing.Color]::WhiteSmoke
            $dialogPanel.Controls.Add($parentDisplay)
            $yPos += 27
            
            $rootCheck = New-Object System.Windows.Forms.CheckBox
            $rootCheck.Text = "In Wurzel erstellen (Root)"
            $rootCheck.Location = New-Object System.Drawing.Point(10, $yPos)
            $rootCheck.Size = New-Object System.Drawing.Size(200, 20)
            $dialogPanel.Controls.Add($rootCheck)
            $yPos += 28
            
            $rootCheck.Add_CheckedChanged({
                if ($rootCheck.Checked) {
                    $parentDisplay.Text = $treeView.Nodes[0].Tag.Name + " (Wurzel)"
                } else {
                    $parentDisplay.Text = $selectedNode.Tag.Name
                }
            })
        }
        
        # Name Label
        $nameLabel = New-Object System.Windows.Forms.Label
        $nameLabel.Text = "Ordnername:"
        $nameLabel.Location = New-Object System.Drawing.Point(10, $yPos)
        $nameLabel.Size = New-Object System.Drawing.Size(360, 20)
        $dialogPanel.Controls.Add($nameLabel)
        $yPos += 20
        
        # Name Input
        $nameInput = New-Object System.Windows.Forms.TextBox
        $nameInput.Text = if ($IsEditMode) { ($NodeToEdit.Tag.Name -replace '^\d+_', '') } else { "Neuer_Ordner" }
        $nameInput.Location = New-Object System.Drawing.Point(10, $yPos)
        $nameInput.Size = New-Object System.Drawing.Size(360, 22)
        $dialogPanel.Controls.Add($nameInput)
        $yPos += 30
        
        # Beschreibung Label
        $descDialogLabel = New-Object System.Windows.Forms.Label
        $descDialogLabel.Text = "Beschreibung:"
        $descDialogLabel.Location = New-Object System.Drawing.Point(10, $yPos)
        $descDialogLabel.Size = New-Object System.Drawing.Size(360, 20)
        $dialogPanel.Controls.Add($descDialogLabel)
        $yPos += 20
        
        # Beschreibung Input
        $descDialogInput = New-Object System.Windows.Forms.TextBox
        $descDialogInput.Text = if ($IsEditMode) { $NodeToEdit.Tag.Description } else { "" }
        $descDialogInput.Location = New-Object System.Drawing.Point(10, $yPos)
        $descDialogInput.Size = New-Object System.Drawing.Size(360, 60)
        $descDialogInput.Multiline = $true
        $descDialogInput.ScrollBars = "Vertical"
        $dialogPanel.Controls.Add($descDialogInput)
        $yPos += 70
        
        # Export Optionen GroupBox
        $dialogOptionsGroup = New-Object System.Windows.Forms.GroupBox
        $dialogOptionsGroup.Text = "Export-Optionen"
        $dialogOptionsGroup.Location = New-Object System.Drawing.Point(10, $yPos)
        $dialogOptionsGroup.Size = New-Object System.Drawing.Size(360, 110)
        $dialogPanel.Controls.Add($dialogOptionsGroup)
        
        # Checkboxes mit Werten aus Node oder Defaults
        $dialogReadmeCheck = New-Object System.Windows.Forms.CheckBox
        $dialogReadmeCheck.Text = "README.md erstellen"
        $dialogReadmeCheck.Location = New-Object System.Drawing.Point(8, 20)
        $dialogReadmeCheck.Size = New-Object System.Drawing.Size(200, 18)
        $dialogReadmeCheck.Checked = if ($IsEditMode -and $NodeToEdit.Tag.ContainsKey('CreateReadme')) { $NodeToEdit.Tag.CreateReadme } else { $readmeCheck.Checked }
        $dialogOptionsGroup.Controls.Add($dialogReadmeCheck)
        
        $dialogGitkeepCheck = New-Object System.Windows.Forms.CheckBox
        $dialogGitkeepCheck.Text = ".gitkeep erstellen"
        $dialogGitkeepCheck.Location = New-Object System.Drawing.Point(8, 40)
        $dialogGitkeepCheck.Size = New-Object System.Drawing.Size(200, 18)
        $dialogGitkeepCheck.Checked = if ($IsEditMode -and $NodeToEdit.Tag.ContainsKey('CreateGitkeep')) { $NodeToEdit.Tag.CreateGitkeep } else { $gitkeepCheck.Checked }
        $dialogOptionsGroup.Controls.Add($dialogGitkeepCheck)
        
        $dialogPropsCheck = New-Object System.Windows.Forms.CheckBox
        $dialogPropsCheck.Text = "Windows-Ordnereigenschaften"
        $dialogPropsCheck.Location = New-Object System.Drawing.Point(8, 60)
        $dialogPropsCheck.Size = New-Object System.Drawing.Size(250, 18)
        $dialogPropsCheck.Checked = if ($IsEditMode -and $NodeToEdit.Tag.ContainsKey('CreateWindowsProps')) { $NodeToEdit.Tag.CreateWindowsProps } else { $folderPropsCheck.Checked }
        $dialogOptionsGroup.Controls.Add($dialogPropsCheck)
        
        $dialogDesktopIniCheck = New-Object System.Windows.Forms.CheckBox
        $dialogDesktopIniCheck.Text = "desktop.ini (Tooltip)"
        $dialogDesktopIniCheck.Location = New-Object System.Drawing.Point(8, 80)
        $dialogDesktopIniCheck.Size = New-Object System.Drawing.Size(200, 18)
        $dialogDesktopIniCheck.Checked = if ($IsEditMode -and $NodeToEdit.Tag.ContainsKey('CreateDesktopIni')) { $NodeToEdit.Tag.CreateDesktopIni } else { $desktopIniCheck.Checked }
        $dialogOptionsGroup.Controls.Add($dialogDesktopIniCheck)
        
        # OK Button
        $okButton = New-Object System.Windows.Forms.Button
        $okButton.Text = "OK"
        $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $okButton.Location = New-Object System.Drawing.Point(210, 410)
        $okButton.Size = New-Object System.Drawing.Size(80, 30)
        $dialogForm.Controls.Add($okButton)
        
        # Cancel Button
        $cancelButton = New-Object System.Windows.Forms.Button
        $cancelButton.Text = "Abbrechen"
        $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $cancelButton.Location = New-Object System.Drawing.Point(295, 410)
        $cancelButton.Size = New-Object System.Drawing.Size(80, 30)
        $dialogForm.Controls.Add($cancelButton)
        
        $dialogForm.AcceptButton = $okButton
        $dialogForm.CancelButton = $cancelButton
        
        $result = $dialogForm.ShowDialog()
        
        if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
            $newName = $nameInput.Text
            $newDesc = $descDialogInput.Text
            
            if ([string]::IsNullOrWhiteSpace($newName)) {
                return
            }
            
            if ($IsEditMode) {
                # Edit-Modus: Node aktualisieren
                $baseName = $newName
                $finalName = $baseName
                
                if ($sortIndexCheck.Checked) {
                    $parentNode = $NodeToEdit.Parent
                    if ($parentNode) {
                        $index = $parentNode.Nodes.IndexOf($NodeToEdit)
                        $finalName = "{0:D2}_{1}" -f $index, $baseName
                    }
                }
                
                $NodeToEdit.Tag.Name = $finalName
                $NodeToEdit.Tag.Description = $newDesc
                $NodeToEdit.Tag.CreateReadme = $dialogReadmeCheck.Checked
                $NodeToEdit.Tag.CreateGitkeep = $dialogGitkeepCheck.Checked
                $NodeToEdit.Tag.CreateWindowsProps = $dialogPropsCheck.Checked
                $NodeToEdit.Tag.CreateDesktopIni = $dialogDesktopIniCheck.Checked
                $NodeToEdit.Text = $finalName
                $NodeToEdit.ToolTipText = $newDesc
                
                $statusLabel.Text = "✓ Bearbeitet: $finalName"
                $statusLabel.BackColor = [System.Drawing.Color]::LightGreen
            } else {
                # Create-Modus: Neuen Node erstellen
                $targetNode = if ($rootCheck.Checked) { $treeView.Nodes[0] } else { $selectedNode }
                
                $baseName = $newName
                $finalName = $baseName
                
                if ($sortIndexCheck.Checked) {
                    $nextIndex = $targetNode.Nodes.Count
                    $finalName = "{0:D2}_{1}" -f $nextIndex, $baseName
                }
                
                $newNode = New-Object System.Windows.Forms.TreeNode
                $newNode.Text = $finalName
                $newNode.ToolTipText = $newDesc
                $newNode.Tag = @{
                    Type = "Folder"
                    Name = $finalName
                    Description = $newDesc
                    ParentPath = $targetNode.Tag.Name
                    CreateReadme = $dialogReadmeCheck.Checked
                    CreateGitkeep = $dialogGitkeepCheck.Checked
                    CreateWindowsProps = $dialogPropsCheck.Checked
                    CreateDesktopIni = $dialogDesktopIniCheck.Checked
                }
                $newNode.Checked = $true
                $targetNode.Nodes.Add($newNode) | Out-Null
                $targetNode.Expand()
                
                # Indices aktualisieren
                Update-NodeIndices -ParentNode $targetNode
                
                $statusLabel.Text = "➕ Ordner hinzugefügt: $finalName"
                $statusLabel.BackColor = [System.Drawing.Color]::LightGreen
            }
        }
        
        $dialogForm.Dispose()
    }
    
    # Event: Bearbeiten Button
    $editButton.Add_Click({
        $selectedNode = $treeView.SelectedNode
        if (-not $selectedNode) {
            [System.Windows.Forms.MessageBox]::Show(
                "Bitte wählen Sie einen Ordner zum Bearbeiten aus.",
                "Kein Ordner ausgewählt",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )
            return
        }
        
        # Root-Dialog oder normaler Ordner-Dialog
        if ($selectedNode.Tag.Type -eq "Root") {
            Open-RootDialog
        } else {
            Open-FolderDialog -NodeToEdit $selectedNode -IsEditMode $true
        }
    })
    
    # Event: Neuer Ordner
    $addButton.Add_Click({
        Open-FolderDialog -IsEditMode $false
    })
    
    # Event: Speichern Button (ganze Struktur)
    $saveButton.Add_Click({
        try {
            # Automatisch als vorlage.json speichern
            $saveDir = Split-Path $JsonPath -Parent
            $vorlagePath = Join-Path $saveDir "vorlage.json"
            
            # Funktion aufrufen
            $success = Save-StructureToFile -FilePath $vorlagePath -TreeView $treeView -StatusLabel $statusLabel `
                -ReadmeCheckBox $readmeCheck -GitkeepCheckBox $gitkeepCheck `
                -WindowsPropsCheckBox $folderPropsCheck -DesktopIniCheckBox $desktopIniCheck
            
            if ($success) {
                # JSON neu laden
                $jsonContent = Get-Content -Path $vorlagePath -Raw -Encoding UTF8
                $script:EditorConfig = $jsonContent | ConvertFrom-Json
                
                # TreeView neu laden
                Fill-TreeView
                
                [System.Windows.Forms.MessageBox]::Show(
                    "Struktur erfolgreich als Vorlage gespeichert!`n`n$vorlagePath",
                    "Erfolg",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Information
                )
            }
        } catch {
            [System.Windows.Forms.MessageBox]::Show(
                "Fehler beim Speichern:`n$_",
                "Fehler",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
        }
    })
    
    # Event: Speichern Als Button
    $saveAsButton.Add_Click({
        try {
            # Dialog für Speichern unter
            $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
            $saveFileDialog.Filter = "JSON-Dateien (*.json)|*.json|Alle Dateien (*.*)|*.*"
            $saveFileDialog.Title = "Vorlage speichern unter..."
            $saveFileDialog.InitialDirectory = Split-Path $JsonPath -Parent
            $saveFileDialog.FileName = "vorlage.json"
            
            if ($saveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                # Funktion aufrufen
                $success = Save-StructureToFile -FilePath $saveFileDialog.FileName -TreeView $treeView -StatusLabel $statusLabel `
                    -ReadmeCheckBox $readmeCheck -GitkeepCheckBox $gitkeepCheck `
                    -WindowsPropsCheckBox $folderPropsCheck -DesktopIniCheckBox $desktopIniCheck
                
                if ($success) {
                    # JSON neu laden
                    $jsonContent = Get-Content -Path $saveFileDialog.FileName -Raw -Encoding UTF8
                    $script:EditorConfig = $jsonContent | ConvertFrom-Json
                    
                    # TreeView neu laden
                    Fill-TreeView
                    
                    [System.Windows.Forms.MessageBox]::Show(
                        "Vorlage erfolgreich gespeichert!`n`n$($saveFileDialog.FileName)",
                        "Erfolg",
                        [System.Windows.Forms.MessageBoxButtons]::OK,
                        [System.Windows.Forms.MessageBoxIcon]::Information
                    )
                }
            }
        } catch {
            [System.Windows.Forms.MessageBox]::Show(
                "Fehler beim Speichern:`n$_",
                "Fehler",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
        }
    })
    
    # Event: Löschen
    $deleteButton.Add_Click({
        $selectedNode = $treeView.SelectedNode
        if (-not $selectedNode -or $selectedNode.Tag.Type -eq "Root") {
            [System.Windows.Forms.MessageBox]::Show(
                "Bitte wählen Sie einen Ordner zum Löschen aus.",
                "Kein Ordner ausgewählt",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )
            return
        }
        
        $result = [System.Windows.Forms.MessageBox]::Show(
            "Möchten Sie '$($selectedNode.Text)' wirklich löschen?",
            "Löschen bestätigen",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )
        
        if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
            $parentNode = $selectedNode.Parent
            $selectedNode.Remove()
            
            # Indices aktualisieren
            if ($parentNode) {
                Update-NodeIndices -ParentNode $parentNode
            }
            
            $statusLabel.Text = "🗑️ Gelöscht: $($selectedNode.Text)"
        }
    })
    
    # Event: Nach oben
    $moveUpButton.Add_Click({
        $selectedNode = $treeView.SelectedNode
        if (-not $selectedNode -or $selectedNode.Tag.Type -eq "Root") {
            [System.Windows.Forms.MessageBox]::Show(
                "Bitte wählen Sie einen Ordner aus.",
                "Kein Ordner ausgewählt",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )
            return
        }
        
        $parentNode = $selectedNode.Parent
        if (-not $parentNode) { return }
        
        $index = $parentNode.Nodes.IndexOf($selectedNode)
        if ($index -gt 0) {
            $parentNode.Nodes.RemoveAt($index)
            $parentNode.Nodes.Insert($index - 1, $selectedNode)
            $treeView.SelectedNode = $selectedNode
            
            # Index aktualisieren wenn sortiert
            if ($sortIndexCheck.Checked) {
                for ($i = 0; $i -lt $parentNode.Nodes.Count; $i++) {
                    $node = $parentNode.Nodes[$i]
                    $baseName = $node.Tag.Name -replace '^\d+_', ''
                    $newName = "{0:D2}_{1}" -f $i, $baseName
                    $node.Tag.Name = $newName
                    $node.Text = $newName
                }
            }
            
            $statusLabel.Text = "✓ Nach oben verschoben"
            $statusLabel.BackColor = [System.Drawing.Color]::LightGreen
        }
    })
    
    # Event: Nach unten
    $moveDownButton.Add_Click({
        $selectedNode = $treeView.SelectedNode
        if (-not $selectedNode -or $selectedNode.Tag.Type -eq "Root") {
            [System.Windows.Forms.MessageBox]::Show(
                "Bitte wählen Sie einen Ordner aus.",
                "Kein Ordner ausgewählt",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )
            return
        }
        
        $parentNode = $selectedNode.Parent
        if (-not $parentNode) { return }
        
        $index = $parentNode.Nodes.IndexOf($selectedNode)
        if ($index -lt $parentNode.Nodes.Count - 1) {
            $parentNode.Nodes.RemoveAt($index)
            $parentNode.Nodes.Insert($index + 1, $selectedNode)
            $treeView.SelectedNode = $selectedNode
            
            # Index aktualisieren wenn sortiert
            if ($sortIndexCheck.Checked) {
                for ($i = 0; $i -lt $parentNode.Nodes.Count; $i++) {
                    $node = $parentNode.Nodes[$i]
                    $baseName = $node.Tag.Name -replace '^\d+_', ''
                    $newName = "{0:D2}_{1}" -f $i, $baseName
                    $node.Tag.Name = $newName
                    $node.Text = $newName
                }
            }
            
            $statusLabel.Text = "✓ Nach unten verschoben"
            $statusLabel.BackColor = [System.Drawing.Color]::LightGreen
        }
    })
    
    # Form anzeigen
    [void]$editorForm.ShowDialog()
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
        
        # Prüfen ob Ordner aktiv ist (enabled)
        $isEnabled = $true
        if ($folderData -is [hashtable] -and $folderData.ContainsKey('enabled')) {
            $isEnabled = $folderData['enabled']
        }
        
        # Überspringen wenn deaktiviert
        if (-not $isEnabled) {
            $relativePath = $folderPath.Replace($script:RootPath, "").TrimStart("\")
            Add-LogMessage "Überspringe (deaktiviert): $relativePath" "Warning"
            continue
        }
        
        # Beschreibung extrahieren
        $description = ""
        if ($folderData -is [hashtable] -and $folderData.ContainsKey('description')) {
            $description = $folderData['description']
        }
        
        # Export-Optionen extrahieren
        $createReadme = $false
        $createGitkeep = $false
        $createWindowsProps = $false
        $createDesktopIni = $false
        
        if ($folderData -is [hashtable]) {
            if ($folderData.ContainsKey('create_readme')) {
                $createReadme = $folderData['create_readme']
            }
            if ($folderData.ContainsKey('create_gitkeep')) {
                $createGitkeep = $folderData['create_gitkeep']
            }
            if ($folderData.ContainsKey('create_windows_props')) {
                $createWindowsProps = $folderData['create_windows_props']
            }
            if ($folderData.ContainsKey('create_desktop_ini')) {
                $createDesktopIni = $folderData['create_desktop_ini']
            }
        }
        
        # Ordner erstellen
        New-CompanyFolder -Path $folderPath -Description $description `
            -CreateReadme $createReadme `
            -CreateGitkeep $createGitkeep `
            -CreateWindowsProps $createWindowsProps `
            -CreateDesktopIni $createDesktopIni
        
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
$jsonTextBox.Size = New-Object System.Drawing.Size(435, 25)
# Automatisch vorlage.json laden, wenn vorhanden
$vorlagePath = Join-Path $PSScriptRoot "vorlage.json"
if (Test-Path $vorlagePath) {
    $jsonTextBox.Text = $vorlagePath
} else {
    $jsonTextBox.Text = ""
}
$jsonGroupBox.Controls.Add($jsonTextBox)

$jsonBrowseButton = New-Object System.Windows.Forms.Button
$jsonBrowseButton.Location = New-Object System.Drawing.Point(455, 23)
$jsonBrowseButton.Size = New-Object System.Drawing.Size(80, 25)
$jsonBrowseButton.Text = "Durchsuchen"
$jsonGroupBox.Controls.Add($jsonBrowseButton)

$jsonEditButton = New-Object System.Windows.Forms.Button
$jsonEditButton.Location = New-Object System.Drawing.Point(540, 23)
$jsonEditButton.Size = New-Object System.Drawing.Size(90, 25)
$jsonEditButton.Text = "📝 Bearbeiten"
$jsonGroupBox.Controls.Add($jsonEditButton)

# Zielpfad Gruppe
$targetGroupBox = New-Object System.Windows.Forms.GroupBox
$targetGroupBox.Location = New-Object System.Drawing.Point(20, 150)
$targetGroupBox.Size = New-Object System.Drawing.Size(640, 60)
$targetGroupBox.Text = "Zielordner"
$form.Controls.Add($targetGroupBox)

$targetTextBox = New-Object System.Windows.Forms.TextBox
$targetTextBox.Location = New-Object System.Drawing.Point(10, 25)
$targetTextBox.Size = New-Object System.Drawing.Size(520, 25)
# Zielpfad leer lassen - Benutzer muss immer wählen
$targetTextBox.Text = ""
$targetGroupBox.Controls.Add($targetTextBox)

$targetBrowseButton = New-Object System.Windows.Forms.Button
$targetBrowseButton.Location = New-Object System.Drawing.Point(540, 23)
$targetBrowseButton.Size = New-Object System.Drawing.Size(80, 25)
$targetBrowseButton.Text = "Durchsuchen"
$targetGroupBox.Controls.Add($targetBrowseButton)

# Export Optionen Gruppe
$exportOptionsGroup = New-Object System.Windows.Forms.GroupBox
$exportOptionsGroup.Location = New-Object System.Drawing.Point(20, 220)
$exportOptionsGroup.Size = New-Object System.Drawing.Size(640, 55)
$exportOptionsGroup.Text = "Export-Optionen"
$form.Controls.Add($exportOptionsGroup)

# Root-Ordner erstellen Checkbox
$createRootFolderCheck = New-Object System.Windows.Forms.CheckBox
$createRootFolderCheck.Text = "Root-Ordner erstellen (Firmenname als Hauptordner)"
$createRootFolderCheck.Location = New-Object System.Drawing.Point(10, 22)
$createRootFolderCheck.Size = New-Object System.Drawing.Size(400, 20)
$createRootFolderCheck.Checked = $true
$exportOptionsGroup.Controls.Add($createRootFolderCheck)

# Start Button
$startButton = New-Object System.Windows.Forms.Button
$startButton.Location = New-Object System.Drawing.Point(20, 285)
$startButton.Size = New-Object System.Drawing.Size(640, 35)
$startButton.Text = "🚀 Ordnerstruktur erstellen"
$startButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$startButton.BackColor = [System.Drawing.Color]::LightGreen
$form.Controls.Add($startButton)

# Fortschrittsbalken
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 335)
$progressBar.Size = New-Object System.Drawing.Size(640, 25)
$progressBar.Style = "Continuous"
$progressBar.Value = 0
$script:ProgressBar = $progressBar
$form.Controls.Add($progressBar)

# Status Label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(20, 365)
$statusLabel.Size = New-Object System.Drawing.Size(640, 20)
$statusLabel.Text = "Bereit zum Start..."
$script:StatusLabel = $statusLabel
$form.Controls.Add($statusLabel)

# Log TextBox
$logGroupBox = New-Object System.Windows.Forms.GroupBox
$logGroupBox.Location = New-Object System.Drawing.Point(20, 395)
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

# JSON Bearbeiten Button
$jsonEditButton.Add_Click({
    $jsonPath = $jsonTextBox.Text
    if ([string]::IsNullOrWhiteSpace($jsonPath)) {
        [System.Windows.Forms.MessageBox]::Show(
            "Bitte wählen Sie zuerst eine JSON-Datei aus.",
            "Keine Datei ausgewählt",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
        return
    }
    
    Open-StructureEditor -JsonPath $jsonPath
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
        $script:Config = Get-Content -Path $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
        
        Add-LogMessage "Firma: $($script:Config.company_name)" "Success"
        Add-LogMessage "Version: $($script:Config.version)" "Success"
        Add-LogMessage "Beschreibung: $($script:Config.description)" "Success"
        
        # Zielpfad bestimmen - mit oder ohne Root-Ordner
        $targetBase = $targetTextBox.Text
        if ($createRootFolderCheck.Checked) {
            $script:RootPath = Join-Path $targetBase $script:Config.company_name
            Add-LogMessage "Modus: Mit Root-Ordner ($($script:Config.company_name))" "Info"
        } else {
            $script:RootPath = $targetBase
            Add-LogMessage "Modus: Ohne Root-Ordner (direkt im Zielordner)" "Info"
        }
        
        Add-LogMessage "Zielordner: $script:RootPath" "Info"
        
        # Bestätigung bei existierendem Ordner
        if (Test-Path $script:RootPath) {
            $warningMessage = if ($createRootFolderCheck.Checked) {
                "Der Ordner existiert bereits:`n$script:RootPath`n`nMöchten Sie fortfahren?"
            } else {
                "ACHTUNG: Struktur wird direkt im Zielordner erstellt!`n$script:RootPath`n`nVorhandene Ordner werden überschrieben.`n`nFortfahren?"
            }
            
            $result = [System.Windows.Forms.MessageBox]::Show(
                $warningMessage,
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
            
            # enabled-Status übergeben (default = true)
            if ($property.Value.PSObject.Properties['enabled']) {
                $structureHash[$property.Name]['enabled'] = $property.Value.enabled
            } else {
                $structureHash[$property.Name]['enabled'] = $true
            }
            
            # Export-Optionen übergeben
            if ($property.Value.PSObject.Properties['create_readme']) {
                $structureHash[$property.Name]['create_readme'] = $property.Value.create_readme
            }
            if ($property.Value.PSObject.Properties['create_gitkeep']) {
                $structureHash[$property.Name]['create_gitkeep'] = $property.Value.create_gitkeep
            }
            if ($property.Value.PSObject.Properties['create_windows_props']) {
                $structureHash[$property.Name]['create_windows_props'] = $property.Value.create_windows_props
            }
            if ($property.Value.PSObject.Properties['create_desktop_ini']) {
                $structureHash[$property.Name]['create_desktop_ini'] = $property.Value.create_desktop_ini
            }
            
            if ($property.Value.folders) {
                $foldersHash = @{}
                foreach ($folder in $property.Value.folders.PSObject.Properties) {
                    $foldersHash[$folder.Name] = @{
                        'description' = $folder.Value.description
                    }
                    
                    # enabled für Unterordner
                    if ($folder.Value.PSObject.Properties['enabled']) {
                        $foldersHash[$folder.Name]['enabled'] = $folder.Value.enabled
                    } else {
                        $foldersHash[$folder.Name]['enabled'] = $true
                    }
                    
                    # Export-Optionen für Unterordner
                    if ($folder.Value.PSObject.Properties['create_readme']) {
                        $foldersHash[$folder.Name]['create_readme'] = $folder.Value.create_readme
                    }
                    if ($folder.Value.PSObject.Properties['create_gitkeep']) {
                        $foldersHash[$folder.Name]['create_gitkeep'] = $folder.Value.create_gitkeep
                    }
                    if ($folder.Value.PSObject.Properties['create_windows_props']) {
                        $foldersHash[$folder.Name]['create_windows_props'] = $folder.Value.create_windows_props
                    }
                    if ($folder.Value.PSObject.Properties['create_desktop_ini']) {
                        $foldersHash[$folder.Name]['create_desktop_ini'] = $folder.Value.create_desktop_ini
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
