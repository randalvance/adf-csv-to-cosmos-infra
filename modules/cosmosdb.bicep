targetScope = 'resourceGroup'

param accountName string
param subnetId string

var location = resourceGroup().location

resource account 'Microsoft.DocumentDB/databaseAccounts@2021-10-15' = {
  name: accountName
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    publicNetworkAccess: 'Disabled'
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
      }
    ]
    isVirtualNetworkFilterEnabled: true
    virtualNetworkRules: [
      {
        id: subnetId
        ignoreMissingVNetServiceEndpoint: false
      }
    ]
  }
  identity: {
    type: 'SystemAssigned'
  }

  resource database 'sqlDatabases' = {
    name: 'awesomedb'
    properties: {
      resource: {
        id: 'awesomedb'
      }
    }

    resource container 'containers' = {
      name: 'people'
      properties: {
        resource: {
          id: 'people'
          partitionKey: {
            paths: [
              '/id'
            ]
            kind: 'Hash'
          }
        }
      }
    }
  }
}
