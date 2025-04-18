@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name for the first storage account')
param storageAccount1Name string

@description('Name for the second storage account')
param storageAccount2Name string

@description('VNET 1 Storage Subnet ID')
param vnet1StorageSubnetId string

@description('VNET 2 Storage Subnet ID')
param vnet2StorageSubnetId string

// Storage Account in VNET1
resource storageAccount1 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccount1Name
  location: location
  sku: {
    name: 'Standard_ZRS' // Zone Redundant Storage
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          id: vnet1StorageSubnetId
          action: 'Allow'
        }
      ]
    }
  }
}

// Storage Account in VNET2
resource storageAccount2 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccount2Name
  location: location
  sku: {
    name: 'Standard_ZRS' // Zone Redundant Storage
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          id: vnet2StorageSubnetId
          action: 'Allow'
        }
      ]
    }
  }
}

// Outputs
output storageAccount1Id string = storageAccount1.id
output storageAccount2Id string = storageAccount2.id
