param vnetName string
param location string

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vnetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'web'
        properties: {
          addressPrefix: '10.1.1.0/24'
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'storage'
        properties: {
          addressPrefix: '10.1.2.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
              locations: [
                location
              ]
            }
            {
              service: 'Microsoft.AzureCosmosDB'
              locations: [
                '*'
              ]
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

resource storage 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: vnet
  name: 'storage'
  properties: {
    addressPrefix: '10.1.2.0/24'
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
        locations: [
          location
        ]
      }
      {
        service: 'Microsoft.AzureCosmosDB'
        locations: [
          '*'
        ]
      }
    ]
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource web 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: vnet
  name: 'web'
  properties: {
    addressPrefix: '10.1.1.0/24'
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

output virtualNetworkName string = vnet.name
