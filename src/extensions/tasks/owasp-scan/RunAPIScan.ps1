#
# RunApiScan.ps1
#

[CmdletBinding()]
param()

Trace-VstsEnteringInvocation $MyInvocation

try {

    Install-Module -Name Az.Accounts -Scope CurrentUser -Repository PSGallery -Force
    Install-Module -Name Az.ContainerInstance -Scope CurrentUser -Repository PSGallery -Force
    Import-Module Az.Accounts -Verbose
    Import-Module Az.ContainerInstance -Verbose

    # Import-Module "$PSScriptRoot\ps_modules\VstsTaskSdk\VstsTaskSdk.psm1" -force
    Import-Module "$PSScriptRoot\ps_modules\OwaspScanHelpers.psm1" -force

    Clear-AzContext -Scope Process
    Disable-AzContextAutosave

    Write-Verbose "Entering script $($MyInvocation.MyCommand.Name)"
    Write-Verbose "Parameter Values"

    Write-Host $PSScriptRoot

    Import-VstsLocStrings "$PSScriptRoot\Task.json"

    # Get task variables.
    [bool]$debug = Get-VstsTaskVariable -Name System.Debug -AsBool

    # Get the inputs.
    [string]$Location = Get-VstsInput -Name Location -Require
    [string]$ConnectedServiceName = Get-VstsInput -Name ConnectedServiceName -Require
    [string]$ApiEndpoint = Get-VstsInput -Name ApiEndpoint -Require
    [string]$ResourceGroupName = Get-VstsInput -Name ResourceGroupName -Require
    [string]$StorageAccountName = Get-VstsInput -Name StorageAccountName -Require
    [string]$ShareName = Get-VstsInput -Name ShareName -Require
    [string]$ImageName = Get-VstsInput -Name ImageName -Require
    [string]$VNet = Get-VstsInput -Name VNet -Require
    [string]$Subnet = Get-VstsInput -Name Subnet -Require
    [string]$OptionFilePath = Get-VstsInput -Name OptionFilePath -Require

    $serviceNameInput = Get-VstsInput -Name ConnectedServiceNameSelector -Default 'ConnectedServiceName'
    $serviceName = Get-VstsInput -Name $serviceNameInput -Default (Get-VstsInput -Name DeploymentEnvironmentName)

    # to be removed, included for local debugging
    # [string]$ApiEndpoint = $env:ApiEndpoint
    # [string]$ResourceGroupName = $env:ResourceGroupName
    # [string]$StorageAccountName = $env:StorageAccountName
    # [string]$ShareName = $env:ShareName
    # [string]$ImageName = $env:ImageName
    # [string]$ServiceConnectionId = $env:ServiceConnectionId

    # Import the helpers.
    # . $PSScriptRoot\Get-VSPath.ps1

    Write-Host "Initial parameters:"

    Write-Host "debug Value = $debug"
    Write-Host "ApiEndpoint Value = $ApiEndpoint"
    Write-Host "StorageAccountName Value = $StorageAccountName"
    Write-Host "ResourceGroupName Value = $ResourceGroupName"
    Write-Host "ShareName Value = $ShareName"
    Write-Host "ImageName Value = $ImageName"
    Write-Host "Location Value = $Location"
    Write-Host "ConnectedServiceName Value = $ConnectedServiceName"
    Write-Host "ServiceName Value = $serviceName"
    Write-Host "OptionFilePath Value = $OptionFilePath"
    Write-Host "VNet Value = $VNet"
    Write-Host "Subnet Value = $Subnet"

    # Get the end point from the name passed as a parameter
    $Endpoint = Get-VstsEndpoint -Name $ConnectedServiceName -Require
    # Get the authentication details
    $clientID = $Endpoint.Auth.parameters.serviceprincipalid
    $key = $Endpoint.Auth.parameters.serviceprincipalkey
    $tenantId = $Endpoint.Auth.parameters.tenantid
    $subscriptionId = $Endpoint.Data.subscriptionid
    $SecurePassword = $key | ConvertTo-SecureString -AsPlainText -Force
    $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $clientID, $SecurePassword
    
    # Authenticate
    az login --service-principal -u $clientID -p $key --tenant $tenantId
    az account set --subscription $subscriptionId

    Connect-AzAccount -Credential $cred -TenantId $tenantId -ServicePrincipal
    Select-AzSubscription -SubscriptionId $subscriptionId -Tenant $tenantId
    
    #Validation
    Test-OptionFile -value $OptionFilePath -variableName "OptionFilePath"

    # Set up the OWASP API scan options
    $SetOwaspApiScanOptionsParameters = @{
        ApiSwaggerEndpoint = $ApiEndpoint
        ResourceGroupName  = $ResourceGroupName
        StorageAccountName = $StorageAccountName
        ShareName          = $ShareName
        OptionFilePath     = $OptionFilePath
    }        
    $OwaspZapOptionsDictionary = Set-OwaspApiScanOptions @SetOwaspApiScanOptionsParameters
    Write-Host "Completed Step 1 Set-OwaspApiScanOptions"
    Write-Output $OwaspZapOptionsDictionary
    
    $OwaspZAPOptions = $OwaspZapOptionsDictionary.OwaspZAPOptions
    $XmlReportName = $OwaspZapOptionsDictionary.XmlReportName
    $AciInstanceName = $OwaspZapOptionsDictionary.AciInstanceName

    Write-Output $OwaspZAPOptions

    #create the container instance
    $NewOwaspContainerParameters = @{
        AciInstanceName    = $AciInstanceName
        ResourceGroupName  = $ResourceGroupName
        Location           = $Location
        VNET               = $VNet
        Subnet             = $Subnet
        StorageAccountName = $StorageAccountName
        ShareName          = $ShareName
        ImageName          = $ImageName
        OwaspZAPOptions    = $OwaspZAPOptions
    }        
    New-OwaspContainer @NewOwaspContainerParameters
    Write-Host "Completed Step 2 New-OwaspContainer"

    #remove the container instance
    $RemoveOwaspContainerParameters = @{
        AciInstanceName   = $AciInstanceName
        ResourceGroupName = $ResourceGroupName    
    }  
    Remove-OwaspContainer @RemoveOwaspContainerParameters
    Write-Host "Completed Step 3 Remove-OwaspContainer"

    # Copy results from File Share to the build agent
    $reportPath = $ENV:SYSTEM_ARTIFACTSDIRECTORY + '\Reports'
    New-Item -ItemType Directory -Force -Path $reportPath

    $GetOwaspResultsParameters = @{
        ResourceGroupName  = $ResourceGroupName
        StorageAccountName = $StorageAccountName
        ShareName          = $ShareName
        XmlReportName      = $XmlReportName
        OwaspZapReportPath = $reportPath
    }  
    Get-OwaspResults @GetOwaspResultsParameters
    Write-Host "Completed Step 4 Get-OwaspResults"

}
Catch {
    Write-Host "An error occurred: $($_.Exception.Message)..."
    Break
}
finally {
    Disconnect-AzAccount -Scope Process
    Clear-AzContext -Scope Process

    Trace-VstsLeavingInvocation $MyInvocation
}


