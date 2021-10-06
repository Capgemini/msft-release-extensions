- [1. Description](#1-description)
- [2. Tasks](#2-tasks)
  - [2.1. Create Release Notes](#21-create-release-notes)
    - [2.1.1. More Information](#211-more-information)
  - [2.2. Azure Devops Extension - capgemini-uk-msft-owaspscan-extensions](#22-azure-devops-extension---capgemini-uk-msft-owaspscan-extensions)
    - [2.2.1. Usage:](#221-usage)
      - [2.2.1.1. Install the below extension in your azure devops organization:](#2211-install-the-below-extension-in-your-azure-devops-organization)
      - [2.2.1.2. Dependencies:](#2212-dependencies)
      - [2.2.1.3. Use the extension as a pipeline task in your azure devops yaml pipeline to run Security Scan on API's:](#2213-use-the-extension-as-a-pipeline-task-in-your-azure-devops-yaml-pipeline-to-run-security-scan-on-apis)
      - [2.2.1.4. Output:](#2214-output)
- [3. How this Extension works:](#3-how-this-extension-works)
- [4. More Information:](#4-more-information)
## 1. Description

Azure.DevOps.Extension.Xrm.Release provides tasks for use in Azure DevOps release pipelines. These tasks enable a Continuous Deployment pipeline to be created for Dynamics 365.

## 2. Tasks

### 2.1. Create Release Notes

Creates a release note page for each release to a specific environment. You must provide a wiki structure that matches the WikiPath property in the task.

Please remember to give the build agent service contributor permissions to the Wiki. On installation you must provide the organisation name as a parameter to


#### 2.1.1. More Information

More information can be found in our [GitHub Wiki](https://github.com/Capgemini/msft-release-extensions/wiki).

----

### 2.2. Azure Devops Extension - capgemini-uk-msft-owaspscan-extensions

OWASP Zed Attack Proxy (ZAP) is an open source security tool used in the industry for performing security scan on web applications and APIs. Doing Security scan on a application helps ensure that there are no security vulnerabilities hackers could exploit and development team will be able to identify security loopholes in the system before it goes to production.

This extension provides OWASP Scan tasks for use in Azure DevOps release pipelines. This task enable easily scan APIs and publish report to pipeline in Test tab.

#### 2.2.1. Usage:

##### 2.2.1.1. Install the below extension in your azure devops organization:

https://marketplace.visualstudio.com/items?itemName=capgemini-msft-uk.build-release-task

##### 2.2.1.2. Dependencies:
- Azure Storage account and File Share - Storage account with File share is required. Once scan is finished OWASP xml and html report is being stored inside file share. This extension supports using storage account which is in private network.
- Azure container instance (ACI) - This extension uses Azure Container Instance(ACI) to run OWASP Zap image (**zap-api-scan.py**). So it will create ACI on the fly to scan the apis. Once scan is finished and reports is published, it will automatically delete ACI. Make sure appropriate permissions are in place so that extension can create and delete ACI.
- options.prop file - 

##### 2.2.1.3. Use the extension as a pipeline task in your azure devops yaml pipeline to run Security Scan on API's:
You will also need to use **PublishTestResults@2** task with this extension in order to publish test result after scan is completed. below is the example which shows how to use it in YAML pipeline.

```
- task: capgemini-uk-msft-owaspscan-extensions@0
      inputs:
        azureSubscription: 'Visual Studio Enterprise(87151172-d1e4-4872-97de-bbfef17fa048)'
        ResourceGroupName: 'owasp-demos-rg'
        Location: 'UK South'
        VNet: 'aci-vnet'
        Subnet: 'aci-subnet'
        ApiEndpoint: 'https://weatherapiowaspdemo.azurewebsites.net/swagger/v1/swagger.json'
        StorageAccountName: 'apitestsdemost'
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


##### 2.2.1.4. Output:
Once task runs successfully, you can view scan output in,
- ###### View published report in Pipeline - Test tab
Once scan is finished succesfully you can view scan report in pipeline - _Test tab_. Below is the example of how Scan report look like after using this extension.
![ScreenShot](images/Screenshot_OwaspScanResult.PNG)

- ###### View HTML report in Storage Account - File Share
Detailed HTML report is also stored inside Storgae account - File Share. You can use it to analyze all the security vulnerabilities in detail.
![ScreenShot](images/Screenshot_StorageShare.PNG)


## 3. How this Extension works:


## 4. More Information:

More information can be found in our [GitHub Wiki](https://github.com/Capgemini/msft-release-extensions/).