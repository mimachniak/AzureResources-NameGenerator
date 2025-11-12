# AzureResourcesNameGenerator.psm1
# PowerShell module for generating standardized Azure resource names
# Author: Michal Machniak
# Version: 1.0.0

# Ensure module imports functions dynamically
$PublicFunctions = Get-ChildItem -Path $PSScriptRoot\public\*.ps1 -ErrorAction SilentlyContinue

foreach ($Function in @($PublicFunctions)) {
    try {
        . $Function.FullName
    }
    catch {
        Write-Error "Failed to import function from $($Function.FullName): $_"
    }
}

# Export only public functions
if ($PublicFunctions) {
    Export-ModuleMember -Function $($PublicFunctions.BaseName)
}
else {
    # If you don’t use subfolders, explicitly list functions here
    Export-ModuleMember -Function 'New-AzResourceName', 'Get-AzResourcePrefix'
}
