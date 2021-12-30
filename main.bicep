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
    vnetName: 'vnet-${projectName}'
  }
}

module appservice './modules/app-service.bicep' = {
  name: '${deploymentName}-appservice'
  scope: resourceGroup
  params: {
    appServicePlanName: '${projectName}-${environment}-plan'
    appServiceName: '${projectName}-${environment}'
    virtualNetworkName: vnet.outputs.virtualNetworkName
  }
}
