@description('Location for the VM resources')
param location string = resourceGroup().location

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

@description('VNET 1 Infra Subnet ID')
param vnet1InfraSubnetId string

@description('VNET 2 Infra Subnet ID')
param vnet2InfraSubnetId string

// VM1 Network Interface
resource nic1 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: '${vm1Name}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnet1InfraSubnetId
          }
        }
      }
    ]
  }
}

// VM2 Network Interface
resource nic2 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: '${vm2Name}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnet2InfraSubnetId
          }
        }
      }
    ]
  }
}

// VM1 in VNET1
resource vm1 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: vm1Name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vm1Name
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic1.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

// VM2 in VNET2
resource vm2 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: vm2Name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vm2Name
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic2.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

// Outputs
output vm1Id string = vm1.id
output vm2Id string = vm2.id
