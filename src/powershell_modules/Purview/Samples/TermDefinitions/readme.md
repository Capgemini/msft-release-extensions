# Managing TermDefinitions

Manage TermDefinitions in Purview

## Example Config

**File**: TermDefinitionsExample.json
```json
{
  "termTemplateDefs": [
    {
      "name": "POC1",
      "description": "POC Template1",
      "attributeDefs": [
        {
          "name": "Test2",
          "description": "Test2",
          "isOptional": false,
          "typeName": "string",
          "defaultValue": "Hello",
          "options": {
            "isDisabled": "false"
          }
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

**File**: ConfigureTermDefinitions.ps1
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

  $config = Get-Content $file.FullName  | ConvertFrom-Json

  Set-TermTemplate -AccessToken $AccessToken -BaseUri $baseUrl -templateDefinition $config      

}
```

## Example Usage

```powershell
ConfigureTermDefinitions.ps1 -AccountName DEVPRV1001 -ConfigFilePath C:\Temp\TermDefinitionsExample.json
```
