[CmdletBinding()] 
param(
    [string][Parameter(Mandatory=$true)] $ApiKey,
    [string][Parameter(Mandatory=$true)] $ServiceName,
    [string][Parameter(Mandatory=$true)] $JsonConfigFilePath,
    [string][Parameter(Mandatory=$false)] $RunIndexers = "no",
    [string][Parameter(Mandatory=$false)] $ConnectionString = $null,
    [string][Parameter(Mandatory=$false)] $StorageAccountName = $null,
    [string][Parameter(Mandatory=$false)] $StorageAccountRG = $null
)

$ErrorActionPreference = "Stop"
[Net.ServicepointManager]::SecurityProtocol =[Net.SecurityProtocolType]::Tls12
Import-Module "$PSScriptRoot\..\modules\AzureSearchRestFunctions.psm1" -force 

$configPath = Split-Path $JsonConfigFilePath
$jsonConfigFile = (Get-Content $JsonConfigFilePath -Raw) | ConvertFrom-Json

foreach ($config in $jsonConfigFile.AzureSearchConfigs)
{   

    if ($config.IndexName) 
    {
        Write-Host "Setting Index $($config.IndexName)"
        $IndexFilePath = "$configPath\$($config.IndexFilePath)"

        Set-AzureSearchIndex -ApiKey $ApiKey -ServiceName $ServiceName -ApiVersion $jsonConfigFile.ApiVersion`
            -IndexName $config.IndexName -IndexFilePath $IndexFilePath
    }

    if ($config.DataSourceName)
    {
        Write-Host "Setting DataSource $($config.DataSourceName)"
        $DataSourceFilePath = "$configPath\$($config.DataSourceFilePath)"

        if (!$ConnectionString)
        {
            $ConnectionString = $config.DataSourceConnectionString
        }

        if ($StorageAccountName -and $StorageAccountRG)
        {
            $keys = Get-AzStorageAccountKey -ResourceGroupName "$StorageAccountRG" -AccountName "$StorageAccountName"
            $connString = "DefaultEndpointsProtocol=https;AccountName=$StorageAccountName;AccountKey=$($keys[0].value);EndpointSuffix=core.windows.net"
            $ConnectionString = $connString
        }

        Set-AzureSearchDataSource -ApiKey $ApiKey -ServiceName $ServiceName -ApiVersion $jsonConfigFile.ApiVersion`
            -DataSourceName $config.DataSourceName -DataSourceFilePath $DataSourceFilePath `
            -DataSourceConnectionString $ConnectionString 
    }

    if ($config.IndexerName -and $config.DataSourceName -and $config.IndexName)
    {
        Write-Host "Setting Indexer $($config.IndexerName)"
        $IndexerFilePath = "$configPath\$($config.IndexerFilePath)"

        Set-AzureSearchIndexer -ApiKey $ApiKey -ServiceName $ServiceName -ApiVersion $jsonConfigFile.ApiVersion`
            -IndexerName $config.IndexerName -IndexerFilePath $IndexerFilePath `
            -DataSourceName $config.DataSourceName -IndexName $config.IndexName

        if ($RunIndexers -eq "yes") {
            Write-Host "Running Indexer $($config.IndexerName)"
            Start-AzureSearchIndexer -ApiKey $ApiKey -ServiceName $ServiceName -ApiVersion $jsonConfigFile.ApiVersion`
                -IndexerName $config.IndexerName
        }
    }
}