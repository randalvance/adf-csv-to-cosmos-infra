targetScope = 'resourceGroup'

param accountName string
param subnetId string

var location = resourceGroup().location

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: accountName
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
          id: subnetId
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
      name: 'uploaded'
      properties: {
        publicAccess: 'None'
      }
    }
  }
}

output accountName string = storageAccount.name
