@description('The keyvault name.')
param vaultName string

@description('The custom tags object.')
param customTags object
param aadTenantId string
param accessPolicies array
param location string = resourceGroup().location

@description('The DefaultTags parameters object.')
param defaultTags object

resource vault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: vaultName
  location: location
  tags: union(defaultTags, customTags)
  properties: {
    tenantId: aadTenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    accessPolicies: accessPolicies
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
    enableRbacAuthorization: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
  }
}
