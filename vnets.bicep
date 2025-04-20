param location string
param vnet1Name string
param vnet2Name string
param vnet1AddressPrefix string
param vnet2AddressPrefix string
param vnet1InfraSubnetPrefix string
param vnet1StorageSubnetPrefix string
param vnet2InfraSubnetPrefix string
param vnet2StorageSubnetPrefix string

resource vnet1 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnet1Name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [vnet1AddressPrefix]
    }
    subnets: [
      { name: 'infra'; properties: { addressPrefix: vnet1InfraSubnetPrefix } }
      { name: 'storage'; properties: { addressPrefix: vnet1StorageSubnetPrefix } }
    ]
  }
}

resource vnet2 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnet2Name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [vnet2AddressPrefix]
    }
    subnets: [
      { name: 'infra'; properties: { addressPrefix: vnet2InfraSubnetPrefix } }
      { name: 'storage'; properties: { addressPrefix: vnet2StorageSubnetPrefix } }
    ]
  }
}

output vnet1Id string = vnet1.id
output vnet2Id string = vnet2.id
output vnet1InfraSubnetId string = vnet1.properties.subnets[0].id
output vnet1StorageSubnetId string = vnet1.properties.subnets[1].id
output vnet2InfraSubnetId string = vnet2.properties.subnets[0].id
output vnet2StorageSubnetId string = vnet2.properties.subnets[1].id
