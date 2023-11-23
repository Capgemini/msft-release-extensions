# Managing Glossaries

Glossary management is a key feature in Azure Purview. It manages terminologyof data and assets.

## Example Config

**File**: GlossaryExample.json
```json
{
    "Glossaries" : [
        {
            "Name" : "GlossaryPOC",
            "Description" : "Glossary Description POC",
            "Experts" : [{
                "Id" : "3bb9eea2-cb42-4292-bdd5-bb99e74fd39e",
                "Info" : "The Expert for Glossary"
            }],
            "Stewards" :  [{
                "Id" : "3bb9eea2-cb42-4292-bdd5-bb99e74fd39e",
                "Info" : "The Steward for Glossary"
            }],
            "Terms" : [
                {
                    "name": "POC12",
                    "anchor": {
                        "glossaryGuid": "_INHERITED_"
                    },
                    "status": "Draft",
                    "nickName": "POC12",
                    "longDescription": "<div>POC1</div>",
                    "additionalAttributes": {
                        "microsoft_isDescriptionRichText": "true"
                    },
                    "abbreviation": "POC",
                    "resources": [
                        {
                            "displayName": "POC",
                            "url": "https://test.com"
                        }
                    ],
                    "synonyms": [
                        {
                            "termGuid": "66bedec9-e5b2-4919-8ad5-e774c71f1042"
                        }
                    ],
                    "seeAlso": [
                        {
                            "termGuid": "66bedec9-e5b2-4919-8ad5-e774c71f1042"
                        }
                    ],
                    "attributes": {}
                }
            ],
            "WorkFlows" : [
                {
                    "workFlowId" : "1274e7b9-db78-4296-acf5-79e5dc9fef7f",
                    "name": "Create glossary term",
                    "isEnabled": true,
                    "description": "For new glossary Terms",
                    "triggers": [
                      {
                        "type": "when_term_creation_is_requested",
                        "underGlossaryHierarchy": "/glossaries/b9c83d4c-04ef-46d4-9c3b-c856d5b43793"
                      }
                    ],
                    "actionDag": {
                      "actions": {
                        "Start and wait for an approval": {
                          "type": "Approval",
                          "inputs": {
                            "parameters": {
                              "approvalType": "PendingOnAll",
                              "title": "Approval Request for Create Glossary Term",
                              "assignedTo": [
                                "3bb9eea2-cb42-4292-bdd5-bb99e74fd39e"
                              ]
                            }
                          },
                          "runAfter": {}
                        },
                        "Condition": {
                          "type": "If",
                          "expression": {
                            "and": [
                              {
                                "equals": [
                                  "@{outputs('Start and wait for an approval')['outcome']}",
                                  "Approved"
                                ]
                              }
                            ]
                          },
                          "actions": {
                            "Create glossary term": {
                              "type": "CreateTerm",
                              "runAfter": {}
                            },
                            "Send email notification": {
                              "type": "EmailNotification",
                              "inputs": {
                                "parameters": {
                                  "emailSubject": "Glossary Term Create - APPROVED",
                                  "emailMessage": "Your request for Glossary Term @{runInput()['term']['name']} is approved.",
                                  "emailRecipients": [
                                    "@{runInput()['requestor']}",
                                    "3bb9eea2-cb42-4292-bdd5-bb99e74fd39e"
                                  ]
                                }
                              },
                              "runAfter": {
                                "Create glossary term": [
                                  "Succeeded"
                                ]
                              }
                            }
                          },
                          "else": {
                            "actions": {
                              "Send reject email notification": {
                                "type": "EmailNotification",
                                "inputs": {
                                  "parameters": {
                                    "emailSubject": "Glossary Term Create - REJECTED",
                                    "emailMessage": "Your request for Glossary Term @{runInput()['term']['name']} is rejected.",
                                    "emailRecipients": [
                                      "@{runInput()['requestor']}",
                                      "3bb9eea2-cb42-4292-bdd5-bb99e74fd39e"
                                    ]
                                  }
                                },
                                "runAfter": {}
                              }
                            }
                          },
                          "runAfter": {
                            "Start and wait for an approval": [
                              "Succeeded"
                            ]
                          }
                        }
                      }
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

**File**: ConfigureGlossary.ps1
```powershell
param (
    [Parameter(Mandatory = $true)]
    [string]$AccountName,

    [Parameter(Mandatory = $true)]
    [string]$ConfigFilePath
)

Import-Module $PSScriptRoot/../..PurviewModule.psm1 -Force
$jsonFiles = Get-ChildItem -Path $ConfigFilePath -Filter "*.json" -Recurse

$baseUrl = "https://$AccountName.purview.azure.com"

$AccessToken = (Get-AzAccessToken -Resource "https://purview.azure.net").Token

foreach ($file in $jsonFiles) 
{
  $config = Get-Content $file.FullName | ConvertFrom-Json

  foreach ($glossary in $config.Glossaries) 
  {  
        $experts = @()
        $stewards = @()

        foreach ($exp in $glossary.Experts)
        {
            $experts += @{
                    id = $exp.Id
                    info = $exp.Info
                }
        }

        foreach ($ste in $glossary.Stewards)
        {
            $stewards += @{
                    id = $ste.Id
                    info = $ste.Info
                }
        }

        $id = Set-Glossary -accessToken $accessToken -glossaryName $glossary.Name -glossaryDescription $glossary.Description -experts $experts -stewards $stewards -BaseUri $baseUrl
        
        Write-Host "Glossary Upserted with ID $($id.guid)"
       
        foreach($term in $glossary.Terms)
        {
            Write-Host "Setting GlossaryTerms"
            Set-GlossaryTerm -accessToken $accessToken -glossaryName $glossary.Name -BaseUri $baseUrl -TermObject $term -GlossaryId $id.guid
        } 
       
        foreach($workflow in $glossary.WorkFlows)
        {
            Write-Host "Setting Glossary Workflows"
            Set-Workflow -AccessToken $AccessToken -WorkFlow $workflow -BaseUri $baseUrl -GlossaryId $id.guid
        }         

  }
}
```

## Example Usage

```powershell
ConfigureGlossary.ps1 -AccountName DEVPRV1001 -ConfigFilePath C:\Temp\GlossaryExample.json
```
