param vnet1Id string
param vnet2Id string
param vnet1Name string
param vnet2Name string

resource peer1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-05-01' = {
  name: '${vnet1Name}/to-${vnet2Name}'
  properties: {
    remoteVirtualNetwork: { id: vnet2Id }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

resource peer2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-05-01' = {
  name: '${vnet2Name}/to-${vnet1Name}'
  properties: {
    remoteVirtualNetwork: { id: vnet1Id }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}
