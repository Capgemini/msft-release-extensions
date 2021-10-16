# Before running this script ensure az module is installed and you are logged in to Azure

Describe "SetDataLakeFolderStructureTest" {
    Context "Exists" {

            It "Runs-devtrfinfdl1003" {

                $scriptPath = "$PSScriptRoot\..\SetDataLakeFolderStructure.ps1"

                & "$scriptPath" `
                    -DataLakeAccountName "devtrfinfdl1003" `
                    -ContainerName "defraanalyticsdata" `
                    -ConfigurationFile "$PSScriptRoot\testfolder\PathToJsonTest.json" 
            }
    }
}
