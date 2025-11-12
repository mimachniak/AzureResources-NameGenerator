# Get-AzResourcesListGenerator

## SYNOPSIS

Azure Resource Naming Convention Generator resource managment.

## Example 

```powershell

Get-AzResourcesListGenerator -ShowOnlyResourceType

# Output 

Using default WEB data source for resource types, defined in this repo: https://github.com/mspnp/AzureNamingTool
AnalysisServices/servers
ApiManagement/service
ApiManagement/service/api-version-sets
ApiManagement/service/apis
ApiManagement/service/apis/issues
ApiManagement/service/apis/issues/attachments
ApiManagement/service/apis/issues/comments
ApiManagement/service/apis/operations
ApiManagement/service/apis/operations/tags
ApiManagement/service/apis/releases
ApiManagement/service/apis/schemas

```

## PARAMETERS

### -ResourcesData
    Use default settings to load resource schema from web in JSON format.
### -ShowOnlyResourceType
    Show only Resource Types.
### -ShowResourcesDetails
    Show Resource Details like regxp, shotname, valid and invalid text.
