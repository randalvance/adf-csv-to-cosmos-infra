targetScope = 'resourceGroup'

param storageAccountName string

var location = resourceGroup().location

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
      virtualNetworkRules: []
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
