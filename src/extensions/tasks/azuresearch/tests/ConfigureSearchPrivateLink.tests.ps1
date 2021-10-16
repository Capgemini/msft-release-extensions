# Before running this script ensure az module is installed and you are logged in to Azure

Describe "ConfigureSearchPrivateLinkTest" {
    Context "Exists" {

            It "Runs" {
                $scriptPath = "$PSScriptRoot\..\ConfigureSearchPrivateLink.ps1"

                & "$scriptPath" `
                    -ServiceName "devtrfinfse1001" `
                    -ResourceGroupName "DEVTRFINFRG1001" `
                    -PrivateLinkName "search-devtrfinfse1001-sa-devtrfinfsa1011" `
                    -PrivateLinkResourceId "/subscriptions/d6f720f6-0e75-44c9-a406-2840c33ec61e/resourceGroups/DEVTRFINFRG1001/providers/Microsoft.Storage/storageAccounts/devtrfinfsa1011" `
                    -PrivateLinkGroup "blob"
            }
    }
}
