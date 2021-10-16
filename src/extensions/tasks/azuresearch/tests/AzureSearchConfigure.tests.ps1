# Before running this script ensure az module is installed and you are logged in to Azure

Describe "AzureSearchConfigureTest" {
    Context "Exists" {

            It "RunsConnString" {

                $keys = Get-AzSearchAdminKeyPair -ResourceGroupName "DEVTRFINFRG1003" -ServiceName "devtrfinfse1003"

                $storageAccount = Get-AzStorageAccount  -ResourceGroupName "DEVTRFINFRG1003" -Name "devtrfinfsa1003"

                $scriptPath = "$PSScriptRoot\..\AzureSearchConfigure.ps1"
                $configFilePath= "$PSScriptRoot\TestFiles\AzureSearchConfig.json"

                & "$scriptPath" `
                    -ApiKey $keys.Primary `
                   -ServiceName "devtrfinfse1003" `
                    -JsonConfigFilePath $configFilePath `
                    -ConnectionString "ResourceId=$($storageAccount.Id)"
            }
            
            It "RunsStorageName" {

                $keys = Get-AzSearchAdminKeyPair -ResourceGroupName "DEVTRFINFRG1003" -ServiceName "devtrfinfse1003"

                $scriptPath = "$PSScriptRoot\..\AzureSearchConfigure.ps1"
                $configFilePath= "$PSScriptRoot\TestFiles\AzureSearchConfig.json"

                & "$scriptPath" `
                    -ApiKey $keys.Primary `
                    -ServiceName "devtrfinfse1003" `
                    -JsonConfigFilePath $configFilePath `
                    -StorageAccountName "devtrfinfsa1003" `
                    -StorageAccountRG "DEVTRFINFRG1003"
            }
    }
}
