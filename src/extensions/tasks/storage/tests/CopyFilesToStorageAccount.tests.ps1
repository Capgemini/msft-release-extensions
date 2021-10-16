# Before running this script ensure az module is installed and you are logged in to Azure

Describe "CopyFilesToStorageAccount-Test" {
    Context "Exists" {

            It "FlattenFiles" {

                $scriptPath = "$PSScriptRoot\..\CopyFilesToStorageAccount.ps1"

                & "$scriptPath" `
                    -StorageName "devtrfinfdl1003" `
                    -StorageRG "DEVTRFINFRG1003" `
                    -ContainerName "defraanalyticsdata" `
                    -SourceDirectory "$PSScriptRoot\testfolder" `
                    -TargetDirectory "testsflat" `
                    -FilesFilter "*.json" `
                    -FlattenFiles $true
            }

            It "NoFlattenFiles" {

                $scriptPath = "$PSScriptRoot\..\CopyFilesToStorageAccount.ps1"

                & "$scriptPath" `
                    -StorageName "devtrfinfdl1003" `
                    -StorageRG "DEVTRFINFRG1003" `
                    -ContainerName "defraanalyticsdata" `
                    -SourceDirectory "$PSScriptRoot\testfolder" `
                    -TargetDirectory "testsnoflat" `
                    -FilesFilter "*.json" `
                    -FlattenFiles $false
            }
    }
}
