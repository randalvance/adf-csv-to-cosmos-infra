targetScope = 'resourceGroup'

param storageAccountName string
param virtualNetworkName string

var location = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
  name: virtualNetworkName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    networkAcls: {
      bypass: 'None'
      virtualNetworkRules: [
        {
          id: vnet.properties.subnets[1].id
          action: 'Allow'
          state: 'Succeeded'
        }
      ]
      ipRules: []
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
  }

  resource defaultBlobService 'blobServices' = {
    name: 'default'

    resource container 'containers' = {
      name: 'input'
      properties: {
        publicAccess: 'None'
      }
    }
  }
}
