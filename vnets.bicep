@description('Location for all resources.')
param location string = resourceGroup().location

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

resource vnet1 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnet1Name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet1AddressPrefix
      ]
    }
    subnets: [
      {
        name: 'infra'
        properties: {
          addressPrefix: vnet1InfraSubnetPrefix
        }
      }
      {
        name: 'storage'
        properties: {
          addressPrefix: vnet1StorageSubnetPrefix
        }
      }
    ]
  }
}

resource vnet2 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnet2Name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet2AddressPrefix
      ]
    }
    subnets: [
      {
        name: 'infra'
        properties: {
          addressPrefix: vnet2InfraSubnetPrefix
        }
      }
      {
        name: 'storage'
        properties: {
          addressPrefix: vnet2StorageSubnetPrefix
        }
      }
    ]
  }
}

output vnet1Id string = vnet1.id
output vnet2Id string = vnet2.id
output vnet1InfraSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet1Name, 'infra')
output vnet1StorageSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet1Name, 'storage')
output vnet2InfraSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet2Name, 'infra')
output vnet2StorageSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet2Name, 'storage')
