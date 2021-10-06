# Get-Childitem *.Tests.ps1 -recurse | ForEach-Object { Invoke-Pester -CI -Path $_.FullName -PassThru}
# Get-Childitem *.Tests.ps1 -recurse | ForEach-Object { Invoke-Pester -CI -Path $_.FullName}
# $testResults = Invoke-Pester -OutputFile Test.xml -OutputFormat NUnitXml -CodeCoverage (Get-ChildItem -Path $PSScriptRoot\*.psm1 -Exclude *.Tests.* ).FullName -PassThru

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
param()

$scriptPath = Split-Path $MyInvocation.MyCommand.Path -Parent
Remove-Module "OwaspScanHelpers" -Force -ErrorAction Ignore
$path = Resolve-Path -Path "$scriptPath\..\..\src\extensions\tasks\owasp-scan\ps_modules"
Write-Host $path
Import-Module -Name "$path\VstsTaskSdk\VstsTaskSdk.psm1"
Import-Module -Name "$path\OwaspScanHelpers"

InModuleScope 'OwaspScanHelpers' {

    BeforeAll { 
        # Global variables
        $containerName = "dummy-owasptests-dev-aci-01"
        $resourceGroup = "dummy-owasptests-dev-rg-01"
        $location = "UK South"
        $optionFilePathParameter = "OptionFilePath"
        $storageAccountName = "dummywowasptestsdevst01"
        $shareName = "owaspresults"
        $imageName = "owasp/zap2docker-weekly"
        $apiSwaggerEndpoint = "https://apidummytestsite/swagger/v1/swagger.json"
        $owaspZAPOptions = "zap-api-scan.py ...."
        $aciVNet = "aci-vnet"
        $aciSubnet = "aci-subnet"
        $Env:BUILD_BUILDID = "b001"
    }
    Describe "OwaspScanModule" {

        BeforeAll {

            Mock Write-Host {}
            Mock Test-Path { return $true }
            Mock Start-Sleep {} 
            Mock Get-ChildItem {}
            Mock az {}
            Mock az -MockWith { '{"key": "123456"}' } -ParameterFilter { "$args" -match "storage account keys list" }
            Mock Get-RandomString { return "abc12" }
        }

        Context "Set-OwaspApiScanOptions" {

            BeforeAll {
                $setOwaspApiScanOptionsParameters = @{
                    ApiSwaggerEndpoint = $apiSwaggerEndpoint
                    ResourceGroupName  = $resourceGroup
                    StorageAccountName = $storageAccountName  
                    ShareName          = $shareName  
                    OptionFilePath     = $optionFilePathParameter               
                }
            }

            It "Should throw An Exception" {
                Mock Get-Content { throw }

                { Set-OwaspApiScanOptions @setOwaspApiScanOptionsParameters } | Should -Throw

            }

            It "Should return True" {
                Mock Get-Content -Verifiable { "
                    replacer.full_list(0).description=AzureAdAuth 
                    replacer.full_list(0).enabled=true 
                    replacer.full_list(0).matchtype=REQ_HEADER 
                    replacer.full_list(0).matchstr=Authorization 
                    replacer.full_list(0).regex=false 
                    replacer.full_list(0).replacement=Bearer\ DummyAccessToken1/fFAGRNJru1FTz70BzhT3Zg
                    replacer.full_list(1).description=ContentTypeHeader 
                    replacer.full_list(1).enabled=true 
                    replacer.full_list(1).matchtype=REQ_HEADER 
                    replacer.full_list(1).matchstr=Content-Type 
                    replacer.full_list(1).regex=false 
                    replacer.full_list(1).replacement=application/json 
                    replacer.full_list(2).description=AccceptHeader 
                    replacer.full_list(2).enabled=true 
                    replacer.full_list(2).matchtype=REQ_HEADER 
                    replacer.full_list(2).matchstr=Accept 
                    replacer.full_list(2).regex=false 
                    replacer.full_list(2).replacement=application/json
                "}

                $actualResult = Set-OwaspApiScanOptions @setOwaspApiScanOptionsParameters
                
                Should -Invoke Get-Content -Times 1 -Exactly

                $actualResult | Should -Not -BeNullOrEmpty
                $actualResult.OwaspZAPOptions | Should -BeExactly "zap-api-scan.py -t ""https://apidummytestsite/swagger/v1/swagger.json"" -f openapi -r ""apitest-b001-abc12/Api-abc12.html"" -x ""apitest-b001-abc12/Api-abc12.xml"" -z '-config replacer.full_list(0).description=AzureAdAuth replacer.full_list(0).enabled=true replacer.full_list(0).matchtype=REQ_HEADER replacer.full_list(0).matchstr=Authorization replacer.full_list(0).regex=false replacer.full_list(0).replacement=Bearer\ DummyAccessToken1/fFAGRNJru1FTz70BzhT3Zg replacer.full_list(1).description=ContentTypeHeader replacer.full_list(1).enabled=true replacer.full_list(1).matchtype=REQ_HEADER replacer.full_list(1).matchstr=Content-Type replacer.full_list(1).regex=false replacer.full_list(1).replacement=application/json replacer.full_list(2).description=AccceptHeader replacer.full_list(2).enabled=true replacer.full_list(2).matchtype=REQ_HEADER replacer.full_list(2).matchstr=Accept replacer.full_list(2).regex=false replacer.full_list(2).replacement=application/json ' -d"
                $actualResult.XmlReportName | Should -BeExactly "apitest-b001-abc12/Api-abc12.xml"
                $actualResult.AciInstanceName | Should -BeExactly "owasp-zap-aci-b001-abc12"
            }
        }

        Context "New-OwaspContainer" {
            BeforeEach {                
                Mock az -MockWith { '{"data": "container successfully created..."}' } -ParameterFilter { "$args" -match "container create" }
                Mock az -MockWith { '{"data": "container id: 123456..."}' } -ParameterFilter { "$args" -match "container show" } 
                Mock az -MockWith { 'Terminated' } -ParameterFilter { "$args" -match "container show" -and "$args" -match "--query containers\[\]\.instanceView.currentState\.state" }

                $newOwaspContainerParameters = @{
                    AciInstanceName    = $containerName
                    ResourceGroupName  = $resourceGroup
                    Location           = $location
                    VNet               = $aciVNet
                    Subnet             = $aciSubnet
                    StorageAccountName = $storageAccountName
                    ShareName          = $shareName
                    ImageName          = $imageName
                    OwaspZAPOptions    = $owaspZAPOptions
                }
            }

            It "Should throw an Exception if an Error occurs when creating the container" {                
                Mock az -MockWith { Throw "An error occurred when creating the container instance." } -ParameterFilter { "$args" -match "container create" } 

                { New-OwaspContainer @newOwaspContainerParameters } | Should -Throw
            }

            It "Should return True if container has been created successfully" {

                $actualResult = New-OwaspContainer @newOwaspContainerParameters

                $actualResult[0] | Should -Be '{"data": "container successfully created..."}' 
                $actualResult[1] | Should -Be $true    
            }

        }

        Context "Remove-OwaspContainer" {

            It "Should throw an Exception if Container Instance is not found" {                
                Function Get-AzContainerGroup { $null }

                { Remove-OwaspContainer -AciInstanceName $containerName -ResourceGroupName $resourceGroup } | Should -Throw "An Azure Container Instance with the name '$containerName' does not exist in the Resource Group $resourceGroup"
            }

            It "Should return True if resource exists and has been successfully deleted" {                
                Function Get-AzContainerGroup { @{id = "123456789" } }
                Function Remove-AzContainerGroup { "Successfully Deleted the container" }
                    
                $actualResult = Remove-OwaspContainer -AciInstanceName $containerName -ResourceGroupName $resourceGroup

                $actualResult[0] | Should -Be "Successfully Deleted the container"
                $actualResult[1] | Should -Be $true
            }

        }

        Context "Get-OwaspResults" {
            BeforeEach {
                Mock az -MockWith { '{"filename": "123456"}' } -ParameterFilter { "$args" -match "storage file download" }
                Mock Invoke-XslLoad {}
                Mock Invoke-XslTransform {}

                $getOwaspResultsParameters = @{
                    ResourceGroupName  = $resourceGroup
                    StorageAccountName = $storageAccountName
                    ShareName          = $shareName
                    XmlReportName      = "owaspresults.xml"
                    OwaspZapReportPath = "C:\Temp\"
                }
            }

            It "Should throw an Exception if an Error occurs when creating the container" {                
                Mock az -MockWith { Throw "File does not exist." } -ParameterFilter { "$args" -match "storage file download" } 

                { Get-OwaspResults @getOwaspResultsParameters } | Should -Throw
            }

            It "Should return True if container has been created successfully" {
            
                $actualResult = Get-OwaspResults @getOwaspResultsParameters

                $actualResult | Should -Be $true    
            }

        }

        
        Context "Test-OptionFile" {

            BeforeAll {
                Mock Test-Null { $false }
                Mock Test-Path { $true }  # default for all parameter values
                Mock Test-Path { $false } -ParameterFilter { $LiteralPath -eq 'C:\DummyPathDoesNotExists' } 
            }

            It "Should throw an Exception if options File is not Found" {                  
                $filePath = "C:\DummyPathDoesNotExists"
                { Test-OptionFile -value $filePath -variableName $optionFilePathParameter } | Should -Throw "File path $filePath does not exist."
            }

            It "Should throw an Exception if Path does not end with .prop (options filepath: <value>)" -ForEach @(
                @{ value = "/path/c/d/options.txt" }
                @{ value = "/path/c/d/options.log" }
                @{ value = "/path/c/d/options.prop1" }
            ) {
                { Test-OptionFile -value $value -variableName $optionFilePathParameter } | Should -Throw  "Invalid Option file = $value. File Name should have '.prop' extension"
            }

            It "Should return true if valid options.prop file is provided" {                
                $value = "/tmp/options.prop"

                $actualResult = Test-OptionFile -value $value -variableName $optionFilePathParameter
                $actualResult | Should -Be $true
            }

        }
        

        Context "Test-Null" {

            It "Should return <expected> (<value>)" -ForEach @(
                @{ value = " non-empty string "; expected = $false }
                @{ value = "/path"; expected = $false }
            ) {
                Test-Null -value $value -variableName $optionFilePathParameter | Should -Be $expected
            }

            It "Should throw an Exception (<scenario>)" -ForEach @(
                @{ value = ""; scenario = "Empty String" }
                @{ value = " "; scenario = "Empty String with spaces" }
                @{ value = $null; scenario = "Null value" }
            ) {
                { Test-Null -value $value -variableName $optionFilePathParameter -ErrorAction Stop } | Should -Throw # "Parameter $variable cannot be null or empty."
            }

        }
    }
}