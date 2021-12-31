targetScope = 'resourceGroup'

param dataFactoryName string
param environment string

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
}
