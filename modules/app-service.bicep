targetScope = 'resourceGroup'

param appServicePlanName string
param appServiceName string
param storageAccountName string
param cosmosAccountName string
param subnetId string
param dataFactoryName string
param tenantId string
param applicationId string
param clientSecret string
param subscriptionId string

var location = resourceGroup().location

var cosmosDataContributorRoleName = '00000000-0000-0000-0000-000000000002'

resource cosmosdbAccount 'Microsoft.DocumentDB/databaseAccounts@2021-10-15' existing = {
  name: cosmosAccountName
}

resource storage 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: storageAccountName
}

resource storageBlobDataContributorRole 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' /* Guid for the Blob Contributor Role */
}

resource cosmosDataContributorRole 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2021-04-15' existing = {
  parent: cosmosdbAccount
  name: cosmosDataContributorRoleName
}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: appServicePlanName
  location: location
  kind: 'linux'
  properties: {
    reserved: true
  }
  sku: {
    name: 'P1v2'
    tier: 'PremiumV2'
    size: 'P1v2'
    family: 'P1v2'
    capacity: 1
  }
}

resource appService 'Microsoft.Web/sites@2021-02-01' = {
  name: appServiceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: appServicePlan.id
    clientAffinityEnabled: false
    virtualNetworkSubnetId: subnetId
  }

  resource appsettingsConfig 'config' = {
    name: 'appsettings'
    properties: {
      AzureSubscriptionId: subscriptionId
      AzureDataFactory__ResourceGroup: resourceGroup().name
      AzureDataFactory__DataFactoryName: dataFactoryName
      AzureClientCredentials__TenantId: tenantId
      AzureClientCredentials__ApplicationId: applicationId
      AzureClientCredentials__ClientSecret: clientSecret
      BlobStorageEndpoint: storage.properties.primaryEndpoints.blob
      CosmosDbEndpoint: 'https://${cosmosAccountName}.documents.azure.com:443/'
    }
  }

  resource webConfig 'config' = {
    name: 'web'
    properties: {
      alwaysOn: true
      detailedErrorLoggingEnabled: true
      http20Enabled: true
      linuxFxVersion: 'DOTNETCORE|6.0'
      vnetRouteAllEnabled: true
    }
  }

  resource hostNameBindings 'hostNameBindings' = {
    name: '${appServiceName}.azurewebsites.net'
    properties: {
      siteName: appServiceName
      hostNameType: 'Verified'
    }
  }
}

resource storageRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  scope: storage
  name: guid(storage.name, storageBlobDataContributorRole.name, appService.name)
  properties: {
    roleDefinitionId: storageBlobDataContributorRole.id
    principalId: appService.identity.principalId
  }
}

resource cosmosDataContributorGrant 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2021-04-15' = {
  parent: cosmosdbAccount
  name: guid(cosmosDataContributorRoleName, appServiceName)
  properties: {
    roleDefinitionId: cosmosDataContributorRole.id
    scope: cosmosdbAccount.id
    principalId: appService.identity.principalId
  }
}
