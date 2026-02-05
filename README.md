
# 🧭 Azure Resource Name Generator PowerShell Module

![PowerShell Gallery](https://img.shields.io/powershellgallery/v/AzureResourcesNameGenerator.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-PowerShell%207%2B-lightgrey)
![Downloads](https://img.shields.io/powershellgallery/dt/AzureResourcesNameGenerator)
[![CI](https://github.com/mimachniak/AzureResources-NameGenerator/actions/workflows/ci-process.yml/badge.svg)](https://github.com/mimachniak/AzureResources-NameGenerator/actions/workflows/ci-process.yml)

---

## 📘 Table of Contents
- [Overview](#overview)
  - [Default loaded data](#Default-loaded-data)
- [Purpose](#purpose)
- [Key Features](#key-features)
- [Install module on your desktop](#install-module-on-your-desktop)
- [Get resources data](#get-resources-data)
   - [Ouput for function example](#Ouput-for-function-example )
- [Generate name for Azure resources](#generate-name-for-Azure-resources)
   - [Naming Schema file guide and example](#Naming-Schema-file-guide-and-example)
   - [Example of Json file with naming schema](#Example-of-Json-file-with-naming-schema)
   - [Example of schema for resources base on json file ](#Example-of-schema-for-resources-base-on-json-file)
   - [Output resources names ](#Output-resources-names)
   - [Output resources in bicep files names:](#Output-resources-in-bicep-files-names)
- [Limitations](#limitations)
- [Features](#features)
- [Testing and code coverage](#testing-and-code-coverage)

---

## Overview
The **Azure Resource Name Generator PowerShell Module** provides an automated and standardized way to generate compliant, consistent, and meaningful names for Azure resources base on your own defined schema for resources. 

It integrates with [**Azure Naming Tools**](https://github.com/mspnp/AzureNamingTool), buy loading resources and requirements.  

The current list of commands implemented in the module:

- [New-AzResourceNameGenerator](./docs/New-AzResourceNameGenerator.md)
- [Get-AzResourcesListGenerator](./docs/Get-AzResourcesListGenerator.md)  
- [New-AzResourceNameGeneratorGUI](./docs/New-AzResourceNameGenerator.md)


---

## Default loaded data:

- **Loaded naming schema file:** [general resources naming shema](https://raw.githubusercontent.com/mimachniak/AzureResources-NameGenerator/refs/heads/main/data/general_naming_shema.json)
- **Loaded resources file:** [Resource types file](https://raw.githubusercontent.com/mspnp/AzureNamingTool/refs/heads/main/src/repository/resourcetypes.json")

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

## Testing and code coverage

This repository uses **Pester** in CI to run tests and generate code coverage. The workflow produces a JaCoCo report file named `coverage.xml` and uploads it as a build artifact.

**Where to find the report:**
- CI artifact: `PesterCodeCoverage` (contains `coverage.xml`)

If you want to run tests locally, run Pester in the repo root and a coverage file will be created as `coverage.xml`.

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

### Ouput for function example for listing resources

```powershell

id                           : 328
resource                     : Web/serverfarms
optional                     : UnitDept
exclude                      : Org,Function
property                     : 
ShortName                    : asp
scope                        : resource group
lengthMin                    : 1
lengthMax                    : 40
validText                    : Alphanumerics and hyphens.
invalidText                  : 
invalidCharacters            : 
invalidCharactersStart       : 
invalidCharactersEnd         : 
invalidCharactersConsecutive : 
regx                         : ^[a-zA-Z0-9-]{1,40}$
staticValues                 : 

id                           : 329
resource                     : Web/sites
optional                     : UnitDept
exclude                      : Org,Function
property                     : Static Web App
ShortName                    : stapp
scope                        : global
lengthMin                    : 2
lengthMax                    : 60
validText                    : Contains alphanumerics and hyphens.
invalidText                  : Can't start or end with hyphen.
invalidCharacters            : 
invalidCharactersStart       : -
invalidCharactersEnd         : -
invalidCharactersConsecutive : 
regx                         : ^[a-zA-Z0-9][a-zA-Z0-9-]{0,58}[a-zA-Z0-9]$
staticValues                 : 

id                           : 330
resource                     : Web/sites
optional                     : UnitDept
exclude                      : Org,Function
property                     : Web App
ShortName                    : app
scope                        : global
lengthMin                    : 2
lengthMax                    : 60
validText                    : Contains alphanumerics and hyphens.
invalidText                  : Can't start or end with hyphen.
invalidCharacters            : 
invalidCharactersStart       : -
invalidCharactersEnd         : -
invalidCharactersConsecutive : 
regx                         : ^[a-zA-Z0-9][a-zA-Z0-9-]{0,58}[a-zA-Z0-9]$
staticValues                 : 

id                           : 331
resource                     : Web/sites
optional                     : UnitDept
exclude                      : Org,Function
property                     : Function App
ShortName                    : func
scope                        : global
lengthMin                    : 2
lengthMax                    : 60
validText                    : Contains alphanumerics and hyphens.
invalidText                  : Can't start or end with hyphen.
invalidCharacters            : 
invalidCharactersStart       : -
invalidCharactersEnd         : -
invalidCharactersConsecutive : 
regx                         : ^[a-zA-Z0-9][a-zA-Z0-9-]{0,58}[a-zA-Z0-9]$
staticValues                 : 

id                           : 332
resource                     : Web/sites
optional                     : UnitDept
exclude                      : Org,Function
property                     : App Service Environment
ShortName                    : ase
scope                        : global
lengthMin                    : 2
lengthMax                    : 60
validText                    : Contains alphanumerics and hyphens.
invalidText                  : Can't start or end with hyphen.
invalidCharacters            : 
invalidCharactersStart       : -
invalidCharactersEnd         : -
invalidCharactersConsecutive : 
regx                         : ^[a-zA-Z0-9][a-zA-Z0-9-]{0,58}[a-zA-Z0-9]$
staticValues                 : 

id                           : 333
resource                     : Web/sites
optional                     : UnitDept
exclude                      : Org,Function
property                     : Azure Static Web Apps
ShortName                    : aswba
scope                        : global
lengthMin                    : 2
lengthMax                    : 60
validText                    : Contains alphanumerics and hyphens.
invalidText                  : Can't start or end with hyphen.
invalidCharacters            : 
invalidCharactersStart       : -
invalidCharactersEnd         : -
invalidCharactersConsecutive : 
regx                         : ^[a-zA-Z0-9][a-zA-Z0-9-]{0,58}[a-zA-Z0-9]$
staticValues                 : 

id                           : 334
resource                     : Web/sites/slots
optional                     : UnitDept
exclude                      : Org,Function
property                     : 
ShortName                    : slot
scope                        : site
lengthMin                    : 2
lengthMax                    : 60
validText                    : Alphanumerics and hyphens.
invalidText                  : 
invalidCharacters            : 
invalidCharactersStart       : 
invalidCharactersEnd         : 
invalidCharactersConsecutive : 
regx                         : ^[a-zA-Z0-9-]{2,60}$
staticValues                 : 

```

## Generate name for Azure resources

- **Loaded naming schema file:** [general resources naming shema](https://raw.githubusercontent.com/mimachniak/AzureResources-NameGenerator/refs/heads/main/data/general_naming_shema.json)
- **Loaded resources file:** [Resource types file](https://raw.githubusercontent.com/mspnp/AzureNamingTool/refs/heads/main/src/repository/resourcetypes.json")

```powershell

# Generate name for multiple resources

New-AzResourceNameGenerator -environment Prod -resourceTypeName @("Storage/storageAccounts", "Web/sites", "Subscription/subscriptions") -regionName "West Europe" -uniqueidentifier MARK@ -number 1 -separator "-"

# Generate name for multiple resources and convert all to lower cases

New-AzResourceNameGenerator -environment Prod -resourceTypeName @("Storage/storageAccounts", "Web/sites") -regionName "West Europe" -uniqueidentifier MARK -number 1 -separator "-" -convertTolower $true

# Generate bicep file with @export() variables

New-AzResourceNameGenerator -environment Prod -resourceTypeName @("Storage/storageAccounts", "Web/sites") -regionName "West Europe" -uniqueidentifier MARK -number 1 -separator "-" -convertTolower $true -bicepFileGeneration -bicepFileType Static -bicepFileOutputPath c:\temp\output_static.bicep

# Generate bicepparam file with extendableParamFiles feature and dynamic name

New-AzResourceNameGenerator -environment Prod -resourceTypeName @("Storage/storageAccounts", "Web/sites") -regionName "West Europe" -uniqueidentifier MARK -number 1 -separator "-" -convertTolower $true -bicepFileGeneration -bicepFileType Dynamic -bicepFileOutputPath c:\temp\output_dynamic.bicepparam

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

### Output resources names:   

```powershell

resourceTypeName      : Storage/storageAccounts
regionName            : West Europe
uniqueidentifier      : MARK
environment           : Prod
abbreviation          : stvm
number                : 1
SchemaPattern         : environment-uniqueidentifier-regionName-abbreviation-number
resourceNameGenerated : prodmarkweustvm01
removedChars          : ----

resourceTypeName      : Storage/storageAccounts
regionName            : West Europe
uniqueidentifier      : MARK
environment           : Prod
abbreviation          : st
number                : 1
SchemaPattern         : environment-uniqueidentifier-regionName-abbreviation-number
resourceNameGenerated : prodmarkweust01
removedChars          : ----

resourceTypeName      : Web/sites
regionName            : West Europe
uniqueidentifier      : MARK
environment           : Prod
abbreviation          : stapp
number                : 1
SchemaPattern         : environment-uniqueidentifier-regionName-abbreviation-number
resourceNameGenerated : prod-mark-weu-stapp-01
removedChars          : 

resourceTypeName      : Web/sites
regionName            : West Europe
uniqueidentifier      : MARK
environment           : Prod
abbreviation          : app
number                : 1
SchemaPattern         : environment-uniqueidentifier-regionName-abbreviation-number
resourceNameGenerated : prod-mark-weu-app-01
removedChars          : 

resourceTypeName      : Web/sites
regionName            : West Europe
uniqueidentifier      : MARK
environment           : Prod
abbreviation          : func
number                : 1
SchemaPattern         : environment-uniqueidentifier-regionName-abbreviation-number
resourceNameGenerated : prod-mark-weu-func-01
removedChars          : 

resourceTypeName      : Web/sites
regionName            : West Europe
uniqueidentifier      : MARK
environment           : Prod
abbreviation          : ase
number                : 1
SchemaPattern         : environment-uniqueidentifier-regionName-abbreviation-number
resourceNameGenerated : prod-mark-weu-ase-01
removedChars          : 

resourceTypeName      : Web/sites
regionName            : West Europe
uniqueidentifier      : MARK
environment           : Prod
abbreviation          : aswba
number                : 1
SchemaPattern         : environment-uniqueidentifier-regionName-abbreviation-number
resourceNameGenerated : prod-mark-weu-aswba-01
removedChars          : 

```

### Output resources in bicep files names:  

#### Static 

Static is using @export() decorator and can be imported to bicep files, @export support only static value.

```bicep

@export()
var storageAccounts_stvm_1 = 'prodmarkweustvm01'

@export()
var storageAccounts_st_1 = 'prodmarkweust01'

@export()
var sites_stapp_1 = 'prod-mark-weu-stapp-01'

@export()
var sites_app_1 = 'prod-mark-weu-app-01'

@export()
var sites_func_1 = 'prod-mark-weu-func-01'

@export()
var sites_ase_1 = 'prod-mark-weu-ase-01'

@export()
var sites_aswba_1 = 'prod-mark-weu-aswba-01'


```

#### Dynamic

Dynamic is integreted with extended bicepparm feature. 

```bicep

using none

param environment = 'Prod'

param uniqueidentifier = 'MARK'

param regionName = 'WEu'

param number = '01'

param storageAccounts_stvm_1 = '${environment}${uniqueidentifier}${regionName}stvm${number}'
param storageAccounts_st_1 = '${environment}${uniqueidentifier}${regionName}st${number}'
param sites_stapp_1 = '${environment}-${uniqueidentifier}-${regionName}-stapp-${number}'
param sites_app_1 = '${environment}-${uniqueidentifier}-${regionName}-app-${number}'
param sites_func_1 = '${environment}-${uniqueidentifier}-${regionName}-func-${number}'
param sites_ase_1 = '${environment}-${uniqueidentifier}-${regionName}-ase-${number}'
param sites_aswba_1 = '${environment}-${uniqueidentifier}-${regionName}-aswba-${number}'


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
    - Add option to use separator or not based on resource type.
    - Custom schema for different resource types.
    - Add support for more complex naming conventions.
    - Load suggestion of resources from external source (e.g., CSV, database).
    - Add interactive mode for user input.
    - Add corelation between resources (e.g., VM and its associated resources).
    - Convert to module for easier reuse.


