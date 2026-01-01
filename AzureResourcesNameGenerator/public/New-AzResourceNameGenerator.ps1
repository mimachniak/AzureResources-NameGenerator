function New-AzResourceNameGenerator {

<#

.Author
    Michał Machniak

.SYNOPSIS
    Azure Resource Naming Convention Generator
.DESCRIPTION
    This script generates Azure resource names based on a predefined naming convention schema and resource-specific rules.
    It ensures that the generated names comply with Azure's naming restrictions and best practices.
.PARAMETER resourceTypeName
    The type of Azure resource (e.g., "Virtual Machine", "Storage Account").
.PARAMETER regionName
    The Azure region where the resource will be deployed (e.g., "East US", "West Europe").
.PARAMETER uniqueidentifier
    A unique identifier for the resource, such as a project code or application name.
.PARAMETER environment
    The environment in which the resource will be used (e.g., "Dev", "Test", "Prod").
.PARAMETER number
    An optional number to append to the resource name for uniqueness (default is 1).
.PARAMETER separator
    The character used to separate different parts of the resource name (default is "-").
.PARAMETER convertTolower
    A switch to convert the final resource name to lowercase (default is $true).

.PARAMETER ResourceNameSchema
    Path to the resource scheama JSON file that defines general naming convention.
.PARAMETER ResourcesData
    Use default settings to load resource schema from web in JSON format.
.EXAMPLE
    New-AzResourceNameGenerator -environment Prod -resourceTypeName @("Storage/storageAccounts", "Web/sites", "Subscription/subscriptions") -regionName "West Europe" -uniqueidentifier MARK@ -number 1 -separator "-"
    New-AzResourceNameGenerator -environment Prod -resourceTypeName @("Storage/storageAccounts", "Web/sites") -regionName "West Europe" -uniqueidentifier MARK -number 1 -separator "-" -convertTolower $true
.NOTES
    Ensure that the .data\resource_schema.json and .data\general_naming_shema.json files are present in the script directory.
    Adjust the paths in the script if necessary to point to the correct location of these files.

    New-AzResourceNameGenerator -environment Prod -resourceTypeName @("Storage/storageAccounts", "Web/sites", "Subscription/subscriptions") -regionName "West Europe" -uniqueidentifier MARK@ -number 1 -separator "-"
    New-AzResourceNameGenerator -environment Prod -resourceTypeName @("Storage/storageAccounts", "Web/sites") -regionName "West Europe" -uniqueidentifier MARK -number 1 -separator "-" -convertTolower $true
    New-AzResourceNameGenerator -environment Prod -resourceTypeName @("Storage/storageAccounts", "Web/sites") -regionName "West Europe" -uniqueidentifier MARK -number 1 -separator "-" -convertTolower $true -bicepFileGeneration -bicepFileType Static -bicepFileOutputPath c:\temp

#>

[CmdletBinding(DefaultParameterSetName = 'NoBicep')]
param(

    [Parameter(Mandatory = $true, HelpMessage = "Specify the environment in which the resource will be used (e.g., Dev, Test, Prod).")]
    [string]$environment,

    [Parameter(HelpMessage = "Select the type of Azure resource.")]
    [string[]]$resourceTypeNames,

    [Parameter(Mandatory = $true, HelpMessage = "Select the Azure region where resources will be deployed.")]
    [string]$regionName,

    [Parameter(Mandatory = $true, HelpMessage = "Provide a unique identifier for the resource, such as a project code or application name.")]
    [string]$uniqueidentifier,

    [Parameter(Mandatory = $true, HelpMessage = "An optional number to append to the resource name for uniqueness.")]
    [int]$number = 1,

    [Parameter(Mandatory = $true, HelpMessage = "The character used to separate different parts of the resource name.")]
    [string]$separator = "-",

    [Parameter(HelpMessage = "A switch to convert the final resource name to lowercase.")]
    [bool]$convertTolower = $false,

    [Parameter(HelpMessage = "Include property in the resource name if applicable.")]
    [string]$property,

    [Parameter(HelpMessage = "Path to the resource scheama JSON file.")]
    [string]$ResourceNameSchema = "https://raw.githubusercontent.com/mimachniak/AzureResources-NameGenerator/refs/heads/main/data/general_naming_shema.json",


    [Parameter(HelpMessage = "Use default settings to load resource schema from web.")]
    [string]$ResourcesData = "https://raw.githubusercontent.com/mspnp/AzureNamingTool/refs/heads/main/src/repository/resourcetypes.json",

    [Parameter(
        HelpMessage = "Enable Bicep file generation for the resources.",
        ParameterSetName = 'Bicep'
    )]
    [switch]$bicepFileGeneration,

    [Parameter(
        HelpMessage = "Type of name generation: Dynamic or Static for bicep generation. Static will create variables for each resource with generated name, Dynamic will use parameters and concat function.",
        ParameterSetName = 'Bicep'
    )]
    [ValidateSet("Dynamic", "Static")]
    [string]$bicepFileType = "Dynamic",

    [Parameter(
        Mandatory = $true,
        HelpMessage = "Path where the Bicep files will be generated.",
        ParameterSetName = 'Bicep'
    )]
    [ValidateNotNullOrEmpty()]
    [string]$bicepFileOutputPath

    )

    # Function process to sanitize string based on regex
    function Sanitize-String {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$string,
        [Parameter(Mandatory = $true)][string]$regex
    )

        Write-Verbose "Sanitize-String: Input='$string' Regex='$regex'"

        # quick pass if already valid
        if ($string -match $regex) {
            Write-Verbose "String already valid per regex."
            return @{ Sanitized = $string; RemovedChars = "" }
        }

        $sanitized = $string
        $removedChars = ""

        # --- Extract bracket groups and expand ranges into literal characters ---
        $allowedCharsMatches = [regex]::Matches($regex, '\[([^\]]+)\]')
        $expandedAllowed = ""

        foreach ($m in $allowedCharsMatches) {
            $group = $m.Groups[1].Value
            # Use -creplace (case-sensitive) to correctly expand ranges
            $group = $group -creplace 'a-z', 'abcdefghijklmnopqrstuvwxyz'
            $group = $group -creplace 'A-Z', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
            $group = $group -creplace '0-9', '0123456789'
            $expandedAllowed += $group
            Write-Verbose "Expanded character group: '$group'"
        }

        if (-not $expandedAllowed) {
            $expandedAllowed = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-'
        }

        # Preserve first-seen order and remove duplicates
        $seen = New-Object System.Collections.Generic.List[char]
        foreach ($c in $expandedAllowed.ToCharArray()) {
            if (-not $seen.Contains($c)) { $seen.Add($c) }
        }
        $uniqueAllowed = -join $seen

        # --- Determine case rules from the expanded literal set ---
        $hasUpper = $false; $hasLower = $false
        foreach ($c in $uniqueAllowed.ToCharArray()) {
            if ([char]::IsUpper($c)) { $hasUpper = $true }
            if ([char]::IsLower($c)) { $hasLower = $true }
        }

        Write-Verbose "Expanded allowed chars (literal): $uniqueAllowed"
        Write-Verbose "Case detection -> HasUpper=$hasUpper HasLower=$hasLower"

        # --- Build safe character class: escape meta-chars, move hyphen last ---
        $safeAllowed = $uniqueAllowed -replace '([\\\^\]\[])', '\\$1'
        if ($safeAllowed -match '-') {
            $safeAllowed = ($safeAllowed -replace '-', '') + '-'
        }
        $pattern = "[^$safeAllowed]"
        Write-Verbose "Constructed removal pattern: $pattern"

        # --- Remove disallowed chars and record them ---
        $removedChars = -join (($sanitized -split '') | Where-Object { $_ -match $pattern })
        $sanitized = ($sanitized -replace $pattern, '')

        # --- Trim invalid leading/trailing dashes if regex forbids them ---
        if ($regex -match '^\^\[a-zA-Z0-9\]' -and $regex -match '\[a-zA-Z0-9\]\$$') {
            $beforeTrim = $sanitized
            $sanitized = $sanitized.Trim('-')
            if ($beforeTrim -ne $sanitized) {
                Write-Verbose "Trimmed leading/trailing hyphens."
            }
        }

        # --- Enforce max length if present ---
        $max = $null
        if ($regex -match '\{(?:\d+),(\d+)\}') {
            $max = [int]$matches[1]
        } elseif ($regex -match '\{(\d+)\}') {
            $max = [int]$matches[1]
        }
        if ($max -and $sanitized.Length -gt $max) {
            $removedFromTrim = $sanitized.Substring($max)
            $sanitized = $sanitized.Substring(0, $max)
            $removedChars += $removedFromTrim
            Write-Verbose "Trimmed to max length $max"
        }

        # --- Defensive case application using expanded literal set ---
        if ($hasLower -and -not $hasUpper) {
            Write-Verbose "Lowercase-only allowed by expanded set → converting to lowercase (Invariant)."
            $sanitized = $sanitized.ToLowerInvariant()
        } elseif ($hasUpper -and $hasLower) {
            Write-Verbose "Mixed-case allowed by expanded set → preserving case."
        } else {
            Write-Verbose "Case not explicit or digits-only → preserving original case."
        }

        Write-Verbose "Output: Sanitized='$sanitized' Removed='$removedChars'"

        return @{
            Sanitized    = $sanitized
            RemovedChars = $removedChars
        }
    } # end function Sanitize-String

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
        $responseResources = Get-Content -Path $ResourcesData -Raw
    }
    else {
        return 'Unknown'
        Write-Verbose "Sanitize-String: '$string' using regex '$regex' → pattern '$pattern' → '$sanitized'"

    }

    $resourceOutput = @()
    $resourceBicep = @()

    # check there is data in response for schema
    if ($ResourceNameSchema -match '^(http://|https://|ftp://)') {
        Write-Verbose  "General naming convention schema loaded web: $ResourceNameSchema"
        try {
                $responseName = Invoke-RestMethod -Uri $ResourceNameSchema

            } catch {
                Throw "Failed to fetch data from URL: $ResourceNameSchema. Error: $_"
            }
    }
    elseif (Test-Path $ResourceNameSchema) {
        Write-Verbose  "General naming convention schema loaded Local Path: $ResourceNameSchema"
        $responseName = Get-Content -Path $ResourceNameSchema -Raw | ConvertFrom-Json 
    }
    else {
        return 'Unknown'
    }

    # Generating general naming schema pattern

    $generalNamingSchema = $responseName | Sort-Object order
    $generalSchemaPattern = ($generalNamingSchema | Select-Object -ExpandProperty name) -join $separator
    Write-Verbose  "General naming schema defined in file: $generalSchemaPattern"
    
    # check there is data in response
    if (-Not $responseResources) {
        Throw "No data found in the response resource won't be generated"
    } else {

        foreach ($resourceTypeName in $resourceTypeNames) {
        Write-Verbose  "Processing resource type definition: $resourceTypeName"


        $ResourceData = $responseResources | where-object {$_.resource -eq "$resourceTypeName"}
        foreach ($resource in $ResourceData) {
            Write-Verbose  "Generating name for resource type $($resourceTypeName) with ShortName: $($resource.ShortName), regex $($resource.regx), max length $($resource.lengthMax), valid text $($resource.validText)"

            # Put parameters into hashtable dynamically for resources
            $mappingTable = @{
                resourceTypeName = $resourceTypeName
                regionName       = $regionName
                uniqueidentifier = $uniqueidentifier
                environment      = $environment
                abbreviation     = $resource.ShortName
                number           = $number
            }

            # Mpping and generating resource name parts

            $resourceNameParts = foreach ($attribute in $generalNamingSchema) {
                
                $name   = $attribute.name
                $attributeValue = $mappingTable[$name]
                $length    = [int]$attribute.length
                $transformation = [bool]$attribute.transformation

                if ($transformation -eq $true -and $attribute.transformationRegex.pattern -ne $null -and $attribute.transformationRegex.replacement -ne $null) {
                    $attributeValue = [regex]::Replace($attributeValue, $attribute.transformationRegex.pattern, $attribute.transformationRegex.replacement)
                } 

                # Truncate to limit and don't transform just substring
                if (($attributeValue.length -gt $length) -and ($transformation -eq $false)) {
                $attributeValue = $attributeValue.Substring(0, $length)
                }

                $attributeValue
            }

            # to lower case if switch is set
                if ($convertTolower) {
                    $finalResourceName = ($resourceNameParts -join $separator).ToLower()
                    Write-Verbose  "Generated resource $($resourceTypeName) name base on schema and transformation: $($finalResourceName)"

                }   else {
                    $finalResourceName = $resourceNameParts -join $separator
                    Write-Verbose  "Generated resource $($resourceTypeName) name base on schema and transformation: $($finalResourceName)"
                }
            # Validate and sanitize resource name based on regex from resource definition

            $original = $finalResourceName
            $regex = $($resource.regx | Out-String)
            if ($resource.regx -eq "" -or $resource.regx -eq $null) {
                Write-Warning "No regex found for resource type: $resourceTypeName. Skipping validation."
                Write-Host "Resource name: $($finalResourceName)"
                continue
            } else {
                write-Verbose  "Validating resource name: $original against regex: $regex"
                if ($original -match $regex) {
                 Write-Host "Valid: $original"
                }
                else {
                $result = Sanitize-String -string $original -regex "$regex"
                Write-Verbose "Orginal string base on parameters: $original"
                Write-Verbose "Resource name: $($result.Sanitized)"
                Write-Verbose "Removed characters form string: $($result.RemovedChars)"


                $resourceOutput += [PSCustomObject]@{
                        resourceTypeName = $resourceTypeName
                        regionName       = $regionName
                        uniqueidentifier = $uniqueidentifier
                        environment      = $environment
                        abbreviation     = $resource.ShortName
                        number           = $number
                        SchemaPattern = $generalSchemaPattern
                        resourceNameGenerated     = $result.Sanitized
                        removedChars     = $result.RemovedChars
                    }

                $resourceBicep += [PSCustomObject]@{
                        resourceTypeName = $resourceTypeName
                        regionName       = $regionName
                        uniqueidentifier = $uniqueidentifier
                        environment      = $environment
                        abbreviation     = $resource.ShortName
                        number           = $number
                        SchemaPattern = $generalSchemaPattern
                        resourceNameGenerated     = $result.Sanitized
                        removedChars     = $result.RemovedChars
                    }

                }
            }
  

            } # foreach end resource in resourceTypeName
    
        } # foreach end resourceTypeNames

            $resourceOutput

            $resourceOutput | Export-Csv "C:\temp\output.csv" -NoTypeInformation -Force

         ### bicep file generation can be added here in future ###
            if ($PSCmdlet.ParameterSetName -eq 'Bicep') {
                Write-Host "Bicep generation enabled"
                Write-Host "Output path: $bicepFileOutputPath"

                $resourceOutputBicep = @()

                if ($bicepFileType -eq "Dynamic") {
                    Write-Host "Bicep file type: Dynamic"

                    $resourceOutputBicep += "using none"
                    $resourceOutputBicep += ""


                    

                    if ($bicepFileOutputPath.Extension -ieq ".bicep") {
                        $bicepFileOutputPath = [IO.Path]::ChangeExtension($bicepFileOutputPath.FullName, ".bicepparam")
                    }
                    if (-not (Test-Path $bicepFileOutputPath)) {                       
                        New-Item -Path $bicepFileOutputPath -ItemType File -Force | Out-Null

                        $resourceOutputBicep | Out-File  "$bicepFileOutputPath" -Force
                    }

                } elseif ($bicepFileType -eq "Static") {

                    Write-Host "Bicep file type: Static"

                    foreach ($bicepResource in $resourceOutput) {
                        
                        
                        $resourceTypeNameBicep = ($bicepResource.resourceTypeName).Split('/')[-1]
                        $resourceOutputBicep += "@export()"
                        $resourceOutputBicep += "var $($resourceTypeNameBicep)_$($bicepResource.abbreviation)_$($bicepResource.number) = '$($bicepResource.resourceNameGenerated)'"
                        $resourceOutputBicep += ""

                    }

                    if (-not (Test-Path $bicepFileOutputPath)) {
                        New-Item -Path $bicepFileOutputPath -ItemType File -Force | Out-Null

                        $resourceOutputBicep | Out-File  "$bicepFileOutputPath" -Force
                    }

                }
            }
            else {
                Write-Verbose "Bicep generation disabled"
            }
        
    } # else end respond is true


} # function end process