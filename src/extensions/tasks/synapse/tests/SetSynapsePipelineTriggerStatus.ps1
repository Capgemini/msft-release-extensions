# Before running this script ensure az module is installed and you are logged in to Azure

Describe "SetSynapsePipelineTriggerStatusTest" {
    Context "Exists" {

            It "Runs" {

                $scriptPath = "$PSScriptRoot\..\SetSynapsePipelineTriggerStatus.ps1"

                & "$scriptPath" `
                    -SynapseWorkspaceName "DEVTRFINFAS1002" `
                    -ActivateTriggers $true 
            }
    }
}
