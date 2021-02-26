#
# SetReleaseBuildsTag.ps1
#
[CmdletBinding()] 
param(
[string][Parameter(Mandatory=$true)] $AdoAccountName,
[string][Parameter(Mandatory=$true)] $AdoProjectName,
[string][Parameter(Mandatory=$true)] $AdoUser,
[string][Parameter(Mandatory=$true)] $AdoToken,
[int][Parameter(Mandatory=$true)] $ReleaseId,
[int][Parameter(Mandatory=$true)] $DefinitionId,
[int][Parameter(Mandatory=$true)] $DefinitionEnvironmentId,
[string][Parameter(Mandatory=$true)] $WikiId,
[string][Parameter(Mandatory=$true)] $WikiPagePath,
[string][Parameter(Mandatory=$true)] $StageName,
[string][Parameter(Mandatory=$true)] $ReleaseNoteField
)

Import-Module "$PSScriptRoot\powershell\Modules\AdoHelpers.psm1" -force
Import-Module "$PSScriptRoot\powershell\Modules\MarkdownHelpers.psm1" -force

$adoAuthorizationToken = "Basic {0}" -f [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $adoUser,$adoToken)))
$adoConnection = New-Object PSObject -Property @{
				AdoAccountName = $AdoAccountName
				AdoProjectName = $AdoProjectName
				AdoAuthorizationToken = $AdoAuthorizationToken
			}

			
$release = Get-ReleaseById -AdoConnection $adoConnection -ReleaseId $ReleaseId
$sourceBuildId = $release.artifacts[0].definitionReference.project.id

$itemsInfo = Get-WorkitemsForDeployment $adoConnection $ReleaseId $DefinitionId $DefinitionEnvironmentId $sourceBuildId $ReleaseNoteField

if ($null -ne $itemsInfo)
{
	$pageContent = "#Release - " +  $release.name + "`r`n`r`n"
	$pageContent+= "##Details: `r`n"
	$pageContent+= "**Release No** : " + $ReleaseId + "`r`n"
	$pageContent+= "**Release Trigger** : " + $release.reason + "`r`n"
	$pageContent+= "**Status** : " + $release.status + "`r`n"
	$pageContent+= "**Environment** : " + $StageName + "`r`n"
	$pageContent+= "**Started On** : " + $release.createdOn + "`r`n"
	$pageContent+= "**Released By** : " + $release.createdFor.Displayname + "`r`n`r`n"

	[string]$artifacts = Write-MdTableFromArtifacts -Artifacts $release.artifacts
	$pageContent += "`r`n $artifacts"

	$lastDeployment = $itemsInfo.deploymentsInfo.lastSucesfullDeployment
	if ($null -ne $lastDeployment)
	{
		$lastRelease = Get-ReleaseById -AdoConnection $adoConnection -ReleaseId $lastDeployment.release.id
		$pageContent+= "`r`n#Previous Successful release - " + $lastRelease.name + "`r`n`r`n"
		$pageContent+= "##Details: `r`n"
		$pageContent+= "**Release Trigger** : " + $lastRelease.reason + "`r`n"
		$pageContent+= "**Status** : " + $lastRelease.status + "`r`n"
		$pageContent+= "**Started On** : " + $lastRelease.createdOn + "`r`n"
		$pageContent+= "**Released By** : " + $lastRelease.createdFor.Displayname + "`r`n`r`n"


		[string]$artifactsLast = Write-MdTableFromArtifacts -Artifacts $lastRelease.artifacts
		$pageContent += "`r`n $artifactsLast"
	}

	[string]$tableWorkITems = Write-MdTableFromWorkItems -WorkItems $itemsInfo.workItems -ReleaseNoteField $ReleaseNoteField
	$pageContent += "`r`n $tableWorkITems"

	if ($WikiId -ne $null -and $WikiId -ne "")
	{
		Set-WikiPageContent -AdoConnection $adoConnection -WikiId $WikiId -PagePath $WikiPagePath/$StageName/"Latest" -PageContent $pageContent
		Set-WikiPageContent -AdoConnection $adoConnection -WikiId $WikiId -PagePath $WikiPagePath/$StageName/"Release-"$ReleaseId -PageContent $pageContent
	}
}