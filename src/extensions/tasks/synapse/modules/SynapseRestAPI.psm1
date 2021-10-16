
$ApiVersion = "2019-06-01-preview"

Function Get-SynapseManagedPrivateLink {
	[CmdletBinding()]
	param(
	   [Parameter(Mandatory=$true)][string]$AuthToken,
       [Parameter(Mandatory=$true)][string]$WorkspaceName,
       [Parameter(Mandatory=$true)][string]$PrivateLinkName
    )

    $headers = @{
        Authorization = "Bearer $AuthToken"
    }

    $url = "https://$WorkspaceName.dev.azuresynapse.net/managedVirtualNetworks/default/managedPrivateEndpoints?api-version=$ApiVersion"
    $results = Invoke-RestMethod -Uri $url -ContentType "application/json" -Headers $headers -Method Get -UseBasicParsing

    foreach ($item in $results.value) {
        if ($item.name -eq $PrivateLinkName ) {
            Write-Debug "Found Private Link $PrivateLinkName"
            return $item
        }
    }

    Write-Debug "No Private Link Found $PrivateLinkName"
    return $null
}

Function New-SynapseManagedPrivateLink {
	[CmdletBinding()]
	param(
	   [Parameter(Mandatory=$true)][string]$AuthToken,
       [Parameter(Mandatory=$true)][string]$WorkspaceName,
       [Parameter(Mandatory=$true)][string]$PrivateLinkName,
       [Parameter(Mandatory=$true)][string]$PrivateLinkResourceId,
       [Parameter(Mandatory=$true)][string]$PrivateLinkGroup
    )

    $headers = @{
        Authorization = "Bearer $AuthToken"
    }

    $privateLink = Get-SynapseManagedPrivateLink -AuthToken $AuthToken -WorkspaceName $WorkspaceName -PrivateLinkName $PrivateLinkName
    
    if ($null -eq $privateLink) {
        $url = "https://$WorkspaceName.dev.azuresynapse.net/managedVirtualNetworks/default/managedPrivateEndpoints/$($PrivateLinkName)?api-version=$ApiVersion" 
        $jsonBody = "{
            ""properties"": {
              ""privateLinkResourceId"": ""$PrivateLinkResourceId"",
              ""groupId"": ""$PrivateLinkGroup""
            }
          }"
    
        Write-Debug "Creating Private Link $PrivateLinkName"
        return Invoke-RestMethod -Method Put -ContentType "application/json" -Uri $url -Headers $headers -Body $jsonBody -UseBasicParsing
    }
    else {
        Write-Debug "Private Link $PrivateLinkName already exists state: $($privateLink.properties.provisioningState)"
        return $privateLink
    }
 }