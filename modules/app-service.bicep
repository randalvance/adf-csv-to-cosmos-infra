targetScope = 'resourceGroup'

param appServicePlanName string
param appServiceName string
param virtualNetworkName string

var location = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: virtualNetworkName
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
  }

  resource appsettingsConfig 'config' = {
    name: 'appsettings'
    properties: {
      COSMOS_ENDPOINT: ''
      STORAGE_BLOB_ENDPOINT: ''
    }
  }

  resource webConfig 'config' = {
    name: 'web'
    properties: {
      alwaysOn: true
      detailedErrorLoggingEnabled: true
      ftpsState: 'FtpsOnly'
      http20Enabled: true
      httpLoggingEnabled: true
      netFrameworkVersion: 'v4.0'
      linuxFxVersion: 'DOTNETCORE|5.0'
      minTlsVersion: '1.2'
      requestTracingEnabled: true
      ipSecurityRestrictions: [
        {
          vnetSubnetResourceId: vnet.properties.subnets[0].id
          action: 'Allow'
          tag: 'Default'
          priority: 100
        }
        {
          ipAddress: 'Any'
          action: 'Deny'
          priority: 2147483647
          name: 'Deny all'
          description: 'Deny all access'
        }
      ]
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
