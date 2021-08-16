[![Build Status](https://capgeminiuk.visualstudio.com/GitHub%20Support/_apis/build/status/CI-Builds/Azure%20DevOps%20Extensions/Capgemini.msft-release-extensions?branchName=master)](https://capgeminiuk.visualstudio.com/GitHub%20Support/_build/latest?definitionId=218&branchName=master)

## Table of contents

- [Table of contents](#table-of-contents)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Contributing](#contributing)

## Prerequisites
You will need an Azure Devops instance. The following configurations are supported:
- Azure DevOps Online
- Hosted Azure DevOps on Premise

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


## Contributing

Refer to the contributing [guide](./CONTRIBUTING.md).
