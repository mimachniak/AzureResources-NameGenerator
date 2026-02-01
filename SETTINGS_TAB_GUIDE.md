# Azure Resource Name Generator GUI - Settings Tab Guide

## New Settings Tab Features

The GUI now includes a **Settings** tab that allows you to customize:
1. **Naming Schema File** - The JSON file that defines your naming convention rules
2. **Resources Data File** - The JSON or text file containing available Azure resource types

## Using the Settings Tab

### Loading a Custom Naming Schema

1. Click the **Settings** tab in the GUI
2. Click **Browse Schema...** button next to "Naming Schema File"
3. Select your custom JSON schema file
4. Click **Open**
5. The schema will be loaded and used for all subsequent name generations

**Schema File Format:**
The schema file should be a JSON array defining naming components:
```json
[
  {
    "order": 1,
    "name": "environment"
  },
  {
    "order": 2,
    "name": "uniqueidentifier"
  },
  {
    "order": 3,
    "name": "regionName"
  },
  {
    "order": 4,
    "name": "abbreviation"
  },
  {
    "order": 5,
    "name": "number"
  }
]
```

### Loading a Custom Resources File

1. Click the **Settings** tab in the GUI
2. Click **Browse Resources...** button next to "Resources Data File"
3. Select your custom resources file (JSON or text format)
4. Click **Open**
5. The resources list will be automatically updated in the Resources tab

**Resources File Formats:**

**Text Format (one resource per line):**
```
Storage/storageAccounts
Network/virtualNetworks
Compute/virtualMachines
KeyVault/vaults
```

**JSON Format (with detailed resource information):**
```json
[
  {
    "id": 1,
    "resource": "Storage/storageAccounts",
    "ShortName": "st",
    "lengthMin": "3",
    "lengthMax": "24",
    "regx": "^[a-z0-9]{3,24}$"
  },
  {
    "id": 2,
    "resource": "Network/virtualNetworks",
    "ShortName": "vnet",
    "lengthMin": "2",
    "lengthMax": "64",
    "regx": "^[a-zA-Z0-9][a-zA-Z0-9-_.]{0,62}[a-zA-Z0-9]$"
  }
]
```

### Resetting to Default Files

1. Click the **Settings** tab
2. Click either:
   - **Reset to Default** next to "Naming Schema File" - to reset the naming convention
   - **Reset to Default** next to "Resources Data File" - to reset the resources list

The GUI will automatically reload the default files:
- **Default Naming Schema:** Remote URL from GitHub
- **Default Resources:** Local file (`data\resourcetypes.json`) or remote URL if not found

## File Path Display

Each file's current path is displayed in read-only text boxes for reference. These show:
- Local file paths (e.g., `C:\projects\custom_schema.json`)
- Remote URLs (e.g., `https://raw.githubusercontent.com/...`)

## Creating Custom Naming Schema Files

Your custom naming schema should define the order and names of components used in resource naming:

```json
[
  {
    "order": 1,
    "name": "environment"
  },
  {
    "order": 2,
    "name": "uniqueidentifier"
  },
  {
    "order": 3,
    "name": "regionName"
  },
  {
    "order": 4,
    "name": "abbreviation"
  },
  {
    "order": 5,
    "name": "number"
  }
]
```

When generating names, the GUI combines these components in the specified order with the separator (default: "-").

## Creating Custom Resources Files

### Text Format (Simple)
Create a `.txt` file with one resource per line:
```
Microsoft.Storage/storageAccounts
Microsoft.Network/virtualNetworks
Microsoft.Compute/virtualMachines
```

### JSON Format (Recommended)
Create a `.json` file with detailed resource information:
```json
[
  {
    "id": 1,
    "resource": "Storage/storageAccounts",
    "ShortName": "st",
    "scope": "global",
    "lengthMin": "3",
    "lengthMax": "24",
    "validText": "Lowercase letters, numbers only.",
    "regx": "^[a-z0-9]{3,24}$",
    "staticValues": ""
  },
  {
    "id": 2,
    "resource": "Network/virtualNetworks",
    "ShortName": "vnet",
    "scope": "resource group",
    "lengthMin": "2",
    "lengthMax": "64",
    "validText": "Letters, numbers, periods, hyphens, underscores.",
    "regx": "^[a-zA-Z0-9][a-zA-Z0-9-_.]{0,62}[a-zA-Z0-9]$",
    "staticValues": ""
  }
]
```

## Example Workflow

1. **Start the GUI:**
   ```powershell
   New-AzResourceNameGeneratorGUI
   ```

2. **Load custom files:**
   - Go to Settings tab
   - Click "Browse Resources..." → Select `custom_resources.json`
   - Click "Browse Schema..." → Select `custom_schema.json`

3. **Generate names:**
   - Go to Resources tab
   - Select resources you want
   - Go to Parameters tab
   - Enter your parameters
   - Click "Generate Names"

4. **Export results:**
   - View results in Results tab
   - Click "Export to File" to save as CSV or text

## Troubleshooting

### "Failed to load resources"
- Ensure your JSON file is valid JSON format
- Check file path is correct
- Try clicking "Reset to Default" to verify the GUI works with defaults

### "No resources appear in the list"
- Verify the file contains data
- Check that JSON is properly formatted
- Ensure resource names match the format expected by the generator

### Schema changes not applying
- The schema is used for all new generations
- Click "Generate Names" after loading a new schema

## Tips

- **Share custom files:** You can share your custom `schema.json` and `resources.json` files with team members
- **Version control:** Store custom files in a repository for consistency
- **Backup defaults:** Keep a copy of the default files before modifying
- **Validate JSON:** Use an online JSON validator to check your custom files before loading
