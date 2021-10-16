# Before running this script ensure az module is installed and you are logged in to Azure

Describe "ConfigureSynapsePrivateLinkTest" {
    Context "Exists" {

            It "Runs" {
                $scriptPath = "$PSScriptRoot\..\ConfigureSynapsePrivateLink.ps1"

                & "$scriptPath" `
                    -SynapseWorkspaceName "devtrfinfas1003" `
                    -PrivateLinkName "synapse-ws-dl-devtrfinfsa1003" `
                    -PrivateLinkResourceId "/subscriptions/d6f720f6-0e75-44c9-a406-2840c33ec61e/resourceGroups/DEVTRFINFRG1003/providers/Microsoft.Storage/storageAccounts/devtrfinfsa1003" `
                    -PrivateLinkGroup "blob"
            }
    }
}
