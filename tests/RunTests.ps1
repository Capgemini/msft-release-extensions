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
# Get-Childitem *.Tests.ps1 -recurse | ForEach-Object { Invoke-Pester -CI -Path $_.FullName}
# $testResults = Invoke-Pester -OutputFile Test.xml -OutputFormat NUnitXml -CodeCoverage (Get-ChildItem -Path $PSScriptRoot\*.psm1 -Exclude *.Tests.* ).FullName -PassThru
$scriptPath = Split-Path $MyInvocation.MyCommand.Path -Parent

$path = Resolve-Path -Path "$scriptPath\..\src\extensions\tasks\owasp-scan\ps_modules"

# Get-Childitem *.Tests.ps1 -recurse | ForEach-Object { Invoke-Pester -CI -Path $_.FullName -OutputFormat NUnitXml  -OutputFile "./Test-Pester.xml" -CodeCoverage "$path/$([System.IO.Path]::GetFileNameWithoutExtension($_)).psm1" -PassThru}
Get-Childitem *.Tests.ps1 -recurse -exclude "CreateReleaseNotesTest.tests.ps1"  | ForEach-Object { 
    [string]$modulePath="$path\$([System.IO.Path]::GetFileNameWithoutExtension($_).Replace('.Tests', '')).psm1"; 
    Write-Host $modulePath
    Invoke-Pester -Script $_.FullName -OutputFile "$scriptPath\TestResults\Pester-Tests.xml" -OutputFormat NUnitXml  -Verbose -CodeCoverage "$modulePath" -CodeCoverageOutputFile "$scriptPath\TestResults\Pester-Coverage.xml" -CodeCoverageOutputFileFormat JaCoCo -PassThru -Show All
}

