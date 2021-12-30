targetScope = 'resourceGroup'

param staticWebsiteName string

var location = resourceGroup().location

resource staticWebsite 'Microsoft.Web/staticSites@2021-02-01' = {
  name: staticWebsiteName
  location: location
  sku: {
    name: 'Free'
    tier: 'Free'
  }
  properties: {
    stagingEnvironmentPolicy: 'Enabled'
    allowConfigFileUpdates: true
  }
}