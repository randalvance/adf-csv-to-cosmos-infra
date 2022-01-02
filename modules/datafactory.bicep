targetScope = 'resourceGroup'

param dataFactoryName string
param applicationObjectId string
param storageAccountName string
param cosmosDbAccountName string
param environment string

var cosmosDataContributorRoleName = '00000000-0000-0000-0000-000000000002'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: storageAccountName
}

resource cosmosdbAccount 'Microsoft.DocumentDB/databaseAccounts@2021-10-15' existing = {
  name: cosmosDbAccountName
}

resource storageBlobDataContributorRole 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' /* Guid for the Blob Contributor Role */
}

resource dataFactoryContributorRole 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: '673868aa-7521-48a0-acc6-0f60742d39f5' /* Guid for the Data Factory Contributor Role */
}

resource cosmosDataContributorRole 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2021-04-15' existing = {
  parent: cosmosdbAccount
  name: cosmosDataContributorRoleName
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
  scope: storageAccount
  name: guid(storageAccount.name, storageBlobDataContributorRole.name, dataFactoryName)
  properties: {
    roleDefinitionId: storageBlobDataContributorRole.id
    principalId: factory.identity.principalId
  }
}

resource cosmosAdfDataContributorGrant 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2021-04-15' = {
  parent: cosmosdbAccount
  name: guid(cosmosDataContributorRoleName, dataFactoryName, 'adf')
  properties: {
    roleDefinitionId: cosmosDataContributorRole.id
    scope: cosmosdbAccount.id
    principalId: factory.identity.principalId
  }
}

resource cosmosSpDataContributorGrant 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2021-04-15' = {
  parent: cosmosdbAccount
  name: guid(cosmosDataContributorRoleName, dataFactoryName, 'adApp')
  properties: {
    roleDefinitionId: cosmosDataContributorRole.id
    scope: cosmosdbAccount.id
    principalId: applicationObjectId
  }
}

resource dataFactoryContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  scope: factory
  name: guid(factory.name, dataFactoryContributorRole.name, dataFactoryName)
  properties: {
    roleDefinitionId: dataFactoryContributorRole.id
    principalId: applicationObjectId
  }
}
