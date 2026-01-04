# New-AzResourceNameGenerator

## SYNOPSIS

Azure Resource Naming Convention Generator, This script generates Azure resource names based on a predefined naming convention schema and resource-specific rules.It ensures that the generated names comply with Azure's naming restrictions and best practices.

## Example 

```powershell

    New-AzResourceNameGenerator -environment Prod -resourceTypeName @("Storage/storageAccounts", "Web/sites", "Subscription/subscriptions") -regionName "West Europe" -uniqueidentifier MARK@ -number 1 -separator "-"

    # Global Convert to lower cases

    New-AzResourceNameGenerator -environment Prod -resourceTypeName @("Storage/storageAccounts", "Web/sites") -regionName "West Europe" -uniqueidentifier MARK -number 1 -separator "-" -convertTolower $true

    #Load custom schema: 

    New-AzResourceNameGenerator -environment Prod -resourceTypeName @("Storage/storageAccounts", "Web/sites") -regionName "West Europe" -uniqueidentifier MARK -number 1 -separator "-" -convertTolower $true -ResourceNameSchema "https://raw.githubusercontent.com/mimachniak/AzureResources-NameGenerator/refs/heads/main/data/general_naming_shema.json"

```
    
## PARAMETERS

### -resourceTypeName {hashTable}
    The type of Azure resource (e.g., "Virtual Machine", "Storage Account").
###  regionName {String}
    The Azure region where the resource will be deployed (e.g., "East US", "West Europe").
### -uniqueidentifier {String}
    A unique identifier for the resource, such as a project code or application name.
###  -environment {String}
    The environment in which the resource will be used (e.g., "Dev", "Test", "Prod").
###  -number {intiger}
    An optional number to append to the resource name for uniqueness (default is 1).
### -separator {charcters}
    The character used to separate different parts of the resource name (default is "-").
### -convertTolower {boole}
    A switch to convert the final resource name to lowercase (default is $true).
### -ResourceNameSchema {String}
    Path to the resource scheama JSON file that defines general naming convention. Cane be web o local path
### -ResourcesData {String}
    Use default settings to load resource schema from web in JSON format. Default URL: 
### -bicepFileGeneration
    A switch to enable Bicep file generation for the resources.
### -bicepFileType
    Type of name generation: Dynamic or Static for bicep generation. Static will create variables for each resource with generated name, Dynamic will use parameters and concat function.
### -bicepFileOutputPath
    Path where the Bicep files will be generated.