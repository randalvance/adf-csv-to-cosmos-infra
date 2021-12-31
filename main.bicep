targetScope = 'subscription'

param environment string
param resourceGroupName string

var projectName = 'adf-csv-to-cosmos'
var deploymentName = deployment().name
var location = deployment().location

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module vnet  './modules/vnet.bicep' = {
  name: '${deploymentName}-vnet'
  scope: resourceGroup
  params: {
    vnetName: 'vnet-${projectName}-${environment}'
  }
}

module appservice './modules/app-service.bicep' = {
  name: '${deploymentName}-appservice'
  scope: resourceGroup
  params: {
    appServicePlanName: '${projectName}-plan-${environment}'
    appServiceName: '${projectName}-${environment}'
    subnetId: vnet.outputs.webSubnetId
  }
}

module storage './modules/storage.bicep' = {
  name: '${deploymentName}-storage'
  scope: resourceGroup
  params: {
    accountName: 'adfcsvcosmos${environment}'
    subnetId: vnet.outputs.storageSubnetId
  }
}

module staticWebsiteStorage './modules/static-website.bicep' = {
  name: '${deploymentName}-static-website'
  scope: resourceGroup
  params: {
    accountName: 'adfcsvcosmosweb${environment}'
  }
}
