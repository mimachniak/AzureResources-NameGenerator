    @{
    # Script module or binary module file associated with this manifest.
    RootModule = ''

    # Version number of this module.
    ModuleVersion = '1.0.0'

    # Supported PSEditions
    CompatiblePSEditions = @('Desktop', 'Core')

    # ID used to uniquely identify this module
    GUID = 'c49b051b-c0ff-4652-b1ee-f73226a15799'

    # Author of this module
    Author = 'Michał Machniak'

    # Company or vendor of this module
    CompanyName = 'Michał Machniak'

    # Copyright statement for this module
    Copyright = '(c) Michał Machniak. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'PowerShell module generates Azure resource names based on a predefined naming convention schema and resource-specific rules.It ensures that the generated names comply with Azure naming restrictions and best practices'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Functions to export from this module
    FunctionsToExport = @('*')

    # Cmdlets to export from this module
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @('*')

    # Aliases to export from this module
    AliasesToExport = @()

    PrivateData      = @{
        PSData = @{
            ExternalModuleDependencies = @('Microsoft.PowerShell.Management', 'Microsoft.PowerShell.Utility')
            ProjectUri                 = 'https://github.com/mimachniak/AzureResources-NameGenerator'
            Tags                       = @('Azure', 'Naming', 'Convention', 'Generator', 'Validation')
        }
    }
    }