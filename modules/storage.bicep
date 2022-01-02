targetScope = 'resourceGroup'

param accountName string
param subnetId string
param developerGroupObjectId string

var location = resourceGroup().location

resource storageBlobDataContributorRole 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' /* Guid for the Blob Contributor Role */
}

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
      bypass: 'AzureServices'
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

// Add Developer group as Blob Contributor
resource storageRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  scope: storageAccount
  name: guid(storageAccount.name, storageBlobDataContributorRole.name, 'developer')
  properties: {
    roleDefinitionId: storageBlobDataContributorRole.id
    principalId: developerGroupObjectId
  }
}


output accountName string = storageAccount.name
