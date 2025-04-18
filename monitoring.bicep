@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name for the Azure Monitor workspace')
param logWorkspaceName string

@description('VM1 Resource ID')
param vm1Id string

@description('VM2 Resource ID')
param vm2Id string

@description('Storage Account 1 Resource ID')
param storageAccount1Id string

@description('Storage Account 2 Resource ID')
param storageAccount2Id string

// Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: logWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

// VM1 Diagnostic Settings
resource vm1DiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: resourceId('Microsoft.Compute/virtualMachines', split(vm1Id, '/')[8])
  name: 'vm1-diagnostic-settings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// VM2 Diagnostic Settings
resource vm2DiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: resourceId('Microsoft.Compute/virtualMachines', split(vm2Id, '/')[8])
  name: 'vm2-diagnostic-settings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// Storage Account 1 Diagnostic Settings
resource storage1DiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: resourceId('Microsoft.Storage/storageAccounts', split(storageAccount1Id, '/')[8])
  name: 'storage1-diagnostic-settings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
  }
}

// Storage Account 2 Diagnostic Settings
resource storage2DiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: resourceId('Microsoft.Storage/storageAccounts', split(storageAccount2Id, '/')[8])
  name: 'storage2-diagnostic-settings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
  }
}

// Output the Log Analytics Workspace ID
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
