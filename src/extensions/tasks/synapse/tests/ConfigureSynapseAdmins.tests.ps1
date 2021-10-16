# Before running this script ensure az module is installed and you are logged in to Azure

Describe "ConfigureSynapseAdminsTest" {
    Context "Exists" {

            It "Runs" {

                $scriptPath = "$PSScriptRoot\..\ConfigureSynapseAdmins.ps1"

                & "$scriptPath" `
                    -SynapseWorkspaceName "DEVTRFINFAS1003" `
                    -SynapseAdminRole "AG-Azure-TRD-DEV1-Contributor" `
                    -SynapseAdminRoleId "e267558d-40ad-49a4-a740-2b6ee1f7581f"
            }
    }
}
