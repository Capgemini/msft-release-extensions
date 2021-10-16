[CmdletBinding()] 
param(
    [string][Parameter(Mandatory=$true)] $SynapseWorkspaceName,
    [string][Parameter(Mandatory=$true)] $PackagesLocation
    )

[Net.ServicepointManager]::SecurityProtocol =[Net.SecurityProtocolType]::Tls12

Import-Module Az.Synapse

$localPakages = Get-ChildItem -File -Path $PackagesLocation -Filter "*.whl"

$pool = Get-AzSynapseSparkPool -WorkspaceName $SynapseWorkspaceName

Write-Host "Packages being uploaded $localPakages"

$packageExistsOnSynapse = Get-AzSynapseWorkspacePackage -WorkspaceName $SynapseWorkspaceName

Write-Host "Existing Packages $packageExistsOnSynapse"

foreach($localPakage in $localPakages)
{   
    $found = $packageExistsOnSynapse | Where-Object -Property Name -eq $localPakage.Name

    if($null -eq $found)
    {
        Write-Host "$localPakage Package doesnt exist, uploading it to synapse and updating all spark pools"
        $packageCreated = New-AzSynapseWorkspacePackage -WorkspaceName $SynapseWorkspaceName -Package "$PackagesLocation\$localPakage"
        Update-AzSynapseSparkPool -WorkspaceName $SynapseWorkspaceName -Name $pool.Name -PackageAction Add -Package $packageCreated        
    }
    else
    {
        Write-Host "$localPakage already exists, skipping"
    }
}