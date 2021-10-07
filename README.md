[![Build Status](https://capgeminiuk.visualstudio.com/GitHub%20Support/_apis/build/status/CI-Builds/Azure%20DevOps%20Extensions/Capgemini.msft-release-extensions?branchName=master)](https://capgeminiuk.visualstudio.com/GitHub%20Support/_build/latest?definitionId=218&branchName=master)

## Table of contents

- [Table of contents](#table-of-contents)
- [Prerequisites](#prerequisites)
    - [Azure PaaS](#azure-paas)
    - [Others](#others)
- [Installation](#installation)
  - [Tasks](#tasks)
    - [Release Note Generator (Classic Pipelines)](#release-note-generator-classic-pipelines)
    - [OWASP API Scan (YAML Pipeline)](#owasp-api-scan-yaml-pipeline)
      - [Prerequisites](#prerequisites-1)
      - [Azure PaaS](#azure-paas-1)
      - [Others](#others-1)
- [Contributing](#contributing)

## Prerequisites
You will need an Azure Devops instance. The following configurations are supported:
- Azure DevOps Online
- Hosted Azure DevOps on Premise


#### Azure PaaS
- Storage Account, File Share, Virtual Network and Subnet for the running an Azure Container Instance.

#### Others
- Option File (.prop) - You will need to provide option file which contains configurations that require for API Scanning. You can refer below example to understand how to use it.
  
## Installation

You can install the extensions from the Azure DevOps MarketPlace https://marketplace.visualstudio.com/azuredevops 

### Tasks

#### Release Note Generator (Classic Pipelines)
Writes release notes to a designated Wiki Page within Azure DevOps. Upon adding a task to your pipeline, the variables are preconfigured with suggested values. If you have a custom release notes field, you must supply the field name e.g. Custom.ReleaseNoteField. This field is optional.

You must supply:
- Organisation Name (Which you can get from the Url of Azure DevOps)
- Wiki Path (Can be a nested path if you wish)
- Wiki release Notes root path (Top Level Path)
- User Name (This is a friendly name of your choice and will be shown on the release notes

The rest of the fields are pre-populated to make the installation much easier.

![release-notes-extension](https://user-images.githubusercontent.com/22330376/129528879-1d752e28-5866-48be-9329-66989fc6d8e3.png)


#### OWASP API Scan (YAML Pipeline)

Using this task, you can run security scan on API using OWASP zap and publish result to pipeline. Upon adding a task to your pipeline, few variables are preconfigured with suggested values.
You must supply:
- Azure Subscription (Azure Resource Manager subscription for the deployment)
- Name of the resource group (The name of the resource group that contains the storage account)
- Location (Location for deploying the container)
- Api Swagger endpoint url (Api Swagger endpoint url to scan)
- Name of the storage account (The name of the Storage Account to be used by the OWASP container to store the results of the OWASP Scan)
- Name of the File Share (The name of the file share in the Storage Account where results of the OWASP Scan will be stored)
- Name of the OWASP Image (OWASP Scan image)
- Path to Option file (The path to option file which will be use to prepare request headers require for the api scan)

The rest of the fields are pre-populated to make the installation much easier.

##### Prerequisites
In addition to the =an Azure Devops instance. You will require the following pre-requisities listed below to use this task.
##### Azure PaaS
- Storage Account, File Share
##### Others
- Option File (options.prop) - You will need to provide option file (options.prop) which contains configurations that require for your API Scanning. Below example shows the how this file looks like. Basically these are the request header paraemters to API which OWASP requires for scanning. You will have to modify this file (for e.g. You might need to send authentication header in it for authorizing apis during the OWASP run.) This is the mandatory file which you can generate dnamically during the build stage as a artifact and will need to provide to this extension task and 
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
- Virtual Network and Subnet for the running an Azure Container Instance.

## Contributing

Refer to the contributing [guide](./CONTRIBUTING.md).
