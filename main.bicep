@secure()
param adminPassword string


param location string = resourceGroup().location

// First VNET configuration
param vnet1Name string = 'vnet1'
param vnet1AddressPrefix string = '10.0.0.0/16'
param vnet1InfraSubnetPrefix string = '10.0.0.0/24'
param vnet1StorageSubnetPrefix string = '10.0.1.0/24'

// Second VNET configuration
param vnet2Name string = 'vnet2'
param vnet2AddressPrefix string = '10.1.0.0/16'
param vnet2InfraSubnetPrefix string = '10.1.0.0/24'
param vnet2StorageSubnetPrefix string = '10.1.1.0/24'

// Deploy first VNET by referencing your module
module vnet1 './modules/vnet.bicep' = {
  name: 'vnet1Deployment'  // This is the deployment operation name in Azure
  params: {
    vnetName: vnet1Name
    location: location
    vnetAddressPrefix: vnet1AddressPrefix
    infraSubnetPrefix: vnet1InfraSubnetPrefix
    storageSubnetPrefix: vnet1StorageSubnetPrefix
  }
}

// Deploy second VNET
module vnet2 './modules/vnet.bicep' = {
  name: 'vnet2Deployment'
  params: {
    vnetName: vnet2Name
    location: location
    vnetAddressPrefix: vnet2AddressPrefix
    infraSubnetPrefix: vnet2InfraSubnetPrefix
    storageSubnetPrefix: vnet2StorageSubnetPrefix
  }
}

// Create peering from vnet1 to vnet2
module vnet1Tovnet2Peering './modules/vnet-peering.bicep' = {
  name: 'vnet1Tovnet2Peering'
  params: {
    sourceVnetName: vnet1Name
    targetVnetId: vnet2.outputs.vnetId
    peeringName: 'peering-to-vnet2'
  }
  dependsOn: [
    vnet1
  ]
}

// Create peering from vnet2 to vnet1
module vnet2Tovnet1Peering './modules/vnet-peering.bicep' = {
  name: 'vnet2Tovnet1Peering'
  params: {
    sourceVnetName: vnet2Name
    targetVnetId: vnet1.outputs.vnetId
    peeringName: 'peering-to-vnet1'
  }
  dependsOn: [
    vnet2
  ]
}

module vm1 './modules/vm.bicep' = {
  name: 'vm1Deployment'
  params: {
    vmName: 'vm-vnet1'
    location: location
    subnetId: vnet1.outputs.infraSubnetId
    adminPassword: adminPassword
  }
}

// Deploy VM in second VNET
module vm2 './modules/vm.bicep' = {
  name: 'vm2Deployment'
  params: {
    vmName: 'vm-vnet2'
    location: location
    subnetId: vnet2.outputs.infraSubnetId
    adminPassword: adminPassword
  }
}

// Add storage account deployments with shorter names 
module storage1 './modules/storage.bicep' = {
  name: 'storage1Deployment'
  params: {
    storageAccountName: 'st${uniqueString(resourceGroup().id)}1'
    location: location
  }
}

module storage2 './modules/storage.bicep' = {
  name: 'storage2Deployment'
  params: {
    storageAccountName: 'st${uniqueString(resourceGroup().id)}2'
    location: location
  }
}

// Add after VM and storage modules
module monitor './modules/monitor.bicep' = {
  name: 'monitorDeployment'
  params: {
    location: location
  }
}
