@description('Location for all resources.')
param location string = resourceGroup().location

@description('First VNET name')
param vnet1Name string

@description('Second VNET name')
param vnet2Name string

@description('First VNET address prefix')
param vnet1AddressPrefix string

@description('Second VNET address prefix')
param vnet2AddressPrefix string

@description('Infra subnet address prefix for VNET1')
param vnet1InfraSubnetPrefix string

@description('Storage subnet address prefix for VNET1')
param vnet1StorageSubnetPrefix string

@description('Infra subnet address prefix for VNET2')
param vnet2InfraSubnetPrefix string

@description('Storage subnet address prefix for VNET2')
param vnet2StorageSubnetPrefix string

// VNET 1
resource vnet1 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnet1Name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet1AddressPrefix
      ]
    }
    subnets: [
      {
        name: 'infra'
        properties: {
          addressPrefix: vnet1InfraSubnetPrefix
        }
      }
      {
        name: 'storage'
        properties: {
          addressPrefix: vnet1StorageSubnetPrefix
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
              locations: [
                location
              ]
            }
          ]
        }
      }
    ]
  }
}

// VNET 2
resource vnet2 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnet2Name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet2AddressPrefix
      ]
    }
    subnets: [
      {
        name: 'infra'
        properties: {
          addressPrefix: vnet2InfraSubnetPrefix
        }
      }
      {
        name: 'storage'
        properties: {
          addressPrefix: vnet2StorageSubnetPrefix
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
              locations: [
                location
              ]
            }
          ]
        }
      }
    ]
  }
}

// VNET Peering VNET1 to VNET2
resource vnet1ToVnet2Peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-05-01' = {
  name: '${vnet1Name}/peering-to-${vnet2Name}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vnet2.id
    }
  }
  dependsOn: [
    vnet1
    vnet2
  ]
}

// VNET Peering VNET2 to VNET1
resource vnet2ToVnet1Peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-05-01' = {
  name: '${vnet2Name}/peering-to-${vnet1Name}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vnet1.id
    }
  }
  dependsOn: [
    vnet1
    vnet2
  ]
}

// Outputs
output vnet1Id string = vnet1.id
output vnet2Id string = vnet2.id
output vnet1InfraSubnetId string = vnet1.properties.subnets[0].id
output vnet1StorageSubnetId string = vnet1.properties.subnets[1].id
output vnet2InfraSubnetId string = vnet2.properties.subnets[0].id
output vnet2StorageSubnetId string = vnet2.properties.subnets[1].id
