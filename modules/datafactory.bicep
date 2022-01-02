targetScope = 'resourceGroup'

param dataFactoryName string
param groupObjectId string
param storageAccountName string
param environment string

resource storage 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: storageAccountName
}

resource storageBlobDataContributorRole 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' /* Guid for the Blob Contributor Role */
}

resource dataFactoryContributorRole 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: '673868aa-7521-48a0-acc6-0f60742d39f5' /* Guid for the Data Factory Contributor Role */
}

var location = resourceGroup().location

resource factory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  properties: {
    repoConfiguration: environment == 'dev' ? {
      type: 'FactoryGitHubConfiguration'
      accountName: 'randalvance'
      repositoryName: 'adf-csv-to-cosmos-adf-pipeline'
      collaborationBranch: 'main'
      rootFolder: 'datafactory'
    } : {}
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource storageBlobContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  scope: storage
  name: guid(storage.name, storageBlobDataContributorRole.name, dataFactoryName)
  properties: {
    roleDefinitionId: storageBlobDataContributorRole.id
    principalId: factory.identity.principalId
  }
}

resource dataFactoryContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  scope: factory
  name: guid(factory.name, dataFactoryContributorRole.name, dataFactoryName)
  properties: {
    roleDefinitionId: dataFactoryContributorRole.id
    principalId: groupObjectId
  }
}
