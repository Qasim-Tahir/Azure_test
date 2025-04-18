param resourceId string
param location string

resource diagnostic 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diagSettings'
  scope: resourceId
  properties: {
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
    logs: [
      {
        category: 'AuditLogs'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
    workspaceId: '/subscriptions/bf93058d-40eb-487b-85eb-6d66bd0ed4e1/resourceGroups/<rg>/providers/Microsoft.OperationalInsights/workspaces/<workspace-name>'
  }
}
