@description('The keyvault name.')
param vaultName string

@description('The VNET infra object. Paramter are :{name, subnets: []}')
param vnetInfra object

@description('The resourceGroups parameters object. Parameters are: {infraRg, apimRg}')
param resourceGroups object

@description('The custom tags object.')
param customTags object
param aadTenantId string
param accessPolicies array

@description('The DefaultTags parameters object.')
param defaultTags object

var vnetRules = [for i in range(0, length(vnetInfra.subnets)): {
  id: '${resourceId(resourceGroups.infraRg, 'Microsoft.Network/virtualNetworks', vnetInfra.name)}/subnets/${vnetInfra.subnets[i]}'
}]

resource vault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: vaultName
  location: resourceGroup().location
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
    enablePurgeProtection: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      virtualNetworkRules: vnetRules
    }
  }
}