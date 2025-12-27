# Этот файл содержит исправленную версию функции Open-StructureEditor
# Скопируйте содержимое в create_structure_GUI.ps1

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
    $editorForm.Size = New-Object System.Drawing.Size(1000, 750)
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
    
    # Toolbar Panel
    $toolbarPanel = New-Object System.Windows.Forms.Panel
    $toolbarPanel.Dock = "Top"
    $toolbarPanel.Height = 40
    $toolbarPanel.BackColor = [System.Drawing.Color]::WhiteSmoke
    $editorForm.Controls.Add($toolbarPanel)
    
    # Speichern Button
    $saveButton = New-Object System.Windows.Forms.Button
    $saveButton.Location = New-Object System.Drawing.Point(10, 5)
    $saveButton.Size = New-Object System.Drawing.Size(120, 30)
    $saveButton.Text = "💾 Speichern"
    $saveButton.BackColor = [System.Drawing.Color]::LightGreen
    $toolbarPanel.Controls.Add($saveButton)
    
    # Neuer Ordner Button
    $addButton = New-Object System.Windows.Forms.Button
    $addButton.Location = New-Object System.Drawing.Point(140, 5)
    $addButton.Size = New-Object System.Drawing.Size(120, 30)
    $addButton.Text = "➕ Ordner"
    $toolbarPanel.Controls.Add($addButton)
    
    # Löschen Button
    $deleteButton = New-Object System.Windows.Forms.Button
    $deleteButton.Location = New-Object System.Drawing.Point(270, 5)
    $deleteButton.Size = New-Object System.Drawing.Size(120, 30)
    $deleteButton.Text = "🗑️ Löschen"
    $toolbarPanel.Controls.Add($deleteButton)
    
    # Schließen Button
    $closeEditorButton = New-Object System.Windows.Forms.Button
    $closeEditorButton.Location = New-Object System.Drawing.Point(860, 5)
    $closeEditorButton.Size = New-Object System.Drawing.Size(120, 30)
    $closeEditorButton.Text = "Schließen"
    $toolbarPanel.Controls.Add($closeEditorButton)
    
    # Split Container für Struktur und Details
    $splitContainer = New-Object System.Windows.Forms.SplitContainer
    $splitContainer.Dock = "Fill"
    $splitContainer.SplitterDistance = 400
    $splitContainer.BorderStyle = "Fixed3D"
    $editorForm.Controls.Add($splitContainer)
    
    # Linke Seite - TreeView für Struktur
    $treeLabel = New-Object System.Windows.Forms.Label
    $treeLabel.Text = "📁 Ordnerstruktur"
    $treeLabel.Dock = "Top"
    $treeLabel.Height = 30
    $treeLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $treeLabel.TextAlign = "MiddleLeft"
    $treeLabel.Padding = New-Object System.Windows.Forms.Padding(10, 0, 0, 0)
    $splitContainer.Panel1.Controls.Add($treeLabel)
    
    $treeView = New-Object System.Windows.Forms.TreeView
    $treeView.Dock = "Fill"
    $treeView.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $treeView.CheckBoxes = $true
    $treeView.HideSelection = $false
    $splitContainer.Panel1.Controls.Add($treeView)
    
    # Rechte Seite - Details Panel
    $detailsLabel = New-Object System.Windows.Forms.Label
    $detailsLabel.Text = "📝 Eigenschaften"
    $detailsLabel.Dock = "Top"
    $detailsLabel.Height = 30
    $detailsLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $detailsLabel.TextAlign = "MiddleLeft"
    $detailsLabel.Padding = New-Object System.Windows.Forms.Padding(10, 0, 0, 0)
    $splitContainer.Panel2.Controls.Add($detailsLabel)
    
    $detailsPanel = New-Object System.Windows.Forms.Panel
    $detailsPanel.Dock = "Fill"
    $detailsPanel.AutoScroll = $true
    $detailsPanel.Padding = New-Object System.Windows.Forms.Padding(10)
    $splitContainer.Panel2.Controls.Add($detailsPanel)
    
    # Name Label und TextBox
    $nameLabel = New-Object System.Windows.Forms.Label
    $nameLabel.Text = "Ordnername:"
    $nameLabel.Location = New-Object System.Drawing.Point(10, 10)
    $nameLabel.Size = New-Object System.Drawing.Size(520, 20)
    $detailsPanel.Controls.Add($nameLabel)
    
    $nameTextBox = New-Object System.Windows.Forms.TextBox
    $nameTextBox.Location = New-Object System.Drawing.Point(10, 35)
    $nameTextBox.Size = New-Object System.Drawing.Size(520, 25)
    $nameTextBox.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $detailsPanel.Controls.Add($nameTextBox)
    
    # Beschreibung Label und TextBox
    $descLabel = New-Object System.Windows.Forms.Label
    $descLabel.Text = "Beschreibung:"
    $descLabel.Location = New-Object System.Drawing.Point(10, 70)
    $descLabel.Size = New-Object System.Drawing.Size(520, 20)
    $detailsPanel.Controls.Add($descLabel)
    
    $descTextBox = New-Object System.Windows.Forms.TextBox
    $descTextBox.Location = New-Object System.Drawing.Point(10, 95)
    $descTextBox.Size = New-Object System.Drawing.Size(520, 80)
    $descTextBox.Multiline = $true
    $descTextBox.ScrollBars = "Vertical"
    $descTextBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $detailsPanel.Controls.Add($descTextBox)
    
    # Optionen GroupBox
    $optionsGroup = New-Object System.Windows.Forms.GroupBox
    $optionsGroup.Text = "⚙️ Export-Optionen"
    $optionsGroup.Location = New-Object System.Drawing.Point(10, 190)
    $optionsGroup.Size = New-Object System.Drawing.Size(520, 150)
    $detailsPanel.Controls.Add($optionsGroup)
    
    # README.md Checkbox
    $readmeCheck = New-Object System.Windows.Forms.CheckBox
    $readmeCheck.Text = "README.md erstellen"
    $readmeCheck.Location = New-Object System.Drawing.Point(15, 25)
    $readmeCheck.Size = New-Object System.Drawing.Size(300, 25)
    $readmeCheck.Checked = $true
    $optionsGroup.Controls.Add($readmeCheck)
    
    # .gitkeep Checkbox
    $gitkeepCheck = New-Object System.Windows.Forms.CheckBox
    $gitkeepCheck.Text = ".gitkeep erstellen"
    $gitkeepCheck.Location = New-Object System.Drawing.Point(15, 55)
    $gitkeepCheck.Size = New-Object System.Drawing.Size(300, 25)
    $gitkeepCheck.Checked = $true
    $optionsGroup.Controls.Add($gitkeepCheck)
    
    # Beschreibung in Ordner-Eigenschaften Checkbox
    $folderPropsCheck = New-Object System.Windows.Forms.CheckBox
    $folderPropsCheck.Text = "Beschreibung in Windows-Ordnereigenschaften"
    $folderPropsCheck.Location = New-Object System.Drawing.Point(15, 85)
    $folderPropsCheck.Size = New-Object System.Drawing.Size(400, 25)
    $folderPropsCheck.Checked = $false
    $optionsGroup.Controls.Add($folderPropsCheck)
    
    # Beschreibung in desktop.ini Checkbox
    $desktopIniCheck = New-Object System.Windows.Forms.CheckBox
    $desktopIniCheck.Text = "desktop.ini mit Beschreibung (Tooltip)"
    $desktopIniCheck.Location = New-Object System.Drawing.Point(15, 115)
    $desktopIniCheck.Size = New-Object System.Drawing.Size(400, 25)
    $desktopIniCheck.Checked = $false
    $optionsGroup.Controls.Add($desktopIniCheck)
    
    # Speichern Button für Eigenschaften
    $savePropsButton = New-Object System.Windows.Forms.Button
    $savePropsButton.Text = "💾 Eigenschaften speichern"
    $savePropsButton.Location = New-Object System.Drawing.Point(10, 350)
    $savePropsButton.Size = New-Object System.Drawing.Size(250, 35)
    $savePropsButton.BackColor = [System.Drawing.Color]::LightBlue
    $detailsPanel.Controls.Add($savePropsButton)
    
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
            $node.Checked = $true
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
                    $subNode.Checked = $true
                    $node.Nodes.Add($subNode) | Out-Null
                }
            }
        }
        
        $rootNode.Expand()
    }
    
    # TreeView füllen
    Fill-TreeView
    
    # Event: TreeView Selection Changed
    $treeView.Add_AfterSelect({
        $selectedNode = $treeView.SelectedNode
        if ($selectedNode -and $selectedNode.Tag) {
            $nodeData = $selectedNode.Tag
            $nameTextBox.Text = $nodeData.Name
            $descTextBox.Text = $nodeData.Description
            $statusLabel.Text = "Ausgewählt: $($nodeData.Name)"
        }
    })
    
    # Event: Eigenschaften speichern
    $savePropsButton.Add_Click({
        $selectedNode = $treeView.SelectedNode
        if (-not $selectedNode) {
            [System.Windows.Forms.MessageBox]::Show(
                "Bitte wählen Sie einen Ordner aus.",
                "Kein Ordner ausgewählt",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )
            return
        }
        
        $nodeData = $selectedNode.Tag
        $oldName = $nodeData.Name
        $newName = $nameTextBox.Text
        $newDesc = $descTextBox.Text
        
        # Update Node
        $nodeData.Name = $newName
        $nodeData.Description = $newDesc
        $selectedNode.Text = $newName
        $selectedNode.ToolTipText = $newDesc
        
        $statusLabel.Text = "✓ Gespeichert: $newName"
        $statusLabel.BackColor = [System.Drawing.Color]::LightGreen
    })
    
    # Event: Speichern Button (ganze Struktur)
    $saveButton.Add_Click({
        try {
            # Struktur aus TreeView rekonstruieren
            $newStructure = @{}
            $rootNode = $treeView.Nodes[0]
            
            foreach ($node in $rootNode.Nodes) {
                $folderName = $node.Tag.Name
                $folderDesc = $node.Tag.Description
                
                $newStructure[$folderName] = @{
                    description = $folderDesc
                }
                
                if ($node.Nodes.Count -gt 0) {
                    $subFolders = @{}
                    foreach ($subNode in $node.Nodes) {
                        $subName = $subNode.Tag.Name
                        $subDesc = $subNode.Tag.Description
                        $subFolders[$subName] = @{
                            description = $subDesc
                        }
                    }
                    $newStructure[$folderName]['folders'] = $subFolders
                }
            }
            
            # Config aktualisieren
            $script:EditorConfig.structure = [PSCustomObject]$newStructure
            
            # Als JSON speichern
            $jsonOutput = $script:EditorConfig | ConvertTo-Json -Depth 10
            $jsonOutput | Out-File -FilePath $JsonPath -Encoding UTF8 -Force
            
            $statusLabel.Text = "✓ Struktur gespeichert: $(Get-Date -Format 'HH:mm:ss')"
            $statusLabel.BackColor = [System.Drawing.Color]::LightGreen
            
            [System.Windows.Forms.MessageBox]::Show(
                "Struktur erfolgreich gespeichert!",
                "Erfolg",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            )
        } catch {
            $statusLabel.Text = "✗ Fehler beim Speichern"
            $statusLabel.BackColor = [System.Drawing.Color]::LightCoral
            
            [System.Windows.Forms.MessageBox]::Show(
                "Fehler beim Speichern:`n$_",
                "Fehler",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
        }
    })
    
    # Event: Neuer Ordner
    $addButton.Add_Click({
        $selectedNode = $treeView.SelectedNode
        if (-not $selectedNode) {
            [System.Windows.Forms.MessageBox]::Show(
                "Bitte wählen Sie einen übergeordneten Ordner aus.",
                "Kein Ordner ausgewählt",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )
            return
        }
        
        $newName = [Microsoft.VisualBasic.Interaction]::InputBox(
            "Geben Sie den Namen für den neuen Ordner ein:",
            "Neuer Ordner",
            "Neuer_Ordner"
        )
        
        if ([string]::IsNullOrWhiteSpace($newName)) {
            return
        }
        
        $newNode = New-Object System.Windows.Forms.TreeNode
        $newNode.Text = $newName
        $newNode.Tag = @{
            Type = "Folder"
            Name = $newName
            Description = ""
            ParentPath = $selectedNode.Tag.Name
        }
        $newNode.Checked = $true
        $selectedNode.Nodes.Add($newNode) | Out-Null
        $selectedNode.Expand()
        
        $statusLabel.Text = "➕ Ordner hinzugefügt: $newName"
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
            $selectedNode.Remove()
            $statusLabel.Text = "🗑️ Gelöscht: $($selectedNode.Text)"
        }
    })
    
    # Event: Schließen
    $closeEditorButton.Add_Click({
        $editorForm.Close()
    })
    
    # Form anzeigen
    [void]$editorForm.ShowDialog()
}
