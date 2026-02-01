# Azure Resource Name Generator - Bug Fixes

## Issues Fixed

### 1. **Missing JSON Parsing for Local Resource Files**
   - **File**: [New-AzResourceNameGenerator.ps1](AzureResourcesNameGenerator/public/New-AzResourceNameGenerator.ps1#L232)
   - **Problem**: When loading the `resourcetypes.json` file from disk, the function was reading it as a raw string instead of parsing it as JSON.
   - **Fix**: Added `| ConvertFrom-Json` to properly parse the JSON file.
   ```powershell
   # Before:
   $responseResources = Get-Content -Path $ResourcesData -Raw
   
   # After:
   $responseResources = Get-Content -Path $ResourcesData -Raw | ConvertFrom-Json
   ```

### 2. **Results Not Returned for Valid Resource Names**
   - **File**: [New-AzResourceNameGenerator.ps1](AzureResourcesNameGenerator/public/New-AzResourceNameGenerator.ps1#L331)
   - **Problem**: The function only added results to the output array when a resource name FAILED validation. When a name PASSED validation, it was discarded.
   - **Fix**: Added logic to include valid names in the output.
   ```powershell
   if ($original -match $regex) {
       Write-Host "Valid: $original"
       
       # Now adds to output even when valid
       $resourceOutput += [PSCustomObject]@{
           resourceTypeName = $resourceTypeName
           resourceNameGenerated = $original
           ...
       }
   }
   ```

### 3. **Missing Return Statement**
   - **File**: [New-AzResourceNameGenerator.ps1](AzureResourcesNameGenerator/public/New-AzResourceNameGenerator.ps1#L512)
   - **Problem**: The function didn't explicitly return the `$resourceOutput` array.
   - **Fix**: Added explicit return statement at the end of the function.
   ```powershell
   # Return the generated resource names
   return $resourceOutput
   ```

### 4. **GUI Using Remote URL Instead of Local File**
   - **File**: [New-AzResourceNameGeneratorGUI.ps1](AzureResourcesNameGenerator/public/New-AzResourceNameGeneratorGUI.ps1#L46)
   - **Problem**: The GUI was always trying to load resources from a remote URL, which could fail or be slow.
   - **Fix**: Modified to use the local `resourcetypes.json` file first, then fall back to the URL if not found.
   ```powershell
   # Now prioritizes local file
   if (Test-Path $localResourcesFile) {
       $ResourcesData = $localResourcesFile
   } else {
       $ResourcesData = "https://raw.githubusercontent.com/mspnp/AzureNamingTool/..."
   }
   ```

### 5. **Improved Error Logging and Debugging**
   - **File**: [New-AzResourceNameGeneratorGUI.ps1](AzureResourcesNameGenerator/public/New-AzResourceNameGeneratorGUI.ps1#L468)
   - **Improvement**: Enhanced console output showing all parameters being passed to the generator for easier debugging.

## Testing Results

All fixes have been tested and verified:

```powershell
$result = New-AzResourceNameGenerator `
    -environment "Dev" `
    -resourceTypeNames @("Blueprint/blueprints", "Storage/storageAccounts") `
    -regionName "westeurope" `
    -uniqueidentifier "MARK" `
    -number 1 `
    -separator "-" `
    -convertTolower $true `
    -ResourcesData "D:\Git\AzureResources-NameGenerator\data\resourcetypes.json"

# Result: 3 names generated successfully
```

## How to Test the GUI

1. Load the module:
   ```powershell
   Import-Module "D:\Git\AzureResources-NameGenerator\AzureResourcesNameGenerator"
   ```

2. Launch the GUI:
   ```powershell
   New-AzResourceNameGeneratorGUI
   ```

3. Click "Load Resources" and select `data\sample_resourcetypes.txt`

4. Select a resource from the list (e.g., "Storage/storageAccounts")

5. Click "Generate Names"

6. Results should now appear in the Results tab
