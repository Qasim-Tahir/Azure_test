@description('Location for all resources')
param location string = 'eastus'

@description('Username for the VM admin')
param adminUsername string

@description('Password for the VM admin')
@secure()
param adminPassword string

@description('Name for the first virtual network')
param vnet1Name string = 'vnet1'

@description('Name for the second virtual network')
param vnet2Name string = 'vnet2'

@description('VNet1 address space and subnets')
param vnet1Prefix string = '10.0.0.0/16'
param vnet1InfraPrefix string = '10.0.1.0/24'
param vnet1StoragePrefix string = '10.0.2.0/24'

@description('VNet2 address space and subnets')
param vnet2Prefix string = '10.1.0.0/16'
param vnet2InfraPrefix string = '10.1.1.0/24'
param vnet2StoragePrefix string = '10.1.2.0/24'

// Virtual Networks
module vnet1 'modules/vnet.bicep' = {
  name: 'vnet1Deploy'
  params: {
    name: vnet1Name
    location: location
    addressPrefix: vnet1Prefix
    infraSubnetPrefix: vnet1InfraPrefix
    storageSubnetPrefix: vnet1StoragePrefix
  }
}

module vnet2 'modules/vnet.bicep' = {
  name: 'vnet2Deploy'
  params: {
    name: vnet2Name
    location: location
    addressPrefix: vnet2Prefix
    infraSubnetPrefix: vnet2InfraPrefix
    storageSubnetPrefix: vnet2StoragePrefix
  }
}

// VNet Peering
resource vnet1ToVnet2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-05-01' = {
  name: '${vnet1Name}/vnet1-to-vnet2'
  properties: {
    remoteVirtualNetwork: {
      id: vnet2.outputs.vnetId
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

resource vnet2ToVnet1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-05-01' = {
  name: '${vnet2Name}/vnet2-to-vnet1'
  properties: {
    remoteVirtualNetwork: {
      id: vnet1.outputs.vnetId
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

// VMs
module vm1 'modules/vm.bicep' = {
  name: 'vm1'
  params: {
    name: 'vm1'
    location: location
    adminUsername: adminUsername
    adminPassword: adminPassword
    subnetId: vnet1.outputs.subnets.infra
  }
}

module vm2 'modules/vm.bicep' = {
  name: 'vm2'
  params: {
    name: 'vm2'
    location: location
    adminUsername: adminUsername
    adminPassword: adminPassword
    subnetId: vnet2.outputs.subnets.infra
  }
}

// Storage Accounts
module storage1 'modules/storage.bicep' = {
  name: 'storage1'
  params: {
    name: 'storage1zrs'
    location: location
  }
}

module storage2 'modules/storage.bicep' = {
  name: 'storage2'
  params: {
    name: 'storage2zrs'
    location: location
  }
}
