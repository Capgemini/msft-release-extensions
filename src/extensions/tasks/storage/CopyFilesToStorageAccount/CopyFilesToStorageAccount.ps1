Param(
    [Parameter(Mandatory = $true)][string]$StorageName,
    [Parameter(Mandatory = $true)][string]$StorageRG,
    [Parameter(Mandatory = $true)][string]$ContainerName,
    [Parameter(Mandatory = $true)][string]$SourceDirectory,
    [Parameter(Mandatory = $true)][string]$TargetDirectory,
    [Parameter(Mandatory = $true)][string]$FilesFilter,
    [Parameter(Mandatory = $false)][bool]$FlattenFiles
)

$ErrorActionPreference = "Stop"
[Net.ServicepointManager]::SecurityProtocol =[Net.SecurityProtocolType]::Tls12


$storageAccount = Get-AzStorageAccount -ResourceGroupName $StorageRG -Name $StorageName
$files = Get-ChildItem $SourceDirectory -recurse -Include $FilesFilter
Write-Host "Total files found $($files.Count) in directory $($SourceDirectory)"

foreach ($file in $files) {
    $folderName = (Split-Path (Split-Path $file -Parent) -Leaf)
    $fileName = (Split-Path $file -Leaf)
    $newFilePath = ""

    if ($FlattenFiles) {
        $newFilePath = Join-Path -Path $TargetDirectory -ChildPath  "\$fileName"
    }
    else {
        $newFilePath = Join-Path -Path $TargetDirectory -ChildPath  "\$folderName\$fileName"
    }

    Write-Host "[Start] Copy File $file to $newFilePath"
    Set-AzStorageBlobContent -Context $storageAccount.Context  -Container $ContainerName -File $file -Blob $newFilePath -Force | Out-Null
    Write-Host "[Finish] Copy File"
}