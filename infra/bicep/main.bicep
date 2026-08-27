@description('Azure region for all showcase resources.')
param location string = resourceGroup().location
@description('Short, lowercase resource prefix.')
param namePrefix string = 'azkshowcase'
@description('AKS node count for the demonstration environment.')
param agentCount int = 2
@description('AKS node VM size. Review Azure pricing before deployment.')
param agentVmSize string = 'Standard_B2s'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${namePrefix}-logs'
  location: location
  properties: { retentionInDays: 30 }
}
resource registry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: '${namePrefix}acr'
  location: location
  sku: { name: 'Basic' }
  properties: { adminUserEnabled: false }
}
resource aks 'Microsoft.ContainerService/managedClusters@2024-09-01' = {
  name: '${namePrefix}-aks'
  location: location
  identity: { type: 'SystemAssigned' }
  properties: {
    dnsPrefix: '${namePrefix}-aks'
    agentPoolProfiles: [{
      name: 'system'
      count: agentCount
      vmSize: agentVmSize
      mode: 'System'
      osType: 'Linux'
      type: 'VirtualMachineScaleSets'
    }]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'azure'
      loadBalancerSku: 'standard'
      outboundType: 'loadBalancer'
    }
    oidcIssuerProfile: { enabled: true }
    securityProfile: { workloadIdentity: { enabled: true } }
  }
}
resource acrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(registry.id, aks.id, 'acrpull')
  scope: registry
  properties: {
    principalId: aks.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
  }
}
output aksName string = aks.name
output registryName string = registry.name
output logWorkspaceName string = logAnalytics.name
