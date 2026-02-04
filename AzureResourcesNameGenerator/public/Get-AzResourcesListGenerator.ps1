function Get-AzResourcesListGenerator {

<#

.Author
    Michał Machniak

.SYNOPSIS
    Azure Resource Naming Convention Generator
.DESCRIPTION
    This script generates Azure resource names based on a predefined naming convention schema and resource-specific rules.
    It ensures that the generated names comply with Azure's naming restrictions and best practices.
.PARAMETER ResourcesData
    Use default settings to load resource schema from web in JSON format.
.PARAMETER ShowOnlyResourceType
    Show only Resource Types.
.PARAMETER ShowResourcesDetails
    Show Resource Details like regxp, shotname, valid and invalid text.
.EXAMPLE

.NOTES
 

#>

[CmdletBinding()]
param(

    [Parameter(HelpMessage = "Use default settings to load resource schema from web.")]
    [string]$ResourcesData = "https://raw.githubusercontent.com/mspnp/AzureNamingTool/refs/heads/main/src/repository/resourcetypes.json",

    [Parameter(HelpMessage = "Show only Resource Types.")]
    [switch]$ShowOnlyResourceType,
    [Parameter(HelpMessage = "Show Resource Details like regxp, shotname, valid and invalid text.")]
    [switch]$ShowResourcesDetails

    )

    # check there is data in response for resource types

    if ($ResourcesData -eq "https://raw.githubusercontent.com/mspnp/AzureNamingTool/refs/heads/main/src/repository/resourcetypes.json") {
        Write-Host "Using default WEB data source for resource types, defined in this repo: https://github.com/mspnp/AzureNamingTool"
    }

    if ($ResourcesData -match '^(http://|https://|ftp://)') {
        write-Verbose  "Loading WEB data from: $ResourcesData"
        try {
                $responseResources = Invoke-RestMethod -Uri $ResourcesData

            } catch {
                Throw "Failed to fetch data from URL: $ResourcesData. Error: $_"
            }
    }
    elseif (Test-Path $ResourcesData) {
        #return 'Local Path'
            $responseResources = Get-Content -Path $ResourcesData -Raw | ConvertFrom-Json
    }
    else {
        return 'Unknown'

    }

    if ($ShowOnlyResourceType -and -not $ShowResourcesDetails) {
    # Show only resource types, unique and sorted
    $responseResources.resource | Sort-Object -Unique | ForEach-Object {
            [PSCustomObject]@{
                ResourceType = $_
            }
        }
        
    }
    elseif ($showResourcesDetalils) {
        # Show detailed resource information
        # Return detailed objects
        $responseResources | ForEach-Object {
            [PSCustomObject]@{
                Resource      = $_.resource
                ShortName     = $_.ShortName
                Regex         = $_.regx
                ValidText     = $_.validText
                InvalidText   = $_.invalidText
            }
        }
    }
    else {
        # Default output
        $responseResources
    }

} #end function Get-AzResourcesListGenerator {

