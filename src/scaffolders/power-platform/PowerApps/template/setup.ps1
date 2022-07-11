$AdoAccountName = "__adoAccountName__"
$ProjectName = "__adoProjectName__"
$AdoToken = "__patToken__"

$orgUrl = "https://dev.azure.com/$AdoAccountName"

$env:AZURE_DEVOPS_EXT_PAT = $AdoToken

$existingProject = az devops project show --project $ProjectName --org $orgUrl

if($null -eq $existingProject)
{
	Write-Host "Project $ProjectName must exist"
	return -1
}




$projectWiki = az devops wiki list --project $ProjectName --scope project --org $orgUrl --name "WIKI" | ConvertFrom-Json

if ($null -eq $projectWiki)
{
	az devops wiki create --name "WIKI" --project $ProjectName --type 'projectwiki'
}

az devops wiki page create --path 'PowerApps ALM' --wiki $projectWiki --content "Hello World" --org $orgUrl --project $ProjectName


return 0
