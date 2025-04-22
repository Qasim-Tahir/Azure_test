param location string = resourceGroup().location
@secure()
param adminPassword string
param adminUsername string
param vmSize string = 'Standard_B2s'

@description('Name for the first VNET')
param vnet1Name string ='vnet1'

@description('Name for the second VNET')
param vnet2Name string ='vnet2'

@description('Address prefix for VNET 1')
param vnet1AddressPrefix string ='10.0.0.0/16'

@description('Address prefix for VNET 2')
param vnet2AddressPrefix string ='10.1.0.0/16'

@description('Infra subnet prefix for VNET 1')
param vnet1InfraSubnetPrefix string = '10.0.0.0/24'

@description('Storage subnet prefix for VNET 1')
param vnet1StorageSubnetPrefix string = '10.0.1.0/24'

@description('Infra subnet prefix for VNET 2')
param vnet2InfraSubnetPrefix string ='10.1.0.0/24'

@description('Storage subnet prefix for VNET 2')
param vnet2StorageSubnetPrefix string = '10.1.1.0/24'

module vnet1 './vnets.bicep' = {
  name: 'vnet1Deployment'
  params: {
    vnetName: vnet1Name
    location: location
    vnetAddressPrefix: vnet1AddressPrefix
    infraSubnetPrefix: vnet1InfraSubnetPrefix
    storageSubnetPrefix: vnet1StorageSubnetPrefix
  }
}

// Deploy second VNET
module vnet2 './vnets.bicep' = {
  name: 'vnet2Deployment'
  params: {
    vnetName: vnet2Name
    location: location
    vnetAddressPrefix: vnet2AddressPrefix
    infraSubnetPrefix: vnet2InfraSubnetPrefix
    storageSubnetPrefix: vnet2StorageSubnetPrefix
  }
}





// VNET PEERING
module peering './peering.bicep' = {
  name: 'VnetPeering'
  params: {
    sourceVnetName: vnet1Name
    targetVnetId: vnet2.outputs.vnet2Id
    peeringName: 'peering-to-vnet2'
  }
  dependsOn: [
    vnet1
  ]
}

// MONITORING (first, so we can use its output later)
module monitoring './monitoring.bicep' = {
  name: 'monitoringSetup'
  params: {
    location: location
  }
}

// VM 1
module vm1 './vm.bicep' = {
  name: 'vm1Deployment'
  params: {
    location: location
    vmName: 'vm-east-001'
    subnetId: vnet1.outputs.vnet1InfraSubnetId
    adminUsername: adminUsername
    adminPassword: adminPassword
    vmSize: vmSize
  }
}

// VM 2
module vm2 './vm.bicep' = {
  name: 'vm2Deployment'
  params: {
    location: location
    vmName: 'vm-east-002'
    subnetId: vnet2.outputs.vnet2InfraSubnetId
    adminUsername: adminUsername
    adminPassword: adminPassword
    vmSize: vmSize
  }
}

module storage1 './storage.bicep' = {
  name: 'storage1Deployment'
  params: {
    storageAccountName: 'st${uniqueString(resourceGroup().id)}1'
    location: location
  }
}

module storage2 './storage.bicep' = {
  name: 'storage2Deployment'
  params: {
    storageAccountName: 'st${uniqueString(resourceGroup().id)}2'
    location: location
  }
}


