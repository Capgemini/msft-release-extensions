[CmdletBinding()] 
param(
[string][Parameter(Mandatory=$true)] $AdoAccountName,
[string][Parameter(Mandatory=$true)] $AdoToken,
[string][Parameter(Mandatory=$true)] $NameOfCustomisedProcess
)

Import-Module "$PSScriptRoot\..\..\..\powershell_modules\AdoHelpers.psm1" -force
$baseProcessId = "adcc42ab-9882-485e-a3ed-7678f01f66bc" 

$adoAuthorizationToken = "Basic {0}" -f [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $adoUser,$adoToken)));

$adoConnection = New-Object PSObject -Property @{
				AdoAccountName = $AdoAccountName
				AdoAuthorizationToken = $AdoAuthorizationToken
			};

Write-Host "Connecting to" $adoConnection.AdoAccountName;
			
$allProcesses = Get-OrganisationProcess -AdoConnection $adoConnection

$exists =  $allProcesses.value |  Where-Object {$_.name -eq $NameOfCustomisedProcess}

$baseProcessName = ""
foreach($process in $allProcesses.value)
{
	Write-Host $process.typeId +  $process.name
	if ($baseProcessId -eq $process.typeId) {
		$baseProcessName = $process.name
	}
}

if ($null -ne $exists)
{
	Write-Host "Process already exists, skipping setup of template.."
}
else
{
	Write-Host "Creating template" $NameOfCustomisedProcess
	
	$newProcess = Set-OrganisationProcess -Name $NameOfCustomisedProcess `
										  -BaseTemplateTypeId $baseProcessId `
										  -AdoConnection $adoConnection `
										  -Description "ORGANISATION COMMON PROCESS based on $baseProcessName"

	Write-Host "Created custom template with Id" $newProcess.typeId

	Set-NewWorkItemType -AdoConnection $adoConnection -TemplateId $newProcess.typeId

	Set-NewWorkItemTypeBehaviour -AdoConnection $adoConnection -ProcessId $newProcess.typeId -ProcessName $NameOfCustomisedProcess -WorkItemName "TechnicalDebt"

}