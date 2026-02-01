@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'AzureResourcesNameGenerator.psm1'

    # Version number of this module.
    ModuleVersion = '1.0.5'

    # Supported PSEditions
    CompatiblePSEditions = @('Desktop', 'Core')

    # ID used to uniquely identify this module
    GUID = 'c49b051b-c0ff-4652-b1ee-f73226a15799'

    # Author of this module
    Author = 'Michal Machniak'

    # Company or vendor of this module
    CompanyName = 'Michal Machniak'

    # Copyright statement for this module
    Copyright = '(c) Michal Machniak. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'PowerShell module generates Azure resource names based on a predefined naming convention schema and resource-specific rules.It ensures that the generated names comply with Azure naming restrictions and best practices'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Functions to export from this module
    FunctionsToExport = @('*')

    # Cmdlets to export from this module
    CmdletsToExport = @('New-AzResourceNameGenerator','Get-AzResourcesListGenerator','New-AzResourceNameGeneratorGUI')

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport = @()

    PrivateData      = @{
        PSData = @{
            # ExternalModuleDependencies = @('Microsoft.PowerShell.Management', 'Microsoft.PowerShell.Utility')
            ProjectUri                 = 'https://github.com/mimachniak/AzureResources-NameGenerator'
            LicenseUri                 = 'https://github.com/mimachniak/AzureResources-NameGenerator/blob/main/LICENSE'
            IconUri = ''
            Tags                       = @('Azure', 'Naming', 'Convention', 'Generator', 'Validation')

            # ReleaseNotes of this module
            ReleaseNotes = '
            v.1.0.3
                - Add output to PS Custom object with generated name and details.
                - Add bicep parameter to generate bicep variable declaration.
                - Add bicep output - Static @export() with variables.
                - Add bicep output - Dynamic with extendableParamFiles.
            v.1.0.2 - Fixed minor bugs and improved performance.
            v.1.0.0 - Initial release of AzureResourcesNameGenerator module.
            '

            # Prerelease string of this module
            Prerelease   = ''
        } # End of PSData hashtable
    } # End of PrivateData hashtable
} # End of module manifest hashtable