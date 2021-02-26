#
# MarkdownHelpers.psm1
#

$EOL = "`r`n"

function Write-MdTableRow{
    [CmdletBinding()] 
    param(
       [Parameter(Mandatory=$true)][System.Collections.ArrayList]$RowData
     )

	[string]$result = $EOL + "|"

	foreach ($col in $RowData)
	{
		$result += $col + "|"
	}

	return $result
}

function Write-MdTable{
    [CmdletBinding()] 
    param(
       [Parameter(Mandatory=$true)][System.Collections.ArrayList]$TableData
     )

	$header = $TableData[0]

	$tableContent = Write-MdTableRow -RowData $header

	$divBar = New-Object System.Collections.ArrayList
	foreach ($row in $header)
	{
		$divBar.Add("---") | Out-Null 
	}

	$tableContent += Write-MdTableRow -RowData $divBar

	$idx = 0

	foreach ($row in $TableData)
	{
		if ($idx -gt 0)
		{
		   $tableContent += Write-MdTableRow -RowData $row
		}

		$idx++
	}

	return $tableContent
}

function Get-DictionaryFromJson{
	[CmdletBinding()] 
    [OutputType([System.Collections.Generic.Dictionary[string,PSObject]])]
    param(
	   [Parameter(Mandatory=$false)][psobject]$JsonContent = $null
    )

   	$results = New-Object 'System.Collections.Generic.Dictionary[string,PSObject]'

	if ($JsonContent -ne $null)
	{
		ForEach ($obj in $JsonContent.psobject)
		{
			ForEach ($prop in $obj.Properties)
			{
				$results.Add($prop.Name, $prop.Value) | Out-Null 
			}
		}
	}

	return $results
}

function Get-GenerationConfigFileDict{
	[CmdletBinding()] 
    [OutputType([System.Collections.Generic.Dictionary[string,PSObject]])]
    param(
	   [Parameter(Mandatory=$true)][string]$FilePath
    )

	$jsonFile = (Get-Content $FilePath -Raw) | ConvertFrom-Json

	$results = Get-DictionaryFromJson -JsonContent $jsonFile

	return $results
}

function Get-TableFromCsv {
	[CmdletBinding()] 
    param(
	   [Parameter(Mandatory=$true)][string]$FilePath,
	   [Parameter(Mandatory=$false)][psobject]$CollumnsConfig = $null
    )

	[System.Collections.Generic.Dictionary[string,PSObject]]$config = Get-DictionaryFromJson -JsonContent $CollumnsConfig

	$CsvFile= Import-Csv -Path $FilePath

	[System.Collections.ArrayList]$tableData = New-Object 'System.Collections.ArrayList'
	[System.Collections.ArrayList]$header = New-Object 'System.Collections.ArrayList'
	[System.Collections.ArrayList]$ignoredRows = New-Object 'System.Collections.ArrayList'

	#Generate headers
	$rowNo = 0
	foreach($prop in $CsvFile[0].psobject.Properties)
	{
		if ($CollumnsConfig -eq $null)
		{
			$header.Add($prop.Name) | Out-Null

		} 
		elseif ($config.ContainsKey($prop.Name))
		{
			$header.Add($config[$prop.Name]) | Out-Null
		}
		else 
		{
			$ignoredRows.Add($rowNo) | Out-Null
		}

		$rowNo ++
	}

	$tableData.Add($header) | Out-Null

	#Gemerate Rows
	foreach($rowCsv in $CsvFile)
	{
		[System.Collections.ArrayList]$row = New-Object 'System.Collections.ArrayList'

		$rowNo = 0
		foreach($prop in $rowCsv.psobject.Properties)
		{
			if ($CollumnsConfig -eq $null -or $ignoredRows.Contains($rowNo) -eq $false)
			{
				$row.Add($prop.Value) | Out-Null
			}

			$rowNo ++
		}

		$tableData.Add($row) | Out-Null
	}

	return $tableData
}

function Write-MdTableFromCsv {
	[CmdletBinding()] 
    param(
	   [Parameter(Mandatory=$true)][string]$FilePath,
	   [Parameter(Mandatory=$true)][psobject]$GenConfig
    )

	$pageContent = "##" + $GenConfig.Category + "`r`n`r`n"
	$pageContent += $GenConfig.Description + "`r`n"

	$csvTable =  Get-TableFromCsv -FilePath $FilePath -CollumnsConfig $GenConfig.Collumns
	$pageContent += Write-MdTable -TableData $csvTable

	return $pageContent
}

function Write-MdTableFromWorkItems {
	[CmdletBinding()] 
	[OutputType([string])]
	param (
		[Parameter(Mandatory=$true)][Object]$WorkItems,
		[Parameter(Mandatory=$false)][Object]$ReleaseNoteField
	)

	$pageContent = "`r`n## Included WorkItems ($($WorkItems.count)): `r`n"
	[System.Collections.ArrayList]$headers = "Type", "Details"

	if ($null -ne $ReleaseNoteField)
	{
		$headers.Add("Release Notes")
	}	

	[System.Collections.ArrayList]$tableData =  New-Object 'System.Collections.ArrayList'
	$tableData.Add($headers) | Out-Null

	foreach($workItem in $WorkItems)
	{
		[System.Collections.ArrayList]$row = New-Object 'System.Collections.ArrayList'
		$fields =  $workItem.fields
		$row.Add("$($fields.'System.WorkItemType')") | Out-Null
		$row.Add(" #$($workItem.id) ") | Out-Null
		if ($null -ne $ReleaseNoteField)
		{
			$row.Add("$($fields.$ReleaseNoteField)") | Out-Null
		}
		
		$tableData.Add($row) | Out-Null
	}

	$pageContent += Write-MdTable -TableData $tableData
	return $pageContent
} 

function Write-MdTableFromArtifacts {
	[CmdletBinding()] 
	[OutputType([string])]
	param (
		[Parameter(Mandatory=$true)][Object]$Artifacts
	)

	$pageContent = "`r`n## Included Artifacts: `r`n"
	[System.Collections.ArrayList]$headers = "Name","Version","Type"

	[System.Collections.ArrayList]$tableData =  New-Object 'System.Collections.ArrayList'
	$tableData.Add($headers) | Out-Null

	foreach($artifact in $Artifacts)
	{
		[System.Collections.ArrayList]$row = New-Object 'System.Collections.ArrayList'
		$row.Add(" $($artifact.alias) ") | Out-Null
		$row.Add(" $($artifact.definitionReference.version.name) ") | Out-Null
		$row.Add(" $($artifact.type) ") | Out-Null
		
		$tableData.Add($row) | Out-Null
	}

	$pageContent += Write-MdTable -TableData $tableData
	return $pageContent

} 