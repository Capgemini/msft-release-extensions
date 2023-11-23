# Managing Collections

Collections are logical groupings of data based on an organization hierarchy. The example scripts shows you how to create collections and assign AD groups (Guids) to the permissions of the collection

## Example Config

**File**: CollectionExample.json
```json
{
    "Collections" : [
        {
            "Name" : "Example",
            "ParentCollectionName" : "ExampleParent",
            "Permissions" : [
                {
                    "Group" : "data-curator",
                    "GroupNames" : ["96aa1b87-1221-4af7-ac08-89fab541e533","efab6d4d-d21f-498a-a879-5b70726bad54"]
                }
            ]
        },
        {
            "Name" : "Example1",
            "ParentCollectionName" : "Example",
            "Permissions" : [
                {
                    "Group" : "data-curator",
                    "GroupNames" : ["96aa1b87-1221-4af7-ac08-89fab541e533","efab6d4d-d21f-498a-a879-5b70726bad54"]
                }
            ]
        }                 
    ]
}
```

## Example Script

### Parameters
**AccountName** - The name of the Purview Account

**ConfigFilePath** - The path to the config file (Example above)

**File**: ConfigureCollections.ps1
```powershell
param (
    [Parameter(Mandatory = $true)]
    [string]$AccountName,

    [Parameter(Mandatory = $true)]
    [string]$ConfigFilePath,

    [Parameter(Mandatory = $true)]
    [string]$Environment
)

Import-Module $PSScriptRoot/../../Modules/Purview/PurviewModule.psm1

$jsonFiles = Get-ChildItem -Path $ConfigFilePath -Filter "*.json" -Recurse

$baseUrl = "https://$AccountName.purview.azure.com"

$AccessToken = (Get-AzAccessToken -Resource "https://purview.azure.net").Token

foreach ($file in $jsonFiles) {
  Write-Host $file.FullName
  $config = Get-Content $file.FullName 
  $config = $config.Replace("__ENVIRONMENT__", $Environment) | ConvertFrom-Json

  foreach ($collection in $config.Collections) 
  {
      $shortname = [regex]::Replace($collection.Name, "[^a-zA-Z0-9]", "")
      $collectionObject = Get-PurviewCollections -AccessToken $AccessToken -ApiVersion '2019-11-01-preview' -BaseUri $baseUrl
      $targetCollection = $collectionObject.value | Where-Object { $_.friendlyName -eq $collection.ParentCollectionName }

      $existingCollection = $collectionObject.value | Where-Object { $_.friendlyName -eq $collection.Name }

      if ($null -eq $existingCollection)
      {
        Write-Host "Upserting Collection" $collection.Name
       New-PurviewCollection -AccessToken $AccessToken -CollectionName $collection.Name -ApiVersion '2019-11-01-preview' -BaseUri $baseUrl -ParentCollectionName $targetCollection.name
      }
      else {
        $shortname = $existingCollection.name
      }      

      foreach ($permission in $collection.Permissions) 
      {      
        foreach($permissionGroup in $permission.GroupNames)   
        {
          Write-Host "Updating Policy for $permissionGroup"
          #You need to get the policy each time to avoid 409 conflicts as the policy is versioned
          $policy = Get-PurviewPolicyByCollectionName -AccessToken $AccessToken -CollectionName $shortname -ApiVersion '2021-07-01-preview' -BaseUri $baseUrl
         
          #Assign a group to a role
          Add-PurviewPolicyRole -AccessToken $AccessToken -BaseUri $baseUrl -ApiVersion '2021-07-01-preview' -Policy $policy.values[0] -RoleName $permission.Group -GroupId $permissionGroup -CollectionName $shortname
          Write-Host "Added group with id $permissionGroup to the $permissionGroup role"
        }
      }
  }
}
```

## Example Usage

```powershell
ConfigureCollections.ps1 -AccountName DEVPRV1001 -ConfigFilePath C:\Temp\CollectionExample.json
```
