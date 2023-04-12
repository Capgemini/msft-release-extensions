@description('The function app service plan parameter objects. Parameters are: {name, skuTier, skuCode, skuCapacity, skuFamily}')
param app object

@description('The DefaultTags parameters object.')
param defaultTags object

param location string = resourceGroup().location

resource app_name 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: app.name
  location: location
  tags: defaultTags
  properties: {
    perSiteScaling: false
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
  }
  sku: {
    tier: app.skuTier
    name: app.skuCode
    size: app.skuCode
    capacity: app.skuCapacity
    family: app.skuFamily
  }
}
