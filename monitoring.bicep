@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name for the Azure Monitor workspace')
param logWorkspaceName string

@description('VM1 Name')
param vm1Name string

@description('VM2 Name')
param vm2Name string

@description('Storage Account 1 Name')
param storageAccount1Name string

@description('Storage Account 2 Name')
param storageAccount2Name string

@description('Log Analytics Workspace ID for diagnostics')
param logAnalyticsWorkspaceId string

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

// Reference the existing VMs and storage accounts
resource vm1 'Microsoft.Compute/virtualMachines@2021-11-01' existing = {
  name: vm1Name
}

resource vm2 'Microsoft.Compute/virtualMachines@2021-11-01' existing = {
  name: vm2Name
}

resource storageAccount1 'Microsoft.Storage/storageAccounts@2021-08-01' existing = {
  name: storageAccount1Name
}

resource storageAccount2 'Microsoft.Storage/storageAccounts@2021-08-01' existing = {
  name: storageAccount2Name
}

// VM1 Diagnostic Settings
resource vm1DiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: vm1
  name: 'vm1-diagnostic-settings'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
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
  scope: vm2
  name: 'vm2-diagnostic-settings'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
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
  scope: storageAccount1
  name: 'storage1-diagnostic-settings'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
    logs: [
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
  scope: storageAccount2
  name: 'storage2-diagnostic-settings'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
    logs: [
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
