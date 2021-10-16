[CmdletBinding()] 
param(
    [string][Parameter(Mandatory=$true)] $SynapseWorkspaceName,
    [bool][Parameter(Mandatory=$true)] $ActivateTriggers
)

$ErrorActionPreference = "Stop"
[Net.ServicepointManager]::SecurityProtocol =[Net.SecurityProtocolType]::Tls12

Import-Module Az.Synapse

$synapseTriggers = Get-AzSynapseTrigger -WorkspaceName $SynapseWorkspaceName 

if ($ActivateTriggers) 
{
    $synapseTriggers | ForEach-Object { Start-AzSynapseTrigger -Name $_.name -WorkspaceName $SynapseWorkspaceName }
    Write-Host "Starting Triggers"
}
else {
    $synapseTriggers | ForEach-Object { Stop-AzSynapseTrigger -Name $_.name -WorkspaceName $SynapseWorkspaceName } 
    Write-Host "Stopping Triggers"
}