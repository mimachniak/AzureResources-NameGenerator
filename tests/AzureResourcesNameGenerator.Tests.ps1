$ErrorActionPreference = 'Stop'

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path (Join-Path $here '..')).Path
$modulePath = Join-Path $repoRoot 'AzureResourcesNameGenerator' 'AzureResourcesNameGenerator.psd1'
$resourcesData = Join-Path $repoRoot 'data' 'resourcetypes.json'
$schemaData = Join-Path $repoRoot 'data' 'general_naming_shema.json'

Import-Module $modulePath -Force

Describe 'Get-AzResourcesListGenerator' {
    Context 'Local test data file' {
                BeforeAll {
                        $script:testResourcesData = Join-Path $TestDrive 'resourcetypes-test.json'
                        @'
[
    {
        "resource": "TypeA",
        "ShortName": "a",
        "regx": "^a$",
        "validText": "",
        "invalidText": ""
    },
    {
        "resource": "TypeB",
        "ShortName": "b",
        "regx": "^b$",
        "validText": "",
        "invalidText": ""
    },
    {
        "resource": "TypeA",
        "ShortName": "a",
        "regx": "^a$",
        "validText": "",
        "invalidText": ""
    }
]
'@ | Set-Content -Path $script:testResourcesData -Encoding utf8
                }

        It 'returns unique resource types when ShowOnlyResourceType is set' {
                        $result = Get-AzResourcesListGenerator -ResourcesData $script:testResourcesData -ShowOnlyResourceType

            $result | Should -HaveCount 2
            $result.ResourceType | Should -Contain 'TypeA'
            $result.ResourceType | Should -Contain 'TypeB'
        }

        It 'returns raw objects when no switches are set' {
            $result = Get-AzResourcesListGenerator -ResourcesData $script:testResourcesData

            $result | Should -HaveCount 3
            $result[0].resource | Should -Be 'TypeA'
        }
    }
}

Describe 'New-AzResourceNameGenerator' {
    It 'generates a name that matches the resource regex' {
        $results = New-AzResourceNameGenerator `
            -environment Dev `
            -resourceTypeNames 'ApiManagement/service' `
            -regionName 'West Europe' `
            -uniqueidentifier 'App' `
            -number 1 `
            -separator '-' `
            -convertTolower $true `
            -ResourceNameSchema $schemaData `
            -ResourcesData $resourcesData

        $results | Should -HaveCount 1
        $results[0].resourceNameGenerated | Should -Match $results[0].regex
    }

    It 'sanitizes invalid characters from the generated name' {
        $results = New-AzResourceNameGenerator `
            -environment Dev `
            -resourceTypeNames 'ApiManagement/service' `
            -regionName 'West Europe' `
            -uniqueidentifier 'App@' `
            -number 1 `
            -separator '-' `
            -convertTolower $true `
            -ResourceNameSchema $schemaData `
            -ResourcesData $resourcesData

        $results | Should -HaveCount 1
        $results[0].resourceNameGenerated | Should -Not -Match '@'
        if ($results[0].removedChars) {
            $results[0].removedChars | Should -Match '@'
        } else {
            $results[0].removedChars | Should -BeNullOrEmpty
        }
        $results[0].resourceNameGenerated | Should -Match $results[0].regex
    }
}
