# Azure Resource Name Generator - Troubleshooting Guide

## Issue: "No Results" When Generating Names

### Root Cause
The resource types must match the format used in the `resourcetypes.json` file. The file uses resource type names in the format:
- `Storage/storageAccounts`
- `Network/virtualNetworks`
- `Compute/virtualMachines`

NOT the Microsoft.* format like:
- `Microsoft.Storage/storageAccounts` ❌
- `Microsoft.Network/virtualNetworks` ❌

## Solution

### Option 1: Use the Provided Sample File
1. Click **"Load Resources"** button in the Resources tab
2. Navigate to `data\sample_resourcetypes.txt`
3. Select and load the file
4. The listbox will populate with valid resource types

### Option 2: Load Resources from the Default JSON
The GUI can load resources directly from the JSON file:
```powershell
# This loads from the resourcetypes.json file automatically
New-AzResourceNameGeneratorGUI
```

### Option 3: Create Your Own Resource File
Create a text file with one resource per line using the correct format:
```
Storage/storageAccounts
Network/virtualNetworks
Compute/virtualMachines
KeyVault/vaults
Sql/servers
Web/sites
```

Or use a JSON file extracted from the resourcetypes.json file.

## Debugging Steps

1. **Check the PowerShell Console** for error messages and loaded resource count
2. **Verify Resource Selection** - You must select at least one resource from the listbox
3. **Validate Parameters**:
   - Environment: Must not be empty (e.g., "Dev", "Test", "Prod")
   - Region: Must not be empty (e.g., "westeurope", "eastus")
   - Unique Identifier: Must not be empty (e.g., "MARK", "APP")

4. **Check Resource Format** - If you load custom resources, ensure they match the format:
   - Valid: `ServiceCategory/resourceType`
   - Invalid: `Microsoft.ServiceCategory/resourceType`

## Correct Format Examples

From `resourcetypes.json`:
```json
{
  "id": 1,
  "resource": "AnalysisServices/servers",
  "ShortName": "as",
  ...
}
```

The `resource` field value is what you should use: `AnalysisServices/servers`

## Need More Resource Types?

Extract them from the official `resourcetypes.json` file:
- Local: `data\resourcetypes.json`
- Online: https://raw.githubusercontent.com/mspnp/AzureNamingTool/refs/heads/main/src/repository/resourcetypes.json

You can create a custom list by copying the `resource` field values from the JSON file.
