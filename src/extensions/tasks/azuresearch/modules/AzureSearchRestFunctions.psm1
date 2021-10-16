#
# AzureSearchRestFunctions.psm1
#

Function Set-AzureSearchIndex {
	[CmdletBinding()]
	param(
	   [Parameter(Mandatory=$true)][string]$ApiKey,
       [Parameter(Mandatory=$true)][string]$ServiceName,
       [Parameter(Mandatory=$true)][string]$ApiVersion,
       [Parameter(Mandatory=$true)][string]$IndexName,
	   [Parameter(Mandatory=$true)][string]$IndexFilePath
    )
    
    $body = Get-Content -Raw -Path $IndexFilePath | ConvertFrom-Json

    $body.name = $IndexName

    $bodyText =  ConvertTo-Json -InputObject $body -Compress -Depth 20

    $headers = @{
        "api-key" = $ApiKey
        "Content-Type" = "application/json"
    }

    $url = "https://$($ServiceName).search.windows.net/indexes/$($IndexName)?api-version=$($ApiVersion)"

    Invoke-RestMethod -Uri $url -ContentType "application/json" -Headers $headers -Method Put -Body $bodyText -UseBasicParsing

}

Function Set-AzureSearchDataSource {
	[CmdletBinding()]
	param(
	   [Parameter(Mandatory=$true)][string]$ApiKey,
       [Parameter(Mandatory=$true)][string]$ServiceName,
       [Parameter(Mandatory=$true)][string]$ApiVersion,
       [Parameter(Mandatory=$true)][string]$DataSourceName,
       [Parameter(Mandatory=$true)][string]$DataSourceFilePath,
       [Parameter(Mandatory=$true)][string]$DataSourceConnectionString
    )
    
    $body = Get-Content -Raw -Path $DataSourceFilePath | ConvertFrom-Json

    $body.name = $DataSourceName
    $body.credentials.connectionString = $DataSourceConnectionString

    $bodyText =  ConvertTo-Json -InputObject $body -Compress -Depth 20

    $headers = @{
        "api-key" = $ApiKey
        "Content-Type" = "application/json"
    }

    $url = "https://$($ServiceName).search.windows.net/datasources/$($DataSourceName)?api-version=$($ApiVersion)"

    Invoke-RestMethod -Uri $url -ContentType "application/json" -Headers $headers -Method Put -Body $bodyText -UseBasicParsing

}

Function Set-AzureSearchIndexer {
	[CmdletBinding()]
	param(
	   [Parameter(Mandatory=$true)][string]$ApiKey,
       [Parameter(Mandatory=$true)][string]$ServiceName,
       [Parameter(Mandatory=$true)][string]$ApiVersion,
       [Parameter(Mandatory=$true)][string]$IndexerName,
       [Parameter(Mandatory=$true)][string]$IndexerFilePath,
       [Parameter(Mandatory=$true)][string]$DataSourceName,
       [Parameter(Mandatory=$true)][string]$IndexName
    )
    
    $body = Get-Content -Raw -Path $IndexerFilePath | ConvertFrom-Json

    $body.name = $IndexerName
    $body.dataSourceName = $DataSourceName
    $body.targetIndexName = $IndexName

    $bodyText =  ConvertTo-Json -InputObject $body -Compress -Depth 20

    $headers = @{
        "api-key" = $ApiKey
        "Content-Type" = "application/json"
    }

    $url = "https://$($ServiceName).search.windows.net/indexers/$($IndexerName)?api-version=$($ApiVersion)"

    Invoke-RestMethod -Uri $url -ContentType "application/json" -Headers $headers -Method Put -Body $bodyText -UseBasicParsing

}

Function Start-AzureSearchIndexer {
	[CmdletBinding()]
	param(
	   [Parameter(Mandatory=$true)][string]$ApiKey,
       [Parameter(Mandatory=$true)][string]$ServiceName,
       [Parameter(Mandatory=$true)][string]$ApiVersion,
       [Parameter(Mandatory=$true)][string]$IndexerName
    )

    $headers = @{
        "api-key" = $ApiKey
        "Content-Type" = "application/json"
    }

    $url = "https://$($ServiceName).search.windows.net/indexers/$($IndexerName)/run?api-version=$($ApiVersion)"

    Invoke-RestMethod -Uri $url -ContentType "application/json" -Headers $headers -Method Post -UseBasicParsing

}