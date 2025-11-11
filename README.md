
# 🧭 Azure Resource Name Generator PowerShell Module

## Overview
The **Azure Resource Name Generator PowerShell Module** provides an automated and standardized way to generate compliant, consistent, and meaningful names for Azure resources base on your own defined schema for resources. 

It integrates with [**Azure Naming Tools**]("https://github.com/mspnp/AzureNamingTool"), buy loading resources and requirements

---

## Purpose
This module simplifies the process of creating Azure resource names that align with organizational or Microsoft best practices by:

- Automatically retrieving valid resource name patterns based on resource type.
- Generating suggested names according to standard naming rules.
- Validating existing resource names for compliance and uniqueness.

---

## Key Features  
- 🔹 **Name Generation:** Generates compliant names for Azure resources (e.g., VMs, Storage Accounts, Resource Groups, etc.).  
- 🔹 **Validation:** Validates names against Azure naming conventions and provides feedback.    

---

## Example Usage

```powershell
# Import module
Import-Module AzureResourceNameGenerator

# Get all available resource types
Get-AzResourceName -ShowOnlyResourceType

# Get naming details for specific resources
Get-AzResourceName -ShowResourcesDetails

# Generate a name for a specific Azure resource type
Get-AzResourceName -ResourceType "Microsoft.Storage/storageAccounts" -Region "eastus" -Project "FinOps"
