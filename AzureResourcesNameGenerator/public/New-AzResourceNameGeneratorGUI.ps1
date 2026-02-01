function New-AzResourceNameGeneratorGUI {

<#
.AUTHOR
    Michał Machniak

.SYNOPSIS
    Azure Resource Naming Convention Generator GUI
.DESCRIPTION
    This function provides a graphical user interface (GUI) for generating Azure resource names based on naming conventions.
    Users can select resource types from a file, configure naming parameters, and generate resource names with visual feedback.
    The generated names can be displayed in a results window or exported to clipboard.

.PARAMETER ResourceNameSchema
    Path to the resource schema JSON file that defines general naming convention.
    Default: https://raw.githubusercontent.com/mimachniak/AzureResources-NameGenerator/refs/heads/main/data/general_naming_shema.json

.PARAMETER ResourcesData
    Path to the resource types JSON file. Can be a URL or local file path.
    Default: https://raw.githubusercontent.com/mspnp/AzureNamingTool/refs/heads/main/src/repository/resourcetypes.json

.PARAMETER ResourceTypesFile
    Path to a file containing resource types (one per line) to be loaded into the GUI dropdown.
    This allows users to select from predefined resource types.

.EXAMPLE
    New-AzResourceNameGeneratorGUI

.EXAMPLE
    New-AzResourceNameGeneratorGUI -ResourceTypesFile "C:\resourcetypes.txt"

.NOTES
    This GUI requires Windows Forms assembly. It provides an interactive way to:
    - Select multiple resource types from a searchable list
    - Configure environment, region, unique identifier, and other parameters
    - Generate resource names in real-time
    - View results in a grid
    - Export results to clipboard or file
#>

    [CmdletBinding()]
    param(
        [Parameter(HelpMessage = "Path to the resource schema JSON file.")]
        [string]$ResourceNameSchema = "https://raw.githubusercontent.com/mimachniak/AzureResources-NameGenerator/refs/heads/main/data/general_naming_shema.json",

        [Parameter(HelpMessage = "Use default settings to load resource schema from web.")]
        [string]$ResourcesData,

        [Parameter(HelpMessage = "Path to a file containing resource types (one per line).")]
        [string]$ResourceTypesFile
    )

    # Determine the script directory to find resourcetypes.json
    $scriptDir = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
    $localResourcesFile = Join-Path -Path $scriptDir -ChildPath "data\resourcetypes.json"
    
    # If ResourcesData is not specified, try to use local file first, then fall back to URL
    if ([string]::IsNullOrWhiteSpace($ResourcesData)) {
        if (Test-Path $localResourcesFile) {
            $ResourcesData = $localResourcesFile
            Write-Host "Using local resource types file: $ResourcesData" -ForegroundColor Green
        }
        else {
            $ResourcesData = "https://raw.githubusercontent.com/mspnp/AzureNamingTool/refs/heads/main/src/repository/resourcetypes.json"
            Write-Host "Using remote resource types from: $ResourcesData" -ForegroundColor Yellow
        }
    }

    # Load required assemblies
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    # Helper function to load resources from JSON file
    function Get-ResourceTypesFromJson {
        param(
            [Parameter(Mandatory = $true)]
            [string]$Path
        )
        
        try {
            $content = $null
            
            # Check if it's a URL or file path
            if ($Path -match '^https?://') {
                # Download from URL
                Write-Verbose "Loading resources from URL: $Path"
                $content = Invoke-WebRequest -Uri $Path -ErrorAction Stop | Select-Object -ExpandProperty Content
            }
            elseif (Test-Path $Path) {
                # Load from file
                Write-Verbose "Loading resources from file: $Path"
                $content = Get-Content -Path $Path -Raw -ErrorAction Stop
            }
            else {
                Write-Warning "Resource file not found: $Path"
                return @()
            }
            
            # Parse JSON and extract resource names
            $jsonData = $content | ConvertFrom-Json -ErrorAction Stop
            
            # Handle both array of objects and simple array
            if ($jsonData -is [System.Collections.IEnumerable] -and -not ($jsonData -is [string])) {
                # If it's an array of objects, extract the 'resource' property
                if ($jsonData[0] -is [PSCustomObject] -and $jsonData[0].PSObject.Properties['resource']) {
                    $resources = @($jsonData | Select-Object -ExpandProperty resource | Sort-Object -Unique)
                    Write-Verbose "Extracted 'resource' property from JSON objects"
                }
                else {
                    # If it's a simple array of strings
                    $resources = @($jsonData | Sort-Object -Unique)
                    Write-Verbose "Using array of strings from JSON"
                }
            }
            else {
                Write-Warning "Unexpected JSON format: Expected array but got $($jsonData.GetType().Name)"
                return @()
            }
            
            if ($resources.Count -gt 0) {
                Write-Verbose "Loaded $($resources.Count) resource types: $($resources[0..4] -join ', ')..."
                Write-Host "Successfully loaded $($resources.Count) resource types from file" -ForegroundColor Green
            }
            return $resources
        }
        catch {
            Write-Error "Error loading resources from $Path : $_" -ErrorAction Continue
            Write-Host "Failed to load resources: $_" -ForegroundColor Red
            return @()
        }
    }

    # Load resource types from file or JSON - use script scope to ensure accessibility in nested scopes
    $script:resourceTypesToLoad = @()
    if ($ResourceTypesFile -and (Test-Path $ResourceTypesFile)) {
        if ($ResourceTypesFile -match '\.json$') {
            # Load from JSON file
            $script:resourceTypesToLoad = @(Get-ResourceTypesFromJson -Path $ResourceTypesFile)
        }
        else {
            # Load from text file (one per line)
            $script:resourceTypesToLoad = @(Get-Content -Path $ResourceTypesFile | Where-Object { $_ -notmatch '^\s*$' })
        }
    }
    else {
        # Try to load from default ResourcesData
        $script:resourceTypesToLoad = @(Get-ResourceTypesFromJson -Path $ResourcesData)
    }

    # Create main form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Azure Resource Name Generator"
    $form.Width = 1000
    $form.Height = 700
    $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
    $form.TopMost = $false
    $form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font

    # Create a TabControl for organizing UI
    $tabControl = New-Object System.Windows.Forms.TabControl
    $tabControl.Dock = [System.Windows.Forms.DockStyle]::Fill
    $tabControl.ItemSize = New-Object System.Drawing.Size(100, 30)

    # Tab 1: Parameters
    $tabParameters = New-Object System.Windows.Forms.TabPage
    $tabParameters.Text = "Parameters"
    $tabParameters.Padding = New-Object System.Windows.Forms.Padding(10)

    # Create GroupBox for parameters
    $groupParams = New-Object System.Windows.Forms.GroupBox
    $groupParams.Text = "Configuration"
    $groupParams.Dock = [System.Windows.Forms.DockStyle]::Top
    $groupParams.Height = 280
    $groupParams.AutoSize = $true
    $groupParams.Padding = New-Object System.Windows.Forms.Padding(10)

    $yPos = 20

    # Environment Label and TextBox
    $labelEnvironment = New-Object System.Windows.Forms.Label
    $labelEnvironment.Text = "Environment (Dev, Test, Prod):"
    $labelEnvironment.Location = New-Object System.Drawing.Point(10, $yPos)
    $labelEnvironment.AutoSize = $true
    $groupParams.Controls.Add($labelEnvironment)

    $textEnvironment = New-Object System.Windows.Forms.TextBox
    $textEnvironment.Text = "Dev"
    $textEnvironment.Location = New-Object System.Drawing.Point(250, $yPos)
    $textEnvironment.Width = 200
    $groupParams.Controls.Add($textEnvironment)

    $yPos += 40

    # Region Label and TextBox
    $labelRegion = New-Object System.Windows.Forms.Label
    $labelRegion.Text = "Region (e.g., westeurope, eastus):"
    $labelRegion.Location = New-Object System.Drawing.Point(10, $yPos)
    $labelRegion.AutoSize = $true
    $groupParams.Controls.Add($labelRegion)

    $textRegion = New-Object System.Windows.Forms.TextBox
    $textRegion.Text = "westeurope"
    $textRegion.Location = New-Object System.Drawing.Point(250, $yPos)
    $textRegion.Width = 200
    $groupParams.Controls.Add($textRegion)

    $yPos += 40

    # Unique Identifier Label and TextBox
    $labelUniqueId = New-Object System.Windows.Forms.Label
    $labelUniqueId.Text = "Unique Identifier (Project Code):"
    $labelUniqueId.Location = New-Object System.Drawing.Point(10, $yPos)
    $labelUniqueId.AutoSize = $true
    $groupParams.Controls.Add($labelUniqueId)

    $textUniqueId = New-Object System.Windows.Forms.TextBox
    $textUniqueId.Text = "MARK"
    $textUniqueId.Location = New-Object System.Drawing.Point(250, $yPos)
    $textUniqueId.Width = 200
    $groupParams.Controls.Add($textUniqueId)

    $yPos += 40

    # Number Label and NumericUpDown
    $labelNumber = New-Object System.Windows.Forms.Label
    $labelNumber.Text = "Number:"
    $labelNumber.Location = New-Object System.Drawing.Point(10, $yPos)
    $labelNumber.AutoSize = $true
    $groupParams.Controls.Add($labelNumber)

    $numericNumber = New-Object System.Windows.Forms.NumericUpDown
    $numericNumber.Value = 1
    $numericNumber.Location = New-Object System.Drawing.Point(250, $yPos)
    $numericNumber.Width = 200
    $numericNumber.Minimum = 1
    $numericNumber.Maximum = 999
    $groupParams.Controls.Add($numericNumber)

    $yPos += 40

    # Separator Label and TextBox
    $labelSeparator = New-Object System.Windows.Forms.Label
    $labelSeparator.Text = "Separator:"
    $labelSeparator.Location = New-Object System.Drawing.Point(10, $yPos)
    $labelSeparator.AutoSize = $true
    $groupParams.Controls.Add($labelSeparator)

    $textSeparator = New-Object System.Windows.Forms.TextBox
    $textSeparator.Text = "-"
    $textSeparator.Location = New-Object System.Drawing.Point(250, $yPos)
    $textSeparator.Width = 200
    $groupParams.Controls.Add($textSeparator)

    $yPos += 40

    # Convert to Lower Checkbox
    $checkLower = New-Object System.Windows.Forms.CheckBox
    $checkLower.Text = "Convert to Lowercase"
    $checkLower.Location = New-Object System.Drawing.Point(250, $yPos)
    $checkLower.AutoSize = $true
    $checkLower.Checked = $true
    $groupParams.Controls.Add($checkLower)

    $tabParameters.Controls.Add($groupParams)

    # Tab 2: Resource Types
    $tabResources = New-Object System.Windows.Forms.TabPage
    $tabResources.Text = "Resources"
    $tabResources.Padding = New-Object System.Windows.Forms.Padding(10)

    # Search Label and TextBox
    $labelSearch = New-Object System.Windows.Forms.Label
    $labelSearch.Text = "Search Resources:"
    $labelSearch.Location = New-Object System.Drawing.Point(10, 10)
    $labelSearch.AutoSize = $true
    $tabResources.Controls.Add($labelSearch)

    $textSearch = New-Object System.Windows.Forms.TextBox
    $textSearch.Location = New-Object System.Drawing.Point(150, 10)
    $textSearch.Width = 300
    $textSearch.Height = 25
    $tabResources.Controls.Add($textSearch)

    # ListBox for resource types
    $labelResourceTypes = New-Object System.Windows.Forms.Label
    $labelResourceTypes.Text = "Available Resource Types:"
    $labelResourceTypes.Location = New-Object System.Drawing.Point(10, 45)
    $labelResourceTypes.AutoSize = $true
    $tabResources.Controls.Add($labelResourceTypes)

    # Load Resources Button
    $buttonLoadResources = New-Object System.Windows.Forms.Button
    $buttonLoadResources.Text = "Load Resources"
    $buttonLoadResources.Location = New-Object System.Drawing.Point(370, 10)
    $buttonLoadResources.Width = 90
    $buttonLoadResources.Height = 25
    $tabResources.Controls.Add($buttonLoadResources)

    $listBoxResources = New-Object System.Windows.Forms.ListBox
    $listBoxResources.SelectionMode = [System.Windows.Forms.SelectionMode]::MultiSimple
    $listBoxResources.Location = New-Object System.Drawing.Point(10, 70)
    $listBoxResources.Width = 450
    $listBoxResources.Height = 500
    $tabResources.Controls.Add($listBoxResources)

    # Selected Resources Label and TextBox
    $labelSelected = New-Object System.Windows.Forms.Label
    $labelSelected.Text = "Selected Resources:"
    $labelSelected.Location = New-Object System.Drawing.Point(480, 45)
    $labelSelected.AutoSize = $true
    $tabResources.Controls.Add($labelSelected)

    $textSelectedResources = New-Object System.Windows.Forms.TextBox
    $textSelectedResources.Multiline = $true
    $textSelectedResources.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
    $textSelectedResources.Location = New-Object System.Drawing.Point(480, 70)
    $textSelectedResources.Width = 450
    $textSelectedResources.Height = 500
    $textSelectedResources.ReadOnly = $true
    $tabResources.Controls.Add($textSelectedResources)

    # Search functionality
    $textSearch_TextChanged = {
        $filter = $textSearch.Text.ToLower()
        $listBoxResources.Items.Clear()

        if ([string]::IsNullOrEmpty($filter)) {
            foreach ($item in $script:resourceTypesToLoad) {
                [void]$listBoxResources.Items.Add($item)
            }
        }
        else {
            foreach ($item in $script:resourceTypesToLoad) {
                if ($item.ToLower().Contains($filter)) {
                    [void]$listBoxResources.Items.Add($item)
                }
            }
        }
    }

    $textSearch.Add_TextChanged($textSearch_TextChanged)

    # Load Resources button click event
    $buttonLoadResources.Add_Click({
        $openDialog = New-Object System.Windows.Forms.OpenFileDialog
        $openDialog.Filter = "JSON Files (*.json)|*.json|Text Files (*.txt)|*.txt|All Files (*.*)|*.*"
        $openDialog.Title = "Select Resource File"
        
        if ($openDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            try {
                $script:resourceTypesToLoad = @()
                
                if ($openDialog.FileName -match '\.json$') {
                    # Load from JSON file
                    $script:resourceTypesToLoad = @(Get-ResourceTypesFromJson -Path $openDialog.FileName)
                }
                else {
                    # Load from text file
                    $script:resourceTypesToLoad = @(Get-Content -Path $openDialog.FileName | Where-Object { $_ -notmatch '^\s*$' })
                }
                
                if ($script:resourceTypesToLoad.Count -gt 0) {
                    # Refresh the listbox
                    $listBoxResources.Items.Clear()
                    foreach ($item in $script:resourceTypesToLoad) {
                        [void]$listBoxResources.Items.Add($item)
                    }
                    
                    [System.Windows.Forms.MessageBox]::Show("Loaded $($script:resourceTypesToLoad.Count) resource types.", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                }
                else {
                    [System.Windows.Forms.MessageBox]::Show("No resources found in the selected file.", "No Data", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
                }
            }
            catch {
                [System.Windows.Forms.MessageBox]::Show("Error loading resources:`n`n$($_.Exception.Message)", "Load Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        }
    })

    # Load initial resource types
    if ($script:resourceTypesToLoad.Count -gt 0) {
        foreach ($item in $script:resourceTypesToLoad) {
            [void]$listBoxResources.Items.Add($item)
        }
    }

    # Update selected resources display
    $updateSelectedResources = {
        $selected = @($listBoxResources.SelectedItems | ForEach-Object { $_ })
        $textSelectedResources.Text = $selected -join [Environment]::NewLine
    }

    $listBoxResources.Add_SelectedIndexChanged($updateSelectedResources)

    # Tab 3: Settings
    $tabSettings = New-Object System.Windows.Forms.TabPage
    $tabSettings.Text = "Settings"
    $tabSettings.Padding = New-Object System.Windows.Forms.Padding(10)
    $tabSettings.AutoScroll = $true

    # Create GroupBox for file settings
    $groupFileSettings = New-Object System.Windows.Forms.GroupBox
    $groupFileSettings.Text = "File Configuration"
    $groupFileSettings.Dock = [System.Windows.Forms.DockStyle]::Top
    $groupFileSettings.Height = 350
    $groupFileSettings.AutoSize = $true
    $groupFileSettings.Padding = New-Object System.Windows.Forms.Padding(10)

    $ySettingsPos = 20

    # Naming Schema File
    $labelSchemaFile = New-Object System.Windows.Forms.Label
    $labelSchemaFile.Text = "Naming Schema File:"
    $labelSchemaFile.Location = New-Object System.Drawing.Point(10, $ySettingsPos)
    $labelSchemaFile.AutoSize = $true
    $groupFileSettings.Controls.Add($labelSchemaFile)

    $textSchemaFile = New-Object System.Windows.Forms.TextBox
    $textSchemaFile.Text = $ResourceNameSchema
    $textSchemaFile.Location = New-Object System.Drawing.Point(10, ($ySettingsPos + 25))
    $textSchemaFile.Width = 650
    $textSchemaFile.Height = 40
    $textSchemaFile.Multiline = $true
    $textSchemaFile.ReadOnly = $true
    $textSchemaFile.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
    $groupFileSettings.Controls.Add($textSchemaFile)

    $buttonBrowseSchema = New-Object System.Windows.Forms.Button
    $buttonBrowseSchema.Text = "Browse Schema..."
    $buttonBrowseSchema.Location = New-Object System.Drawing.Point(670, ($ySettingsPos + 25))
    $buttonBrowseSchema.Width = 120
    $buttonBrowseSchema.Height = 25
    $groupFileSettings.Controls.Add($buttonBrowseSchema)

    $buttonResetSchema = New-Object System.Windows.Forms.Button
    $buttonResetSchema.Text = "Reset to Default"
    $buttonResetSchema.Location = New-Object System.Drawing.Point(670, ($ySettingsPos + 55))
    $buttonResetSchema.Width = 120
    $buttonResetSchema.Height = 25
    $groupFileSettings.Controls.Add($buttonResetSchema)

    $ySettingsPos += 100

    # Resources Data File
    $labelResourcesFile = New-Object System.Windows.Forms.Label
    $labelResourcesFile.Text = "Resources Data File:"
    $labelResourcesFile.Location = New-Object System.Drawing.Point(10, $ySettingsPos)
    $labelResourcesFile.AutoSize = $true
    $groupFileSettings.Controls.Add($labelResourcesFile)

    $textResourcesFile = New-Object System.Windows.Forms.TextBox
    $textResourcesFile.Text = $ResourcesData
    $textResourcesFile.Location = New-Object System.Drawing.Point(10, ($ySettingsPos + 25))
    $textResourcesFile.Width = 650
    $textResourcesFile.Height = 40
    $textResourcesFile.Multiline = $true
    $textResourcesFile.ReadOnly = $true
    $textResourcesFile.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
    $groupFileSettings.Controls.Add($textResourcesFile)

    $buttonBrowseResources = New-Object System.Windows.Forms.Button
    $buttonBrowseResources.Text = "Browse Resources..."
    $buttonBrowseResources.Location = New-Object System.Drawing.Point(670, ($ySettingsPos + 25))
    $buttonBrowseResources.Width = 120
    $buttonBrowseResources.Height = 25
    $groupFileSettings.Controls.Add($buttonBrowseResources)

    $buttonResetResources = New-Object System.Windows.Forms.Button
    $buttonResetResources.Text = "Reset to Default"
    $buttonResetResources.Location = New-Object System.Drawing.Point(670, ($ySettingsPos + 55))
    $buttonResetResources.Width = 120
    $buttonResetResources.Height = 25
    $groupFileSettings.Controls.Add($buttonResetResources)

    $ySettingsPos += 100

    # Info Label
    $labelSettingsInfo = New-Object System.Windows.Forms.Label
    $labelSettingsInfo.Text = "Note: Changes to files will be applied after reloading. Use 'Browse' buttons to select custom files."
    $labelSettingsInfo.Location = New-Object System.Drawing.Point(10, $ySettingsPos)
    $labelSettingsInfo.Size = New-Object System.Drawing.Size(780, 50)
    $labelSettingsInfo.AutoSize = $false
    $labelSettingsInfo.ForeColor = [System.Drawing.Color]::Blue
    $groupFileSettings.Controls.Add($labelSettingsInfo)

    $tabSettings.Controls.Add($groupFileSettings)

    $tabControl.TabPages.Add($tabParameters)
    $tabControl.TabPages.Add($tabResources)
    $tabControl.TabPages.Add($tabSettings)
    $form.Controls.Add($tabControl)

    # Create buttons at the bottom
    $buttonPanel = New-Object System.Windows.Forms.Panel
    $buttonPanel.Dock = [System.Windows.Forms.DockStyle]::Bottom
    $buttonPanel.Height = 60
    $buttonPanel.Padding = New-Object System.Windows.Forms.Padding(10)

    # Generate Button
    $buttonGenerate = New-Object System.Windows.Forms.Button
    $buttonGenerate.Text = "Generate Names"
    $buttonGenerate.Location = New-Object System.Drawing.Point(10, 10)
    $buttonGenerate.Width = 150
    $buttonGenerate.Height = 40
    $buttonPanel.Controls.Add($buttonGenerate)

    # Copy to Clipboard Button
    $buttonCopy = New-Object System.Windows.Forms.Button
    $buttonCopy.Text = "Copy Results"
    $buttonCopy.Location = New-Object System.Drawing.Point(170, 10)
    $buttonCopy.Width = 150
    $buttonCopy.Height = 40
    $buttonCopy.Enabled = $false
    $buttonPanel.Controls.Add($buttonCopy)

    # Export Button
    $buttonExport = New-Object System.Windows.Forms.Button
    $buttonExport.Text = "Export to File"
    $buttonExport.Location = New-Object System.Drawing.Point(330, 10)
    $buttonExport.Width = 150
    $buttonExport.Height = 40
    $buttonExport.Enabled = $false
    $buttonPanel.Controls.Add($buttonExport)

    # Close Button
    $buttonClose = New-Object System.Windows.Forms.Button
    $buttonClose.Text = "Close"
    $buttonClose.Location = New-Object System.Drawing.Point(490, 10)
    $buttonClose.Width = 150
    $buttonClose.Height = 40
    $buttonPanel.Controls.Add($buttonClose)

    $buttonClose.Add_Click({ $form.Close() })

    $form.Controls.Add($buttonPanel)

    # Results DataGridView
    $dataGridResults = New-Object System.Windows.Forms.DataGridView
    $dataGridResults.Dock = [System.Windows.Forms.DockStyle]::Fill
    $dataGridResults.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::AllCells
    $dataGridResults.ReadOnly = $true
    $dataGridResults.AllowUserToAddRows = $false
    $dataGridResults.AllowUserToDeleteRows = $false
    $dataGridResults.ColumnHeadersHeightSizeMode = [System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode]::AutoSize

    # Add columns to DataGridView
    $dataGridResults.Columns.Add("ResourceType", "Resource Type") | Out-Null
    $dataGridResults.Columns.Add("GeneratedName", "Generated Name") | Out-Null
    $dataGridResults.Columns.Add("Abbreviation", "Abbreviation") | Out-Null
    $dataGridResults.Columns.Add("RemovedChars", "Removed Characters") | Out-Null

    # Tab 3: Results
    $tabResults = New-Object System.Windows.Forms.TabPage
    $tabResults.Text = "Results"
    $tabResults.Controls.Add($dataGridResults)
    $tabControl.TabPages.Add($tabResults)

    # Generate button click event
    $buttonGenerate.Add_Click({
        $selectedResources = @($listBoxResources.SelectedItems | ForEach-Object { $_ })

        if ($selectedResources.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("Please select at least one resource type.", "No Resources Selected", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }

        # Validate parameters
        if ([string]::IsNullOrWhiteSpace($textEnvironment.Text)) {
            [System.Windows.Forms.MessageBox]::Show("Environment is required.", "Missing Parameter", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }

        if ([string]::IsNullOrWhiteSpace($textRegion.Text)) {
            [System.Windows.Forms.MessageBox]::Show("Region is required.", "Missing Parameter", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }

        if ([string]::IsNullOrWhiteSpace($textUniqueId.Text)) {
            [System.Windows.Forms.MessageBox]::Show("Unique Identifier is required.", "Missing Parameter", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }

        # Clear previous results
        $dataGridResults.Rows.Clear()

        # Call the name generator function
        try {
            Write-Host "========== GENERATION PARAMETERS ==========" -ForegroundColor Cyan
            Write-Host "Environment: $($textEnvironment.Text)" -ForegroundColor Gray
            Write-Host "Region: $($textRegion.Text)" -ForegroundColor Gray
            Write-Host "Unique ID: $($textUniqueId.Text)" -ForegroundColor Gray
            Write-Host "Number: $([int]$numericNumber.Value)" -ForegroundColor Gray
            Write-Host "Separator: '$($textSeparator.Text)'" -ForegroundColor Gray
            Write-Host "Convert to Lower: $($checkLower.Checked)" -ForegroundColor Gray
            Write-Host "Selected Resources Count: $($selectedResources.Count)" -ForegroundColor Gray
            Write-Host "Selected Resources: $($selectedResources -join ', ')" -ForegroundColor Yellow
            Write-Host "ResourceNameSchema: $ResourceNameSchema" -ForegroundColor Gray
            Write-Host "ResourcesData: $ResourcesData" -ForegroundColor Gray
            Write-Host "==========================================" -ForegroundColor Cyan

            $results = New-AzResourceNameGenerator `
                -environment $textEnvironment.Text `
                -resourceTypeNames $selectedResources `
                -regionName $textRegion.Text `
                -uniqueidentifier $textUniqueId.Text `
                -number ([int]$numericNumber.Value) `
                -separator $textSeparator.Text `
                -convertTolower $checkLower.Checked `
                -ResourceNameSchema $ResourceNameSchema `
                -ResourcesData $ResourcesData

            Write-Host "Results count: $(if ($results) { $results.Count } else { 0 })" -ForegroundColor Cyan

            # Add results to DataGridView
            if ($results) {
                foreach ($result in $results) {
                    $dataGridResults.Rows.Add(
                        $result.resourceTypeName,
                        $result.resourceNameGenerated,
                        $result.abbreviation,
                        $result.removedChars
                    )
                }

                # Enable export buttons
                $buttonCopy.Enabled = $true
                $buttonExport.Enabled = $true

                # Switch to Results tab
                $tabControl.SelectedIndex = 2

                [System.Windows.Forms.MessageBox]::Show("Names generated successfully! Check the Results tab.", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            }
            else {
                [System.Windows.Forms.MessageBox]::Show("No results returned. Check the PowerShell console for detailed error information.", "No Results", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            }
        }
        catch {
            Write-Error "Generation Error: $($_.Exception.Message)" -ErrorAction Continue
            Write-Error "Stack Trace: $($_.Exception.StackTrace)" -ErrorAction Continue
            [System.Windows.Forms.MessageBox]::Show("Error generating names:`n`n$($_.Exception.Message)", "Generation Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    })

    # Copy to Clipboard button click event
    $buttonCopy.Add_Click({
        if ($dataGridResults.Rows.Count -gt 0) {
            $clipboardText = @()
            foreach ($row in $dataGridResults.Rows) {
                $clipboardText += "Resource: $($row.Cells[0].Value)"
                $clipboardText += "Generated Name: $($row.Cells[1].Value)"
                $clipboardText += ""
            }

            $clipboardContent = $clipboardText -join [Environment]::NewLine
            [System.Windows.Forms.Clipboard]::SetText($clipboardContent)

            [System.Windows.Forms.MessageBox]::Show("Results copied to clipboard!", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        }
    })

    # Export button click event
    $buttonExport.Add_Click({
        if ($dataGridResults.Rows.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("No results to export.", "No Data", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }

        $saveDialog = New-Object System.Windows.Forms.SaveFileDialog
        $saveDialog.Filter = "CSV Files (*.csv)|*.csv|Text Files (*.txt)|*.txt|All Files (*.*)|*.*"
        $saveDialog.DefaultExt = "csv"

        if ($saveDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            try {
                $exportData = @()
                foreach ($row in $dataGridResults.Rows) {
                    $exportData += [PSCustomObject]@{
                        ResourceType     = $row.Cells[0].Value
                        GeneratedName    = $row.Cells[1].Value
                        Abbreviation     = $row.Cells[2].Value
                        RemovedChars     = $row.Cells[3].Value
                    }
                }

                if ($saveDialog.FileName.EndsWith(".csv")) {
                    $exportData | Export-Csv -Path $saveDialog.FileName -NoTypeInformation -Force
                }
                else {
                    $exportData | Format-Table -AutoSize | Out-File -Path $saveDialog.FileName -Force
                }

                [System.Windows.Forms.MessageBox]::Show("Results exported successfully to:`n`n$($saveDialog.FileName)", "Export Successful", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            }
            catch {
                [System.Windows.Forms.MessageBox]::Show("Error exporting results:`n`n$($_.Exception.Message)", "Export Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        }
    })

    # Browse Schema button click event
    $buttonBrowseSchema.Add_Click({
        $openDialog = New-Object System.Windows.Forms.OpenFileDialog
        $openDialog.Filter = "JSON Files (*.json)|*.json|All Files (*.*)|*.*"
        $openDialog.Title = "Select Naming Schema File"
        
        if ($openDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            try {
                $content = Get-Content -Path $openDialog.FileName -Raw | ConvertFrom-Json -ErrorAction Stop
                $script:ResourceNameSchema = $openDialog.FileName
                $textSchemaFile.Text = $openDialog.FileName
                [System.Windows.Forms.MessageBox]::Show("Schema file loaded successfully from:`n`n$($openDialog.FileName)", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                Write-Host "Naming schema loaded from: $($openDialog.FileName)" -ForegroundColor Green
            }
            catch {
                [System.Windows.Forms.MessageBox]::Show("Error loading schema file:`n`n$($_.Exception.Message)", "Load Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        }
    })

    # Reset Schema button click event
    $buttonResetSchema.Add_Click({
        $defaultSchema = "https://raw.githubusercontent.com/mimachniak/AzureResources-NameGenerator/refs/heads/main/data/general_naming_shema.json"
        $script:ResourceNameSchema = $defaultSchema
        $textSchemaFile.Text = $defaultSchema
        [System.Windows.Forms.MessageBox]::Show("Schema file reset to default.", "Reset Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        Write-Host "Naming schema reset to default: $defaultSchema" -ForegroundColor Green
    })

    # Browse Resources button click event
    $buttonBrowseResources.Add_Click({
        $openDialog = New-Object System.Windows.Forms.OpenFileDialog
        $openDialog.Filter = "JSON Files (*.json)|*.json|Text Files (*.txt)|*.txt|All Files (*.*)|*.*"
        $openDialog.Title = "Select Resources Data File"
        
        if ($openDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            try {
                if ($openDialog.FileName -match '\.json$') {
                    $content = Get-Content -Path $openDialog.FileName -Raw | ConvertFrom-Json -ErrorAction Stop
                }
                else {
                    $content = Get-Content -Path $openDialog.FileName | Where-Object { $_ -notmatch '^\s*$' }
                }
                
                $script:ResourcesData = $openDialog.FileName
                $textResourcesFile.Text = $openDialog.FileName
                
                # Reload the resources in the listbox
                $script:resourceTypesToLoad = @()
                if ($openDialog.FileName -match '\.json$') {
                    $script:resourceTypesToLoad = @(Get-ResourceTypesFromJson -Path $openDialog.FileName)
                }
                else {
                    $script:resourceTypesToLoad = @(Get-Content -Path $openDialog.FileName | Where-Object { $_ -notmatch '^\s*$' })
                }
                
                if ($script:resourceTypesToLoad.Count -gt 0) {
                    $listBoxResources.Items.Clear()
                    foreach ($item in $script:resourceTypesToLoad) {
                        [void]$listBoxResources.Items.Add($item)
                    }
                    [System.Windows.Forms.MessageBox]::Show("Resources file loaded successfully with $($script:resourceTypesToLoad.Count) resources from:`n`n$($openDialog.FileName)", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                    Write-Host "Resources loaded from: $($openDialog.FileName) - Total: $($script:resourceTypesToLoad.Count)" -ForegroundColor Green
                }
                else {
                    [System.Windows.Forms.MessageBox]::Show("No resources found in the selected file.", "No Data", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
                }
            }
            catch {
                [System.Windows.Forms.MessageBox]::Show("Error loading resources file:`n`n$($_.Exception.Message)", "Load Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        }
    })

    # Reset Resources button click event
    $buttonResetResources.Add_Click({
        $scriptDir = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
        $localResourcesFile = Join-Path -Path $scriptDir -ChildPath "data\resourcetypes.json"
        
        $defaultResources = $null
        if (Test-Path $localResourcesFile) {
            $defaultResources = $localResourcesFile
        }
        else {
            $defaultResources = "https://raw.githubusercontent.com/mspnp/AzureNamingTool/refs/heads/main/src/repository/resourcetypes.json"
        }
        
        $script:ResourcesData = $defaultResources
        $textResourcesFile.Text = $defaultResources
        
        # Reload the resources in the listbox
        $script:resourceTypesToLoad = @(Get-ResourceTypesFromJson -Path $defaultResources)
        if ($script:resourceTypesToLoad.Count -gt 0) {
            $listBoxResources.Items.Clear()
            foreach ($item in $script:resourceTypesToLoad) {
                [void]$listBoxResources.Items.Add($item)
            }
        }
        
        [System.Windows.Forms.MessageBox]::Show("Resources file reset to default.", "Reset Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        Write-Host "Resources reset to default: $defaultResources" -ForegroundColor Green
    })

    # Show the form
    [void]$form.ShowDialog()
}
