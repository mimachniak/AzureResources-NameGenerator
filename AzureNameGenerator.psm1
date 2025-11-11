#Set-StrictMode -Version Latest

# Get public and private function definition files
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue -Recurse )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue -Recurse )

# Importing all functions
foreach ($import in @($public + $private)) {
    try {
        Write-Verbose "Importing $($import.FullName)..."
        . $import.FullName
    }
    catch {
        Write-Error "Failed to import function $($import.FullName): $_"
    }
}

# Export public functions
Export-ModuleMember -Function '*' -Alias '*'