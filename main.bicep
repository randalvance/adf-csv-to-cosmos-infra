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
    virtualNetworkName: vnet.outputs.virtualNetworkName
  }
}

module storage './modules/storage.bicep' = {
  name: '${deploymentName}-storage'
  scope: resourceGroup
  params: {
    storageAccountName: 'adfcsvcosmos${environment}'
    virtualNetworkName: vnet.outputs.virtualNetworkName
  }
}
