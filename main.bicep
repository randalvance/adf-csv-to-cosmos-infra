targetScope = 'subscription'

param environment string
param resourceGroupName string
param developerGroupObjectId string
param tenantId string
param applicationId string
param clientSecret string
param applicationObjectId string
param subscriptionId string

var projectName = 'adf-csv-to-cosmos'
var deploymentName = deployment().name
var location = deployment().location

var dataFactoryName = 'df-${projectName}-${environment}'
var cosmosDbAccountName = 'cdb-${projectName}-${environment}'

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

module storage './modules/storage.bicep' = {
  name: '${deploymentName}-storage'
  scope: resourceGroup
  params: {
    accountName: 'adfcsvcosmos${environment}'
    subnetId: vnet.outputs.subnetId
    developerGroupObjectId: developerGroupObjectId
  }
}

module appservice './modules/app-service.bicep' = {
  name: '${deploymentName}-appservice'
  scope: resourceGroup
  params: {
    appServicePlanName: '${projectName}-plan-${environment}'
    appServiceName: '${projectName}-${environment}'
    storageAccountName: storage.outputs.accountName
    cosmosAccountName: cosmosDbAccountName
    subnetId: vnet.outputs.subnetId
    dataFactoryName: dataFactoryName
    tenantId: tenantId
    applicationId: applicationId
    clientSecret: clientSecret
    subscriptionId: subscriptionId
  }
}

module cosmosdb './modules/cosmosdb.bicep' = {
  name: '${deploymentName}-cosmos'
  scope: resourceGroup
  params: {
    accountName: cosmosDbAccountName
    subnetId: vnet.outputs.subnetId
  }
}

module staticWebsiteStorage './modules/static-website.bicep' = {
  name: '${deploymentName}-static-website'
  scope: resourceGroup
  params: {
    accountName: 'adfcsvcosmosweb${environment}'
  }
}

module dataFactory './modules/datafactory.bicep' = {
  name: '${deploymentName}-data-factory'
  scope: resourceGroup
  params: {
    dataFactoryName: dataFactoryName
    cosmosDbAccountName: cosmosDbAccountName
    storageAccountName: storage.outputs.accountName
    applicationObjectId: applicationObjectId
    environment: environment
  }
  dependsOn: [
    cosmosdb
  ]
}
