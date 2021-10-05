"current location: $(Get-Location)"
"script root: $PSScriptRoot"
"retrieve available modules"

$modules = Get-Module -list

if ($modules.Name -notcontains 'pester') {
    Write-Host "installing the module Pester"
    Install-Module -Name Pester -Scope CurrentUser -Force -SkipPublisherCheck
    Write-Host "Successfully installed the module Pester"
}

Import-Module Pester -MinimumVersion 5.0.0

$Env:BUILD_BUILDID = "B01"
$scriptPath = Split-Path $MyInvocation.MyCommand.Path -Parent

$path = Resolve-Path -Path "$scriptPath\..\src\extensions\tasks\owasp-scan\ps_modules"

Get-Childitem *.Tests.ps1 -recurse -exclude "CreateReleaseNotesTest.tests.ps1"  | ForEach-Object { 

    [string]$modulePath="$path\$([System.IO.Path]::GetFileNameWithoutExtension($_).Replace('.Tests', '')).psm1"; 
    Write-Host $modulePath

    $configuration = [PesterConfiguration]@{
        Run = @{
            Path = $_.FullName
        }
        Output = @{
            Verbosity = 'Detailed'
        }
        TestResult   = @{
            Enabled      = $true
            OutputFormat = "NUnitXml"
            OutputPath   = "$scriptPath\TestResults\Pester-Coverage.xml"
        }
        CodeCoverage = @{
            Enabled      = $true
            Path         = $modulePath
            OutputFormat = "JaCoCo"
            OutputPath   = "$scriptPath\TestResults\Pester-Coverage.xml"
        }
        Should = @{
            ErrorAction = 'Continue'
        }
    }

    Invoke-Pester -Configuration $Configuration

}

