# Before running this script ensure az module is installed and you are logged in to Azure

Describe "SetSynapseDataFlow" {
    Context "Exists" {

            It "Runs" {

                $scriptPath = "$PSScriptRoot\..\SetSynapseDataFlow.ps1"

                & "$scriptPath" `
                    -SynapseWorkspaceName "TSTTRFINFAS1001" `
                    -SourceFile "C:\Extract\TemplateForWorkspace.json" `
                    -TempDirectory "C:\Extract\Temp" `
                    -ReplaceToken "1002" `
                    -ReplaceTokenValue "1001" `
                    -EnvironmentPrefix "TST" `
            }
    }
}