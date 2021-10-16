[CmdletBinding()] 
param(
    [string][Parameter(Mandatory=$true)] $ServiceName,
    [string][Parameter(Mandatory=$true)] $ResourceGroupName,
    [string][Parameter(Mandatory=$true)] $PublicAccess
)

$ErrorActionPreference = "Stop"
[Net.ServicepointManager]::SecurityProtocol =[Net.SecurityProtocolType]::Tls12
Import-Module Az.Search

$service = Get-AzSearchService -ResourceGroupName $ResourceGroupName -Name $ServiceName
Write-Host "Current Public Access mode: $($service.PublicNetworkAccess) for $ServiceName"

if ($service.PublicNetworkAccess -ne $PublicAccess) {
    $service = Set-AzSearchService -ResourceGroupName $ResourceGroupName -Name $ServiceName -PublicNetworkAccess $PublicAccess

    $cnt = 120
    while (($service.Status -eq "Provisioning") -and ($cnt -gt 0)) {
        Write-Debug "Waiting 5s for Azure Search to finish provisioning ..."
        $cnt--
        Start-Sleep -Seconds 5
        $service = Get-AzSearchService -ResourceGroupName $ResourceGroupName -Name $ServiceName
    }

    if ($cnt -gt 0) {
        Write-Host "Setting Public Access to $($service.PublicNetworkAccess) for $ServiceName - OK"
    }
    else {
        Write-Warning "Setting Public Access to $($service.PublicNetworkAccess) for $ServiceName - Timeout"
    }

}
else {
    Write-Host "Setting Public Access to $($service.PublicNetworkAccess) is already configured for $ServiceName"
}

