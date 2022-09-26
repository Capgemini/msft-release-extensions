[CmdletBinding()] 
param(
[string][Parameter(Mandatory=$true)] $AdoAccountName = "markcunningham",
[string][Parameter(Mandatory=$true)] $AdoToken= "ijkecujgn5g2qd6lksfejo4wuk5q3um2czdnioxexrdwksjfipzq",
[string][Parameter(Mandatory=$true)] $InheritedProcessName= "Capgemini",
[string][Parameter(Mandatory=$true)] $ProjectName="DEMO-TEST-1",
[string][Parameter(Mandatory=$true)] $ConfigurationType ="Capgemini"
)

Import-Module "$PSScriptRoot\..\..\..\powershell_modules\AdoHelpers.psm1" -force

$adoAuthorizationToken = "Basic {0}" -f [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $adoUser,$adoToken)));

$adoConnection = New-Object PSObject -Property @{
				AdoAccountName = $AdoAccountName
				AdoAuthorizationToken = $AdoAuthorizationToken
			};

$configContent = Get-Content -Path "$PSScriptRoot\..\Project\project-templates\$ConfigurationType.json" | ConvertFrom-Json
$projectDashboardConfig = Get-Content -Path "$PSScriptRoot\..\Project\project-templates\dashboards\$ConfigurationType\Project\dashboards.json" | ConvertFrom-Json
$dashboardConfig = Get-Content -Path "$PSScriptRoot\..\Project\project-templates\dashboards\$ConfigurationType\Team\dashboards.json" | ConvertFrom-Json
$wikiConfig = Get-Content -Path "$PSScriptRoot\..\Project\project-templates\wiki\$ConfigurationType\wiki.json" | ConvertFrom-Json

Write-Host "Connecting to" $adoConnection.AdoAccountName;
		
$orgUrl = "https://dev.azure.com/$($adoConnection.AdoAccountName)"

$env:AZURE_DEVOPS_EXT_PAT = $AdoToken

$project = az devops project show --project $ProjectName --org $orgUrl | ConvertFrom-Json 

#Create Project
if($null -eq $project)
{
	$project = az devops project create --org $orgUrl --name $ProjectName --process $InheritedProcessName | ConvertFrom-Json
}

#Wiki
Set-ProjectWiki -ProjectId $project.id -AdoConnection $adoConnection
$projectWiki = az devops wiki list --project $ProjectName --scope project --org $orgUrl | ConvertFrom-Json

foreach ($wikiPage in $wikiConfig.pages)
{
	$path = "$PSScriptRoot\..\Project\project-templates\wiki\$ConfigurationType\" + $wikiPage.file
	$wikicontent = Get-Content $path -Raw
	Set-WikiPageContent -AdoConnection $adoConnection -WikiId $projectWiki.id -PagePath $wikiPage.path -PageContent $wikicontent -ProjectName $ProjectName
}

#Shared Queries
$sharedQueryTechDebt = Set-SharedQuery  -AdoConnection $adoConnection -ProjectName $ProjectName  -QueryName "Technical Debt" -Wiql "SELECT [System.Id],[System.WorkItemType],[System.Title],[System.AssignedTo],[System.State],[System.Tags] FROM WorkItems WHERE [System.TeamProject] = '$ProjectName' AND ( [System.WorkItemType] = 'Technical Debt' AND [System.State] IN ('Active') OR [System.State] = 'Accepted')"

#Default Team
$defaultteam = az devops team list --project $project.id --org $orgUrl | ConvertFrom-Json

#Dashboards and queries
$dashboards = Get-TeamDashboard -AdoConnection $adoConnection -ProjectName $ProjectName

$sharedQueryBugs = Set-SharedQuery  -AdoConnection $adoConnection -ProjectName $ProjectName  -QueryName "Defects" -Wiql "SELECT [System.Id],[System.WorkItemType],[System.Title],[System.AssignedTo],[System.State],[System.Tags] FROM WorkItems WHERE [System.TeamProject] = '$ProjectName' AND ( [System.WorkItemType] = 'Bug' AND [System.State] IN ('Active') OR [System.State] = 'Accepted')"

foreach($widget in $projectDashboardConfig.widgets)
{
	#tokenise settings
	if( $null -ne $widget.settings)
	{
		$widget.settings = $widget.settings.Replace("__TEAMID__", $defaultteam.id);
		$widget.settings = $widget.settings.Replace("__PROJECTID__", $project.id);
		$widget.settings = $widget.settings.Replace("__TECH_DEBT_QUERY_ID__", $sharedQueryTechDebt.id);
		$widget.settings = $widget.settings.Replace("__DEFECTS_QUERY_ID__", $sharedQueryBugs.id);
	}

	Set-DashboardWidget -AdoConnection $adoConnection -ProjectName $ProjectName -TeamName "$ProjectName Team" -DashboardId $dashboards.value[0].id -Widget $widget
}

#Set the team dashboard
$teamDashboard = Set-ProjectDashboard -ProjectName $ProjectName -AdoConnection $adoConnection
#Set-ProjectDashboardWidgets -DashboardId $teamDashboard.id -AdoConnection $adoConnection -ProjectId $project.id -Widgets $dashboardConfig.widgets -ExistingDashboard $teamDashboard

#Create Teams and default dashboards for each
foreach ($team in $configContent.teams)
{
	 $teamid = az devops team create --name $team.name --project $ProjectName --org $orgUrl | ConvertFrom-Json
	 Write-Host "Created Team with id $teamid.id"
	 $teamdasboardid = Set-TeamDashboard -AdoConnection $adoConnection -ProjectName $ProjectName -TeamName $team.name
	
	 foreach($widget in $dashboardConfig.widgets)
		{
			if( $null -ne $widget.settings)
			{
				$widget.settings = $widget.settings.Replace("__TEAMID__", $teamid.id);
				$widget.settings = $widget.settings.Replace("__PROJECTID__", $project.id);
				$widget.settings = $widget.settings.Replace("__TECH_DEBT_QUERY_ID__", $sharedQueryTechDebt.id);
				$widget.settings = $widget.settings.Replace("__DEFECTS_QUERY_ID__", $sharedQueryBugs.id);
			}

			Set-DashboardWidget -AdoConnection $adoConnection -ProjectName $ProjectName -TeamName $team.name -DashboardId $teamdasboardid.id -Widget $widget
		}	 
}

#Create Area
foreach ($area in $configContent.areas)
{
	if ($null -eq $area.parentPath)
	{
		az boards area project create --name $area.name --project $ProjectName --org $orgUrl
	}
	else 
	{
		az boards area project create --name $area.name --project $ProjectName --org $orgUrl --path "\$ProjectName\Area\$($area.parentPath)"
	}

	foreach($areaTeam in $area.teams)
	{
		az boards area team add --path "\$ProjectName\$($area.name)" --team $areaTeam.name --org $orgUrl --project $ProjectName --set-as-default --include-sub-areas $areaTeam.includeSubAreas
	}
}

#Create Iterations
foreach ($iteration in $configContent.iterations)
{
	if ($null -eq $iteration.parentPath)
	{
		az boards iteration project create --name $iteration.name --project $ProjectName --org $orgUrl
	}
	else 
	{
		az boards iteration project create --name $iteration.name --project $ProjectName --org $orgUrl --path "\$ProjectName\Iteration\$($iteration.parentPath)"
	}

	for ($i=0; $i -le $iteration.numberOfSprints; $i++) 
	{
		az boards iteration project create --name "Sprint$i" --project $ProjectName --org $orgUrl --path "\$ProjectName\Iteration\$($iteration.name)"
	}
}

#WorkItems
#foreach ($workItem in $configContent.workItems)
#{
#	az boards work-item create --title $workItem.title --project $ProjectName --org $orgUrl --description $workItem.description --type $workItem.type
#}