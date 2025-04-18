param location string = 'eastus'
param adminUsername string

@secure()
param adminPassword string // ✅ Now marked as secure

// VNET1
module vnet1 'modules/vnet.bicep' = {
  name: 'vnet1Module'
  params: {
    name: 'vnet1'
    location: location
    addressPrefix: '10.0.0.0/16'
    infraSubnetPrefix: '10.0.1.0/24'
    storageSubnetPrefix: '10.0.2.0/24'
  }
}

module vnet2 'modules/vnet.bicep' = {
  name: 'vnet2Module'
  params: {
    name: 'vnet2'
    location: location
    addressPrefix: '10.1.0.0/16'
    infraSubnetPrefix: '10.1.1.0/24'
    storageSubnetPrefix: '10.1.2.0/24'
  }
}

// Peering — use correct parent reference instead of scope
resource vnet1ToVnet2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-05-01' = {
  name: 'vnet1-to-vnet2'
  scope: resourceGroup() // 👈 Optional, depending on context
  properties: {
    remoteVirtualNetwork: {
      id: vnet2.outputs.vnetId
    }
    allowVirtualNetworkAccess: true
  }
  dependsOn: [
    vnet1
    vnet2
  ]
}


resource vnet2ToVnet1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-05-01' = {
  name: 'vnet2-to-vnet1'
  scope: resourceGroup() // 👈 Optional, depending on context
  properties: {
    remoteVirtualNetwork: {
      id: vnet1.outputs.vnetId
    }
    allowVirtualNetworkAccess: true
  }
  dependsOn: [
    vnet1
    vnet2
  ]
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
