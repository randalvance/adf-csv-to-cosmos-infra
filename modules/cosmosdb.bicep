targetScope = 'resourceGroup'

param accountName string

var location = resourceGroup().location

resource database 'Microsoft.DocumentDB/databaseAccounts@2021-10-15' = {
  name: accountName
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
      }
    ]
  }
}
