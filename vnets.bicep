param location string = resourceGroup().location
@description('Location for all resources')
param location             string

@description('Name of the first VNET')
param vnet1Name            string

@description('Name of the second VNET')
param vnet2Name            string

@description('Address prefix for VNET 1')
param vnet1AddressPrefix   string

@description('Address prefix for VNET 2')
param vnet2AddressPrefix   string

@description('Infra subnet prefix for VNET 1')
param vnet1InfraSubnetPrefix   string

@description('Storage subnet prefix for VNET 1')
param vnet1StorageSubnetPrefix string

@description('Infra subnet prefix for VNET 2')
param vnet2InfraSubnetPrefix   string

@description('Storage subnet prefix for VNET 2')
param vnet2StorageSubnetPrefix string

resource vnet1 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: 'vnet1'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'infra'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        name: 'storage'
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
    ]
  }
}

resource vnet2 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: 'vnet2'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'infra'
        properties: {
          addressPrefix: '10.1.1.0/24'
        }
      }
      {
        name: 'storage'
        properties: {
          addressPrefix: '10.1.2.0/24'
        }
      }
    ]
  }
}

// VNet Peering from vnet1 to vnet2
resource peer1to2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-05-01' = {
  name: 'vnet1-to-vnet2'
  parent: vnet1
  properties: {
    remoteVirtualNetwork: {
      id: vnet2.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

// VNet Peering from vnet2 to vnet1
resource peer2to1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-05-01' = {
  name: 'vnet2-to-vnet1'
  parent: vnet2
  properties: {
    remoteVirtualNetwork: {
      id: vnet1.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}
output vnet1Id                string = vnet1.id
output vnet2Id                string = vnet2.id
output vnet1InfraSubnetId     string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet1.name, 'infra')
output vnet1StorageSubnetId   string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet1.name, 'storage')
output vnet2InfraSubnetId     string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet2.name, 'infra')
output vnet2StorageSubnetId   string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet2.name, 'storage')
