#
# AdoHelpers.psm1
#
# Module to wrap common Azure DevOps API commands
#

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
	 [Parameter(Mandatory=$false)] [string]$PageContent
	)

	$authHeader = @{Authorization=($($AdoConnection.AdoAuthorizationToken))}
	$apiVersion ="5.0"
	$apiUrl = "https://$($AdoConnection.AdoAccountName).visualstudio.com/DefaultCollection/$($AdoConnection.AdoProjectName)/_apis"

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
		 [Parameter(Mandatory=$true)] [string]$SourceBuildId
		)

		$authHeader = @{Authorization=($($AdoConnection.AdoAuthorizationToken))}
		$apiUrl = "https://$($AdoConnection.AdoAccountName).vsrm.visualstudio.com/$($AdoConnection.AdoProjectName)/_apis"
	
		$deploymentsInfo = Get-DeploymentsForEnvironment -AdoConnection $AdoConnection `
							-DefinitionId $DefinitionId `
							-DefinitionEnvironmentId $DefinitionEnvironmentId `
							-SourceBuildId $SourceBuildId
	
		#Get the work Items using the baseId of the Environment stage (BaseRelease) id
		$workItemsUrl = "$apiUrl/Release/releases/$ReleaseId/workitems" #?baseReleaseId=$baseDeployId&`$top=200"
		$workitemIds = Invoke-RestMethod -Uri $workItemsUrl -Method Get -ContentType "application/json" -Headers $authHeader

		$results = $workitemIds.value.id -Join ","

		#Go and Get the Details for the work Items Passing in the ID Array
		$WorkItemDetails = "https://$($AdoConnection.AdoAccountName).visualstudio.com/$SourceBuildId/_apis/wit/workItems?ids=$results&`$expand=4" #Gets the workitems and links / related
		$fullWorkItem = Invoke-RestMethod -Uri $WorkItemDetails -Method Get -ContentType "application/json" -Headers $authHeader
		
		return @{
			workItems = $fullWorkItem.value
			deploymentsInfo = $deploymentsInfo
		}
	}