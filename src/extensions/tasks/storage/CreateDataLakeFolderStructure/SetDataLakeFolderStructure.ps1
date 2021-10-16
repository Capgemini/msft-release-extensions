[CmdletBinding()]
	param(
	   [Parameter(Mandatory=$true)][string]$DataLakeAccountName,
       [Parameter(Mandatory=$true)][string]$ContainerName,
       [Parameter(Mandatory=$true)][string]$ConfigurationFile
    )

    $ErrorActionPreference = "Stop"

    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

    $ctx = New-AzStorageContext -StorageAccountName $DataLakeAccountName -UseConnectedAccount    
    $items = Get-AzDataLakeGen2ChildItem -FileSystem $ContainerName -Context $ctx -Recurse  | Where-Object { $_.IsDirectory }
 
    $json = Get-Content $ConfigurationFile | Out-String | ConvertFrom-Json

    function createSubDirectory($node)
    {   
        if ("" -eq $node[1]){
            $fullPath = $node[0].name;
        }
        else {
            $fullPath = $node[1] + '/' + $node[0].name;
        }     

        $match =  $items | Where-Object { $_.Path -eq $fullPath }

        if($null -eq $match)
        {
            Write-Host 'Creating Directory' $fullPath
            New-AzDataLakeGen2Item  -FileSystem $ContainerName -Path $fullPath -Directory -Context $ctx
        }
        else
        {
            Write-Host 'Directory' $fullPath 'already exists' 
        }

        ForEach ($permission in $node.permissions)
        {       
            $validValues = @('user','group','application') 
            $validInput =  $validValues.Contains($permission.type)

            if ($false -eq $validInput) 
            {
                throw "An invalid entry was supplied in the configuration. Accepted values : "  + $validValues
            }

            if ($permission.type -eq "user")
            {
                $user = Get-AzADUser -DisplayName $permission.name
                $acl = set-AzDataLakeGen2ItemAclObject -AccessControlType user -Permission $permission.permissions -EntityId $user.Id
            }
            if ($permission.type -eq "group")
            {
                $group = Get-AzADGroup -DisplayName $permission.name
                $acl = set-AzDataLakeGen2ItemAclObject -AccessControlType group -Permission $permission.permissions -EntityId $group.Id
            }   
            if ($permission.type -eq "application")
            {
                $appReg = Get-AzADServicePrincipal -DisplayName $permission.name
                $acl = set-AzDataLakeGen2ItemAclObject -AccessControlType user -Permission $permission.permissions -EntityId $appReg.Id
            }   
            
            Update-AzDataLakeGen2Item -Context $ctx -FileSystem $ContainerName -Path $fullPath -Acl $acl            

        }

        ForEach ($subNode in $node.directories)
        {      
            createSubDirectory($subNode, $fullPath)
        }
    }

    ForEach ($item in $json) {
        createSubDirectory($item, '')
    }