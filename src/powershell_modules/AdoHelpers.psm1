function Set-WikiPageContent{
	[CmdletBinding()]
	param(
		 [Parameter(Mandatory=$true)] [PSObject]$AdoConnection,
		 [Parameter(Mandatory=$false)] [string]$WikiId,
		 [Parameter(Mandatory=$false)] [string]$PagePath,
		 [Parameter(Mandatory=$false)] [string]$PageContent
		)
	
		$authHeader = @{Authorization=($($AdoConnection.AdoAuthorizationToken))}
		$apiVersion ="5.0"
		$apiUrl = "https://$($AdoConnection.AdoAccountName).visualstudio.com/DefaultCollection/$($AdoConnection.AdoProjectName)/_apis"
	
		$wikiUrl = "$apiUrl/wiki/wikis/$WikiId/pages?path=$PagePath&api-version=$apiVersion"
	
		$body = New-Object PSObject @{content=$PageContent}
	
		$jsonBody = ConvertTo-Json $body
		
		$wikiResponse = Invoke-RestMethod -Uri $wikiUrl -Method Put -ContentType "application/json" -Headers $authHeader -Body $jsonBody
	
		return $wikiResponse
	}
	

function Set-ProjectWiki{
    [CmdletBinding()]
    param(
       [Parameter(Mandatory=$true)][PSObject]$AdoConnection,
	   [Parameter(Mandatory=$true)][String]$ProjectId
    )

	$uri = "https://dev.azure.com/$($AdoConnection.AdoAccountName)/_apis/wiki/wikis?api-version=6.0-preview.1"

	$myObject = [PSCustomObject]@{
		type = 0
		projectId = "$ProjectId"
		}

	$json = ConvertTo-Json -InputObject $myObject

    $result = Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Headers @{Authorization=($($AdoConnection.AdoAuthorizationToken))} -Body $json

	return $result
}

function Get-TeamDashboard{
    [CmdletBinding()]
    param(
       [Parameter(Mandatory=$true)][PSObject]$AdoConnection,
	   [Parameter(Mandatory=$true)][PSObject]$ProjectName
    )

	$uri = "https://dev.azure.com/$($AdoConnection.AdoAccountName)/$ProjectName/_apis/dashboard/dashboards?api-version=6.0-preview.3"

    $result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers @{Authorization=($($AdoConnection.AdoAuthorizationToken))}

	return $result
}


function Get-ProjectDashboard{
    [CmdletBinding()]
    param(
       [Parameter(Mandatory=$true)][PSObject]$AdoConnection,
	   [Parameter(Mandatory=$true)][PSObject]$ProjectName,
	   [Parameter(Mandatory=$true)][string]$DashboardId
    )

	$uriExisting = "https://dev.azure.com/$($AdoConnection.AdoAccountName)/$ProjectName/_apis/dashboard/dashboards/$DashboardId`?api-version=6.0-preview.3"
	$existingDashboard = Invoke-RestMethod -Uri $uriExisting -Method GET -ContentType "application/json" -Headers @{Authorization=($($AdoConnection.AdoAuthorizationToken))} -Body $json

	return $existingDashboard
}


#https://dev.azure.com/markcunningham/dd209b33-fba2-48f3-adf3-398a7acf3a65/_apis/Dashboard/Dashboards


function Set-ProjectDashboard{
    [CmdletBinding()]
    param(
       [Parameter(Mandatory=$true)][PSObject]$AdoConnection,
	   [Parameter(Mandatory=$true)][PSObject]$ProjectName
    )

	$uri = "https://dev.azure.com/$($AdoConnection.AdoAccountName)/$ProjectName/_apis/dashboard/dashboards?api-version=6.0-preview.3"

	$myObject = [PSCustomObject]@{
		name = "Project Dashboard"
		description = "Dashboard for Project"
		refreshInterval =  $5
	}

	$json = ConvertTo-Json -InputObject $myObject

    $result = Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Headers @{Authorization=($($AdoConnection.AdoAuthorizationToken))} -Body $json

	return $result
}

function Set-TeamDashboard{
    [CmdletBinding()]
    param(
       [Parameter(Mandatory=$true)][PSObject]$AdoConnection,
	   [Parameter(Mandatory=$true)][string]$ProjectName,
	   [Parameter(Mandatory=$true)][string]$TeamName
    )

	$uri = "https://dev.azure.com/$($AdoConnection.AdoAccountName)/$ProjectName/$TeamName/_apis/dashboard/dashboards?api-version=6.0-preview.3"

	$myObject = [PSCustomObject]@{
		name = "$TeamName Dashboard"
		description = "Dashboard for Team $TeamName"
		refreshInterval =  $5
	}

	$json = ConvertTo-Json -InputObject $myObject

    $result = Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Headers @{Authorization=($($AdoConnection.AdoAuthorizationToken))} -Body $json

	return $result
}

function Set-DashboardWidget{
    [CmdletBinding()]
    param(
       [Parameter(Mandatory=$true)][PSObject]$AdoConnection,
	   [Parameter(Mandatory=$true)][string]$ProjectName,
	   [Parameter(Mandatory=$true)][string]$TeamName,
	   [Parameter(Mandatory=$true)][string]$DashboardId,
	   [Parameter(Mandatory=$true)][psobject]$Widget	  
    )

	$uri = "https://dev.azure.com/$($AdoConnection.AdoAccountName)/$ProjectName/$TeamName/_apis/dashboard/dashboards/$DashboardId/widgets?api-version=6.0-preview.2"
	

	$json = ConvertTo-Json -InputObject $Widget
	
    $result = Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Headers @{Authorization=($($AdoConnection.AdoAuthorizationToken))} -Body $json

	return $result
}

function Set-ProjectDashboardWidget{
    [CmdletBinding()]
    param(
       [Parameter(Mandatory=$true)][PSObject]$AdoConnection,
	   [Parameter(Mandatory=$true)][string]$ProjectName,
	   [Parameter(Mandatory=$true)][string]$DashboardId,
	   [Parameter(Mandatory=$true)][psobject]$Widget	  
    )

	$uri = "https://dev.azure.com/$($AdoConnection.AdoAccountName)/$ProjectName/_apis/dashboard/dashboards/$DashboardId/widgets?api-version=6.0-preview.2"
	
	$json = ConvertTo-Json -InputObject $Widget
	
    $result = Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Headers @{Authorization=($($AdoConnection.AdoAuthorizationToken))} -Body $json

	return $result
}

function Set-ProjectDashboard{
    [CmdletBinding()]
    param(
       [Parameter(Mandatory=$true)][PSObject]$AdoConnection,
	   [Parameter(Mandatory=$true)][string]$ProjectName
    )

	$myObject = [PSCustomObject]@{
		name = "Project Dashboard"
		description = "Dashboard for $ProjectName"
		refreshInterval = 5
	}

	$json = ConvertTo-Json -InputObject $myObject

	$uri = "https://dev.azure.com/$($AdoConnection.AdoAccountName)/$ProjectName/_apis/dashboard/dashboards?api-version=6.0-preview.3"
	
    $result = Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Headers @{Authorization=($($AdoConnection.AdoAuthorizationToken))} -Body $json

	return $result
}

function Set-ProjectDashboardWidgets{
    [CmdletBinding()]
    param(
       [Parameter(Mandatory=$true)][PSObject]$AdoConnection,
	   [Parameter(Mandatory=$true)][string]$ProjectName,	
	   [Parameter(Mandatory=$true)][string]$DashboardId,	
	   [Parameter(Mandatory=$true)][psobject]$Widgets	  
    )

	$uriExisting = "https://dev.azure.com/$($AdoConnection.AdoAccountName)/$ProjectName/_apis/dashboard/dashboards/$DashboardId`?api-version=6.0-preview.3"
	$existingDashboard = Invoke-RestMethod -Uri $uriExisting -Method GET -ContentType "application/json" -Headers @{Authorization=($($AdoConnection.AdoAuthorizationToken))} -Body $json

	$existingDashboard.widgets = @($widgets)

	$json = ConvertTo-Json -InputObject $existingDashboard

	$uri = "https://dev.azure.com/$($AdoConnection.AdoAccountName)/$ProjectName/_apis/dashboard/dashboards/$DashboardId`?api-version=6.0-preview.3"

#	$uri = "https://dev.azure.com/markcunningham/fd1a5b6c-5fe5-4756-9dc3-e8cc21fc5f1b/_apis/Dashboard/Dashboards/1d11ba33-40af-4d71-9eae-4fb55c40884e`?api-version=6.0-preview.3"

    $result = Invoke-RestMethod -Uri $uri -Method PUT -ContentType "application/json" -Headers @{Authorization=($($AdoConnection.AdoAuthorizationToken))} -Body $json

	return $result
}

#https://dev.azure.com/markcunningham/9fc5fb0f-f489-423e-9e16-6091f4c89e13/ef50b0ff-ce05-4b98-8e29-faa701cf57da/_apis/Dashboard/Dashboards/b92f791e-2a45-45f3-ab24-2ec578a1665f

function Set-SharedQuery{
    [CmdletBinding()]
    param(
       [Parameter(Mandatory=$true)][PSObject]$AdoConnection,
	   [Parameter(Mandatory=$true)][string]$ProjectName,
	   [Parameter(Mandatory=$true)][string]$QueryName,
	   [Parameter(Mandatory=$true)][string]$Wiql
	   
    )
		
	$uri = "https://dev.azure.com/$($AdoConnection.AdoAccountName)/$ProjectName/_apis/wit/queries/Shared Queries?api-version=6.0-preview.2"

	$myObject = [PSCustomObject]@{
		name = "$QueryName"
		wiql = $Wiql
		isFolder =  $true
		path = "Shared Queries/$QueryName"
	}

	$json = ConvertTo-Json -InputObject $myObject
	
	$Stoploop = $false
	[int]$Retrycount = "0"
 
	do {
		try {
		$result = Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Headers @{Authorization=($($AdoConnection.AdoAuthorizationToken))} -Body $json
		$Stoploop = $true
		}
		catch {
		if ($Retrycount -gt 3){
		Write-Host "Could not send Information after 3 retrys."
		$Stoploop = $true
		}
		else {
		Write-Host "Could not send Information retrying in 5 seconds..."
		Start-Sleep -Seconds 5
		$Retrycount = $Retrycount + 1
		}
		}
		}
	While ($Stoploop -eq $false)


	return $result
}


function Set-NewWorkItemType{
    [CmdletBinding()]
    param(
	   [Parameter(Mandatory=$true)][string]$TemplateId,
       [Parameter(Mandatory=$true)][PSObject]$AdoConnection	   
    )

	$uri = "https://dev.azure.com/$($AdoConnection.AdoAccountName)/_apis/work/processes/$TemplateId/workItemTypes?api-version=6.0-preview.2"

	$myObject = [PSCustomObject]@{
		name = "Technical Debt"
		color = "E60017"
		icon = "icon_flame"
		description =  "Technical Debt type to help track specific tech debt tasks"
		inheritsFrom = $null
		isDisabled= $false
	}

	$json = ConvertTo-Json -InputObject $myObject

	 Write-Host $json

    $newProcess = Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Headers @{Authorization=($($AdoConnection.AdoAuthorizationToken))} -Body $json

	return $newProcess
}

function Set-NewWorkItemTypeBehaviour{
    [CmdletBinding()]
    param(
	   [Parameter(Mandatory=$true)][string]$ProcessId,
       [Parameter(Mandatory=$true)][PSObject]$AdoConnection,	   
	   [Parameter(Mandatory=$true)][string]$ProcessName,
	   [Parameter(Mandatory=$true)][string]$WorkItemName       
    )

	$uri = "https://dev.azure.com/$($AdoConnection.AdoAccountName)/_apis/work/processes/$ProcessId/workItemTypesBehaviors/$ProcessName.$WorkItemName/behaviors?api-version=6.0-preview.1"

	$myObject='{"behavior":{"id": "System.RequirementBacklogBehavior"},"isDefault": false}'

	Write-Host $json

    $behaviour = Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Headers @{Authorization=($($AdoConnection.AdoAuthorizationToken))} -Body $myObject

	return $behaviour
}


function Set-OrganisationProcess{
    [CmdletBinding()]
    param(
       [Parameter(Mandatory=$true)][string]$Name,
	   [Parameter(Mandatory=$true)][string]$BaseTemplateTypeId,
       [Parameter(Mandatory=$true)][PSObject]$AdoConnection,
	   [Parameter(Mandatory=$false)][PSObject]$Description = 'ORGANISATION COMMON CONFIGURATION'
    )

	$uri ="https://dev.azure.com/$($AdoConnection.AdoAccountName)/_apis/work/processes?api-version=6.0-preview.2"

	$myObject = [PSCustomObject]@{
		name = "$Name"
		parentProcessTypeId = "$BaseTemplateTypeId"
		referenceName = "$Name"
		description = $Description
	}

	$json = ConvertTo-Json -InputObject $myObject

	 Write-Host $json

    $newProcess = Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Headers @{Authorization=($($AdoConnection.AdoAuthorizationToken))} -Body $json

	return $newProcess
}

function Get-OrganisationProcess{
    [CmdletBinding()]
    param(
       [Parameter(Mandatory=$true)][PSObject]$AdoConnection
    )

	$uri ="https://dev.azure.com/$($AdoConnection.AdoAccountName)/_apis/work/processes?api-version=6.0-preview.2"

    $processes = Invoke-RestMethod -Uri $uri -Method Get -ContentType "application/json" -Headers @{Authorization=($($AdoConnection.AdoAuthorizationToken))}

	return $processes
}

function Get-VariableGroupsAll {
    [CmdletBinding()]
    param(
       [Parameter(Mandatory=$true)][PSObject]$AdoConnection
    )

	# Construct the REST URL to obtain the release definitions
    $uri = "https://$($AdoConnection.AdoAccountName).visualstudio.com/DefaultCollection/$($AdoConnection.AdoProjectName)/_apis/distributedtask/variablegroups"

    $variables = Invoke-RestMethod -Uri $uri -Method Get -ContentType "application/json" -Headers @{Authorization=($($AdoConnection.AdoAuthorizationToken))}

	return $variables
}

function Get-VariableGroupByName {
    [CmdletBinding()]
    param(
       [Parameter(Mandatory=$true)][PSObject]$AdoConnection,
	   [Parameter(Mandatory=$true)][string]$VariableGroupName
    )

	$variableGroups = Get-VariableGroupsAll -AdoConnection $AdoConnection

	foreach($variable in $variableGroups.value)
	{
	  if ($variable.name -eq $VariableGroupName)
	  {
	     return $variable
	  }
	}
}

function Get-VariableByNameAsDictionary {
	[CmdletBinding()]
	[OutputType([System.Collections.Generic.Dictionary[string,string]])]
    param(
       [Parameter(Mandatory=$true)][PSObject]$AdoConnection,
	   [Parameter(Mandatory=$true)][string]$VariableGroupName
    )

	$varGroup = Get-VariableGroupByName -AdoConnection $AdoConnection -VariableGroupName $VariableGroupName

	[System.Collections.Generic.Dictionary[string,string]]$result = New-Object 'System.Collections.Generic.Dictionary[string,string]'

	foreach($prop in $varGroup.variables.psobject.Properties)
		{
			if ($null -ne $prop)
			{
				if ($prop.Value.isSecret)
				{
					$result.Add($prop.Name, 'Secret')
				}
				else
				{
					$result.Add($prop.Name, $prop.Value.value)
				}
			}
		}

	return $result
}

function Set-BuildTags {
[CmdletBinding()]
param(
	[Parameter(Mandatory=$true)][PSObject]$AdoConnection,
	[Parameter(Mandatory=$false)] [string]$buildId,
	[Parameter(Mandatory=$false)] [string]$buildTags
)

$authHeader = @{Authorization=($($AdoConnection.AdoAuthorizationToken))}
$apiVersion ="2.0"
$apiUrl = "https://$($AdoConnection.AdoAccountName).visualstudio.com/DefaultCollection/$($AdoConnection.AdoProjectName)/_apis"

$buildTagsArray = $buildTags.Split(",");

if ($buildTagsArray.Count -gt 0) {
    foreach($tag in $buildTagsArray)
    {
        $tagURL = "$apiUrl/build/builds/$buildId/tags/$tag`?api-version=$apiVersion"
        Invoke-RestMethod -Uri $tagURL -Headers $authHeader -Method Put
    }
  }
}

function Get-ReleaseById {
[CmdletBinding()]
param(
	[Parameter(Mandatory=$true)][PSObject]$AdoConnection,
	[Parameter(Mandatory=$false)][string]$ReleaseId
)

	$authHeader = @{Authorization=($($AdoConnection.AdoAuthorizationToken))}
	$apiVersion ="5.0"
	$apiUrl = "https://vsrm.dev.azure.com/$($AdoConnection.AdoAccountName)/$($AdoConnection.AdoProjectName)/_apis"

	$uri = "$apiUrl/release/releases/$ReleaseId`?api-version=$apiVersion"

	$response = Invoke-RestMethod -Uri $uri -Method get -ContentType "application/json" -Headers $authHeader

	return $response
}

function Set-BuildVariableForPath {
[CmdletBinding()]
param(
	[Parameter(Mandatory=$true)][PSObject]$AdoConnection,
	[Parameter(Mandatory=$false)] [string]$BuildPath,
	[Parameter(Mandatory=$false)] [string]$VarName,
	[Parameter(Mandatory=$false)] [string]$VarValue
)

$authHeader = @{Authorization=($($AdoConnection.AdoAuthorizationToken))}
$pathEncoded = [System.Web.HttpUtility]::UrlEncode($BuildPath) 

$apiVersion ="2.0"
$apiUrl = "https://$($AdoConnection.AdoAccountName).visualstudio.com/DefaultCollection/$($AdoConnection.AdoProjectName)/_apis"

$buildsUrl = "$apiUrl/build/definitions?path=$pathEncoded&api-version=$($apiVersion)"
$builds= Invoke-RestMethod -Uri $buildsUrl -Method Get -ContentType "application/json" -Headers $authHeader

foreach($item in $builds.value)
{
  if ($item.path -eq $BuildPath)
  {

   $buildId = $item.ID
   $buildUrl = "$apiUrl/build/definitions/$buildId" + "?api-version=$($apiVersion)"
   $build= Invoke-RestMethod -Uri $buildUrl -Method Get -ContentType "application/json" -Headers $authHeader
   $varChanged = $false

   foreach($variable in ($build.variables | Get-Member))
   {
	   if (($variable.MemberType -eq "NoteProperty") -and ($variable.name -eq $VarName) )
	   {
	      $name = $variable.name
		  $value = $build.variables."$name"
		 
	      $value.value = $VarValue
		  $varChanged = $true
	   }
   }

   if ($varChanged -eq $true)
   {
      $body =  ConvertTo-Json -InputObject $build -Compress -Depth 20
      Invoke-RestMethod -Uri $buildUrl -Method Put -ContentType "application/json" -Headers $authHeader -Body $body
   }
   }
  }
}

function Get-TeamEmailAddresses {
[CmdletBinding()]
Param(
	   [Parameter(Mandatory=$true)][PSObject]$AdoConnection,
       [Parameter(Mandatory=$true)][string]$TeamName
    )

    $authHeader = @{Authorization=($($AdoConnection.AdoAuthorizationToken))}

    # set VSTS Rest API Version
    $teamsApiVersion = "1.0"

    # Construct the REST URL to obtain team members
    $uri = "https://$($AdoConnection.AdoAccountName).visualstudio.com/DefaultCollection/_apis/projects/$($AdoConnection.AdoProjectName)/teams/$($teamName)/members?api-version=$($teamsApiVersion)"

    # Invoke the REST call and capture the results
    $teamMembers = Invoke-RestMethod -Uri $uri -Method get -ContentType "application/json" -Headers $authHeader

    $emailAddress = ""
    foreach($member in $teammembers.value)
    {
        if($emailAddress.Length -eq 0)
        {
            $emailAddress = $member.uniqueName
        }
        else
        {
            $emailAddress = $emailAddress + "; " + $member.uniqueName
        }
    }

    return $emailAddress
}

function Get-AgentDetails {
[CmdletBinding()]
param(
	 [Parameter(Mandatory=$true)] [PSObject]$AdoConnection,
     [Parameter(Mandatory=$false)] [string]$PoolName,
	 [Parameter(Mandatory=$false)] [string]$AgentName
	)

	$authHeader = @{Authorization=($($AdoConnection.AdoAuthorizationToken))}

	$apiUrl = "https://$($AdoConnection.AdoAccountName).visualstudio.com/DefaultCollection/_apis"

	$poolsUrl = "$apiUrl/distributedtask/pools"

	$pools= Invoke-RestMethod -Uri $poolsUrl -Method Get -ContentType "application/json" -Headers $authHeader
	$foundAgent = $null

	foreach($pool in $pools.value)
	{
	  if ($pool.name -eq $PoolName)
	   {
	      $agentsUrl = "$apiUrl/distributedtask/pools/" + $pool.id + "/agents"

	      $agents = Invoke-RestMethod -Uri $agentsUrl -Method Get -ContentType "application/json" -Headers $authHeader

		  foreach($agent in $agents.value)
		   {
			   if($agent.name -eq $AgentName)
			   {
					$agentsUrlDet = "$apiUrl/distributedtask/pools/" + $pool.id + "/agents/" + $agent.id + "?includeCapabilities=true"
					$agentsDet = Invoke-RestMethod -Uri $agentsUrlDet -Method Get -ContentType "application/json" -Headers $authHeader
					$foundAgent = $agentsDet

					break
			   }
		   }

		   break
       }
	}

	return $foundAgent;
}

function Get-BuildsByDefinition{
[CmdletBinding()]
param(
	 [Parameter(Mandatory=$true)] [PSObject]$AdoConnection,
     [Parameter(Mandatory=$false)] [string]$BuildDefinitionId
	)

	$authHeader = @{Authorization=($($AdoConnection.AdoAuthorizationToken))}

	$apiVersion ="5.0"
    
	$apiUrl = "https://$($AdoConnection.AdoAccountName).visualstudio.com/DefaultCollection/$($AdoConnection.AdoProjectName)/_apis"

	$buildsUrl = "$apiUrl/build/builds?definitions=$BuildDefinitionId&api-version=$($apiVersion)"

	$builds= Invoke-RestMethod -Uri $buildsUrl -Method Get -ContentType "application/json" -Headers $authHeader

	return $builds

}

function Get-WikiPageContent{
[CmdletBinding()]
param(
	 [Parameter(Mandatory=$true)] [PSObject]$AdoConnection,
     [Parameter(Mandatory=$false)] [string]$WikiId,
	 [Parameter(Mandatory=$false)] [string]$PagePath,
	 [Parameter(Mandatory=$false)] [string]$GetContent = "True"
	)

	$apiVersion ="5.0"

	$authHeader = @{Authorization=($($AdoConnection.AdoAuthorizationToken))}

	$apiUrl = "https://$($AdoConnection.AdoAccountName).visualstudio.com/DefaultCollection/$($AdoConnection.AdoProjectName)/_apis"

	$wikiUrl = "$apiUrl/wiki/wikis/$WikiId/pages?path=$PagePath&includeContent=$GetContent&api-version=$apiVersion"

	try
	{
		$wikiPage = Invoke-WebRequest -Uri $wikiUrl -Method Get -ContentType "application/json" -Headers $authHeader
	    return $wikiPage
	}
	catch 
	{
		return $null
	}
}

function Set-WikiPageContent{
[CmdletBinding()]
param(
	 [Parameter(Mandatory=$true)] [PSObject]$AdoConnection,
     [Parameter(Mandatory=$false)] [string]$WikiId,
	 [Parameter(Mandatory=$false)] [string]$PagePath,
	 [Parameter(Mandatory=$false)] [string]$PageContent,
	 [Parameter(Mandatory=$false)] [string]$ProjectName
	)

	$authHeader = @{Authorization=($($AdoConnection.AdoAuthorizationToken))}
	$apiVersion ="5.0"
	$apiUrl = "https://$($AdoConnection.AdoAccountName).visualstudio.com/DefaultCollection/$ProjectName/_apis"

	$wikiUrl = "$apiUrl/wiki/wikis/$WikiId/pages?path=$PagePath&api-version=$apiVersion"

	$body = New-Object PSObject @{content=$PageContent}

	$jsonBody = ConvertTo-Json $body
	
	$existingPage = Get-WikiPageContent -AdoConnection $AdoConnection -WikiId $WikiId -PagePath $PagePath -GetContent "False"

	if ($null -ne $existingPage)
	{
		$authHeader["If-Match"] = $existingPage.Headers["eTag"]
	}

	$wikiResponse = Invoke-RestMethod -Uri $wikiUrl -Method Put -ContentType "application/json" -Headers $authHeader -Body $jsonBody

	return $wikiResponse
}


function Get-DeploymentsForEnvironment {
	[CmdletBinding()]
	param(
		 [Parameter(Mandatory=$true)] [PSObject]$AdoConnection,
		 [Parameter(Mandatory=$true)] [string]$DefinitionId,
		 [Parameter(Mandatory=$true)] [string]$DefinitionEnvironmentId,
		 [Parameter(Mandatory=$true)] [string]$SourceBuildId
		)

		$authHeader = @{Authorization=($($AdoConnection.AdoAuthorizationToken))}
		$apiVersion ="6.0"		
		$apiUrl = "https://$($AdoConnection.AdoAccountName).vsrm.visualstudio.com/$($AdoConnection.AdoProjectName)/_apis"
	
		$previousDeploy = "$apiUrl/Release/deployments?deploymentStatus=4&definitionId=$DefinitionId&definitionEnvironmentId=$DefinitionEnvironmentId&api-version=$apiVersion"
 
		#Get Last deployment Id. Need to see what happens when it is the first deployment..
		$deployments = Invoke-RestMethod -Uri $previousDeploy -Method Get -ContentType "application/json" -Headers $authHeader

		$lastDeployment = $null

		#IF IT IS NOT THE FIRST DEPLYMENT YOU CAN GET ITEMS SINCE LAST BUILD
		foreach ($depl in $deployments.value) {
			if ($depl.release.id -ne $ReleaseId)
			{
				$lastDeployment =  $depl 
				break
			}
		}

		return @{
			deployments = $deployments
			lastSucesfullDeployment = $lastDeployment
		}
}

function Get-WorkitemsForDeployment{
	[CmdletBinding()]
	param(
		 [Parameter(Mandatory=$true)] [PSObject]$AdoConnection,
		 [Parameter(Mandatory=$true)] [string]$ReleaseId,
		 [Parameter(Mandatory=$true)] [string]$DefinitionId,
		 [Parameter(Mandatory=$true)] [string]$DefinitionEnvironmentId,
		 [Parameter(Mandatory=$true)] [string]$SourceBuildId,
		 [Parameter(Mandatory=$false)] [string]$ReleaseNoteField

		)

		$authHeader = @{Authorization=($($AdoConnection.AdoAuthorizationToken))}
		$apiUrl = "https://$($AdoConnection.AdoAccountName).vsrm.visualstudio.com/$($AdoConnection.AdoProjectName)/_apis"
	
		$deploymentsInfo = Get-DeploymentsForEnvironment -AdoConnection $AdoConnection `
							-DefinitionId $DefinitionId `
							-DefinitionEnvironmentId $DefinitionEnvironmentId `
							-SourceBuildId $SourceBuildId
				
		$baseDeployId = 0 
		if ($null -ne $deploymentsInfo.lastSucesfullDeployment)
		{
			$baseDeployId = $deploymentsInfo.lastSucesfullDeployment.release.id 
		}

		#Get the work Items using the baseId of the Environment stage (BaseRelease) id
		$workItemsUrl = "$apiUrl/Release/releases/$ReleaseId/workitems?baseReleaseId=$baseDeployId&`$top=200"
		$workitemIds = Invoke-RestMethod -Uri $workItemsUrl -Method Get -ContentType "application/json" -Headers $authHeader

		if ($null -eq $workitemIds)
		{
			return $null
		}
		
		$results = $workitemIds.value.id -Join ","

		if ($ReleaseNoteField -ne "")
		{
			$WorkItemDetails = "https://dev.azure.com/$($AdoConnection.AdoAccountName)/$($AdoConnection.AdoProjectName)/_apis/wit/workItems?ids=$results&`$&fields=$ReleaseNoteField,System.WorkItemType"
		}
		else {
			$WorkItemDetails = "https://dev.azure.com/$($AdoConnection.AdoAccountName)/$($AdoConnection.AdoProjectName)/_apis/wit/workItems?ids=$results&`$expand=4" #Gets the workitems and links / related
		}
		
		$fullWorkItem = Invoke-RestMethod -Uri $WorkItemDetails -Method Get -ContentType "application/json" -Headers $authHeader
		
		return @{
			workItems = $fullWorkItem.value
			deploymentsInfo = $deploymentsInfo
		}
	}