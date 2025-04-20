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

@description('Username for the Virtual Machine')
param adminUsername string

@description('Password for the Virtual Machine')
@secure()
param adminPassword string

@description('Name for the first Virtual Machine')
param vm1Name string

@description('Name for the second Virtual Machine')
param vm2Name string

@description('Size of the VM')
param vmSize string = 'Standard_B2s'

@description('Name for the first storage account')
param storageAccount1Name string

@description('Name for the second storage account')
param storageAccount2Name string

@description('Name for the Azure Monitor workspace')
param logWorkspaceName string

// Deploy the Network Module
module networkModule 'vnets.bicep' = {
  name: 'networkDeployment'
  params: {
    location: location
    vnet1Name: vnet1Name
    vnet2Name: vnet2Name
    vnet1AddressPrefix: vnet1AddressPrefix
    vnet2AddressPrefix: vnet2AddressPrefix
    vnet1InfraSubnetPrefix: vnet1InfraSubnetPrefix
    vnet1StorageSubnetPrefix: vnet1StorageSubnetPrefix
    vnet2InfraSubnetPrefix: vnet2InfraSubnetPrefix
    vnet2StorageSubnetPrefix: vnet2StorageSubnetPrefix
  }
}

// Deploy the VM Module
module vmModule 'vm.bicep' = {
  name: 'vmDeployment'
  params: {
    location: location
    adminUsername: adminUsername
    adminPassword: adminPassword
    vm1Name: vm1Name
    vm2Name: vm2Name
    vmSize: vmSize
    vnet1InfraSubnetId: networkModule.outputs.vnet1InfraSubnetId
    vnet2InfraSubnetId: networkModule.outputs.vnet2InfraSubnetId
  }
  dependsOn: [
    networkModule
  ]
}

// Deploy the Storage Module
module storageModule './storage.bicep' = {
  name: 'storageDeployment'
  params: {
    location: location
    storageAccount1Name: storageAccount1Name
    storageAccount2Name: storageAccount2Name
    vnet1StorageSubnetId: networkModule.outputs.vnet1StorageSubnetId
    vnet2StorageSubnetId: networkModule.outputs.vnet2StorageSubnetId
  }
}

// Deploy the Monitoring Module
module monitoringModule 'monitoring.bicep' = {
  name: 'monitoringDeployment'
  params: {
    location: location
    logWorkspaceName: logWorkspaceName
    vm1Name: vm1Name
    vm2Name: vm2Name
    storageAccount1Name: storageAccount1Name
    storageAccount2Name: storageAccount2Name
  }
}

// Outputs
output logAnalyticsWorkspaceId string = monitoringModule.outputs.logAnalyticsWorkspaceId
