param location string = resourceGroup().location
param environmentName string = 'azure-kubernetes-showcase'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${environmentName}-logs'
  location: location
  properties: {
    retentionInDays: 30
  }
}

resource registry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: replace('${environmentName}acr', '-', '')
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
  }
}

output registryName string = registry.name
output logWorkspaceName string = logAnalytics.name
