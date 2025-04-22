param location string = resourceGroup().location
@secure()
param adminPassword string
param adminUsername string
param vmSize string = 'Standard_B2s'

@description('Name for the first VNET')
param vnet1Name string

@description('Name for the second VNET')
param vnet2Name string

@description('Address prefix for VNET 1')
param vnet1AddressPrefix string

@description('Address prefix for VNET 2')
param vnet2AddressPrefix string

@description('Infra subnet prefix for VNET 1')
param vnet1InfraSubnetPrefix string

@description('Storage subnet prefix for VNET 1')
param vnet1StorageSubnetPrefix string

@description('Infra subnet prefix for VNET 2')
param vnet2InfraSubnetPrefix string

@description('Storage subnet prefix for VNET 2')
param vnet2StorageSubnetPrefix string

@description('VM 1 Name')
param vm1Name string

@description('VM 2 Name')
param vm2Name string

@description('Storage Account 1 Name')
param storageAccount1Name string

@description('Storage Account 2 Name')
param storageAccount2Name string

@description('Log Analytics Workspace Name')
param logWorkspaceName string

// VNETS
module vnetsModule './vnets.bicep' = {
  name: 'vnetDeployment'
  params: {
    location:                  location
    vnet1Name:                 'vnet-east-001'
    vnet2Name:                 'vnet-east-002'
    vnet1AddressPrefix:        '10.1.0.0/16'
    vnet2AddressPrefix:        '10.2.0.0/16'
    vnet1InfraSubnetPrefix:    '10.1.0.0/24'
    vnet1StorageSubnetPrefix:  '10.1.1.0/24'
    vnet2InfraSubnetPrefix:    '10.2.0.0/24'
    vnet2StorageSubnetPrefix:  '10.2.1.0/24'
  }
}



// VNET PEERING
module peering './peering.bicep' = {
  name: 'vnetPeering'
  params: {
    vnet1Id: vnetsModule.outputs.vnet1Id
    vnet2Id: vnetsModule.outputs.vnet2Id
    vnet1Name: 'vnet-east-001'
    vnet2Name: 'vnet-east-002'
  }
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
    subnetId: vnetsModule.outputs.vnet1InfraSubnetId
    adminUsername: adminUsername
    vmSize: vmSize
  }
}

// VM 2
module vm2 './vm.bicep' = {
  name: 'vm2Deployment'
  params: {
    location: location
    vmName: 'vm-east-002'
    subnetId: vnetsModule.outputs.vnet2InfraSubnetId
    adminUsername: adminUsername
    adminPassword: adminPassword
    vmSize: vmSize
  }
}

// STORAGE
module storage './storage.bicep' = {
  name: 'storageDeployment'
  params: {
    location: location
    storageAccount1Name: 'steast001'
    storageAccount2Name: 'steast002'
    vnet1StorageSubnetId: vnetsModule.outputs.vnet1StorageSubnetId
    vnet2StorageSubnetId: vnetsModule.outputs.vnet2StorageSubnetId
    logAnalyticsWorkspaceId: monitoring.outputs.logAnalyticsWorkspaceId
  }
}
