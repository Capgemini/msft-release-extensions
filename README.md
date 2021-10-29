[![Build Status](https://capgeminiuk.visualstudio.com/GitHub%20Support/_apis/build/status/CI-Builds/Azure%20DevOps%20Extensions/Capgemini.msft-release-extensions?branchName=master)](https://capgeminiuk.visualstudio.com/GitHub%20Support/_build/latest?definitionId=218&branchName=master)

## Table of contents

- [Table of contents](#table-of-contents)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
  - [Tasks](#tasks)
    - [Release Note Generator (Classic Pipelines)](#release-note-generator-classic-pipelines)
    - [OWASP API Scan (YAML Pipeline)](#owasp-api-scan-yaml-pipeline)
      - [Prerequisites](#prerequisites-1)
        - [Azure PaaS](#azure-paas)
        - [Others](#others)
      - [Use the extension as a pipeline task in your azure devops yaml pipeline to run Security Scan on API's](#use-the-extension-as-a-pipeline-task-in-your-azure-devops-yaml-pipeline-to-run-security-scan-on-apis)
     - [Azure Synapse Package Upload (Classic and YAML Pipeline)](#azure-synapse-package-upload-classic-and-yaml-pipeline)
     - [Azure Synapse Enable Disable Pipeline Triggers (Classic and YAML Pipeline)](#azure-synapse-enable-disable-pipeline-triggers-classic-and-yaml-pipeline)
- [Contributing](#contributing)

## Prerequisites
You will need an Azure Devops instance. The following configurations are supported:
- Azure DevOps Online
- Hosted Azure DevOps on Premise

Additional prerequisites for each task are specified below in each task's section.

## Installation

You can install the extensions from the Azure DevOps MarketPlace https://marketplace.visualstudio.com/items?itemName=capgemini-msft-uk.build-release-task 

### Tasks

#### Release Note Generator (Classic Pipelines)
Writes release notes to a designated Wiki Page within Azure DevOps. Upon adding a task to your pipeline, the variables are preconfigured with suggested values. If you have a custom release notes field, you must supply the field name e.g. Custom.ReleaseNoteField. This field is optional.

You must supply:
- Organisation Name (Which you can get from the Url of Azure DevOps)
- Wiki Path (Can be a nested path if you wish)
- Wiki release Notes root path (Top Level Path)
- User Name (This is a friendly name of your choice and will be shown in the release notes

The rest of the fields are pre-populated to make the installation much easier.

![release-notes-extension](https://user-images.githubusercontent.com/22330376/129528879-1d752e28-5866-48be-9329-66989fc6d8e3.png)


#### OWASP API Scan (YAML Pipeline)

Using this task, you can run a security scan on API using OWASP zap and publish results to the pipeline. Upon adding a task to your pipeline, few variables are preconfigured with suggested values.
You must supply:
- Azure Subscription (Azure Resource Manager subscription for the deployment)
- Name of the resource group (The name of the resource group that contains the storage account)
- Location (Location for deploying the container)
- API Swagger endpoint url (API Swagger endpoint url to scan)
- Name of the storage account (The name of the Storage Account to be used by the OWASP container to store the results of the OWASP Scan)
- Name of the File Share (The name of the file share in the Storage Account where the results of the OWASP Scan will be stored)
- Name of the OWASP Image (OWASP Scan image. It should be 'owasp/zap2docker-weekly')
- Path to Option file (The path to option file which will be used to prepare request headers require for the API scan. The name of the file must be 'options.prop')

The rest of the fields are pre-populated to make the installation much easier.

##### Prerequisites
In addition to the an Azure Devops instance, you will require the following pre-requisities listed below to use this task.
###### Azure PaaS
- Storage Account, File Share
###### Others

- Virtual Network and Subnet. Azure Container Instances enables deployment of container instances into an Azure virtual network. A Virtual Network is used to ensure that access to the Storage account that stores the results of OWASP Scan can be restricted. You can either use Service Endpoints enabled on the Subnet or use a Private Endpoint for the Storage account. Note that build agent will need to be able to connect to the storage account to retrieve the results of the OWASP API Scan. 

- Option File (options.prop) - You will need to provide an option file (options.prop) that contains API Header Request configurations. The example below shows what the contents of this file look like. These are the request header parameters that will be included in the API requests when the OWASP API scan is running. You should modify this file to include any additional headers (e.g. include an Authorization Request Header that contains a bearer token and one for an API Management Subscription Header key 'Ocp-Apim-Subscription-Key' if you are using the Azure API Management.) This is a mandatory file, which you can generate dynamically during the build stage as a artifact. 

```
replacer.full_list(0).description=ContentTypeHeader 
replacer.full_list(0).enabled=true 
replacer.full_list(0).matchtype=REQ_HEADER 
replacer.full_list(0).matchstr=Content-Type 
replacer.full_list(0).regex=false 
replacer.full_list(0).replacement=application/json 
replacer.full_list(1).description=AccceptHeader 
replacer.full_list(1).enabled=true 
replacer.full_list(1).matchtype=REQ_HEADER 
replacer.full_list(1).matchstr=Accept 
replacer.full_list(1).regex=false 
replacer.full_list(1).replacement=application/json

```


#####  Use the extension as a pipeline task in your azure devops yaml pipeline to run Security Scan on API's
You will also need to use **PublishTestResults@2** task with this extension in order to publish test results after the scan is completed. Below is the example which shows how to use it in YAML pipeline.

```
- task: capgemini-uk-msft-owaspscan-extensions@0
      inputs:
        azureSubscription: '{azure connection name}'
        ResourceGroupName: '{resource group name}'
        Location: 'UK South'
        VNet: 'aci-vnet'
        Subnet: 'aci-subnet'
        ApiEndpoint: 'https:{api base url}/swagger/v1/swagger.json'
        StorageAccountName: '{storage account name}'
        ShareName: 'owaspresults'
        ImageName: 'owasp/zap2docker-weekly'
        OptionFilePath: '$(System.ArtifactsDirectory)/drop/Options/options.prop'

- task: PublishTestResults@2
      displayName: 'Publish Test Results **/Converted*.xml'
      inputs:
        testResultsFormat: NUnit
        testResultsFiles: '**/Converted*.xml'
        testRunTitle: 'OWASP API Tests'
        searchFolder: '$(System.ArtifactsDirectory)'  
```
You can read more about this extension and its usage on https://marketplace.visualstudio.com/items?itemName=capgemini-msft-uk.build-release-task  

#### Azure Synapse Package Upload (Classic and YAML Pipeline)
Upload whl files from a specified location to a Synapse workspace and apply it to all spark pools.
![image](https://user-images.githubusercontent.com/22330376/139492579-6149e952-4cdd-4221-94a1-e0ff162991c1.png)

#### Azure Synapse Enable Disable Pipeline Triggers (Classic and YAML Pipeline)
Allows you to enable and disable triggers before and after a release. Recommended by Microsoft.
![image](https://user-images.githubusercontent.com/22330376/139492737-37b286ab-70c8-4e6a-b3e1-208dea0033be.png)

## Contributing

Refer to the contributing [guide](./CONTRIBUTING.md).
