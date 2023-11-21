# Managing Classifications

Manage Classifications in Purview

## Example Config

**File**: ClassificationExample.json
```json
{
    "Classifications" : [
        {
            "Name" : "Custom",
            "Description" : "Custom Classification Example"            
        },
        {
            "Name" : "Customer1",
            "Description" : "Custom Classification Example1"            
        }              
    ]
}
```

## Example Script

### Parameters
**AccountName** - The name of the Purview Account

**ConfigFilePath** - The path to the config file (Example above)

**File**: ConfigureClassification.ps1
```powershell
param (
    [Parameter(Mandatory = $true)]
    [string]$AccountName,

    [Parameter(Mandatory = $true)]
    [string]$ConfigFilePath
)

Import-Module $PSScriptRoot/../../Modules/Purview/PurviewModule.psm1
$jsonFiles = Get-ChildItem -Path $ConfigFilePath -Filter "*.json" -Recurse

$baseUrl = "https://$AccountName.purview.azure.com"
$AccessToken = (Get-AzAccessToken -Resource "https://purview.azure.net").Token


foreach ($file in $jsonFiles) {
  Write-Host $file.FullName
  $config = Get-Content $file.FullName | ConvertFrom-Json

  foreach ($classification in $config.Classifications) 
  {      
      Write-Host $classification.Name "----------" $classification.Description

      try 
      {
         $existingClassification = Get-Classification -AccessToken $AccessToken -ClassificationName $classification.Name -BaseUri $baseUrl
      }
      catch [System.Net.WebException] #Not found
      {
         New-Classification -AccessToken $AccessToken -ClassificationName $classification.Name -ClassificationDescription $classification.Description -ApiVersion '2019-11-01-preview' -BaseUri $baseUrl
      }         
  }
}

```

## Example Usage

```powershell
ConfigureClassification.ps1 -AccountName DEVPRV1001 -ConfigFilePath C:\Temp\ClassificationExample.json
```
