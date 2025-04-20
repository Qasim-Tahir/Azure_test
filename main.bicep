param location string = resourceGroup().location
@secure()
param adminPassword string
param adminUsername string
param vmSize string = 'Standard_B2s'

var vnet1Id = vnetsModule.outputs.vnet1Id
var vnet1InfraSubnetId = vnetsModule.outputs.vnet1InfraSubnetId


module vnets './vnets.bicep' = {
  name: 'vnetDeployment'
  params: {
    location: location
    vnet1Name: 'vnet-east-001'
    vnet2Name: 'vnet-east-002'
    vnet1AddressPrefix: '10.1.0.0/16'
    vnet2AddressPrefix: '10.2.0.0/16'
    vnet1InfraSubnetPrefix: '10.1.0.0/24'
    vnet1StorageSubnetPrefix: '10.1.1.0/24'
    vnet2InfraSubnetPrefix: '10.2.0.0/24'
    vnet2StorageSubnetPrefix: '10.2.1.0/24'
  }
}

module peering './peering.bicep' = {
  name: 'vnetPeering'
  params: {
    vnet1Id: vnets.outputs.vnet1Id
    vnet2Id: vnets.outputs.vnet2Id
    vnet1Name: 'vnet-east-001'
    vnet2Name: 'vnet-east-002'
  }
}

module vm1 './vm.bicep' = {
  name: 'vm1Deployment'
  params: {
    location: location
    vmName: 'vm-east-001'
    subnetId: vnets.outputs.vnet1InfraSubnetId
    adminUsername: adminUsername
    adminPassword: adminPassword
    vmSize: vmSize
  }
}

module vm2 './vm.bicep' = {
  name: 'vm2Deployment'
  params: {
    location: location
    vmName: 'vm-east-002'
    subnetId: vnets.outputs.vnet2InfraSubnetId
    adminUsername: adminUsername
    adminPassword: adminPassword
    vmSize: vmSize
  }
}

module storage './storage.bicep' = {
  name: 'storageDeployment'
  params: {
    location: location
    storageAccount1Name: 'steast001'
    storageAccount2Name: 'steast002'
    vnet1StorageSubnetId: vnets.outputs.vnet1StorageSubnetId
    vnet2StorageSubnetId: vnets.outputs.vnet2StorageSubnetId
    logAnalyticsWorkspaceId: monitoring.outputs.logAnalyticsWorkspaceId
  }
}

module monitoring './monitoring.bicep' = {
  name: 'monitoringSetup'
  params: {
    location: location
    logWorkspaceName: 'log-workspace-east-001'
    vm1Name: 'vm-east-001'
    vm2Name: 'vm-east-002'
    storageAccount1Name: 'steast001'
    storageAccount2Name: 'steast002'
    logAnalyticsWorkspaceId: '' // will be updated dynamically
  }
}
