param location string = resourceGroup().location
param vmName string
param subnetId string
param adminUsername string 
@secure()
param adminPassword string
param vmSize string = 'Standard_B1s'

resource publicIP 'Microsoft.Network/publicIPAddresses@2022-11-01' = {
  name: '${vmName}-pip'
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: { id: subnetId }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress:{id:publicIP.id}
        }
      }
    ]
  }
}
  resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
    name: vmName
    location: location
    properties: {
      hardwareProfile: {
        vmSize: vmSize
      }
      osProfile: {
        computerName: vmName
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
            id: nic.id
          }
        ]
      }
    }
  }


output vmId string = vm.id
output vmName string = vm.name
