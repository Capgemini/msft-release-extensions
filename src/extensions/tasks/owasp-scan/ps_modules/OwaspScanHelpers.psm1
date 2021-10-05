#
# OwaspScanHelpers.psm1
#

<#
    .SYNOPSIS
        This function will create azure container instance to run OWASP ZAP image to perform active security scan on given api endpoints.
    .DESCRIPTION
        Particularly when the comment must be frequently edited,
        as with the help and documentation for a function or script.
#>
Function New-OwaspContainer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [validateNotNullOrEmpty()]
        [string]$AciInstanceName,

        [Parameter(Mandatory = $true)]
        [validateNotNullOrEmpty()]
        [string]$ResourceGroupName,

        [Parameter(Mandatory = $true)]
        [validateNotNullOrEmpty()]
        [string]$Location,

        [Parameter(Mandatory = $true)]
        [validateNotNullOrEmpty()]
        [string]$VNet,

        [Parameter(Mandatory = $true)]
        [validateNotNullOrEmpty()]
        [string]$Subnet,

        [Parameter(Mandatory = $true)]
        [validateNotNullOrEmpty()]
        [string]$StorageAccountName,

        [Parameter(Mandatory = $true)]
        [validateNotNullOrEmpty()]
        [string]$ShareName,

        [Parameter(Mandatory = $true)]
        [validateNotNullOrEmpty()]
        [string]$ImageName,

        [Parameter(Mandatory = $true)]
        [validateNotNullOrEmpty()]
        [string]$OwaspZAPOptions
    )
    try {
        $ErrorActionPreference = "Stop"

        Write-Host "Executing CreateOWASPContainer script"

        $dnsName = "aci-$($Env:BUILD_BUILDID)"
        Write-Host $AciInstanceName $dnsName

        $storageKey = $(az storage account keys list `
                            -g $ResourceGroupName --account-name $StorageAccountName --query "[0].value" --output tsv)

        # Pipeline error: (InvalidIpAddressTypeForNetworkProfile) IP Address type can't be public when network profile is set.
        # Fix: Remove --dns-name-label $dnsName `
        # Public IP or DNS label - Container groups deployed to a virtual network don't currently support exposing containers directly to the internet with a public IP
        az container create `
            --name $AciInstanceName `
            --resource-group $ResourceGroupName `
            --image $ImageName `
            --azure-file-volume-account-name $StorageAccountName `
            --azure-file-volume-account-key $storageKey `
            --azure-file-volume-share-name $ShareName `
            --azure-file-volume-mount-path /zap/wrk/ `
            --location $Location `
            --cpu 4 `
            --memory 8 `
            --query ipAddress.fqdn `
            --command-line $OwaspZAPOptions `
            --restart-policy Never `
            --vnet $VNet `
            --subnet $Subnet `
            --debug

        do {
            Start-Sleep 50

            $currentState = $(az container show `
                    --resource-group $ResourceGroupName `
                    --name $AciInstanceName `
                    --query containers[].instanceView.currentState.state `
                    --output tsv)

            Write-Host "current state:" + $currentState
            Write-Host "Running scan..."
            if ($currentState -ne "Running") {
                Write-Host "Current state:" + $currentState
                break
            }
        } until ($currentState -ne "Running")

        Write-Host "current state:" + $currentState

        return $true

    }
    catch {
        Write-Verbose "Error creating Container Instance: $($_.Exception.ToString())"
        throw $_
    }
}


<#
    .SYNOPSIS
        This function will delete a container instance.
    .DESCRIPTION
        Particularly when the comment must be frequently edited,
        as with the help and documentation for a function or script.
#>
Function Remove-OwaspContainer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [validateNotNullOrEmpty()]
        [string]$AciInstanceName,

        [Parameter(Mandatory = $true)]
        [validateNotNullOrEmpty()]
        [string]$ResourceGroupName
    )

    try {
        $ErrorActionPreference = "Stop"

        $containerInstance = Get-AzContainerGroup -ResourceGroupName $ResourceGroupName -Name $AciInstanceName -ErrorAction SilentlyContinue

        if ($null -eq $containerInstance) {
            ThrowError -errorMessage "An Azure Container Instance with the name '$AciInstanceName' does not exist in the Resource Group $ResourceGroupName"
        }
        else {
            Write-Host "Deleting Container : $AciInstanceName .."
    
            # az container delete `
            #     --name $AciInstanceName `
            #     --resource-group $ResourceGroupName `
            #     --yes
    
            # Replaced with PS as there seems to be an issue with Azure CLI command
            Remove-AzContainerGroup -ResourceGroupName $ResourceGroupName -Name $AciInstanceName 
    
            Write-Host "Deleted Container : $AciInstanceName"
            return $true
        }

    }
    catch {
        Write-Verbose "Error deleting Container Instance: $($_.Exception.ToString())"
        throw $_
    }
    
}


<#
    .SYNOPSIS
        This function download xml report from Share storage and convert it to Nunit3 formatted results file.
    .DESCRIPTION
        The function will retrieve the OWASP API Scans results from a storage account and copy it to the build agent.
#>
Function Get-OwaspResults {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [validateNotNullOrEmpty()]
        [string]$ResourceGroupName,

        [Parameter(Mandatory = $true)]
        [validateNotNullOrEmpty()]
        [string]$StorageAccountName,

        [Parameter(Mandatory = $true)]
        [validateNotNullOrEmpty()]
        [string]$ShareName,

        [Parameter(Mandatory = $true)]
        [validateNotNullOrEmpty()]
        [string]$XmlReportName,

        [Parameter(Mandatory = $true)]
        [validateNotNullOrEmpty()]
        [string]$OwaspZapReportPath

    )
    try {
        $ErrorActionPreference = "Stop"
        $reportName = "owaspscanreport.xml"

        $xslPath = '$PSScriptRoot\..\resources\OWASPToNUnit3.xslt'

        #  Get the storage key
        $storageKey = $(az storage account keys list -g $ResourceGroupName --account-name $StorageAccountName --query "[0].value" --output tsv)

        Write-Host "Download $XmlReportName to $OwaspZapReportPath .."

        (az storage file download `
            --account-name $StorageAccountName `
            --account-key $storageKey `
            -s $ShareName `
            --path $XmlReportName `
            --dest $OwaspZapReportPath\$reportName) | out-null

        Write-Host "Downloaded $XmlReportName successfully."

        Write-Host "Transforming $reportName .."

        Get-ChildItem -Path $OwaspZapReportPath
        $XmlInputPath = "$OwaspZapReportPath\$reportName"
        $XmlOutputPath = "$OwaspZapReportPath\Converted-$reportName"
        $XslTransform = New-Object System.Xml.Xsl.XslCompiledTransform
        Invoke-XslLoad -XmlDoc $XslTransform -XslPath $xslPath
        Invoke-XslTransform -XmlDoc $XslTransform -XmlInputPath $XmlInputPath -XmlOutputPath $XmlOutputPath

        Write-Host "##vso[task.setvariable variable=XmlReportNameOutput]$reportName"
        Write-Host "##vso[task.setvariable variable=OwaspZapReportPathOutput]$XmlOutputPath"

        Write-Host "Transformed $reportName successfully."

        return $true
    
    }
    catch {
        Write-Verbose "Error retrieving OWASP Scan Results: $($_.Exception.ToString())"
        throw $_
    }
}


<#
    .SYNOPSIS
        This function is a wrapper for the System.Xml.Xsl.XslCompiledTransform Load function.
    .DESCRIPTION
        Members of the CLR objects cannot be mocked, so in order to be able to unit tests,
        we wrap the call in a function, which can be mocked..
#>
Function Invoke-XslLoad {
    param( [System.Xml.Xsl.XslCompiledTransform] $XmlDoc, [string] $XslPath )
    $XmlDoc.Load($XslPath)
}

<#
    .SYNOPSIS
        This function is a wrapper for the System.Xml.Xsl.XslCompiledTransform Transform function.
    .DESCRIPTION
        Members of the CLR objects cannot be mocked, so in order to be able to unit tests,
        we wrap the call in a function, which can be mocked..
#>
Function Invoke-XslTransform {
    param( [System.Xml.Xsl.XslCompiledTransform] $XmlDoc, [string] $XmlInputPath, [string] $XmlOutputPath )
    $XmlDoc.Transform($XmlInputPath, $XmlOutputPath)
}



<#
    .SYNOPSIS
        This function sets up options required for API scan
    .DESCRIPTION
        
#>
Function Set-OwaspApiScanOptions {
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.Dictionary[string, string]])]
    param(

        [Parameter(Mandatory = $true)]
        [validateNotNullOrEmpty()]
        [string]$ApiSwaggerEndpoint,

        [Parameter(Mandatory = $true)]
        [validateNotNullOrEmpty()]
        [string]$ResourceGroupName,

        [Parameter(Mandatory = $true)]
        [validateNotNullOrEmpty()]
        [string]$StorageAccountName,

        [Parameter(Mandatory = $true)]
        [validateNotNullOrEmpty()]
        [string]$ShareName,

        [Parameter(Mandatory = $true)]
        [validateNotNullOrEmpty()]
        [string]$OptionFilePath

    )
    try {
        $owaspZapOptionsDictionary = New-Object 'System.Collections.Generic.Dictionary[String,String]'

        Write-Host "Prepare ZAP scan option.."
        Write-Host "Reading = $OptionFilePath"
        $optionsContent = Get-Content -Path $OptionFilePath
        Write-Host "Content read from OptionFile provided by User: $optionsContent"

        $random = (Get-RandomString -length 5)
        $webAppName = "Api-$random"

        $shareFolderName = "ApiTest-$($Env:BUILD_BUILDID)-$random".ToLower()
        $OwaspZAPOptions = "zap-api-scan.py -t ""$ApiSwaggerEndpoint"" -f openapi -r ""$shareFolderName/$webAppName.html"" -x ""$shareFolderName/$webAppName.xml"" -z '"
        foreach ($option in $optionsContent) {
            $OwaspZAPOptions += "-config $option "
        }
        $OwaspZAPOptions = $OwaspZAPOptions.Substring(0, $OwaspZAPOptions.Length - 1)
        $OwaspZAPOptions += "' -d"

        $OwaspZAPOptions = $OwaspZAPOptions.replace("`n", " ").replace("`r", " ") -replace '\s+', ' '

        $owaspZapOptionsDictionary['OwaspZAPOptions'] = $OwaspZAPOptions
        $owaspZapOptionsDictionary['XmlReportName'] = "$shareFolderName/$webAppName.xml"
        $aciName = "owasp-zap-aci-$($Env:BUILD_BUILDID)-$random".ToLower()
        $owaspZapOptionsDictionary['AciInstanceName'] = $aciName

        Write-Host "Create new Sharefolder : $shareFolderName"
        $storageKey = $(az storage account keys list -g $ResourceGroupName --account-name $StorageAccountName --query "[0].value" --output tsv)

        az storage directory create `
            --name $shareFolderName `
            --share-name $ShareName `
            --account-name $StorageAccountName `
            --account-key $storageKey

        return $owaspZapOptionsDictionary
    }
    catch {
        Write-Verbose "Error setting up OWASP API Scan options: $($_.Exception.ToString())"
        throw $_
    }
}

Function Get-RandomString {
    param([string]$length) 
    return -join ((0x30..0x39) + ( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count $length | ForEach-Object { [char]$_ })
}

Function ThrowError {
    param([string]$errorMessage)

    throw "$errorMessage"
}

Function Test-Null(
    [string]$value,
    [string]$variableName
) {
    $value = $value.Trim()
    if (-not $value) {
        ThrowError -errorMessage ("Parameter $variableName cannot be null or empty.")
    }
    return $false
}

Function Test-OptionFile(
    [string]$value,
    [string]$variableName
) {
    
    Test-Null -value $value -variableName $variableName | out-null

    if (-not (Test-Path -LiteralPath $value)) {
        ThrowError -errorMessage ("File path $value does not exist.")
    }

    if (-not ($value.EndsWith('.prop'))) {
        ThrowError -errorMessage ("Invalid Option file = $value. File Name should have '.prop' extension")
    }
    
    Write-Host "Validate-FilePath : $variableName = $value validated succesfully"

    return $true
}
