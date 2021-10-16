# Before running this script ensure az module is installed and you are logged in to Azure

Describe "ConfigureSearchAccessTest" {
    Context "Exists" {
        $scriptPath = "$PSScriptRoot\..\ConfigureSearchAccess.ps1"

            It "RunsPrivate" {
                & "$scriptPath" `
                    -ServiceName "devtrfinfse1003" `
                    -ResourceGroupName "DEVTRFINFRG1003" `
                    -PublicAccess "Disabled"
            }

            It "RunsPublic" {
                & "$scriptPath" `
                    -ServiceName "devtrfinfse1003" `
                    -ResourceGroupName "DEVTRFINFRG1003" `
                    -PublicAccess "Enabled"
            }
    }
}
