
# 🧭 Azure Resource Name Generator PowerShell Module

![PowerShell Gallery](https://img.shields.io/powershellgallery/v/AzureResourceNameGenerator.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-PowerShell%207%2B-lightgrey)

---

## 📘 Table of Contents
- [Overview](#overview)
- [Purpose](#purpose)
- [Key Features](#key-features)
- [Install module on your desktop](#install-module-on-your-desktop)
- [Get resources data](#get-resources-data)
- [Generate name for Azure resources](#generate-name-for-Azure-resources)
- [Limitations](#limitations)
- [Features](#features)

---

## Overview
The **Azure Resource Name Generator PowerShell Module** provides an automated and standardized way to generate compliant, consistent, and meaningful names for Azure resources base on your own defined schema for resources. 

It integrates with [**Azure Naming Tools**](https://github.com/mspnp/AzureNamingTool), buy loading resources and requirements.  

The current list of commands implemented in the module:

- [New-AzResourceNameGenerator](./docs/New-AzResourceNameGenerator.md)
- [Get-AzResourcesListGenerator](./docs/Get-AzResourcesListGenerator.md)


---



## Purpose
This module simplifies the process of creating Azure resource names that align with organizational or Microsoft best practices by:

- Automatically retrieving valid resource name patterns based on resource type.
- Generating suggested names according to standard naming rules.
- Validating existing resource names for compliance and uniqueness.

---

## Key Features  
- **Name Generation:** Generates compliant names for Azure resources (e.g., VMs, Storage Accounts, Resource Groups, etc.). 
- **Bring you own naming convention** Loading your own custom naming schema with transformations in Json files. 
- **Validation:** Validates names against Azure naming conventions and provides feedback.    
- **Load your data** PowerShell module allow to load resource data / namiing schema form any source but in JSON type. 

---

## Install module on your desktop

```powershell
# Import module
Import-Module AzureResourcesNameGenerator

# Install module 

Install-Module AzureResourcesNameGenerator

```

## Get resources data

```powershell

# Get all available resource types
Get-AzResourcesListGenerator -ShowOnlyResourceType

# Get naming details for specific resources
Get-AzResourcesListGenerator -ShowResourcesDetails

# Get all data stored in JSON file on repo: https://github.com/mspnp/AzureNamingTool
Get-AzResourcesListGenerator

```

## Generate name for Azure resources

- **Loaded naming schema file:** [general resources naming shema](https://raw.githubusercontent.com/mimachniak/AzureResources-NameGenerator/refs/heads/main/data/general_naming_shema.json)
- **Loaded resources file:** [Resource types file](https://raw.githubusercontent.com/mspnp/AzureNamingTool/refs/heads/main/src/repository/resourcetypes.json")

```powershell

# Generate name for multiple resources

New-AzResourceNameGenerator -environment Prod -resourceTypeName @("Storage/storageAccounts", "Web/sites", "Subscription/subscriptions") -regionName "West Europe" -uniqueidentifier MARK@ -number 1 -separator "-"

# Generate name for multiple resources and convert all to lower cases

New-AzResourceNameGenerator -environment Prod -resourceTypeName @("Storage/storageAccounts", "Web/sites") -regionName "West Europe" -uniqueidentifier MARK -number 1 -separator "-" -convertTolower $true

```

## Naming Schema file guide and example 

This json files describe how your resource shcema will looks like 

- **name** - descibe parameters used in PowerShell module, cannot be change
- **length** - max lenght of name part, will be cutoff automatical
- **order** - order descibe sorting parts of naming convention generator.
- **transformation** - is it reguired transformation true / false  
        - **transformationRegex** - regexp of transformation  
        - **pattern** - pattern of transformation  
        - **replacement** - replacemnt of transformation  

### Example of Json file with naming schema

```json

[

    {
        "name": "environment", # cannot to be channge 
        "length": 5,
        "order": 1,
        "transformation": false,
        "transformationRegex": {}
    },
    {
        "name": "uniqueidentifier", # cannot to be channge 
        "length": 50,
        "order": 2,
        "transformation": false,
        "transformationRegex": {}
        
    },
    {
        "name": "regionName", # cannot to be channge 
        "length": 3,
        "order": 3,
        "transformation": true,
        "transformationRegex": {
            "pattern": "^(\\w)\\w*\\s+(\\w{2})\\w*$", 
            "replacement": "$1$2"
        }
    },
    {
        "name": "abbreviation", # cannot to be channge 
        "length": 6,
        "order": 4,
        "transformation": false,
        "transformationRegex": {}
    },
    {
        "name": "number", # cannot to be channge 
        "length": 1,
        "order": 5,
        "transformation": true,
        "transformationRegex": {
            "pattern": "\\b(\\d)\\b",
            "replacement": "0$1"
        }
    }

]

```

### Example of schema for resources base on json file 

File above will generate resources name schema that will look like this:

```powershell

environment-uniqueidentifier-regionName-abbreviation-number

```

### Input Data for schema and actions base on file

-environment Prod  
-resourceTypeName @("Storage/storageAccounts", "Web/sites", "Subscription/subscriptions")  
-regionName "West Europe" **will be transformation to WEu base on schema declaration**  
-uniqueidentifier MARK@ - **Remove all characters that are not allowed**  
-number 1 - **will be transformation to "01" base on schema declaration**  
-separator "-"  

### Output for this resources will in this schema will be like this: 

```powershell

Generated resource Storage/storageAccounts name base on schema and transformation: Prod-MARK@-WEu-stvm-01
Resource name: prodmarkweustvm01 # remove characters that are not allowed
Generated resource Storage/storageAccounts name base on schema and transformation: Prod-MARK@-WEu-st-01
Resource name: prodmarkweust01 # remove characters that are not allowed
Generated resource Web/sites name base on schema and transformation: Prod-MARK@-WEu-stapp-01
Resource name: Prod-MARK-WEu-stapp-01 # remove characters that are not allowed
Generated resource Web/sites name base on schema and transformation: Prod-MARK@-WEu-app-01
Resource name: Prod-MARK-WEu-app-01 # remove characters that are not allowed
Generated resource Web/sites name base on schema and transformation: Prod-MARK@-WEu-func-01
Resource name: Prod-MARK-WEu-func-01 # remove characters that are not allowed
Generated resource Web/sites name base on schema and transformation: Prod-MARK@-WEu-ase-01
Resource name: Prod-MARK-WEu-ase-01 # remove characters that are not allowed
Generated resource Web/sites name base on schema and transformation: Prod-MARK@-WEu-aswba-01
Resource name: Prod-MARK-WEu-aswba-01 # remove characters that are not allowed
Generated resource Subscription/subscriptions name base on schema and transformation: Prod-MARK@-WEu-subcr-01

```

## Limitations 
    - Naming schema supports only JSON
    - Resource type supports only JSON

## Features

    - Add more resource types and their specific naming rules to the resource_schema.json file.
    - Implement additional transformations or validations as needed.
    - Integrate with Azure CLI or PowerShell Az module to validate names against existing resources.
    - Implement unit tests to validate the naming logic.
    - Create a GUI for easier input of parameters.
    - Allow exporting the generated names to a file or clipboard.
    - Add option to use separator or not based on resource type.
    - Custom schema for different resource types.
    - Add support for more complex naming conventions.
    - Load suggestion of resources from external source (e.g., CSV, database).
    - Add interactive mode for user input.
    - Add corelation between resources (e.g., VM and its associated resources).
    - Convert to module for easier reuse.
    - Export to bicep or ARM template.
    - Generated bicpe variables for resource names.


