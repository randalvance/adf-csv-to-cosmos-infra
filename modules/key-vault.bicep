targetScope = 'resourceGroup'

param vaultName string
param tenantId string

var location = resourceGroup().location

resource keyvault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: vaultName
  location: location
  properties: {
    enableRbacAuthorization: true
    tenantId: tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}
